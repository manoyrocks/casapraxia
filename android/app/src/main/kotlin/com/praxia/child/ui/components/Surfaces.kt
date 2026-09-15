package com.praxia.child.ui.components

import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.praxia.child.ui.viewmodel.SessionViewModel
import com.praxia.child.ui.viewmodel.SessionState
import com.praxia.child.ui.viewmodel.TargetState
import com.praxia.child.ui.viewmodel.TrialViewModel
import com.praxia.child.audio.TextToSpeechManager

/**
 * Play Surface - Main interaction surface for the child
 * Displays: target word, waveform, scoring buttons, session timer
 */
@Composable
fun PlaySurface(
    targets: List<TargetState>,
    sessionState: SessionState,
    sessionViewModel: SessionViewModel,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        if (!sessionState.isActive) {
            // Session start view
            Text(
                text = "Start a Session",
                style = MaterialTheme.typography.headlineMedium,
                textAlign = TextAlign.Center
            )

            Button(
                onClick = {
                    // Start a session with the available targets
                    val targetIds = targets.map { it.targetID }
                    sessionViewModel.startSession(sessionState.childID, targetIds)
                },
                modifier = Modifier
                    .height(64.dp)
                    .fillMaxWidth(0.8f),
                contentPadding = PaddingValues(horizontal = 24.dp)
            ) {
                Icon(Icons.Filled.PlayArrow, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Start Session", fontSize = 18.sp)
            }
        } else {
            // Active session view
            SessionHeader(isActive = true)

            // Display target word large and clear
            if (targets.isNotEmpty()) {
                val currentTarget = targets.first()
                TargetWordDisplay(
                    word = currentTarget.word,
                    ipa = currentTarget.ipa,
                    level = currentTarget.currentLevel
                )
            }

            // Waveform visualization - real-time audio display
            val audioBuffer by sessionViewModel.audioBuffer.observeAsState(floatArrayOf())
            WaveformCanvas(
                audioBuffer = audioBuffer,
                isRecording = sessionState.isActive,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp)
            )

            // Scoring buttons (≥64dp height for touch targets)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                ScoringButton(
                    label = "Got It!",
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier
                        .weight(1f)
                        .height(64.dp),
                    onClick = { /* Handle scoring */ }
                )
                ScoringButton(
                    label = "Close",
                    color = MaterialTheme.colorScheme.secondary,
                    modifier = Modifier
                        .weight(1f)
                        .height(64.dp),
                    onClick = { /* Handle scoring */ }
                )
                ScoringButton(
                    label = "Not Yet",
                    color = Color(0xFFFF9800),
                    modifier = Modifier
                        .weight(1f)
                        .height(64.dp),
                    onClick = { /* Handle scoring */ }
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // End session button
            Button(
                onClick = { onSessionToggle(false) },
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.errorContainer
                ),
                modifier = Modifier
                    .height(48.dp)
                    .fillMaxWidth(0.6f)
            ) {
                Text("End Session")
            }
        }
    }
}

/**
 * Talk Surface - AAC (Augmentative and Alternative Communication) board
 * Displays: word grid with touch targets, text-to-speech integration
 */
@Composable
fun TalkSurface(
    targets: List<TargetState>,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "AAC Board",
            style = MaterialTheme.typography.headlineMedium
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Word grid - responsive based on available space
        // For now, show as 2-3 columns with touch-friendly sizing
        LazyAACGrid(
            words = targets.map { it.word },
            modifier = Modifier.fillMaxSize()
        )
    }
}

/**
 * Collection Surface - Target word list + progress tracking
 * Displays: targets, cue levels, session history, weekly chart
 */
@Composable
fun CollectionSurface(
    targets: List<TargetState>,
    sessionState: SessionState,
    trialViewModel: TrialViewModel,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Progress",
            style = MaterialTheme.typography.headlineMedium
        )

        // Session summary
        SessionSummaryCard(sessionState = sessionState)

        // Targets list with progress
        Text(
            text = "Targets",
            style = MaterialTheme.typography.titleMedium
        )

        targets.forEach { target ->
            TargetProgressCard(target = target)
        }
    }
}

// MARK: - Component Composables

@Composable
fun SessionHeader(isActive: Boolean, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(
                color = if (isActive)
                    MaterialTheme.colorScheme.primaryContainer
                else
                    MaterialTheme.colorScheme.surfaceVariant,
                shape = MaterialTheme.shapes.medium
            )
            .padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text("Session Active", style = MaterialTheme.typography.titleSmall)
            Text("Trial 5 of 10", style = MaterialTheme.typography.bodySmall)
        }

        Icon(
            imageVector = if (isActive) Icons.Filled.FavoriteBorder else Icons.Filled.Favorite,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary
        )
    }
}

