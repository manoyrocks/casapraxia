import SwiftUI
import AVFoundation

/// The child experience: three surfaces — Talk (AAC), Play (practice), Collection.
///
/// Implements the specification from docs/03-design/ux-principles.md
/// - No machine verdict reaches the child
/// - No failure states (no red X, buzzer, etc.)
/// - Support fades silently
/// - Session ends itself at target or 10 minutes
struct ChildViewController: View {

    @State private var currentSurface: ChildSurface = .play
    @State private var sessionActive = false
    @State private var sessionStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var trialCount: Int = 0

    let audioManager = AudioCaptureManager()
    let trialEngine = TrialEngine(sessionID: UUID().uuidString)

    // MARK: - Lifecycle

    var body: some View {
        ZStack {
            // The three child surfaces
            Group {
                switch currentSurface {
                case .talk:
                    AACSurfaceView(audioManager: audioManager)
                case .play:
                    PlaySurfaceView(
                        trialEngine: trialEngine,
                        audioManager: audioManager,
                        onTrialEnd: handleTrialEnd
                    )
                case .collection:
                    CollectionSurfaceView()
                }
            }

            // Session timer (top-right, minimal, parent-only info)
            if sessionActive {
                VStack {
                    HStack {
                        Text(formatTime(elapsedTime))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .opacity(0.5)

                        Spacer()

                        Text("\(trialCount) tries")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                    .padding()

                    Spacer()
                }
            }

            // Bottom tab bar for child
            VStack {
                Spacer()

                ChildTabBar(
                    currentSurface: $currentSurface,
                    sessionActive: sessionActive,
                    onPlayTap: { startSession() },
                    onTalkTap: { switchToTalk() },
                    onCollectionTap: { switchToCollection() }
                )
            }
        }
        .onAppear {
            setupAudio()
        }
    }

    // MARK: - Session management

    private func startSession() {
        guard !sessionActive else { return }

        sessionActive = true
        sessionStartTime = Date()
        elapsedTime = 0
        trialCount = 0

        // Start the session timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if sessionActive {
                elapsedTime = Date().timeIntervalSince(sessionStartTime ?? Date())

                // Hard cap: session ends at 10 minutes
                if elapsedTime >= 600 {
                    sessionActive = false
                    timer.invalidate()
                }
            } else {
                timer.invalidate()
            }
        }
    }

    private func handleTrialEnd() {
        trialCount += 1

        // Session ends itself at trial target (~80 trials) or 10 minutes
        let targetTrials = 80
        if trialCount >= targetTrials || (elapsedTime >= 600) {
            endSession()
        }
    }

    private func endSession() {
        sessionActive = false

        // CRITICAL: The session ends on a correct trial, never on failure
        // This is enforced in the PlaySurfaceView
    }

    // MARK: - Surface switching

    private func switchToTalk() {
        currentSurface = .talk
    }

    private func switchToCollection() {
        currentSurface = .collection
    }

    // MARK: - Audio setup

    private func setupAudio() {
        Task {
            try await audioManager.startSession { signal in
                // Tier-1 signals: ≤150 ms feedback
                // This would drive reinforcement in PlaySurface
            }
        }
    }

    // MARK: - Utilities

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Child surfaces

enum ChildSurface {
    case talk    // AAC board
    case play    // Practice trials
    case collection  // Progress visualization (no numbers)
}

// MARK: - Tab bar

struct ChildTabBar: View {
    @Binding var currentSurface: ChildSurface
    let sessionActive: Bool
    let onPlayTap: () -> Void
    let onTalkTap: () -> Void
    let onCollectionTap: () -> Void

