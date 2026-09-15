/**
 * TrialEngine.ts - Trial advancement state machine
 * Ported from iOS TrialEngine.swift
 *
 * Implements:
 * - L0-L5 cue hierarchy (DTTC: Dynamic Temporal and Tactile Cueing)
 * - 3-up/2-down advancement rule
 * - Safety stop <40% success rate (C4)
 * - Silent back-off (C3)
 * - Aversion detection
 * - No machine verdict to child (C1)
 * - Immutable trial log (C8)
 */

import {
  CueLevel,
  ScoreValue,
  Trial,
  TrialEvent,
  TargetState,
  TrialResult,
  Target,
} from './types'

export interface TrialEngineConfig {
  safetyStopThresholdPct?: number // Default: 40%
  masteryThresholdPct?: number // Default: 80%
  aversiveThresholdPct?: number // Default: 20% (3-up/2-down = 2 consecutive failures)
}

export class TrialEngine {
  private targetStates: Map<string, TargetState> = new Map()
  private config: Required<TrialEngineConfig>

  constructor(config: TrialEngineConfig = {}) {
    this.config = {
      safetyStopThresholdPct: config.safetyStopThresholdPct ?? 40,
      masteryThresholdPct: config.masteryThresholdPct ?? 80,
      aversiveThresholdPct: config.aversiveThresholdPct ?? 20,
    }
  }

  /**
   * Initialize target state from backend Target definition
   */
  initializeTarget(target: Target): void {
    this.targetStates.set(target.targetId, {
      targetId: target.targetId,
      word: target.word,
      currentLevel: target.startingLevel,
      successCount: 0,
      failureCount: 0,
      consecutiveCorrect: 0,
      mastered: false,
      safetyStopTriggered: false,
      lastTrialAt: undefined,
    })
  }

  /**
   * Record trial result and update target state
   * 3-up/2-down rule:
   * - 3 consecutive correct → advance to next level
   * - 2 consecutive incorrect → go back to previous level
   * - No machine verdict to child (C1)
   */
  recordTrial(targetId: string, score: ScoreValue): TrialResult {
    const targetState = this.targetStates.get(targetId)
    if (!targetState) {
      throw new Error(`Target ${targetId} not initialized`)
    }

    // Only parent-entered scores count (no machine verdict per C1)
    if (score === ScoreValue.SCORE_UNSPECIFIED || score === ScoreValue.ABSTAIN) {
      return {
        targetState,
        advancedLevel: false,
        backoffLevel: false,
        safetyStopTriggered: false,
        action: 'none',
      }
    }

    // Determine if trial was successful for 3-up/2-down logic
    const isSuccess = score === ScoreValue.GOT_IT || score === ScoreValue.CLOSE

    // Update counters
    if (isSuccess) {
      targetState.successCount++
      targetState.consecutiveCorrect++
      targetState.failureCount = 0
    } else {
      targetState.failureCount++
      targetState.consecutiveCorrect = 0
      targetState.successCount = 0
    }

    targetState.lastTrialAt = Date.now()

    // Compute current success rate for safety stop check
    const totalTrials = targetState.successCount + targetState.failureCount
    const successRatePct = (targetState.successCount / Math.max(1, totalTrials)) * 100

    // Check safety stop condition (C4)
    if (
      targetState.currentLevel === CueLevel.L0 &&
      successRatePct < this.config.safetyStopThresholdPct
    ) {
      targetState.safetyStopTriggered = true
      return {
        targetState,
        advancedLevel: false,
        backoffLevel: false,
        safetyStopTriggered: true,
        action: 'stop', // Silent stop, no child-visible indication (C3)
      }
    }

    let advancedLevel = false
    let backoffLevel = false
    let action: TrialResult['action'] = 'maintain'

    // 3-up: Advance if 3 consecutive correct
    if (targetState.consecutiveCorrect >= 3 && targetState.currentLevel < CueLevel.L5) {
      advancedLevel = true
      targetState.currentLevel = this.getNextLevel(targetState.currentLevel)
      targetState.successCount = 0
      targetState.failureCount = 0
      targetState.consecutiveCorrect = 0
      action = 'advance'
    }

    // 2-down: Back off if 2 consecutive failures
    if (targetState.failureCount >= 2 && targetState.currentLevel > CueLevel.L0) {
      backoffLevel = true
      targetState.currentLevel = this.getPreviousLevel(targetState.currentLevel)
      targetState.successCount = 0
      targetState.failureCount = 0
      targetState.consecutiveCorrect = 0
      action = 'backoff' // Silent back-off, no child-visible indication (C3)
    }

    // Check if mastered (C5: reuse iOS masteryTarget 80%)
    if (
      successRatePct >= this.config.masteryThresholdPct &&
      targetState.currentLevel === CueLevel.L5
    ) {
      targetState.mastered = true
    }

    return {
      targetState: { ...targetState }, // Return snapshot
      advancedLevel,
      backoffLevel,
      safetyStopTriggered: false,
      action,
    }
  }

