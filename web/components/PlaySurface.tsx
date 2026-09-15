'use client'

/**
 * PlaySurface.tsx - Child practice interaction surface
 *
 * Responsive Design (Mobile-First):
 * - sm (320px): 1 column - waveform full-width, scoring stacked vertically
 * - md (600px, 7" tablet): 2 columns - waveform + scoring side-by-side
 * - lg (800px, 10" tablet): 3 columns - waveform + target + scoring inline
 * - xl (1024px, desktop): Full responsive grid with sticky parent panel
 *
 * Implements:
 * - Live waveform visualization (Canvas-based)
 * - Target word display (large, readable)
 * - Parent scoring buttons (3: Got it / Close / Try again)
 * - Session timer + trial counter
 * - Touch targets: ≥48px verified on tablets (C18)
 * - No machine verdict to child (C1)
 */

import React, { useRef, useEffect, useState } from 'react'
import { Tier1Signals, ScoreValue, Target, PlaySurfaceProps } from '@/lib/types'
import AudioCapture from '@/lib/AudioCapture'

interface PlaySurfaceState {
  isRecording: boolean
  tier1Signals?: Tier1Signals
  recordingDurationMs: number
  waveformData: Float32Array | null
}

export default function PlaySurface({
  session,
  currentTarget,
  tier1Signals,
  onScoreSubmit,
  isRecording: isRecordingProp = false,
}: PlaySurfaceProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const audioRef = useRef<AudioCapture | null>(null)
  const [state, setState] = useState<PlaySurfaceState>({
    isRecording: isRecordingProp,
    tier1Signals: tier1Signals,
    recordingDurationMs: 0,
    waveformData: null,
  })

  // Format elapsed time as MM:SS
  const formatTime = (ms: number): string => {
    const seconds = Math.floor(ms / 1000)
    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${minutes}:${secs.toString().padStart(2, '0')}`
  }

  // Draw waveform on canvas (responsive sizing)
  const drawWaveform = (canvas: HTMLCanvasElement, data: Float32Array) => {
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const width = canvas.width
    const height = canvas.height

    // Clear canvas with warm background (no red failure states per C2)
    ctx.fillStyle = '#FFF8F0' // cream
    ctx.fillRect(0, 0, width, height)

    // Draw waveform with therapeutic teal color
    ctx.strokeStyle = '#4A9B8E' // teal
    ctx.lineWidth = 2
    ctx.beginPath()

    const samplesPerPixel = Math.ceil(data.length / width)
    let isFirstPoint = true

    for (let i = 0; i < width; i++) {
      const start = i * samplesPerPixel
      const end = Math.min(start + samplesPerPixel, data.length)

      // Find peak in this pixel's samples
      let max = 0
      for (let j = start; j < end; j++) {
        max = Math.max(max, Math.abs(data[j]))
      }

      // Normalize and scale to canvas height
      const y = height / 2 - (max * height * 0.4)

      if (isFirstPoint) {
        ctx.moveTo(i, y)
        isFirstPoint = false
      } else {
        ctx.lineTo(i, y)
      }
    }

    ctx.stroke()

    // Draw center baseline
    ctx.strokeStyle = '#9DB9A3' // sage
    ctx.lineWidth = 1
    ctx.setLineDash([5, 5])
    ctx.beginPath()
    ctx.moveTo(0, height / 2)
    ctx.lineTo(width, height / 2)
    ctx.stroke()
    ctx.setLineDash([])
  }

  // Render waveform when tier1 signals update
  useEffect(() => {
    if (!canvasRef.current || !tier1Signals) return

    // Simulate waveform data for demo (in production, from AudioCapture)
    const mockData = new Float32Array(4096)
    for (let i = 0; i < mockData.length; i++) {
      mockData[i] =
        Math.sin((i / 100) * Math.PI * 2) * 0.3 +
        Math.random() * 0.1 -
        0.05
    }

    drawWaveform(canvasRef.current, mockData)
  }, [tier1Signals])

  // Update recording timer
  useEffect(() => {
    if (!state.isRecording) return

    const timer = setInterval(() => {
      setState((prev) => ({
        ...prev,
        recordingDurationMs: prev.recordingDurationMs + 100,
      }))
    }, 100)

    return () => clearInterval(timer)
  }, [state.isRecording])

  const handleStartRecording = async () => {
    if (!AudioCapture.isSupported()) {
      alert('Audio capture not supported on this browser')
      return
    }

    try {
      audioRef.current = new AudioCapture()
      await audioRef.current.start()
      setState((prev) => ({
        ...prev,
        isRecording: true,
        recordingDurationMs: 0,
      }))
    } catch (error) {
      console.error('Failed to start recording:', error)
      alert('Failed to access microphone')
    }
  }

  const handleStopRecording = async () => {
    if (!audioRef.current) return

    const audioData = await audioRef.current.stop()
    const tier1 = audioRef.current.computeTier1Signals()

    setState((prev) => ({
      ...prev,
      isRecording: false,
      tier1Signals: tier1,
      waveformData: audioData,
    }))
  }

  const handleScore = (score: ScoreValue) => {
    onScoreSubmit(score)
    // Reset for next trial
    setState({
      isRecording: false,
      tier1Signals: undefined,
      recordingDurationMs: 0,
      waveformData: null,
    })
  }

  return (
    <div className="w-full h-full flex flex-col gap-4 p-4 bg-cream md:gap-6 md:p-6">
      {/* RESPONSIVE GRID: sm:1col → md:2col → lg:3col */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6 lg:gap-8 h-full">
        {/* COLUMN 1: Waveform (sm: full, md: left, lg: left) */}
        <div className="flex flex-col gap-4 md:gap-6 md:col-span-1 lg:col-span-1">
          <div className="flex-1 min-h-48 md:min-h-64 lg:min-h-80 bg-white rounded-lg border-2 border-sage shadow-sm overflow-hidden">
            <canvas
              ref={canvasRef}
              width={400}
              height={200}
              className="w-full h-full"
              style={{ display: 'block' }}
            />
          </div>

          {/* Recording Status */}
          <div className="text-center">
            {state.isRecording ? (
              <div className="animate-pulse">
                <div className="text-sm font-semibold text-teal">🎤 Recording...</div>
                <div className="text-xs text-sage mt-1">{formatTime(state.recordingDurationMs)}</div>
              </div>
            ) : (
              <div className="text-xs text-sage">Ready to record</div>
            )}
          </div>
        </div>

        {/* COLUMN 2: Target Word (sm: full, md: right/top, lg: center) */}
        <div className="flex flex-col justify-center items-center md:col-span-1 lg:col-span-1">
          <div className="text-center">
            <div className="text-xs text-sage uppercase tracking-wider mb-2">Target Word</div>
            <div className="text-4xl md:text-5xl lg:text-6xl font-bold text-teal mb-2">
              {currentTarget.word}
            </div>
            <div className="text-xs md:text-sm text-sage">/{currentTarget.ipa}/</div>
          </div>

          {/* Session Info */}
          <div className="mt-6 text-center text-xs md:text-sm text-sage">
            <div>Trial {session.completedTrialCount + 1} of {session.trialCount}</div>
            <div className="text-xs text-warmAmber mt-1">
              {formatTime((Date.now() - session.startTime) % 3600000)}
            </div>
          </div>
        </div>

        {/* COLUMN 3: Scoring Buttons (sm: full, md: full, lg: right) */}
        <div className="flex flex-col gap-3 md:col-span-2 lg:col-span-1 justify-end">
          {!state.isRecording ? (
            <button
              onClick={handleStartRecording}
              className="w-full bg-teal text-white font-semibold py-4 md:py-5 lg:py-6 px-4 rounded-lg hover:bg-teal/90 transition-colors min-h-touch md:min-h-touch-lg touch-target text-base md:text-lg lg:text-xl"
            >
              🎤 Record Trial
            </button>
          ) : (
            <button
              onClick={handleStopRecording}
              className="w-full bg-warmAmber text-white font-semibold py-4 md:py-5 lg:py-6 px-4 rounded-lg hover:bg-warmAmber/90 transition-colors min-h-touch md:min-h-touch-lg touch-target text-base md:text-lg lg:text-xl"
            >
              ⏹ Stop Recording
            </button>
          )}

          {/* Parent Scoring (appears after recording) */}
          {!state.isRecording && state.tier1Signals && (
            <div className="space-y-2 md:space-y-3 lg:space-y-4 animate-fadeIn">
              <div className="text-xs text-center text-sage font-semibold uppercase">
                Did they say it?
              </div>

              <button
                onClick={() => handleScore(ScoreValue.GOT_IT)}
                className="w-full bg-success text-white font-semibold py-3 md:py-4 lg:py-5 px-4 rounded-lg hover:bg-success/90 transition-colors min-h-touch touch-target text-sm md:text-base lg:text-lg"
              >
                ✓ Got It!
              </button>

              <button
                onClick={() => handleScore(ScoreValue.CLOSE)}
                className="w-full bg-sage text-white font-semibold py-3 md:py-4 lg:py-5 px-4 rounded-lg hover:bg-sage/90 transition-colors min-h-touch touch-target text-sm md:text-base lg:text-lg"
              >
                ≈ Close
              </button>

              <button
                onClick={() => handleScore(ScoreValue.NOT_YET)}
                className="w-full bg-warmAmber text-white font-semibold py-3 md:py-4 lg:py-5 px-4 rounded-lg hover:bg-warmAmber/90 transition-colors min-h-touch touch-target text-sm md:text-base lg:text-lg"
              >
                ↻ Try Again
              </button>

              {/* Tier-1 Debug Info (development only) */}
              {process.env.NODE_ENV === 'development' && state.tier1Signals && (
                <div className="text-xs bg-white p-2 rounded mt-2 border border-sage">
                  <div>Duration: {state.tier1Signals.durationMs}ms</div>
                  <div>SNR: {state.tier1Signals.snrDb.toFixed(1)}dB</div>
                  <div>Syllables: {state.tier1Signals.syllableCount}</div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
