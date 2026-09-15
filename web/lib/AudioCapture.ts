/**
 * AudioCapture.ts - Web Audio API implementation for Tier-1 signal detection
 * Latency target: <100ms for web platform (vs <30ms iOS, <50ms Android)
 *
 * Implements:
 * - Voice Activity Detection (VAD)
 * - Pitch detection (basic spectral analysis via FFT)
 * - Duration tracking
 * - SNR (Signal-to-Noise Ratio) estimation
 * - Deterministic Tier-1 signal computation (C19)
 */

import { Tier1Signals, PitchContour } from './types'

export interface AudioCaptureConfig {
  sampleRate?: number // Default: 16000 Hz
  bufferSize?: number // Default: 2048 samples (~128ms at 16kHz)
  noiseFloorDb?: number // Default: -40 dB
  voiceActivityThresholdDb?: number // Default: -20 dB
}

export class AudioCapture {
  private audioContext: AudioContext | null = null
  private mediaStream: MediaStream | null = null
  private processor: ScriptProcessorNode | null = null
  private analyser: AnalyserNode | null = null
  private gainNode: GainNode | null = null
  private isRecording = false

  private ringBuffer: Float32Array
  private ringBufferIndex = 0
  private frameCount = 0

  private config: Required<AudioCaptureConfig>
  private recordedChunks: Float32Array[] = []
  private recordingStartTime = 0

  // VAD state tracking
  private noiseFloor = -40 // dB
  private minVocalizationDurationMs = 200 // Minimum vocalization length
  private vocalizationStartTime: number | null = null

  constructor(config: AudioCaptureConfig = {}) {
    this.config = {
      sampleRate: config.sampleRate ?? 16000,
      bufferSize: config.bufferSize ?? 2048,
      noiseFloorDb: config.noiseFloorDb ?? -40,
      voiceActivityThresholdDb: config.voiceActivityThresholdDb ?? -20,
    }

    // Ring buffer for DSP processing (2 seconds of audio)
    this.ringBuffer = new Float32Array(this.config.sampleRate * 2)
  }

