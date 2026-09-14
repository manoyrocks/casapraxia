# Web Developer Brief: Praxia Progressive Web App (PWA)

**Project:** Praxia — Clinical speech therapy platform for non-verbal children with CAS  
**Platform:** Progressive Web App (React + Next.js + TypeScript)  
**Duration:** 3-4 weeks (target Oct 15, 2026)  
**Responsive Design:** 7-inch (600px), 10-inch (800px), plus phones (320-480px), desktops (1024px+)  
**Target Devices:** Chromebooks, tablets, laptops, low-end Android devices

---

## Executive Summary

**Reuse:** gRPC backend (already production-ready)  
**Build:** React + Next.js PWA + Web Audio API + gRPC-Web  
**Feature Parity:** 90% with iOS (simplified audio, full coaching/analytics)  
**Latency Target:** <100-150ms (Web Audio API acceptable for web)  
**Offline-First:** Service Workers + IndexedDB for offline trial recording  
**Constraint Compliance:** All 19 inviolable constraints verified

---

## Architecture Overview

```
┌───────────────────────────────────────────────────┐
│ Praxia PWA (React + Next.js + TypeScript)         │
├───────────────────────────────────────────────────┤
│ ┌─ Web Audio API (microphone capture)            │
│ ├─ Tier-1 DSP (WebAssembly or Web Audio nodes)   │
│ ├─ IndexedDB (encrypted local storage)           │
│ ├─ Trial Engine (state machine, cue hierarchy)   │
│ ├─ gRPC-Web Client (protobuf + gRPC-Web proxy)   │
│ ├─ Service Worker (offline, sync, push)          │
│ └─ UI Layer (React components, responsive CSS)   │
└───────────────────────────────────────────────────┘
                          │
              gRPC-Web (HTTP/2 at :8080)
                          │
            ┌─────────────▼──────────────┐
            │ Backend (Go)               │
            │ + gRPC-Web Proxy           │
            │ PostgreSQL + NATS          │
            └────────────────────────────┘
```

---

## Detailed Requirements

### 1. Responsive Design (CRITICAL)

