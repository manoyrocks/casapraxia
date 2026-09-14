import SwiftUI

/// Parent-only control panel showing Tier-1 signals and session coaching.
///
/// Display rules:
/// - Desktop: permanent right sidebar (≥600pt width)
/// - Mobile: toggle button, full-screen overlay
/// - Never visible to child (parent-only zone)
/// - Shows: cue level, Tier-1 signals, session stats, weekly chart
struct ParentPanel: View {
    @ObservedObject var trialEngine: TrialEngine
    @ObservedObject var sessionController: SessionViewController
    @State private var showPanel = false

    let targetID: String
    let tier1Signal: Tier1Signal?

    var body: some View {
        // Detect if landscape (desktop-like) or portrait (mobile)
        #if os(iOS)
        GeometryReader { geo in
            if geo.size.width > 600 {
                // Desktop: sidebar
                HStack(spacing: 0) {
                    Spacer()
                    desktopSidebar
                        .frame(width: 280)
                        .background(Color(.systemGray6))
                }
            } else {
                // Mobile: toggle button + overlay
                ZStack {
                    if showPanel {
                        mobilePanelOverlay
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.4))
                            .onTapGesture { showPanel = false }
                    }

                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { showPanel.toggle() }) {
                                Image(systemName: "gear.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        #else
        // macOS: always visible
        desktopSidebar
            .frame(width: 280)
            .background(Color(.controlBackgroundColor))
        #endif
    }

    // MARK: - Desktop sidebar

    private var desktopSidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cue Level")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if let target = trialEngine.getTargetState(targetID: targetID) {
                        HStack {
                            Text(target.currentLevel.displayName)
                                .font(.headline)
                            Spacer()
                            cueLevelBadge(target.currentLevel)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                // Cue hierarchy bar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fading")
                        .font(.caption)
                        .foregroundColor(.gray)

                    cueHierarchyBar
                }

                Divider()

                // Tier-1 signals (parent-only, never child)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Acoustic Signals (Live)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    tier1SignalsDisplay
                }

                Divider()

                // Session stats
                VStack(alignment: .leading, spacing: 12) {
                    Text("Session")
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack {
                        Text("Attempts").font(.caption)
                        Spacer()
                        Text("\(sessionController.trialCount)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }

                    if sessionController.trialCount > 0,
                       let target = trialEngine.getTargetState(targetID: targetID) {
                        let successCount = target.recentTrials.filter { $0 == .correct }.count
                        let accuracy = Float(successCount) / Float(target.recentTrials.count)
                        HStack {
                            Text("Accuracy").font(.caption)
                            Spacer()
                            Text(String(format: "%.0f%%", accuracy * 100))
                                .font(.headline)
                                .foregroundColor(accuracy >= 0.6 ? .green : .orange)
                        }
                    }

                    HStack {
                        Text("Time").font(.caption)
                        Spacer()
                        Text(formatTime(sessionController.elapsedTime))
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }

                Divider()

                // Coaching message rotation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Coaching")
                        .font(.caption)
                        .foregroundColor(.gray)

                    coachingMessageView
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(6)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Mobile panel overlay

    private var mobilePanelOverlay: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Parent View")
                    .font(.headline)
                Spacer()
                Button(action: { showPanel = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    cueLevelSection
                    tier1SignalsDisplay
                    sessionStatsSection
                    coachingMessageView
                }
                .padding()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
    }

    // MARK: - Components

    private var cueLevelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cue Level").font(.caption).foregroundColor(.gray)
            if let target = trialEngine.getTargetState(targetID: targetID) {
                HStack {
                    Text(target.currentLevel.displayName).font(.headline)
                    Spacer()
                    cueLevelBadge(target.currentLevel)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private var cueHierarchyBar: some View {
        HStack(spacing: 4) {
            ForEach([
                TrialEngine.CueLevel.level0,
                .level1, .level2, .level3, .level4, .level5
            ], id: \.self) { level in
                VStack {
                    if let target = trialEngine.getTargetState(targetID: targetID) {
                        let isActive = level == target.currentLevel
                        Capsule()
                            .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 24)
                            .overlay(
                                Text("L\(level.rawValue)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
    }

    private var tier1SignalsDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Acoustic Signals (Live)").font(.caption).foregroundColor(.gray)

            if let signal = tier1Signal {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Vocalizing").font(.caption)
                        Spacer()
                        Image(systemName: signal.vocalizing ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(signal.vocalizing ? .green : .gray)
                    }

                    if let latency = signal.responseLatency {
                        HStack {
                            Text("Latency").font(.caption)
                            Spacer()
                            Text(String(format: "%.0f ms", latency * 1000))
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }

                    HStack {
                        Text("SNR").font(.caption)
                        Spacer()
                        Text(String(format: "%.1f dB", signal.snrDb))
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Syllables").font(.caption)
                        Spacer()
                        Text("\(signal.syllableEstimate)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(6)
            } else {
                Text("—").font(.caption).foregroundColor(.gray)
            }
        }
    }

    private var sessionStatsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session").font(.caption).foregroundColor(.gray)

            HStack {
                Text("Attempts").font(.caption)
                Spacer()
                Text("\(sessionController.trialCount)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            HStack {
                Text("Time").font(.caption)
                Spacer()
                Text(formatTime(sessionController.elapsedTime))
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
    }

    private var coachingMessageView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Tip").font(.caption).foregroundColor(.gray)

            let messages = [
                "Look for: 👀 eyes tracking the model",
                "Reward silence, too: ✓ just trying counts",
                "Match their pace: ⏱️ no rushing",
                "Celebrate attempts: 🎉 not just successes",
                "Keep it fun: 😊 stop if she's frustrated"
            ]

            if let message = messages.randomElement() {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }

    private func cueLevelBadge(_ level: TrialEngine.CueLevel) -> some View {
        Text("L\(level.rawValue)")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(Color.blue)
            .clipShape(Circle())
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Preview

#Preview {
    ParentPanel(
        trialEngine: TrialEngine(sessionID: "preview"),
        sessionController: SessionViewController(
            trialEngine: TrialEngine(sessionID: "preview"),
            audioManager: AudioCaptureManager(),
            trialStore: try! TrialStore(path: NSTemporaryDirectory() + "preview.db", encryptionKey: "preview")
        ),
        targetID: "ba",
        tier1Signal: Tier1Signal(
            timestamp: Date(),
            vocalizing: true,
            responseLatency: 0.145,
            phonationDuration: 0.8,
            intensityEnvelope: [],
            syllableEstimate: 1,
            pitchTrend: .rising,
            snrDb: 22.5
        )
    )
}
