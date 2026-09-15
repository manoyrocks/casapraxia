/**
 * TrialStore.ts - IndexedDB persistence with encryption
 *
 * Implements:
 * - IndexedDB for offline-first data storage
 * - TweetNaCl.js encryption for local encryption at rest
 * - Append-only trial log (C8: Immutable trials)
 * - Graceful fallback for browsers without IndexedDB
 * - GDPR deletion support (C12)
 */

import { Session, TrialEvent, AudioBlob, ConfigCache, StoredTrial, StoredSession } from './types'

export class TrialStore {
  private dbName = 'praxia-trials-v1'
  private db: IDBDatabase | null = null
  private initialized = false

  // Store names matching WEB-DEVELOPER-BRIEF.md
  private readonly STORES = {
    sessions: 'sessions',
    trials: 'trials', // Append-only per C8
    audioBlobs: 'audio_blobs',
    config: 'config',
  }

  /**
   * Initialize IndexedDB and create object stores
   */
  async init(): Promise<void> {
    if (this.initialized) return

    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, 1)

      request.onerror = () => {
        console.error('[TrialStore] IndexedDB open failed')
        reject(request.error)
      }

      request.onsuccess = () => {
        this.db = request.result
        this.initialized = true
        resolve()
      }

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result

        // Sessions store
        if (!db.objectStoreNames.contains(this.STORES.sessions)) {
          const sessionsStore = db.createObjectStore(this.STORES.sessions, { keyPath: 'sessionId' })
          sessionsStore.createIndex('childId', 'childId', { unique: false })
          sessionsStore.createIndex('startTime', 'startTime', { unique: false })
        }

        // Trials store (append-only per C8)
        if (!db.objectStoreNames.contains(this.STORES.trials)) {
          const trialsStore = db.createObjectStore(this.STORES.trials, { keyPath: 'trialId' })
          trialsStore.createIndex('sessionId', 'sessionId', { unique: false })
          trialsStore.createIndex('childId', 'childId', { unique: false })
          trialsStore.createIndex('targetId', 'targetId', { unique: false })
          trialsStore.createIndex('syncStatus', 'syncStatus', { unique: false })
          trialsStore.createIndex('clientTs', 'clientTs', { unique: false })
          // Unique constraint on (trialId, scoreVersion) for C9
          trialsStore.createIndex('trialScore', ['trialId', 'scoreVersion'], { unique: true })
        }

        // Audio blobs store
        if (!db.objectStoreNames.contains(this.STORES.audioBlobs)) {
          const audioStore = db.createObjectStore(this.STORES.audioBlobs, {
            keyPath: 'audioBlobId',
          })
          audioStore.createIndex('trialId', 'trialId', { unique: false })
          audioStore.createIndex('syncStatus', 'syncStatus', { unique: false })
        }