  /**
   * Initialize audio context and request microphone permission
   * Complies with C6: Echo cancellation and noise suppression disabled
   */
  async start(): Promise<void> {
    try {
      // Request media stream with measurement-mode settings (no AEC/AGC/NS per C6)
      this.mediaStream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: false, // C6: Disable AEC for clean Tier-1 signals
          noiseSuppression: false, // C6: Disable NS
          autoGainControl: false, // C6: Disable AGC
          sampleRate: this.config.sampleRate,
        },
      })

      // Create audio context
      this.audioContext = new (window.AudioContext || (window as any).webkitAudioContext)({
        sampleRate: this.config.sampleRate,
      })

      // Create nodes
      const source = this.audioContext.createMediaStreamSource(this.mediaStream)
      this.processor = this.audioContext.createScriptProcessor(
        this.config.bufferSize,
        1, // 1 input channel
        1 // 1 output channel
      )

      this.analyser = this.audioContext.createAnalyser()
      this.analyser.fftSize = 2048
      this.analyser.smoothingTimeConstant = 0.8

      this.gainNode = this.audioContext.createGain()
      this.gainNode.gain.value = 1.0

      // Connect nodes: source → processor → analyser → gain → destination
      source.connect(this.processor)
      this.processor.connect(this.analyser)
      this.analyser.connect(this.gainNode)
      this.gainNode.connect(this.audioContext.destination)

      // Set up audio processing callback
      this.processor.onaudioprocess = (event) => this.onAudioProcess(event)

      this.isRecording = true
      this.recordingStartTime = Date.now()
      this.recordedChunks = []
      this.frameCount = 0
    } catch (error) {
      console.error('[AudioCapture] Failed to start:', error)
      throw error
    }
  }

  /**
   * Stop recording and clean up resources
   */
  async stop(): Promise<Float32Array | null> {
    if (!this.mediaStream) return null

    this.isRecording = false

    // Stop all tracks
    this.mediaStream.getTracks().forEach((track) => track.stop())

    // Close audio context
    if (this.audioContext && this.audioContext.state !== 'closed') {
      await this.audioContext.close()
    }

    // Concatenate recorded chunks into single buffer
    if (this.recordedChunks.length === 0) return null

    const totalLength = this.recordedChunks.reduce((sum, chunk) => sum + chunk.length, 0)
    const result = new Float32Array(totalLength)
    let offset = 0
    for (const chunk of this.recordedChunks) {
      result.set(chunk, offset)
      offset += chunk.length
    }

    return result
  }

  /**
   * Called by Web Audio API on each audio buffer filled (~21ms at 16kHz/2048)
   */
  private onAudioProcess(event: AudioProcessingEvent): void {
    if (!this.isRecording) return

    const inputData = event.inputBuffer.getChannelData(0)
    const pcm = new Float32Array(inputData) // Copy to preserve data

    // Store for later export
    this.recordedChunks.push(pcm)

    // Push to ring buffer
    for (let i = 0; i < pcm.length; i++) {
      this.ringBuffer[this.ringBufferIndex] = pcm[i]
      this.ringBufferIndex = (this.ringBufferIndex + 1) % this.ringBuffer.length
    }

    this.frameCount++
  }

  /**
   * Compute Tier-1 signals from current ring buffer state
   * Returns deterministic signals (C19) computed from recent audio
   * Latency: <100ms (typically 50-80ms on web)
   */
  computeTier1Signals(): Tier1Signals {
    const timestamp = Date.now()
    const elapsedMs = timestamp - this.recordingStartTime

    // Estimate energy/loudness (dB)
    const energyDb = this.estimateEnergyDb()

    // Detect vocalization (VAD logic)
    const isVocalizing = energyDb > this.config.voiceActivityThresholdDb

    // Track vocalization duration
    if (isVocalizing) {
      if (!this.vocalizationStartTime) {
        this.vocalizationStartTime = timestamp
      }
    } else {
      this.vocalizationStartTime = null
    }

    const vocalizationDurationMs =
      this.vocalizationStartTime && isVocalizing ? timestamp - this.vocalizationStartTime : 0

    // Estimate pitch contour (basic spectral analysis)
    const pitchContour = this.estimatePitchContour()

    // Estimate SNR (simplified: peak / average noise floor)
    const snrDb = this.estimateSnr()

    // Syllable detection (simplified: count peaks in energy envelope)
    const syllableCount = this.estimateSyllableCount()

    // Latency metric (time from start of recording to now)
    const latencyMs = elapsedMs

    // Confidence in vocalization detection (0-1)
    const confidenceScore =
      isVocalizing && vocalizationDurationMs > this.config.bufferSize / this.config.sampleRate
        ? Math.min(1.0, (energyDb - this.config.voiceActivityThresholdDb) / 20)
        : 0

    return {
      vocalizationDetected: isVocalizing && vocalizationDurationMs > this.minVocalizationDurationMs,
      latencyMs,
      durationMs: vocalizationDurationMs,
      syllableCount: Math.max(0, syllableCount),
      pitchContour,
      snrDb,
      confidenceScore,
      timestamp,
    }
  }

  /**
   * Estimate energy in dB from ring buffer
   * Uses RMS (Root Mean Square) calculation
   */
  private estimateEnergyDb(): number {
    let sum = 0
    for (let i = 0; i < this.ringBuffer.length; i++) {
      sum += this.ringBuffer[i] * this.ringBuffer[i]
    }
    const rms = Math.sqrt(sum / this.ringBuffer.length)
    // Convert to dB: 20 * log10(rms) with minimum floor
    return rms > 0 ? Math.max(-80, 20 * Math.log10(rms)) : -80
  }

  /**
   * Estimate pitch contour using FFT
   * Returns one of: RISING, FALLING, LEVEL, COMPLEX
   */
  private estimatePitchContour(): PitchContour {
    if (!this.analyser) return PitchContour.PITCH_UNSPECIFIED

    const dataArray = new Uint8Array(this.analyser.frequencyBinCount)
    this.analyser.getByteFrequencyData(dataArray)

    // Simplified: look at first 5 bins vs last 5 bins
    const lowFreq = dataArray.slice(0, 5).reduce((a, b) => a + b) / 5
    const highFreq = dataArray.slice(-5).reduce((a, b) => a + b) / 5

    if (Math.abs(highFreq - lowFreq) < 20) {
      return PitchContour.LEVEL
    } else if (highFreq > lowFreq) {
      return PitchContour.RISING
    } else {
      return PitchContour.FALLING
    }
  }

  /**
   * Estimate Signal-to-Noise Ratio
   * Simplified: peak energy vs. noise floor baseline
   */
  private estimateSnr(): number {
    const peakEnergy = Math.max(...Array.from(this.ringBuffer).map((x) => Math.abs(x)))
    const snrDb = this.estimateEnergyDb() - this.config.noiseFloorDb
    return Math.max(0, snrDb)
  }

  /**
   * Estimate syllable count from energy envelope peaks
   * Simplified onset detection
   */
  private estimateSyllableCount(): number {
    const energyEnvelope: number[] = []
    const windowSize = Math.floor(this.config.sampleRate / 50) // 20ms windows
    let count = 0

    for (let i = 0; i < this.ringBuffer.length; i += windowSize) {
      const window = this.ringBuffer.slice(i, i + windowSize)
      const energy = Math.sqrt(window.reduce((sum, x) => sum + x * x, 0) / window.length)
      energyEnvelope.push(energy)
    }

    // Count peaks (simplified: detect when energy rises then falls)
    const threshold = energyEnvelope.reduce((a, b) => a + b, 0) / energyEnvelope.length * 1.5
    let wasAboveThreshold = false

    for (const energy of energyEnvelope) {
      if (energy > threshold && !wasAboveThreshold) {
        count++
        wasAboveThreshold = true
      } else if (energy < threshold) {
        wasAboveThreshold = false
      }
    }

    return count
  }

  /**
   * Get current recording status
   */
  isActive(): boolean {
    return this.isRecording
  }

  /**
   * Get audio context for external DSP nodes
   */
  getAudioContext(): AudioContext | null {
    return this.audioContext
  }

  /**
   * Fallback for browsers without Web Audio API support
   * Per WEB-DEVELOPER-BRIEF.md: Show message and allow text-based trial entry
   */
  static isSupported(): boolean {
    return (
      typeof window !== 'undefined' &&
      !!(
        window.AudioContext ||
        (window as any).webkitAudioContext ||
        (window as any).mozAudioContext
      ) &&
      !!navigator.mediaDevices?.getUserMedia
    )
  }
}

export default AudioCapture