**Screen Sizes:**
- **Phone (5-6"):** 320px - 480px width (portrait)
- **Phablet (5.5-6.5"):** 480px - 600px width (portrait)
- **Tablet 7":** 600px - 800px width (portrait + landscape)
- **Tablet 10":** 800px - 1024px width (portrait + landscape)
- **Laptop/Desktop:** 1024px+ width

**CSS Breakpoints (Mobile-First):**
```css
/* Base: mobile (320px) */
.play-surface { width: 100%; }

/* Tablet 7" and up */
@media (min-width: 600px) {
    .play-surface { display: grid; grid-template-columns: 1fr 1fr; }
}

/* Tablet 10" and up */
@media (min-width: 800px) {
    .play-surface { display: grid; grid-template-columns: 1fr 1fr 1fr; }
    .parent-panel { width: 280px; }
}

/* Desktop and up */
@media (min-width: 1024px) {
    .container { display: flex; gap: 1rem; }
    .parent-panel { position: sticky; top: 0; }
}
```

**Tailwind CSS + Custom Theme:**
```jsx
// tailwind.config.ts
export default {
    theme: {
        screens: {
            sm: '320px',   // Phone
            md: '600px',   // Tablet 7"
            lg: '800px',   // Tablet 10"
            xl: '1024px',  // Desktop
        },
        colors: {
            cream: '#FFF8F0',
            sage: '#9DB9A3',
            teal: '#4A9B8E',
            warmAmber: '#D4A574',
        },
    },
}
```

**Touch Targets:**
- Minimum: 44px x 44px (mobile)
- Recommended: 48-64px (tablets)
- Verify with responsive inspector at 7" (600px) and 10" (800px)

### 2. Web Audio API & Tier-1 DSP

**Requirement:** Tier-1 signals via Web Audio API (simplified vs. iOS)

**Implementation:**
1. **Web Audio Capture:**
   ```typescript
   class AudioCapture {
       private audioContext: AudioContext;
       private mediaStream: MediaStream;
       
       async start(): Promise<void> {
           this.mediaStream = await navigator.mediaDevices.getUserMedia({
               audio: { echoCancellation: false, noiseSuppression: false }
           });
           const source = this.audioContext.createMediaStreamSource(this.mediaStream);
           const processor = this.audioContext.createScriptProcessor(2048, 1, 1);
           source.connect(processor);
       }
       
       onAudioProcess(data: AudioProcessingEvent): void {
           const pcm = data.inputBuffer.getChannelData(0);
           this.computeTier1Signals(pcm);
       }
   }
   ```

2. **Tier-1 Signals (Simplified):**
   - Vocalization detected (voice activity detection)
   - Duration (seconds)
   - Loudness/energy (dB estimate)
   - Pitch presence (bool, basic spectral analysis)
   - Note: Full latency/syllable counting deferred to Web Audio v2

3. **Web Audio Nodes:**
   - AnalyserNode (FFT for pitch detection)
   - GainNode (volume measurement)
   - ScriptProcessorNode (custom DSP)

**Fallback for Low-End Devices:**
```typescript
if (!navigator.mediaDevices?.getUserMedia) {
    // Show message: "Audio not supported on this browser"
    // Allow text-based trial entry as fallback
}
```

### 3. Local Data Persistence (IndexedDB)

**IndexedDB Stores:**
- `sessions` — Session metadata (id, childId, startTime, trialCount)
- `trials` — Trial events (trialId, sessionId, targetId, score, timestamp)
- `audio_blobs` — Recorded audio clips (trialId, blob, SHA256)
- `config` — Cached program/target config

**Encryption:**
- Use TweetNaCl.js or libsodium.js for local encryption
- Store encrypted at rest in IndexedDB
- Decrypt on read for session processing

```typescript
class TrialStore {
    private db: IDBDatabase;
    
    async recordTrial(trial: Trial): Promise<void> {
        const encrypted = await encrypt(trial);
        const tx = this.db.transaction(['trials'], 'readwrite');
        await tx.objectStore('trials').add(encrypted);
    }
    
    async uploadPendingTrials(): Promise<UploadResult> {
        const pending = await this.db.transaction(['trials'], 'readonly')
            .objectStore('trials')
            .getAll();
        
        return await grpcClient.uploadSession({
            trials: pending.map(decrypt),
        });
    }
}
```

### 4. Trial Engine (Port from iOS)

**Reuse Logic:**
- L0-L5 cue hierarchy
- 3-up/2-down advancement
- Safety stop <40%
- Silent back-off
- Aversion detection

```typescript
class TrialEngine {
    recordTrial(trial: Trial, score: ScoreValue): TrialResult
    getTargetState(targetId: string): TargetState
    backOffLevel(targetId: string): boolean
    advanceLevel(targetId: string): boolean
    checkSafetyStop(targetId: string): boolean
}
```

### 5. gRPC-Web Client Integration

**Backend Modification (One-Time):**
Backend already has gRPC services. Need gRPC-Web proxy:
```bash
# Run alongside Go server
grpcwebproxy --backend_addr=localhost:50051 \
             --run_tls_server=false \
             --allow_all_origins \
             --server_http_debug_port=8080
```

**Dependencies:**
```json
{
    "@grpc-web/grpc-web": "^1.4.0",
    "@grpc-web/improbable-grpc-web": "^0.16.0",
    "google-protobuf": "^3.22.0"
}
```

**Protobuf Generation:**
```bash
protoc -I=../backend/protos \
       --js_out=import_style=commonjs:client/src/generated \
       --grpc-web_out=import_style=commonjs,mode=grpcwebtext:client/src/generated \
       ../backend/protos/*.proto
```

**TypeScript gRPC-Web Client:**
```typescript
import { TrialServiceClient } from './generated/trial_grpc_web_pb';
import { UploadSessionRequest } from './generated/trial_pb';

class BackendClient {
    private trialService: TrialServiceClient;
    
    async uploadSession(req: UploadSessionRequest): Promise<UploadSessionResponse> {
        return new Promise((resolve, reject) => {
            this.trialService.uploadSession(req, {}, (err, response) => {
                if (err) reject(err);
                else resolve(response!);
            });
        });
    }
}
```

### 6. UI Layer (React Components, Responsive)

**Three Core Surfaces:**

#### Play Surface (Child Practice)
- Waveform visualization (Canvas, responsive)
- Target word (large, readable, scale with screen)
- Parent scoring buttons (≥48px, stacked on mobile)
- Session timer + trial counter
- Responsive grid: 1 col (mobile) → 2 col (7") → 3 col (10")

```jsx
export function PlaySurface() {
    const screenSize = useScreenSize();
    
    return (
        <div className={`
            grid gap-4
            sm:grid-cols-1
            md:grid-cols-2
            lg:grid-cols-3
        `}>
            <Waveform audio={audio} />
            <TargetDisplay target={currentTarget} />
            <ParentScoreButtons onScore={handleScore} />
        </div>
    );
}
```

#### Talk Surface (AAC Board)
- Text-to-speech buttons
- Grid layout: 2x3 (phone), 3x4 (7"), 4x5 (10")
- Touch targets: 48-64px based on screen

```jsx
function AACBoard({ words, gridCols }) {
    return (
        <div className={`grid gap-2 grid-cols-${gridCols}`}>
            {words.map(word => (
                <button
                    onClick={() => speak(word)}
                    className="h-16 sm:h-20 md:h-24 lg:h-32 font-bold"
                >
                    {word}
                </button>
            ))}
        </div>
    );
}
```

#### Collection Surface (Progress Tracking)
- Target word list + cue levels
- Session history (scrollable table)
- Weekly progress chart (Chart.js or Recharts)
- Parent coaching messages

#### Parent Panel (Always Visible or Toggle)
- Desktop (≥1024px): Sticky sidebar on right
- Tablet (800-1023px): Toggle button → overlay
- Mobile (<800px): Full-screen toggle

**Theme Support:**
```typescript
function useTheme() {
    const [isDark, setIsDark] = useState(
        window.matchMedia('(prefers-color-scheme: dark)').matches
    );
    
    return isDark ? darkTheme : lightTheme;
}
```

### 7. Service Worker (Offline Support)

**Offline Recording:**
```typescript
// service-worker.ts
self.addEventListener('message', (event) => {
    if (event.data.type === 'RECORD_TRIAL') {
        // Store trial in IndexedDB
        db.trials.add(event.data.trial);
    }
});

// Periodically attempt sync
self.addEventListener('sync', async (event) => {
    if (event.tag === 'sync-trials') {
        const pending = await db.trials.getAll();
        try {
            await grpcClient.uploadSession(pending);
            await db.trials.clear();
        } catch (e) {
            // Retry next sync
        }
    }
});
```

### 8. Constraint Compliance (19 Inviolable)

**Verify All:**
```typescript
const CONSTRAINTS = {
    C1: () => trialEngine.score.rater === 'parent', // No machine verdict
    C2: () => !ui.hasAnyRedElements(), // No failure states
    C3: () => trialEngine.backOffSilent, // Silent back-off
    C4: () => trialEngine.safetyStopAt40Pct, // Safety stop <40%
    C5: () => audioLatency < 150, // Latency <150ms (web acceptable)
    // ... C6-C19
};
```

### 9. Testing Requirements

**Unit Tests (Jest + React Testing Library):**
- TrialEngine: L0-L5, 3-up/2-down, safety stop
- AudioCapture: VAD, pitch detection, noise floor
- TrialStore: IndexedDB persistence, encryption
- gRPC Client: Offline retry, batch upload

**E2E Tests (Playwright):**
- 10-trial session: Start → Capture → Score → View History
- Offline mode: Record trials, sync when online
- Responsive layout: Test at 7" (600px) and 10" (800px) viewports

**Performance Benchmarks:**
- Waveform rendering: <16ms per frame
- Trial storage: <100ms per write
- gRPC upload: <2s for 10 trials
- Page load: <2s on 4G network

### 10. Deliverables (By Oct 15)

- [ ] `web/` directory with Next.js project
- [ ] `AudioCapture.ts` (200 LOC, Web Audio API)
- [ ] `TrialEngine.ts` (250 LOC, ported from iOS)
- [ ] `TrialStore.ts` (200 LOC, IndexedDB + encryption)
- [ ] React Components (600 LOC):
  - `PlaySurface.tsx` (responsive waveform + scoring)
  - `TalkSurface.tsx` (AAC grid, responsive)
  - `CollectionSurface.tsx` (progress tracking)
  - `ParentPanel.tsx` (coaching, analytics)
- [ ] `BackendClient.ts` (gRPC-Web, 150 LOC)
- [ ] `service-worker.ts` (offline sync, 150 LOC)
- [ ] `next.config.ts` + `tailwind.config.ts` (responsive setup)
- [ ] 25+ Jest unit tests + 5 Playwright E2E tests
- [ ] `WEB.md` (100 LOC: development, build, deployment)
- [ ] `COMPLIANCE-AUDIT-WEB.md` (constraint verification)
- [ ] PWA built and hosted (vercel.com or self-hosted)

### 11. Build & Deployment

**Local Development:**
```bash
cd web
npm install
npm run dev                    # http://localhost:3000
```

**Testing:**
```bash
npm test                       # Jest unit tests
npm run test:e2e              # Playwright E2E at 600px, 800px, 1024px
npm run test:responsive       # Chrome DevTools responsive mode
```

**Production Build:**
```bash
npm run build
npm start                      # Production server
npm run export                # Static export for CDN
```

**Docker Container:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install && npm run build
CMD ["npm", "start"]
```

**Deployment Options:**
- Vercel (automatic PWA optimizations)
- Self-hosted Docker (backend + web on same server)
- Cloudflare Pages (edge deployment)

### 12. PWA Features

**Web App Manifest:**
```json
{
    "name": "Praxia Speech Therapy",
    "short_name": "Praxia",
    "start_url": "/",
    "display": "standalone",
    "background_color": "#FFF8F0",
    "theme_color": "#4A9B8E",
    "icons": [
        { "src": "icon-192.png", "sizes": "192x192", "type": "image/png" },
        { "src": "icon-512.png", "sizes": "512x512", "type": "image/png" }
    ]
}
```

**Service Worker Lifecycle:**
- Install: Cache shell + static assets
- Activate: Clean old caches
- Fetch: Serve from cache, fallback to network
- Sync: Upload pending trials when online
- Push: Coaching notifications (optional)

---

## Key Decisions

✅ **React + Next.js** — Server-side rendering, optimized performance  
✅ **TypeScript** — Type safety, better IDE support  
✅ **Tailwind CSS** — Responsive design utilities, mobile-first  
✅ **gRPC-Web** — Same backend, web-friendly protocol  
✅ **IndexedDB** — Offline data persistence, better than localStorage  
✅ **Service Workers** — True offline support, background sync  
✅ **Mobile-First CSS** — Responsive across 320px-1920px  

---

## Success Criteria

- ✅ Responsive at 5", 7", 10" tablets + phones + desktop
- ✅ Touch targets ≥48px (≥64px recommended)
- ✅ All 19 constraints verified in code
- ✅ 25+ unit tests passing
- ✅ 5+ E2E tests at multiple viewport sizes
- ✅ Offline trial recording + background sync
- ✅ gRPC-Web integration with production backend
- ✅ <2s page load on 4G network
- ✅ PWA installable on all browsers (manifest + icons)
- ✅ COMPLIANCE-AUDIT-WEB.md signed off

---

## Timeline

| Week | Milestone | Deliverables |
|------|-----------|--------------|
| Week 1 | Audio + Setup | Web Audio API, IndexedDB, Next.js scaffolding |
| Week 2 | UI + Engine | PlaySurface, TalkSurface, Collection, TrialEngine |
| Week 3 | Integration | gRPC-Web client, Service Worker, offline sync |
| Week 4 | Polish | Responsive testing (7", 10"), 25+ tests, PWA manifest |

---

## Responsive Design Validation

**Test at These Breakpoints:**
```bash
# Chrome DevTools:
# - iPhone SE (375px, portrait)
# - iPad 7" (600px, portrait + landscape)
# - iPad 10" (800px, portrait + landscape)
# - MacBook Pro 13" (1440px)
# - External monitor (2560px)

# Playwright:
page.setViewportSize({ width: 600, height: 800 }); // 7" tablet
page.setViewportSize({ width: 800, height: 1024 }); // 10" tablet
```

---

**Ready to build. Responsive design priority: 7-inch and 10-inch tablets + phone support + desktop.**