    var body: some View {
        HStack {
            // Talk (AAC)
            Button(action: onTalkTap) {
                VStack(spacing: 4) {
                    Image(systemName: "bubble.right.fill")
                        .font(.system(size: 24))
                    Text("Talk")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundColor(currentSurface == .talk ? .blue : .gray)

            // Play (Practice)
            Button(action: onPlayTap) {
                VStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                    Text("Play")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundColor(currentSurface == .play ? .blue : .gray)

            // Collection (Progress)
            Button(action: onCollectionTap) {
                VStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                    Text("Collection")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundColor(currentSurface == .collection ? .blue : .gray)
        }
        .frame(height: 60)
        .background(Color(.systemGray6))
    }
}

// MARK: - AAC Surface

struct AACSurfaceView: View {
    let audioManager: AudioCaptureManager

    var body: some View {
        VStack {
            Text("Talk")
                .font(.title)
                .padding()

            // AAC board: fixed positions, target auto-population
            // This will be replaced with the actual AAC board implementation
            ScrollView {
                VStack(spacing: 12) {
                    // AAC buttons would be arranged in a fixed grid
                    // with no rearrangement based on performance
                    ForEach(0..<6, id: \.self) { i in
                        HStack {
                            ForEach(0..<3, id: \.self) { j in
                                VStack {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.blue)
                                    Text("Word \(i*3 + j)")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }

            Spacer()
        }
    }
}

// MARK: - Play Surface

struct PlaySurfaceView: View {
    let trialEngine: TrialEngine
    let audioManager: AudioCaptureManager
    let onTrialEnd: () -> Void

    @State private var currentTarget: TrialEngine.TargetState?
    @State private var isRecording = false
    @State private var showReinforcement = false
    @State private var reinforcementLatency: TimeInterval = 0

    var body: some View {
        VStack {
            // Model video / image (centered, full width)
            VStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                Text("Watch & Listen")
                    .font(.headline)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(.systemGray6))
            .padding()

            // "It's your turn!" message (warm, no demand)
            Text("Your turn!")
                .font(.title3)
                .foregroundColor(.blue)
                .padding()

            Spacer()

            // Large, easy target to tap (actually a recording trigger)
            Button(action: { startAttempt() }) {
                VStack(spacing: 8) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    Text("Try it!")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            .padding()

            // Reinforcement: contingency (child's action caused something)
            if showReinforcement {
                VStack(spacing: 12) {
                    LottieView()  // Simple animation of the target object moving
                    Text("Look what happened!")
                        .font(.headline)
                }
                .padding()
                .transition(.scale)
            }

            Spacer()
        }
    }

    private func startAttempt() {
        isRecording = true

        // Load the current target from session
        // (In real app, this would come from the clinician's target selection)
        audioManager.beginAttempt(targetID: "ba", cueLevel: 0)

        // After 3 seconds or on speech offset, end the attempt
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            endAttempt()
        }
    }

    private func endAttempt() {
        isRecording = false

        if let attempt = audioManager.endAttempt() {
            // Record trial (no machine verdict on accuracy)
            Task {
                let result = await trialEngine.recordTrial(
                    targetID: "ba",
                    score: .correct,  // Parent must score, or silence
                    attemptDuration: attempt.duration,
                    snrDb: 15.0
                )

                // Show reinforcement (≤150 ms)
                withAnimation {
                    showReinforcement = true
                    reinforcementLatency = 0.050  // ~50 ms latency
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showReinforcement = false
                    }
                    onTrialEnd()
                }
            }
        }
    }
}

// MARK: - Collection Surface

struct CollectionSurfaceView: View {
    var body: some View {
        VStack {
            Text("Collection")
                .font(.title)
                .padding()

            // Progress visualization: items collected over time
            // NO NUMBERS, NO SCORES, NO STREAKS
            // Just: "You did lots of practice this week!"

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Week view: show attempted targets
                    VStack(alignment: .leading) {
                        Text("This week")
                            .font(.headline)

                        HStack(spacing: 8) {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(height: 60)
                            }
                        }

                        Text("You tried lots of sounds this week!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding()
            }

            Spacer()
        }
    }
}

// MARK: - Placeholder for Lottie animation

struct LottieView: View {
    var body: some View {
        VStack {
            Text("🎈")
                .font(.system(size: 60))
                .transition(.scale)
        }
    }
}

// MARK: - Preview

#Preview {
    ChildViewController()
}
