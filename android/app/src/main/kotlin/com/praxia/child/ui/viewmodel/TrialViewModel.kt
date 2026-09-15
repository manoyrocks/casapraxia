package com.praxia.child.ui.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.praxia.child.service.TrialServiceProtocol
import com.praxia.child.storage.TrialDatabase
import com.praxia.child.storage.TargetEntity
import kotlinx.coroutines.launch

/**
 * TrialViewModel manages trial configuration, target loading, and session upload.
 *
 * Responsibilities:
 * - Fetch target configurations from backend or local database
 * - Manage trial service communication
 * - Handle session and audio upload
 * - Track sync status and pending uploads
 */
class TrialViewModel(
    private val trialService: TrialServiceProtocol,
    private val database: TrialDatabase
) : ViewModel() {

    // Available targets
    private val _targets = MutableLiveData<List<TargetEntity>>()
    val targets: LiveData<List<TargetEntity>> = _targets

    // Upload result
    private val _uploadResult = MutableLiveData<UploadResult?>()
    val uploadResult: LiveData<UploadResult?> = _uploadResult

    // Sync status
    private val _syncStatus = MutableLiveData<SyncStatus>()
    val syncStatus: LiveData<SyncStatus> = _syncStatus

    // Loading state
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    // Error state
    private val _errorState = MutableLiveData<String?>()
    val errorState: LiveData<String?> = _errorState

    init {
        _uploadResult.value = null
        _syncStatus.value = SyncStatus.IDLE
        _isLoading.value = false
    }

    /**
     * Load available targets from backend.
     */
    fun loadTargets() {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _errorState.value = null

                // Try to fetch fresh from backend
                val result = trialService.getTargets(childId = "")
                if (result.isSuccess) {
                    val targets = result.getOrNull() ?: emptyList()
                    _targets.value = targets
                    _errorState.value = null
                } else {
                    _errorState.value = result.exceptionOrNull()?.message ?: "Failed to load targets"
                }
            } catch (e: Exception) {
                _errorState.value = "Error loading targets: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Upload a completed session to the backend.
     */
    fun uploadSession(sessionId: String) {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _syncStatus.value = SyncStatus.UPLOADING
                _errorState.value = null

                // Fetch session and events from database
                val session = database.sessionDao().getSession(sessionId)
                if (session == null) {
                    _errorState.value = "Session not found"
                    _syncStatus.value = SyncStatus.IDLE
                    return@launch
                }

                val events = database.trialEventDao().getSessionTrials(sessionId)
                if (events.isEmpty()) {
                    _errorState.value = "Session has no trials"
                    _syncStatus.value = SyncStatus.IDLE
                    return@launch
                }

                // Upload to backend
                val result = trialService.uploadSession(
                    sessionId = sessionId,
                    childId = session.childID,
                    trials = events
                )

                if (result.isSuccess) {
                    // Mark events as synced in database
                    database.trialEventDao().markSynced(events.map { it.eventID })

                    _uploadResult.value = UploadResult(
                        success = true,
                        message = "Session uploaded successfully"
                    )
                    _syncStatus.value = SyncStatus.SUCCESS
                    _errorState.value = null
                } else {
                    _errorState.value = result.exceptionOrNull()?.message ?: "Upload failed"
                    _syncStatus.value = SyncStatus.FAILED
                }
            } catch (e: Exception) {
                _errorState.value = "Error uploading session: ${e.message}"
                _syncStatus.value = SyncStatus.FAILED
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Upload audio file for a trial.
     */
    fun uploadAudio(audioId: String, audioData: ByteArray) {
        viewModelScope.launch {
            try {
                _isLoading.value = true
                _errorState.value = null

                val result = trialService.uploadAudio(
                    audioId = audioId,
                    audioData = audioData
                )

                if (result.isSuccess) {
                    // Mark audio as synced
                    database.audioClipDao().markSynced(audioId, "")

                    _uploadResult.value = UploadResult(
                        success = true,
                        message = "Audio uploaded successfully"
                    )
                    _errorState.value = null
                } else {
                    _errorState.value = result.exceptionOrNull()?.message ?: "Audio upload failed"
                }
            } catch (e: Exception) {
                _errorState.value = "Error uploading audio: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Sync pending uploads.
     */
    fun syncPending() {
        viewModelScope.launch {
            try {
                _syncStatus.value = SyncStatus.SYNCING
                _errorState.value = null

                // Get pending events
                val pendingEvents = database.trialEventDao().getUnsyncedTrials(100)
                if (pendingEvents.isEmpty()) {
                    _syncStatus.value = SyncStatus.IDLE
                    return@launch
                }

                // Group by session and upload
                val groupedBySession = pendingEvents.groupBy { it.sessionID }
                var successCount = 0

                for ((sessionId, events) in groupedBySession) {
                    val session = database.sessionDao().getSession(sessionId)
                    if (session == null) continue

                    val result = trialService.uploadSession(
                        sessionId = sessionId,
                        childId = session.childID,
                        trials = events
                    )

                    if (result.isSuccess) {
                        database.trialEventDao().markSynced(events.map { it.eventID })
                        successCount++
                    }
                }

                _uploadResult.value = UploadResult(
                    success = successCount == groupedBySession.size,
                    message = "Synced $successCount/${groupedBySession.size} sessions"
                )

                _syncStatus.value = if (successCount == groupedBySession.size) SyncStatus.SUCCESS else SyncStatus.PARTIAL
                _errorState.value = null
            } catch (e: Exception) {
                _errorState.value = "Error syncing: ${e.message}"
                _syncStatus.value = SyncStatus.FAILED
            }
        }
    }

    /**
     * Check sync status with backend.
     */
    fun checkSyncStatus() {
        viewModelScope.launch {
            try {
                val result = trialService.getSyncStatus()
                if (result.isSuccess) {
                    _syncStatus.value = result.getOrNull() ?: SyncStatus.IDLE
                    _errorState.value = null
                } else {
                    _errorState.value = "Failed to check sync status"
                }
            } catch (e: Exception) {
                _errorState.value = "Error checking sync status: ${e.message}"
            }
        }
    }
}

// MARK: - Data Classes

data class UploadResult(
    val success: Boolean,
    val message: String
)

enum class SyncStatus {
    IDLE,
    SYNCING,
    UPLOADING,
    SUCCESS,
    PARTIAL,
    FAILED
}