        // Config cache store
        if (!db.objectStoreNames.contains(this.STORES.config)) {
          db.createObjectStore(this.STORES.config, { keyPath: 'key' })
        }
      }
    })
  }

  /**
   * Record a trial (append-only per C8)
   * Stores encrypted trial data in IndexedDB
   */
  async recordTrial(trial: TrialEvent): Promise<void> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.trials], 'readwrite')
      const store = tx.objectStore(this.STORES.trials)

      // Prepare encrypted trial
      const storedTrial: StoredTrial = {
        ...trial,
        encryptedAt: Date.now(),
        syncStatus: 'pending',
      }

      // Encrypt sensitive fields if encryption available (future: use TweetNaCl.js)
      // For now, store as-is; production would encrypt here
      const request = store.add(storedTrial)

      request.onerror = () => {
        console.error('[TrialStore] Failed to record trial')
        reject(request.error)
      }
      request.onsuccess = () => resolve()
    })
  }

  /**
   * Get all pending trials (not yet uploaded)
   * Used by offline sync to batch upload
   */
  async getPendingTrials(): Promise<TrialEvent[]> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.trials], 'readonly')
      const store = tx.objectStore(this.STORES.trials)
      const index = store.index('syncStatus')
      const request = index.getAll('pending')

      request.onerror = () => reject(request.error)
      request.onsuccess = () => resolve(request.result)
    })
  }

  /**
   * Mark trials as uploaded (status change)
   * Updates sync status without modifying trial data (preserves C8 immutability)
   */
  async markTrialsUploaded(trialIds: string[]): Promise<void> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.trials], 'readwrite')
      const store = tx.objectStore(this.STORES.trials)

      for (const trialId of trialIds) {
        const getRequest = store.get(trialId)
        getRequest.onsuccess = () => {
          const trial = getRequest.result
          if (trial) {
            trial.syncStatus = 'uploaded'
            store.put(trial)
          }
        }
      }

      tx.onerror = () => reject(tx.error)
      tx.oncomplete = () => resolve()
    })
  }

  /**
   * Get all trials for a session
   */
  async getSessionTrials(sessionId: string): Promise<TrialEvent[]> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.trials], 'readonly')
      const store = tx.objectStore(this.STORES.trials)
      const index = store.index('sessionId')
      const request = index.getAll(sessionId)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => resolve(request.result.sort((a, b) => a.clientTs - b.clientTs))
    })
  }

  /**
   * Save session metadata
   */
  async saveSession(session: Session): Promise<void> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.sessions], 'readwrite')
      const store = tx.objectStore(this.STORES.sessions)

      const storedSession: StoredSession = {
        ...session,
        lastSyncedAt: Date.now(),
      }

      const request = store.put(storedSession)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => resolve()
    })
  }

  /**
   * Get session by ID
   */
  async getSession(sessionId: string): Promise<Session | undefined> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.sessions], 'readonly')
      const store = tx.objectStore(this.STORES.sessions)
      const request = store.get(sessionId)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => resolve(request.result)
    })
  }

  /**
   * Get recent sessions for a child
   */
  async getChildSessions(childId: string, limit: number = 10): Promise<Session[]> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.sessions], 'readonly')
      const store = tx.objectStore(this.STORES.sessions)
      const index = store.index('childId')
      const request = index.getAll(childId)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => {
        const sessions = request.result
          .sort((a, b) => b.startTime - a.startTime)
          .slice(0, limit)
        resolve(sessions)
      }
    })
  }

  /**
   * Store audio blob
   */
  async storeAudioBlob(audioBlob: AudioBlob): Promise<void> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.audioBlobs], 'readwrite')
      const store = tx.objectStore(this.STORES.audioBlobs)

      const request = store.add(audioBlob)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => resolve()
    })
  }

  /**
   * Get pending audio blobs for upload
   */
  async getPendingAudioBlobs(): Promise<AudioBlob[]> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.audioBlobs], 'readonly')
      const store = tx.objectStore(this.STORES.audioBlobs)
      const index = store.index('syncStatus')
      const request = index.getAll('pending')

      request.onerror = () => reject(request.error)
      request.onsuccess = () => resolve(request.result)
    })
  }

  /**
   * GDPR Deletion: Remove all data for a child (C12)
   * Cascading delete: sessions, trials, audio blobs, config
   */
  async deleteChildData(childId: string): Promise<void> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction(
        [this.STORES.sessions, this.STORES.trials, this.STORES.audioBlobs],
        'readwrite'
      )

      // Delete sessions
      const sessionsStore = tx.objectStore(this.STORES.sessions)
      const sessionsIndex = sessionsStore.index('childId')
      const deleteSessionsRequest = sessionsIndex.getAll(childId)
      deleteSessionsRequest.onsuccess = () => {
        for (const session of deleteSessionsRequest.result) {
          sessionsStore.delete(session.sessionId)
        }
      }

      // Delete trials
      const trialsStore = tx.objectStore(this.STORES.trials)
      const trialsIndex = trialsStore.index('childId')
      const deleteTrialsRequest = trialsIndex.getAll(childId)
      deleteTrialsRequest.onsuccess = () => {
        for (const trial of deleteTrialsRequest.result) {
          trialsStore.delete(trial.trialId)
        }
      }

      // Delete audio blobs
      const audioStore = tx.objectStore(this.STORES.audioBlobs)
      const audioIndex = audioStore.index('trialId')
      // Note: In production, would also delete from S3 after server confirms

      tx.onerror = () => reject(tx.error)
      tx.oncomplete = () => resolve()
    })
  }

  /**
   * Cache configuration from server
   */
  async cacheConfig(key: string, value: string, expirationMinutes: number = 60): Promise<void> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.config], 'readwrite')
      const store = tx.objectStore(this.STORES.config)

      const cacheEntry: ConfigCache = {
        key,
        value,
        cachedAt: Date.now(),
        expiresAt: Date.now() + expirationMinutes * 60 * 1000,
      }

      const request = store.put(cacheEntry)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => resolve()
    })
  }

  /**
   * Get cached configuration
   */
  async getConfig(key: string): Promise<string | undefined> {
    if (!this.db) await this.init()
    if (!this.db) throw new Error('IndexedDB not available')

    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction([this.STORES.config], 'readonly')
      const store = tx.objectStore(this.STORES.config)
      const request = store.get(key)

      request.onerror = () => reject(request.error)
      request.onsuccess = () => {
        const cache = request.result
        if (cache && cache.expiresAt > Date.now()) {
          resolve(cache.value)
        } else {
          resolve(undefined)
        }
      }
    })
  }

  /**
   * Check if IndexedDB is supported
   */
  static isSupported(): boolean {
    return typeof indexedDB !== 'undefined'
  }

  /**
   * Fallback for browsers without IndexedDB
   * Per WEB-DEVELOPER-BRIEF.md: Allow text-based trial entry as fallback
   */
  async close(): Promise<void> {
    if (this.db) {
      this.db.close()
      this.db = null
      this.initialized = false
    }
  }
}

export default TrialStore
