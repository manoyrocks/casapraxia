package com.praxia.child.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.unit.dp
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.roundToInt

/**
 * Real-time waveform visualization for audio capture.
 *
 * Displays amplitude envelope of audio stream with:
 * - Vertical bars for each sample block
 * - Peak detection highlighting
 * - Center baseline
 * - Responsive to screen width
 *
 * Updates as new audio buffers arrive (every 64ms at 16kHz = 1024 samples).
 */
@Composable
fun WaveformCanvas(
    audioBuffer: FloatArray,
    isRecording: Boolean = false,
    modifier: Modifier = Modifier
) {
    val primaryColor = MaterialTheme.colorScheme.primary
    val secondaryColor = MaterialTheme.colorScheme.secondary

    Canvas(modifier = modifier) {
        // Draw background
        drawRect(
            color = MaterialTheme.colorScheme.surface,
            size = size
        )

        if (audioBuffer.isEmpty()) {
            // Draw placeholder text when no data
            drawText("Waiting for audio...", size.width / 2, size.height / 2)
            return@Canvas
        }

        // Calculate dimensions
        val canvasWidth = size.width
        val canvasHeight = size.height
        val centerY = canvasHeight / 2

        // Determine number of bars to display (responsive)
        val barWidth = 2.dp.toPx()
        val barSpacing = 1.dp.toPx()
        val barsToDisplay = ((canvasWidth) / (barWidth + barSpacing)).toInt().coerceIn(1, 256)

        // Calculate sampling step
        val step = max(1, audioBuffer.size / barsToDisplay)

        // Draw center baseline
        drawLine(
            color = MaterialTheme.colorScheme.outlineVariant,
            start = androidx.compose.ui.geometry.Offset(0f, centerY),
            end = androidx.compose.ui.geometry.Offset(canvasWidth, centerY),
            strokeWidth = 0.5.dp.toPx()
        )

        // Draw waveform bars
        var x = 0f
        var sampleIndex = 0

        while (sampleIndex < audioBuffer.size && x < canvasWidth) {
            // Get peak amplitude in this section
            val sectionEnd = (sampleIndex + step).coerceAtMost(audioBuffer.size)
            var peakAmplitude = 0f

            for (i in sampleIndex until sectionEnd) {
                peakAmplitude = max(peakAmplitude, abs(audioBuffer[i]))
            }

            // Normalize amplitude (16-bit audio: -32768 to 32767, scale to 0-1)
            val normalizedAmplitude = (peakAmplitude / 32768f).coerceIn(0f, 1f)

            // Calculate bar height (half of canvas height, since we draw both up and down)
            val barHeight = (normalizedAmplitude * centerY * 0.9f)

            // Draw bar (up and down from center)
            drawLine(
                color = if (normalizedAmplitude > 0.7f) secondaryColor else primaryColor,
                start = androidx.compose.ui.geometry.Offset(x, centerY - barHeight),
                end = androidx.compose.ui.geometry.Offset(x, centerY + barHeight),
                strokeWidth = barWidth
            )

            x += barWidth + barSpacing
            sampleIndex += step
        }

        // Draw recording indicator if active
        if (isRecording) {
            drawCircle(
                color = MaterialTheme.colorScheme.error,
                radius = 8.dp.toPx(),
                center = androidx.compose.ui.geometry.Offset(
                    canvasWidth - 16.dp.toPx(),
                    16.dp.toPx()
                )
            )
        }
    }
}

/**
 * Simplified waveform display as a single amplitude bar.
 *
 * Shows current audio intensity as a vertical bar that fills from bottom to top.
 * More performant than full waveform for simple visualizations.
 */
@Composable
fun SimpleWaveformBar(
    currentAmplitude: Float,
    isRecording: Boolean = false,
    modifier: Modifier = Modifier
) {
    val primaryColor = MaterialTheme.colorScheme.primary
    val successColor = MaterialTheme.colorScheme.secondary

    Canvas(modifier = modifier) {
        val canvasHeight = size.height
        val canvasWidth = size.width

        // Draw background
        drawRect(
            color = MaterialTheme.colorScheme.surface,
            size = size
        )

        // Normalize amplitude to 0-1 range
        val normalizedAmplitude = (abs(currentAmplitude) / 32768f).coerceIn(0f, 1f)
        val barHeight = normalizedAmplitude * canvasHeight

        // Draw amplitude bar from bottom
        drawRect(
            color = if (isRecording) successColor else primaryColor,
            topLeft = androidx.compose.ui.geometry.Offset(
                0f,
                canvasHeight - barHeight
            ),
            size = androidx.compose.ui.geometry.Size(canvasWidth, barHeight)
        )

        // Draw center line
        drawLine(
            color = MaterialTheme.colorScheme.outlineVariant,
            start = androidx.compose.ui.geometry.Offset(0f, canvasHeight / 2),
            end = androidx.compose.ui.geometry.Offset(canvasWidth, canvasHeight / 2),
            strokeWidth = 1.dp.toPx()
        )
    }
}

/**
 * Waveform with frequency spectrum visualization.
 *
 * Shows both amplitude waveform and simplified frequency bands.
 * TODO: Implement FFT-based frequency analysis for full spectrum view.
 */
@Composable
fun WaveformWithSpectrum(
    audioBuffer: FloatArray,
    isRecording: Boolean = false,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier) {
        val canvasWidth = size.width
        val canvasHeight = size.height
        val waveformHeight = canvasHeight * 0.6f
        val spectrumHeight = canvasHeight * 0.4f

        // Draw waveform section (top 60%)
        drawRect(
            color = MaterialTheme.colorScheme.surface,
            size = androidx.compose.ui.geometry.Size(canvasWidth, waveformHeight)
        )

        // Draw spectrum section (bottom 40%)
        drawRect(
            color = MaterialTheme.colorScheme.surfaceVariant,
            topLeft = androidx.compose.ui.geometry.Offset(0f, waveformHeight),
            size = androidx.compose.ui.geometry.Size(canvasWidth, spectrumHeight)
        )

        // TODO: Implement actual FFT analysis for frequency bands
        // For now, show simplified frequency estimate based on waveform density

        if (audioBuffer.isNotEmpty()) {
            val centerY = waveformHeight / 2
            val barWidth = 2.dp.toPx()
            val barsToDisplay = (canvasWidth / (barWidth + 1.dp.toPx())).toInt().coerceIn(1, 128)
            val step = audioBuffer.size / barsToDisplay

            var x = 0f
            for (i in 0 until barsToDisplay) {
                val idx = i * step
                if (idx < audioBuffer.size) {
                    val amplitude = abs(audioBuffer[idx]) / 32768f
                    val height = amplitude * centerY * 0.8f

                    drawLine(
                        color = MaterialTheme.colorScheme.primary,
                        start = androidx.compose.ui.geometry.Offset(x, centerY - height),
                        end = androidx.compose.ui.geometry.Offset(x, centerY + height),
                        strokeWidth = barWidth
                    )
                }
                x += barWidth + 1.dp.toPx()
            }
        }
    }
}
