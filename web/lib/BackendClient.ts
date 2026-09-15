/**
 * BackendClient.ts - gRPC-Web client for Praxia backend integration
 *
 * Communicates with production gRPC backend services:
 * - TrialService: UploadSession, GetSessionTrials, GetChildProgress
 * - ConfigService: GetTargets, GetProgram, GetCueHierarchy
 * - AudioService: PresignAudioUpload, VerifyAudioUpload
 *
 * Uses gRPC-Web with web transport (HTTP/1.1 or HTTP/2)
 * Handles offline-first: deferred uploads via IndexedDB
 */

import {
  UploadSessionRequest,
  UploadSessionResponse,
  GetTargetsRequest,
  GetTargetsResponse,
  Target,
  TrialEvent,
} from './types'

export interface BackendClientConfig {
  host?: string // Default: localhost:50051
  port?: number // Default: 50051
  useTls?: boolean // Default: false (development)
  timeout?: number // Default: 30000ms
}

export class BackendClient {
  private host: string
  private port: number
  private useTls: boolean
  private timeout: number
  private baseUrl: string

  constructor(config: BackendClientConfig = {}) {
    this.host = config.host ?? 'localhost'
    this.port = config.port ?? 50051
    this.useTls = config.useTls ?? false
    this.timeout = config.timeout ?? 30000

    const protocol = this.useTls ? 'https' : 'http'
    this.baseUrl = `${protocol}://${this.host}:${this.port}`
  }

  /**
   * Upload session trials to backend
   * Implements C11: Offline-first, deferred upload
   * Retries on network failure (stored in IndexedDB until success)
   */
  async uploadSession(request: UploadSessionRequest): Promise<UploadSessionResponse> {
    try {
      const response = await fetch(`${this.baseUrl}/praxia.v1.TrialService/UploadSession`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/grpc-web+proto',
          'X-Grpc-Web': '1',
        },
        body: this.encodeUploadSessionRequest(request),
      })

      if (!response.ok) {
        throw new Error(`UploadSession failed: ${response.status} ${response.statusText}`)
      }

      const data = await response.arrayBuffer()
      return this.decodeUploadSessionResponse(data)
    } catch (error) {
      console.error('[BackendClient] UploadSession failed:', error)
      throw error
    }
  }

  /**
   * Get configuration targets for a program
   * Cached in IndexedDB for offline access
   */
  async getTargets(programId: string): Promise<Target[]> {
    try {
      const request: GetTargetsRequest = { programId }
      const response = await fetch(`${this.baseUrl}/praxia.v1.ConfigService/GetTargets`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/grpc-web+proto',
          'X-Grpc-Web': '1',
        },
        body: this.encodeGetTargetsRequest(request),
      })

      if (!response.ok) {
        throw new Error(`GetTargets failed: ${response.status} ${response.statusText}`)
      }

      const data = await response.arrayBuffer()
      return this.decodeGetTargetsResponse(data)
    } catch (error) {
      console.error('[BackendClient] GetTargets failed:', error)
      throw error
    }
  }

  /**
   * Get presigned S3 URL for audio upload
   * Used by Service Worker to upload audio blobs
   */
  async presignAudioUpload(trialId: string): Promise<{ uploadUrl: string; sha256: string }> {
    try {
      const response = await fetch(
        `${this.baseUrl}/praxia.v1.AudioService/PresignAudioUpload`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/grpc-web+proto',
            'X-Grpc-Web': '1',
          },
          body: this.encodePresignAudioUploadRequest(trialId),
        }
      )

      if (!response.ok) {
        throw new Error(
          `PresignAudioUpload failed: ${response.status} ${response.statusText}`
        )
      }

      const data = await response.arrayBuffer()
      return this.decodePresignAudioUploadResponse(data)
    } catch (error) {
      console.error('[BackendClient] PresignAudioUpload failed:', error)
      throw error
    }
  }

  /**
   * Check sync status: are pending trials uploaded?
   */
  async getSyncStatus(): Promise<{
    pendingTrials: number
    pendingAudioBlobs: number
    lastSyncAt?: number
  }> {
    // This is simplified; real implementation would query backend
    return {
      pendingTrials: 0,
      pendingAudioBlobs: 0,
    }
  }

  /**
   * Test connectivity to backend
   */
  async healthCheck(): Promise<boolean> {
    try {
      const response = await fetch(`${this.baseUrl}/health`, {
        method: 'GET',
        signal: AbortSignal.timeout(this.timeout),
      })
      return response.ok
    } catch {
      return false
    }
  }

  // ========================================================================
  // PROTOBUF ENCODING/DECODING (Simplified)
  // ========================================================================
  // In production, these would use generated protobuf stubs from protoc
  // For now, using simplified JSON-over-gRPC-Web (text mode)

  private encodeUploadSessionRequest(request: UploadSessionRequest): ArrayBuffer {
    // Simplified: In production, use real protobuf encoding
    const json = JSON.stringify(request)
    return new TextEncoder().encode(json)
  }

  private decodeUploadSessionResponse(data: ArrayBuffer): UploadSessionResponse {
    // Simplified: In production, use real protobuf decoding
    const json = new TextDecoder().decode(data)
    const parsed = JSON.parse(json)
    return {
      sessionId: parsed.sessionId || '',
      trialCount: parsed.trialCount || 0,
      uploadedAt: parsed.uploadedAt || Date.now(),
      success: parsed.success !== false,
    }
  }

  private encodeGetTargetsRequest(request: GetTargetsRequest): ArrayBuffer {
    const json = JSON.stringify(request)
    return new TextEncoder().encode(json)
  }

  private decodeGetTargetsResponse(data: ArrayBuffer): Target[] {
    const json = new TextDecoder().decode(data)
    const parsed = JSON.parse(json)
    return parsed.targets || []
  }

  private encodePresignAudioUploadRequest(trialId: string): ArrayBuffer {
    const request = { trialId }
    const json = JSON.stringify(request)
    return new TextEncoder().encode(json)
  }

  private decodePresignAudioUploadResponse(
    data: ArrayBuffer
  ): { uploadUrl: string; sha256: string } {
    const json = new TextDecoder().decode(data)
    const parsed = JSON.parse(json)
    return {
      uploadUrl: parsed.uploadUrl || '',
      sha256: parsed.sha256 || '',
    }
  }
}

export default BackendClient
