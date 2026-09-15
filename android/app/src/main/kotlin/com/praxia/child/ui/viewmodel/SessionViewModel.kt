package com.praxia.child.ui.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.praxia.child.trial.TrialEngine
import com.praxia.child.trial.TrialResult
import com.praxia.child.storage.TrialDatabase
import com.praxia.child.storage.SessionEntity
import com.praxia.child.storage.TrialEventEntity
import kotlinx.coroutines.launch
import java.util.UUID

typealias TrialEngineScore = TrialEngine.Score

/**
 * SessionViewModel manages the active session state and trial recording.
 *
 * Responsibilities:
 * - Maintain session state (active, paused, completed)
 * - Track target list and current target
 * - Manage trial engine state machine
 * - Persist sessions to database
 */
class SessionViewModel(
    private val database: TrialDatabase
) : ViewModel() {

    // Session state
    private val _sessionState = MutableLiveData<SessionState>()
    val sessionState: LiveData<SessionState> = _sessionState

    // Target list
    private val _targetList = MutableLiveData<List<TargetState>>()
    val targetList: LiveData<List<TargetState>> = _targetList

    // Current trial result (for UI feedback)
    private val _currentTrialResult = MutableLiveData<TrialResult?>()
    val currentTrialResult: LiveData<TrialResult?> = _currentTrialResult

    // Audio buffer for waveform visualization
    private val _audioBuffer = MutableLiveData<FloatArray>()
    val audioBuffer: LiveData<FloatArray> = _audioBuffer

    // Error state
    private val _errorState = MutableLiveData<String?>()
    val errorState: LiveData<String?> = _errorState

    private var currentSessionId: String? = null
    private var currentChildId: String? = null
    private var trialEngine: TrialEngine? = null

    init {
        _sessionState.value = SessionState(
            sessionID = "",
            childID = "",
            isActive = false,
            trialCount = 0,
            totalTrials = 0,
            elapsedSeconds = 0
        )
    }

    /**
     * Start a new session for a child with specified targets.
     */
    fun startSession(childId: String, targetIds: List<String>) {
        viewModelScope.launch {
            try {
                currentSessionId = UUID.randomUUID().toString()
                currentChildId = childId

                // Create a new TrialEngine instance for this session
                trialEngine = TrialEngine(sessionID = currentSessionId!!)

                // Create session in database
                val session = SessionEntity(
                    sessionID = currentSessionId!!,
                    childID = childId,
                    startedAt = System.currentTimeMillis(),
                    endedAt = null,
                    totalTrials = 0,
                    synced = false
                )
                database.sessionDao().insert(session)

                // Initialize targets in trial engine
                for (targetId in targetIds) {
                    val target = database.targetDao().getTarget(targetId)
                    if (target != null) {
                        trialEngine!!.addTarget(
                            targetID = targetId,
                            name = target.targetName,
                            ipaTranscription = target.ipaTranscription
                        )
                    }
                }

                // Load target configs from database (fallback to empty list if not found)
                val targetList = mutableListOf<TargetState>()
                for (targetId in targetIds) {
                    val target = database.targetDao().getTarget(targetId)
                    if (target != null) {
                        targetList.add(TargetState(
                            targetID = target.targetID,
                            word = target.targetName,
                            ipa = target.ipaTranscription,
                            currentLevel = target.currentLevel
                        ))
                    }
                }

                _targetList.value = targetList
                _sessionState.value = SessionState(
                    sessionID = currentSessionId!!,
                    childID = childId,
                    isActive = true,
                    trialCount = 0,
                    totalTrials = 0,
                    elapsedSeconds = 0
                )

                _errorState.value = null
            } catch (e: Exception) {
                _errorState.value = "Failed to start session: ${e.message}"
            }
        }
    }

    /**
     * Record a trial result for a target.
     *
     * @param targetId The target being tested
     * @param score The score (CORRECT, CLOSE, or NOT_YET)
     * @param signals Tier-1 DSP signals from audio capture
     * @param parentScore Optional parent/clinician score
     */
    fun recordTrial(
        targetId: String,
        score: TrialEngine.Score,
        signals: com.praxia.child.audio.Tier1Signal,
        parentScore: TrialEngine.Score? = null
    ) {
        viewModelScope.launch {
            try {
                if (currentSessionId == null || currentChildId == null || trialEngine == null) {
                    _errorState.value = "No active session"
                    return@launch
                }

                // Record in trial engine with DSP signals
                val result = trialEngine!!.recordTrial(
                    targetID = targetId,
                    score = score,
                    parentScore = parentScore,
                    attemptDuration = signals.phonationDuration,
                    snrDb = signals.snrDb
                )
                _currentTrialResult.value = result

                // Persist event to database with tier1 signal breakdown
                val event = TrialEventEntity(
                    eventID = UUID.randomUUID().toString(),
                    sessionID = currentSessionId!!,
                    childID = currentChildId!!,
                    trialID = UUID.randomUUID().toString(),
                    ordinal = (_sessionState.value?.trialCount ?: 0) + 1,
                    targetID = targetId,
                    cueLevel = result.currentLevel?.level ?: 0,
                    clientTs = System.currentTimeMillis(),
                    serverTs = null,
                    tier1VocalizationDetected = signals.vocalizing,
                    tier1LatencyMs = signals.responseLatency?.toInt() ?: 0,
                    tier1DurationMs = signals.phonationDuration.toInt(),
                    tier1SyllableCount = signals.syllableEstimate,
                    tier1PitchContour = signals.pitchTrend.name,
                    tier1SnrDb = signals.snrDb,
                    synced = false
                )

                database.trialEventDao().insert(event)

                // Update session state
                val currentState = _sessionState.value!!
                val updatedState = currentState.copy(
                    trialCount = currentState.trialCount + 1
                )
                _sessionState.value = updatedState

                _errorState.value = null
            } catch (e: Exception) {
                _errorState.value = "Failed to record trial: ${e.message}"
            }
        }
    }

    /**
     * End the current session.
     */
    fun endSession() {
        viewModelScope.launch {
            try {
                if (currentSessionId == null) {
                    _errorState.value = "No active session"
                    return@launch
                }

                // Update session in database
                database.sessionDao().endSession(currentSessionId!!, System.currentTimeMillis())

                _sessionState.value = _sessionState.value!!.copy(isActive = false)
                currentSessionId = null
                currentChildId = null
                _errorState.value = null
            } catch (e: Exception) {
                _errorState.value = "Failed to end session: ${e.message}"
            }
        }
    }

    /**
     * Get recent session history.
     */
    fun getSessionHistory() {
        viewModelScope.launch {
            try {
                val sessions = database.sessionDao().getRecentSessions(10)
                // TODO: Add LiveData for session history
            } catch (e: Exception) {
                _errorState.value = "Failed to load session history: ${e.message}"
            }
        }
    }

    /**
     * Update audio buffer for real-time waveform visualization.
     * Called from AudioCaptureManager as new audio data arrives.
     */
    fun updateAudioBuffer(buffer: FloatArray) {
        _audioBuffer.postValue(buffer.copyOf())  // Copy to avoid external modifications
    }
}

// MARK: - Data Classes

data class SessionState(
    val sessionID: String,
    val childID: String,
    val isActive: Boolean,
    val trialCount: Int,
    val totalTrials: Int,
    val elapsedSeconds: Int
)

data class TargetState(
    val targetID: String,
    val word: String,
    val ipa: String,
    val currentLevel: Int
)

data class TargetProgress(
    val targetID: String,
    val trialCount: Int,
    val successCount: Int,
    val successRate: Float,
    val currentLevel: Int
)
