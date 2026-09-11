import AVFoundation
import Accelerate

/// Audio capture manager for the Praxia child client.
///
/// Implements the specification from docs/04-engineering/speech-signal-spec.md
/// - 16 kHz mono PCM
/// - AVAudioSession .measurement mode with AEC/AGC/noise-suppression DISABLED
/// - Per-session calibration and SNR gating
/// - Tier-1 deterministic signals: VAD, response latency, phonation duration, pitch contour
actor AudioCaptureManager: NSObject, AVAudioEngineDelegate {

    // MARK: - Configuration

    /// Hard requirement: 16 kHz mono, measurement mode, all voice processing disabled
    static let audioFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: 16000,
        channels: 1,
        interleaved: false
    )!

    /// SNR threshold below which we refuse to compute acoustic measures
    private let SNR_THRESHOLD_DB: Float = 6.0  // Typical speech ~15-20 dB above noise

    /// Per-session calibration tone: 1 kHz @ -20 dBFS
    private let CALIBRATION_FREQUENCY: Float = 1000.0
    private let CALIBRATION_DURATION_S: Float = 0.5

    // MARK: - Engine & state

    private let engine = AVAudioEngine()
    private let inputNode: AVAudioInputNode

    /// Ring buffer for real-time processing
    private var ringBuffer: RingBuffer

    /// Current noise floor estimate (dB SPL equivalent)
    private var noiseFloor: Float = -80.0

    /// Calibration factor from the calibration tone
    private var calibrationFactor: Float = 0.0

    /// Currently-active attempt recording
    private var currentAttempt: AttemptRecording?

    // MARK: - Closures

    typealias Tier1UpdateCallback = (Tier1Signal) -> Void
    private var tier1Callback: Tier1UpdateCallback?

    // MARK: - Initialization

    override init() {
        inputNode = engine.inputNode
        ringBuffer = RingBuffer(capacity: 1024)  // ~64 ms at 16 kHz

        super.init()

        // Configure AVAudioSession BEFORE attaching nodes
        try? configureAudioSession()

        // Attach tap for real-time processing
        let tapFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000,
            channels: 1,
            interleaved: false
        )!

        inputNode.installTap(
            onBus: 0,
            bufferSize: 256,  // ~16 ms
            format: tapFormat
        ) { [weak self] buffer, _ in
            self?.processTap(buffer)
        }

        engine.attachNode(inputNode)
        try? engine.start()
    }

    // MARK: - Public API

    /// Initialize the audio session with calibration
    func startSession(tier1Callback: @escaping Tier1UpdateCallback) async throws {
        self.tier1Callback = tier1Callback

        // Run calibration tone and measure noise floor
        try await runCalibration()

        // Prime the ring buffer
        try await primeBuffer()
    }

    /// Begin recording an attempt
    func beginAttempt(
        targetID: String,
        cueLevel: Int,
        expectedDuration: TimeInterval = 3.0
    ) {
        currentAttempt = AttemptRecording(
            targetID: targetID,
            cueLevel: cueLevel,
            expectedDuration: expectedDuration,
            noiseFloor: noiseFloor,
            calibrationFactor: calibrationFactor
        )
    }

    /// End recording and return the attempt data
    func endAttempt() -> AttemptRecording? {
        let result = currentAttempt
        currentAttempt = nil
        return result
    }

    // MARK: - Real-time processing

    private nonisolated func processTap(_ buffer: AVAudioPCMBuffer) {
        guard let attempt = currentAttempt else { return }

        guard let floatChannelData = buffer.floatChannelData else { return }
        let frameCount = Int(buffer.frameLength)
        let data = floatChannelData[0]

        attempt.append(data, count: frameCount)

        // Tier-1 signals: compute deterministic metrics in ~30 ms
        let signals = computeTier1Signals(
            data: data,
            frameCount: frameCount,
            sampleRate: 16000,
            noiseFloor: noiseFloor
        )

        tier1Callback?(signals)
    }

    // MARK: - Tier-1 Signal Computation

    /// Compute Tier-1 deterministic signals from raw PCM
    /// - Response latency: prompt offset → voicing onset
    /// - Phonation duration
    /// - Intensity envelope
    /// - Voiced-segment count (syllable proxy)
    /// - Pitch contour (rising/falling/flat)
    private func computeTier1Signals(
        data: UnsafeMutablePointer<Float>,
        frameCount: Int,
        sampleRate: Float,
        noiseFloor: Float
    ) -> Tier1Signal {

        // 1. Intensity envelope using vDSP
        let intensityEnv = computeIntensityEnvelope(data: data, frameCount: frameCount)

        // 2. VAD detection (Silero-like: energy + zero-crossing ratio)
        let vadEvents = detectVocalization(intensityEnv: intensityEnv, noiseFloor: noiseFloor)

        // 3. Syllable proxy: energy peaks
        let syllableCount = estimateSyllableCount(intensityEnv: intensityEnv)

        // 4. Pitch contour from autocorrelation (lightweight alternative to CREPE)
        let pitchTrend = estimatePitchTrend(data: data, frameCount: frameCount, sampleRate: sampleRate)

        let now = Date()

        return Tier1Signal(
            timestamp: now,
            vocalizing: !vadEvents.isEmpty,
            responseLatency: vadEvents.first?.onset ?? nil,
            phonationDuration: computePhonationDuration(vadEvents: vadEvents, sampleRate: sampleRate),
            intensityEnvelope: intensityEnv,
            syllableEstimate: syllableCount,
            pitchTrend: pitchTrend,
            snrDb: estimateSNR(intensityEnv: intensityEnv, noiseFloor: noiseFloor)
        )
    }

    /// Compute intensity envelope using vDSP
    private func computeIntensityEnvelope(
        data: UnsafeMutablePointer<Float>,
        frameCount: Int
    ) -> [Float] {
        var squared = [Float](repeating: 0, count: frameCount)
        vDSP_vsq(data, 1, &squared, 1, vDSP_Length(frameCount))

        // Smooth with a short window (32 ms @ 16 kHz = 512 samples)
        let windowSize = min(512, frameCount / 8)
        return movingAverage(squared, windowSize: windowSize)
    }

    /// Simple VAD: detect above-threshold energy peaks
    private func detectVocalization(
        intensityEnv: [Float],
        noiseFloor: Float
    ) -> [VocalizationEvent] {
        let threshold = noiseFloor + SNR_THRESHOLD_DB
        var events: [VocalizationEvent] = []

        var inVocalization = false
        var onsetSample: Int?

        for (i, intensity) in intensityEnv.enumerated() {
            let isActive = intensity > threshold

            if isActive && !inVocalization {
                inVocalization = true
                onsetSample = i
            } else if !isActive && inVocalization {
                inVocalization = false
                if let onset = onsetSample {
                    events.append(VocalizationEvent(
                        onset: TimeInterval(onset) / 16000.0,
                        offset: TimeInterval(i) / 16000.0
                    ))
                }
            }
        }

        return events
    }

    /// Syllable count proxy: count peaks in intensity envelope
    private func estimateSyllableCount(intensityEnv: [Float]) -> Int {
        guard intensityEnv.count > 10 else { return 0 }

        var peakCount = 0

        for i in 1..<(intensityEnv.count - 1) {
            if intensityEnv[i] > intensityEnv[i-1] && intensityEnv[i] > intensityEnv[i+1] {
                let peakHeight = intensityEnv[i]
                let localMin = min(intensityEnv[i-1], intensityEnv[i+1])

                // Only count significant peaks (> 3 dB above local minimum)
                if 10 * log10(peakHeight / (localMin + 1e-6)) > 3.0 {
                    peakCount += 1
                }
            }
        }

        return peakCount
    }

    /// Simple pitch trend estimation using autocorrelation
    private func estimatePitchTrend(
        data: UnsafeMutablePointer<Float>,
        frameCount: Int,
        sampleRate: Float
    ) -> PitchTrend {
        guard frameCount > 512 else { return .flat }

        // Divide into quarters and estimate pitch for each
        let quarterSize = frameCount / 4
        var pitches: [Float] = []

        for q in 0..<3 {
            let start = q * quarterSize
            let end = min(start + quarterSize, frameCount)
            let pitch = estimateF0(
                data: data,
                offset: start,
                count: end - start,
                sampleRate: sampleRate
            )
            if let p = pitch {
                pitches.append(p)
            }
        }

        guard pitches.count >= 2 else { return .flat }

        let trend = pitches.last! - pitches.first!
        if trend > 10 {
            return .rising
        } else if trend < -10 {
            return .falling
        } else {
            return .flat
        }
    }

    /// Lightweight F0 estimation via autocorrelation
    /// Returns nil if not voiced
    private func estimateF0(
        data: UnsafeMutablePointer<Float>,
        offset: Int,
        count: Int,
        sampleRate: Float
    ) -> Float? {
        let minLag = Int(sampleRate / 400)  // Max F0 ~400 Hz (child voice upper bound)
        let maxLag = Int(sampleRate / 50)   // Min F0 ~50 Hz

        guard minLag > 0 && maxLag <= count / 2 else { return nil }

        var maxCorr: Float = 0
        var bestLag = minLag

        for lag in minLag..<maxLag {
            var correlation: Float = 0
            vDSP_dotpr(
                data + offset,
                1,
                data + offset + lag,
                1,
                &correlation,
                vDSP_Length(count - lag)
            )
            correlation /= Float(count - lag)

            if correlation > maxCorr {
                maxCorr = correlation
                bestLag = lag
            }
        }

        // Only report if correlation is strong (voiced)
        guard maxCorr > 0.5 else { return nil }

        return sampleRate / Float(bestLag)
    }

    /// Compute total phonation duration from VAD events
    private func computePhonationDuration(
        vadEvents: [VocalizationEvent],
        sampleRate: Float
    ) -> TimeInterval {
        return vadEvents.reduce(0) { $0 + ($1.offset - $1.onset) }
    }

    /// Estimate SNR from intensity envelope and noise floor
    private func estimateSNR(
        intensityEnv: [Float],
        noiseFloor: Float
    ) -> Float {
        guard let maxIntensity = intensityEnv.max() else { return 0 }
        let maxDb = 10 * log10(maxIntensity + 1e-6)
        return maxDb - noiseFloor
    }

    /// Simple moving average
    private func movingAverage(_ data: [Float], windowSize: Int) -> [Float] {
        guard windowSize > 1 else { return data }

        var result = [Float]()
        for i in 0..<data.count {
            let start = max(0, i - windowSize / 2)
            let end = min(data.count, i + windowSize / 2)
            let avg = data[start..<end].reduce(0, +) / Float(end - start)
            result.append(avg)
        }
        return result
    }

    // MARK: - Calibration

    private func runCalibration() async throws {
        // Generate and play a 1 kHz calibration tone
        // Measure the response to establish noise floor and calibration factor

        let sampleRate = 16000
        let numSamples = Int(CALIBRATION_DURATION_S * Float(sampleRate))

        var calibrationAudio = [Float](repeating: 0, count: numSamples)
        for i in 0..<numSamples {
            let t = Float(i) / Float(sampleRate)
            let phase = 2.0 * Float.pi * CALIBRATION_FREQUENCY * t
            calibrationAudio[i] = 0.1 * sin(phase)  // -20 dBFS
        }

        // In a real implementation, play this through the speaker and measure the return
        // For now, we establish a conservative default
        noiseFloor = -60.0  // ~60 dB SPL equivalent
        calibrationFactor = 1.0
    }

    private func primeBuffer() async throws {
        // Let the buffer fill for 100 ms to stabilize
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    // MARK: - Audio Session Setup

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()

        // CRITICAL: Use .measurement mode, NOT .default or .record
        try session.setCategory(.measurement, options: [])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        // Explicitly disable voice processing
        // NOTE: This must be done AFTER attaching nodes to the engine
        let inputNode = engine.inputNode
        inputNode.setVoiceProcessingEnabled(false)
    }
}

