package com.praxia.child.audio

import android.content.Context
import android.media.AudioManager
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCancellableCoroutine

/**
 * Text-to-Speech Manager for AAC board word pronunciation.
 *
 * Handles:
 * - TTS engine initialization
 * - Word pronunciation with proper speech rate
 * - Callbacks for TTS completion
 * - Resource cleanup on app exit
 */
class TextToSpeechManager(private val context: Context) {

    private var tts: TextToSpeech? = null
    private var isInitialized = false
    private val listeners = mutableListOf<TextToSpeechListener>()

    init {
        initializeTTS()
    }

    /**
     * Initialize TextToSpeech engine asynchronously.
     */
    private fun initializeTTS() {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                try {
                    // Set language to English
                    val result = tts?.setLanguage(Locale.US)
                    if (result == TextToSpeech.LANG_AVAILABLE) {
                        // Set speech rate to 0.9x for clarity
                        tts?.setSpeechRate(0.9f)
                        // Set pitch to normal
                        tts?.setPitch(1.0f)
                        isInitialized = true
                        notifyInitialized()
                        Log.d(TAG, "TextToSpeech initialized successfully")
                    } else if (result == TextToSpeech.LANG_MISSING_DATA ||
                               result == TextToSpeech.LANG_NOT_SUPPORTED) {
                        Log.w(TAG, "Language not available for TTS")
                        isInitialized = false
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error initializing TTS: ${e.message}")
                    isInitialized = false
                }
            } else {
                Log.e(TAG, "TextToSpeech initialization failed with status: $status")
                isInitialized = false
            }
        }
    }

    /**
     * Speak a word or phrase synchronously.
     *
     * @param word The word/phrase to speak
     * @param onCompletion Callback when speech completes (success/failure)
     */
    fun speak(word: String, onCompletion: (success: Boolean) -> Unit) {
        if (!isInitialized || tts == null) {
            Log.w(TAG, "TTS not initialized, cannot speak: $word")
            onCompletion(false)
            return
        }

        try {
            val utteranceId = UUID.randomUUID().toString()
            val params = mutableMapOf<String, String>()
            params[TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID] = utteranceId
            params[TextToSpeech.Engine.KEY_PARAM_STREAM] =
                AudioManager.STREAM_NOTIFICATION.toString()

            // Set up utterance progress listener
            tts!!.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) {
                    notifyOnSpeechStart(word)
                }

                override fun onDone(utteranceId: String?) {
                    onCompletion(true)
                    notifyOnSpeechDone(word)
                }

                @Deprecated("Deprecated in API level 21")
                override fun onError(utteranceId: String?) {
                    onCompletion(false)
                    notifyOnSpeechError(word)
                    Log.e(TAG, "TTS error for utterance: $utteranceId")
                }

                override fun onError(utteranceId: String?, errorCode: Int) {
                    onCompletion(false)
                    notifyOnSpeechError(word)
                    Log.e(TAG, "TTS error $errorCode for utterance: $utteranceId")
                }
            })

            // Speak the word
            tts?.speak(word, TextToSpeech.QUEUE_FLUSH, params)
            Log.d(TAG, "Speaking: $word")
        } catch (e: Exception) {
            Log.e(TAG, "Error speaking '$word': ${e.message}")
            onCompletion(false)
        }
    }

    /**
     * Speak a word asynchronously and suspend until completion.
     */
    suspend fun speakSuspend(word: String): Boolean {
        return suspendCancellableCoroutine { continuation ->
            speak(word) { success ->
                continuation.resume(success)
            }
        }
    }

    /**
     * Stop current speech and clear queue.
     */
    fun stop() {
        try {
            tts?.stop()
            tts?.setOnUtteranceProgressListener(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping TTS: ${e.message}")
        }
    }

    /**
     * Shutdown TTS engine and release resources.
     * Call from Activity.onDestroy() or Fragment.onDestroyView()
     */
    fun shutdown() {
        try {
            tts?.stop()
            tts?.shutdown()
            tts = null
            isInitialized = false
            listeners.clear()
            Log.d(TAG, "TextToSpeech shut down")
        } catch (e: Exception) {
            Log.e(TAG, "Error shutting down TTS: ${e.message}")
        }
    }

    /**
     * Add listener for TTS events.
     */
    fun addListener(listener: TextToSpeechListener) {
        listeners.add(listener)
    }

    /**
     * Remove listener.
     */
    fun removeListener(listener: TextToSpeechListener) {
        listeners.remove(listener)
    }

    /**
     * Check if TTS is ready to speak.
     */
    fun isReady(): Boolean = isInitialized && tts != null

    // Private notification methods
    private fun notifyInitialized() {
        listeners.forEach { it.onTTSInitialized() }
    }

    private fun notifyOnSpeechStart(word: String) {
        listeners.forEach { it.onSpeechStart(word) }
    }

    private fun notifyOnSpeechDone(word: String) {
        listeners.forEach { it.onSpeechDone(word) }
    }

    private fun notifyOnSpeechError(word: String) {
        listeners.forEach { it.onSpeechError(word) }
    }

    companion object {
        private const val TAG = "TextToSpeechManager"

        // Global instance (singleton pattern)
        private var instance: TextToSpeechManager? = null

        /**
         * Get or create TextToSpeechManager singleton instance.
         */
        fun getInstance(context: Context): TextToSpeechManager {
            return instance ?: synchronized(this) {
                instance ?: TextToSpeechManager(context.applicationContext)
                    .also { instance = it }
            }
        }
    }
}

/**
 * Listener interface for TextToSpeech events.
 */
interface TextToSpeechListener {
    fun onTTSInitialized() {}
    fun onSpeechStart(word: String) {}
    fun onSpeechDone(word: String) {}
    fun onSpeechError(word: String) {}
}