@Composable
fun TargetWordDisplay(
    word: String,
    ipa: String,
    level: Int,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .background(
                color = MaterialTheme.colorScheme.primaryContainer,
                shape = MaterialTheme.shapes.large
            )
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = word,
            style = MaterialTheme.typography.displayLarge
        )

        Text(
            text = "IPA: $ipa",
            style = MaterialTheme.typography.bodyMedium
        )

        SurfaceChip(
            label = "Level $level",
            backgroundColor = MaterialTheme.colorScheme.primary
        )
    }
}

@Composable
fun WaveformDisplay(modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier,
        color = MaterialTheme.colorScheme.surfaceVariant,
        shape = MaterialTheme.shapes.medium
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "🎙️ Listening...",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun ScoringButton(
    label: String,
    color: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        modifier = modifier,
        colors = ButtonDefaults.buttonColors(containerColor = color),
        contentPadding = PaddingValues(8.dp)
    ) {
        Text(label, fontSize = 14.sp)
    }
}

@Composable
fun LazyAACGrid(
    words: List<String>,
    modifier: Modifier = Modifier
) {
    // Responsive grid: 3 columns default
    val columnsCount = 3
    val gridSize = (words.size + columnsCount - 1) / columnsCount

    Column(modifier = modifier.verticalScroll(rememberScrollState())) {
        for (row in 0 until gridSize) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                for (col in 0 until columnsCount) {
                    val index = row * columnsCount + col
                    if (index < words.size) {
                        AACWordButton(
                            word = words[index],
                            modifier = Modifier.weight(1f)
                        )
                    } else {
                        Spacer(modifier = Modifier.weight(1f))
                    }
                }
            }
        }
    }
}

@Composable
fun AACWordButton(
    word: String,
    modifier: Modifier = Modifier
) {
    var isPlaying by remember { mutableStateOf(false) }
    val context = LocalContext.current
    val ttsManager = remember { TextToSpeechManager.getInstance(context) }

    Button(
        onClick = {
            if (!isPlaying && ttsManager.isReady()) {
                isPlaying = true
                ttsManager.speak(word) { success ->
                    isPlaying = false
                }
            }
        },
        modifier = modifier
            .height(80.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = if (isPlaying)
                MaterialTheme.colorScheme.tertiary
            else
                MaterialTheme.colorScheme.secondary
        )
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (isPlaying) {
                Icon(
                    imageVector = Icons.Filled.VolumeUp,
                    contentDescription = "Speaking",
                    modifier = Modifier.size(20.dp)
                )
            } else {
                Icon(
                    imageVector = Icons.Filled.Mic,
                    contentDescription = "Tap to speak",
                    modifier = Modifier.size(20.dp)
                )
            }
            Text(word, fontSize = 16.sp)
        }
    }
}

@Composable
fun SessionSummaryCard(sessionState: SessionState, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text("Session Summary", style = MaterialTheme.typography.titleMedium)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Trials Completed:")
                Text("${sessionState.trialCount}/${sessionState.totalTrials}")
            }
        }
    }
}

@Composable
fun TargetProgressCard(target: TargetState, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Row(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(target.word, style = MaterialTheme.typography.titleMedium)
                Text(target.ipa, style = MaterialTheme.typography.bodySmall)
            }

            SurfaceChip(
                label = "L${target.currentLevel}",
                backgroundColor = MaterialTheme.colorScheme.secondary
            )
        }
    }
}

@Composable
fun SurfaceChip(
    label: String,
    backgroundColor: Color,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier
            .padding(4.dp),
        shape = MaterialTheme.shapes.small,
        color = backgroundColor
    ) {
        Text(
            text = label,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            style = MaterialTheme.typography.labelSmall,
            color = Color.White
        )
    }
}

// MARK: - Parent Panel Overlay

@Composable
fun ParentPanelOverlay(
    onDismiss: () -> Unit,
    sessionState: SessionState,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.6f))
    ) {
        Surface(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth(),
            shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp),
            color = MaterialTheme.colorScheme.surface
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text("Parent Panel", style = MaterialTheme.typography.titleLarge)

                Text("Session Stats", style = MaterialTheme.typography.titleMedium)
                Text("Trials: ${sessionState.trialCount}/${sessionState.totalTrials}")

                Button(
                    onClick = onDismiss,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Close")
                }
            }
        }
    }
}

// Note: This is a placeholder implementation
// In production, this should be actual Compose implementations using LazyColumn, LazyRow, etc.