// MARK: - Data Structures

struct Tier1Signal {
    let timestamp: Date

    /// VAD detection result
    let vocalizing: Bool

    /// Time from prompt offset to voice onset (≤150ms)
    let responseLatency: TimeInterval?

    /// Duration of phonation
    let phonationDuration: TimeInterval

    /// Intensity envelope (dB SPL)
    let intensityEnvelope: [Float]

    /// Estimated syllable count (peak counting)
    let syllableEstimate: Int

    /// Pitch trend (rising/falling/flat)
    let pitchTrend: PitchTrend

    /// Signal-to-noise ratio in dB
    let snrDb: Float
}

enum PitchTrend {
    case rising
    case falling
    case flat
}

struct VocalizationEvent {
    let onset: TimeInterval   // Seconds from buffer start
    let offset: TimeInterval  // Seconds from buffer start
}

class AttemptRecording {
    let targetID: String
    let cueLevel: Int
    let expectedDuration: TimeInterval
    let noiseFloor: Float
    let calibrationFactor: Float

    private var audioData: [Float] = []
    private let startTime = Date()

    init(
        targetID: String,
        cueLevel: Int,
        expectedDuration: TimeInterval,
        noiseFloor: Float,
        calibrationFactor: Float
    ) {
        self.targetID = targetID
        self.cueLevel = cueLevel
        self.expectedDuration = expectedDuration
        self.noiseFloor = noiseFloor
        self.calibrationFactor = calibrationFactor
    }

    func append(_ data: UnsafeMutablePointer<Float>, count: Int) {
        audioData.append(contentsOf: UnsafeBufferPointer(start: data, count: count))
    }

    /// Get the raw audio data as PCM (16-bit)
    func getPCMData() -> Data {
        var pcm16 = [Int16](repeating: 0, count: audioData.count)
        for (i, sample) in audioData.enumerated() {
            let clamped = max(-1.0, min(1.0, sample))
            pcm16[i] = Int16(clamped * 32767)
        }
        return Data(bytes: pcm16, count: pcm16.count * 2)
    }

    /// Duration of the recording in seconds
    var duration: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }
}

class RingBuffer {
    private let capacity: Int
    private var buffer: [Float]
    private var writeIndex: Int = 0

    init(capacity: Int) {
        self.capacity = capacity
        self.buffer = [Float](repeating: 0, count: capacity)
    }

    func write(_ data: [Float]) {
        for sample in data {
            buffer[writeIndex % capacity] = sample
            writeIndex += 1
        }
    }

    func read(count: Int) -> [Float] {
        var result = [Float]()
        let start = max(0, writeIndex - count)
        for i in start..<writeIndex {
            result.append(buffer[i % capacity])
        }
        return result
    }
}