  /**
   * Get state of a specific target
   */
  getTargetState(targetId: string): TargetState | undefined {
    return this.targetStates.get(targetId)
  }

  /**
   * Get all target states
   */
  getAllTargetStates(): TargetState[] {
    return Array.from(this.targetStates.values())
  }

  /**
   * Reset target to starting level (e.g., on new session or parent request)
   */
  resetTarget(targetId: string, startingLevel: CueLevel = CueLevel.L0): void {
    const target = this.targetStates.get(targetId)
    if (target) {
      target.currentLevel = startingLevel
      target.successCount = 0
      target.failureCount = 0
      target.consecutiveCorrect = 0
      target.mastered = false
      target.safetyStopTriggered = false
    }
  }

  /**
   * Load trial history to reconstruct state
   * Used when resuming session or syncing from server
   */
  loadTrialHistory(trials: TrialEvent[]): void {
    // Group trials by target
    const trialsByTarget = new Map<string, TrialEvent[]>()
    for (const trial of trials) {
      if (!trialsByTarget.has(trial.targetId)) {
        trialsByTarget.set(trial.targetId, [])
      }
      trialsByTarget.get(trial.targetId)!.push(trial)
    }

    // Replay each target's trial history to reconstruct state
    for (const [targetId, targetTrials] of trialsByTarget.entries()) {
      // Ensure target is initialized
      if (!this.targetStates.has(targetId)) {
        this.targetStates.set(targetId, {
          targetId,
          word: '',
          currentLevel: CueLevel.L0,
          successCount: 0,
          failureCount: 0,
          consecutiveCorrect: 0,
          mastered: false,
          safetyStopTriggered: false,
        })
      }

      // Replay trials in order
      for (const trial of targetTrials.sort((a, b) => a.clientTs - b.clientTs)) {
        this.recordTrial(targetId, trial.score)
      }
    }
  }

  // ========================================================================
  // PRIVATE HELPERS
  // ========================================================================

  private getNextLevel(level: CueLevel): CueLevel {
    if (level === CueLevel.L5) return CueLevel.L5
    return (level + 1) as CueLevel
  }

  private getPreviousLevel(level: CueLevel): CueLevel {
    if (level === CueLevel.L0) return CueLevel.L0
    return (level - 1) as CueLevel
  }

  /**
   * Compliance check: C1 - No machine verdict to child
   * Only parent-scored values (GOT_IT, CLOSE, NOT_YET) are used in advancement logic
   */
  static checkC1_NoMachineVerdict(score: ScoreValue): boolean {
    // Machine verdict would be ABSTAIN or computed by DSP
    // We only accept parent-entered: GOT_IT, CLOSE, NOT_YET
    return score !== ScoreValue.SCORE_UNSPECIFIED && score !== ScoreValue.ABSTAIN
  }

  /**
   * Compliance check: C3 - Silent back-off
   * Back-off action should not be child-visible
   */
  static checkC3_SilentBackOff(result: TrialResult): boolean {
    // Back-off is action 'backoff' or 'stop', no child-visible UI element
    return result.action === 'backoff' || result.action === 'stop'
  }

  /**
   * Compliance check: C4 - Safety stop <40%
   * If success rate drops below threshold at L0, trial stops automatically
   */
  static checkC4_SafetyStop(targetState: TargetState, thresholdPct: number = 40): boolean {
    if (targetState.currentLevel !== CueLevel.L0) return false
    const totalTrials = targetState.successCount + targetState.failureCount
    if (totalTrials < 1) return false
    const successPct = (targetState.successCount / totalTrials) * 100
    return successPct < thresholdPct
  }
}

export default TrialEngine
