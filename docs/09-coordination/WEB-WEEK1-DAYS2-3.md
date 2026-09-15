# Web Developer: Week 1 Days 2-3 (Sept 16-17, 2026)

**Session:** Web Developer (React + Next.js PWA)  
**Timeline:** Sept 16-17, 2026 (Days 2-3 of Week 1)  
**Target Completion:** TalkSurface, CollectionSurface, ParentPanel components + responsive verification

---

## 📋 Day 2-3 Task Breakdown (10 hours)

### 1️⃣ TalkSurface.tsx (150 LOC, 6 hours, Days 2-3)

**Location:** `web/components/TalkSurface.tsx`

**Purpose:** AAC (Augmentative & Alternative Communication) board with text-to-speech synthesis

**Responsive Grid Requirements:**
```
- sm (320px): 2x3 grid (6 words) - stacked for small phones
- md (600px, 7" tablet): 3x4 grid (12 words) - 2 columns to 3 columns
- lg (800px, 10" tablet): 4x5 grid (20 words) - fills tablet width
- xl (1024px, desktop): 4x5 grid + sticky sidebar ready
```

**Specifications:**
- Word buttons: 48-64px height (touch target, C18 compliance)
- Colors: Warm therapeutic palette (sage, teal, warmAmber, cream)
- No red failure states (C2 compliance)
- Text-to-speech on click (use Web Speech API or similar)
- Display current word category (e.g., "Requesting", "Social", "Core Vocabulary")
- Highlight recently used words

**Implementation Pattern (Follow PlaySurface):**

```typescript
// web/components/TalkSurface.tsx
'use client'

import React, { useState, useEffect } from 'react'
import { Target } from '@/lib/types'

interface TalkSurfaceProps {
  currentTargets: Target[] // 6-20 words depending on viewport
  onWordSelect: (word: string) => void
  isRecording: boolean
}

export default function TalkSurface({
  currentTargets,
  onWordSelect,
  isRecording,
}: TalkSurfaceProps) {
  // Grid responsive: sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4
  // Each cell: aspect-square, rounded-lg, touch-friendly
  
  const handleSpeakWord = (word: string) => {
    // Use Web Speech API: new SpeechSynthesisUtterance(word)
    const utterance = new SpeechSynthesisUtterance(word)
    utterance.rate = 0.8 // Slightly slow for clarity
    window.speechSynthesis.speak(utterance)
    onWordSelect(word)
  }
  
  return (
    <div className="w-full h-full flex flex-col gap-4 p-4 bg-cream">
      <div className="text-xs text-sage uppercase font-semibold mb-2">
        AAC Board - Tap a word to hear it
      </div>
      
      {/* RESPONSIVE GRID: 2x3 → 3x4 → 4x5 */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2 md:gap-3 lg:gap-4">
        {currentTargets.map((target) => (
          <button
            key={target.id}
            onClick={() => handleSpeakWord(target.word)}
            disabled={isRecording}
            className="
              aspect-square flex flex-col items-center justify-center
              bg-teal text-white font-bold rounded-lg
              hover:bg-teal/90 transition-colors
              disabled:opacity-50
              text-sm md:text-base lg:text-lg
              min-h-12 md:min-h-14 lg:min-h-16
            "
          >
            {target.word}
          </button>
        ))}
      </div>
    </div>
  )
}
```

**Testing Requirements:**
- Manual test at 320px, 600px, 800px, 1024px
- Verify grid: 2x3 (320), 3x4 (600), 4x5 (800), 4x5 (1024)
- Verify touch targets: minimum 48px on all sizes
- Speech synthesis works on supported browsers
- No errors in console

**Git Commit:**
```bash
git add web/components/TalkSurface.tsx
git commit -m "feat: Implement TalkSurface with responsive AAC board (2x3 → 3x4 → 4x5 grids)"
git push origin claude/vibrant-thompson-mwwucr
```

---

### 2️⃣ CollectionSurface.tsx (100 LOC, 4 hours, Days 2-3)

**Location:** `web/components/CollectionSurface.tsx`

**Purpose:** Progress tracking view showing target mastery, cue levels, session history

**Responsive Layout:**
```
- sm (320px): Card layout (1 card per row, full width)
- md (600px): Card layout (2 cards per row)
- lg (800px): Table layout (or cards 2-3 per row)
- xl (1024px): Full table with sticky header
```

**Specifications:**
- Each target card shows: word, current cue level (L0-L5), success rate, mastery badge
- Session history: last 5 trials for this target
- Progress bar: visual representation of mastery (0-100%)
- Weekly chart: trials completed per day (Chart.js lite or simple divs)
- No red colors (C2) - use teal/sage/amber for progress indication
- Touch targets: clickable areas ≥48px

**Implementation Pattern:**

```typescript
// web/components/CollectionSurface.tsx
'use client'

import React from 'react'
import { TargetState } from '@/lib/types'

interface CollectionSurfaceProps {
  targets: TargetState[]
  sessionStats: {
    completedTrials: number
    totalTrials: number
    sessionDurationMs: number
  }
}

export default function CollectionSurface({
  targets,
  sessionStats,
}: CollectionSurfaceProps) {
  return (
    <div className="w-full h-full flex flex-col gap-4 p-4 bg-cream overflow-y-auto">
      {/* Session Summary */}
      <div className="bg-white rounded-lg p-4 border border-sage">
        <h2 className="text-lg font-bold text-teal mb-2">Session Progress</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-2 text-sm">
          <div>
            <div className="text-xs text-sage">Trials Completed</div>
            <div className="text-xl font-bold text-teal">
              {sessionStats.completedTrials}/{sessionStats.totalTrials}
            </div>
          </div>
          <div>
            <div className="text-xs text-sage">Session Time</div>
            <div className="text-xl font-bold text-warmAmber">
              {Math.floor(sessionStats.sessionDurationMs / 60000)}m
            </div>
          </div>
        </div>
      </div>

      {/* Target Progress Cards (responsive: 1col → 2col) */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {targets.map((target) => (
          <div
            key={target.targetId}
            className="bg-white rounded-lg p-3 border border-sage hover:shadow-md transition-shadow"
          >
            <div className="flex justify-between items-start mb-2">
              <h3 className="font-bold text-teal text-base">{target.targetWord}</h3>
              <span className="text-xs bg-sage text-white px-2 py-1 rounded">
                L{target.currentCueLevel}
              </span>
            </div>

            {/* Progress Bar */}
            <div className="mb-2">
              <div className="text-xs text-sage mb-1">
                {target.successCount}/{target.attemptCount} correct
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-teal h-2 rounded-full transition-all"
                  style={{
                    width: `${
                      target.attemptCount > 0
                        ? (target.successCount / target.attemptCount) * 100
                        : 0
                    }%`,
                  }}
                />
              </div>
            </div>

            {/* Mastery Badge */}
            {target.successCount >= 5 && (
              <div className="text-center text-sm font-semibold text-warmAmber">
                ⭐ Progressing!
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
```

**Testing Requirements:**
- Manual test at 320px (1 card), 600px (2 cards), 800px+
- Verify progress bars display correctly
- Verify no console errors
- Check responsive layout wraps properly

**Git Commit:**
```bash
git add web/components/CollectionSurface.tsx
git commit -m "feat: Implement CollectionSurface with responsive progress tracking"
git push origin claude/vibrant-thompson-mwwucr
```

---

### 3️⃣ ParentPanel.tsx (100 LOC, 2 hours, Days 2-3)

**Location:** `web/components/ParentPanel.tsx`

**Purpose:** Parent coaching display, session stats, cue tracking (sticky sidebar on desktop, toggle overlay on mobile)

**Responsive Behavior:**
```
- sm/md (< 1024px): Hidden, toggle button shows overlay
- lg (≥ 1024px): Sticky sidebar (fixed width 240px)
```

**Specifications:**
- Session metadata: trial number, current target, cue level
- Coaching messages (generated from TrialEngine state)
- Tier-1 signals display (latency, SNR, syllable count - dev only)
- Session time + estimated remaining time
- No machine verdict shown (C1 compliance)
- Warm colors, readable fonts

**Implementation Pattern:**

```typescript
// web/components/ParentPanel.tsx
'use client'

import React, { useState } from 'react'
import { Session, TargetState, Tier1Signals } from '@/lib/types'

interface ParentPanelProps {
  session: Session
  currentTarget: TargetState
  tier1Signals?: Tier1Signals
  viewportWidth: number // Pass from parent to determine responsive behavior
}

export default function ParentPanel({
  session,
  currentTarget,
  tier1Signals,
  viewportWidth,
}: ParentPanelProps) {
  const [isOpen, setIsOpen] = useState(false)
  const isDesktop = viewportWidth >= 1024
  const isVisible = isDesktop || isOpen

  if (!isDesktop && !isVisible) {
    // Mobile: show toggle button only
    return (
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="fixed bottom-4 right-4 bg-teal text-white rounded-full w-12 h-12 flex items-center justify-center shadow-lg"
      >
        👨‍👩‍👧
      </button>
    )
  }

  const panelContent = (
    <div
      className={`
        ${isDesktop ? 'sticky top-0' : 'fixed inset-0 bg-black/50 z-50'}
        ${isDesktop ? 'w-60 h-screen bg-cream border-l-2 border-sage' : 'flex items-end'}
      `}
    >
      <div className={`${isDesktop ? 'w-full h-full' : 'w-full bg-cream rounded-t-lg'} p-4 flex flex-col gap-4 overflow-y-auto`}>
        {/* Close button for mobile overlay */}
        {!isDesktop && (
          <button
            onClick={() => setIsOpen(false)}
            className="text-right text-sage hover:text-teal"
          >
            ✕
          </button>
        )}

        <h2 className="text-sm font-bold text-teal uppercase">Coaching</h2>

        {/* Current Session Info */}
        <div className="bg-white rounded p-2 border border-sage text-xs">
          <div className="text-sage">Trial {session.completedTrialCount + 1} of {session.trialCount}</div>
          <div className="font-bold text-teal">{currentTarget.targetWord}</div>
          <div className="text-sage">Cue Level: L{currentTarget.currentCueLevel}</div>
        </div>

        {/* Coaching Message */}
        <div className="bg-warmAmber/20 rounded p-2 text-xs text-teal border border-warmAmber">
          <div className="font-semibold">Next step:</div>
          <div>Encourage {currentTarget.targetWord} at cue level L{currentTarget.currentCueLevel}</div>
        </div>

        {/* Dev Info (development only) */}
        {process.env.NODE_ENV === 'development' && tier1Signals && (
          <div className="bg-white rounded p-2 border border-sage text-xs">
            <div className="font-semibold text-sage mb-1">Tier-1 Signals</div>
            <div>Latency: {tier1Signals.latencyMs}ms</div>
            <div>SNR: {tier1Signals.snrDb.toFixed(1)}dB</div>
            <div>Syllables: {tier1Signals.syllableCount}</div>
          </div>
        )}
      </div>
    </div>
  )

  return isDesktop ? panelContent : <>{panelContent}</>
}
```

**Testing Requirements:**
- Mobile (320px): toggle button visible, overlay appears/disappears
- Tablet (600px): toggle button visible
- Desktop (1024px): sticky sidebar always visible on right
- Verify no console errors

**Git Commit:**
```bash
git add web/components/ParentPanel.tsx
git commit -m "feat: Implement ParentPanel with responsive sticky sidebar (desktop) / toggle overlay (mobile)"
git push origin claude/vibrant-thompson-mwwucr
```

---

### 4️⃣ Responsive Design Verification (1 hour, Days 2-3)

**Test Procedure:**

1. **Launch dev server:**
   ```bash
   cd web && npm run dev
   ```

2. **Open browser at each breakpoint:**
   - 320px (phone): Chrome DevTools
   - 600px (7" tablet): Chrome DevTools
   - 800px (10" tablet): Chrome DevTools
   - 1024px (desktop): Full screen

3. **Verify each component:**

   ```
   PlaySurface at 320px:
   - 1 waveform column, full width
   - Target word centered below
   - Scoring buttons stacked
   
   PlaySurface at 600px:
   - 2 columns: waveform left, target + scoring right
   - All elements visible without scrolling
   
   PlaySurface at 800px:
   - 3 columns: waveform left, target center, scoring right
   - Good spacing, readable
   
   PlaySurface at 1024px:
   - 3-column layout + sidebar toggle visible
   - Sidebar ready (toggle button on mobile → sticky on desktop)
   ```

   **TalkSurface:**
   ```
   320px: 2x3 grid (6 buttons), touch targets 48px
   600px: 3x4 grid (12 buttons), touch targets 54px
   800px: 4x5 grid (20 buttons), touch targets 60px
   1024px: 4x5 grid with full width
   ```

   **CollectionSurface:**
   ```
   320px: 1 column of cards, full width
   600px: 2 columns of cards, responsive gap
   800px+: 2-3 column layout or table
   ```

4. **Checklist:**
   - [ ] All components render without errors
   - [ ] Grids respond correctly to viewport width
   - [ ] Touch targets ≥48px at all sizes
   - [ ] No horizontal scroll at any breakpoint
   - [ ] Text readable (no clipping)
   - [ ] Colors correct (no red, only warm palette)
   - [ ] Navigation between components works

5. **Screenshot locations (for documentation):**
   ```
   docs/responsive-testing/web-320px.png (PlaySurface)
   docs/responsive-testing/web-600px.png (PlaySurface 2-col)
   docs/responsive-testing/web-800px.png (PlaySurface 3-col)
   docs/responsive-testing/web-1024px.png (Full + sidebar)
   ```

---

## 📦 Deliverables (End of Days 2-3)

**Files to Create:**
- ✅ web/components/TalkSurface.tsx (150 LOC)
- ✅ web/components/CollectionSurface.tsx (100 LOC)
- ✅ web/components/ParentPanel.tsx (100 LOC)

**Total Added:** 350 LOC (bringing Web Week 1 to ~1,950 LOC)

**Git Commits (3 commits, one per component):**
```
commit 1: "feat: Implement TalkSurface with responsive AAC board"
commit 2: "feat: Implement CollectionSurface with responsive progress tracking"
commit 3: "feat: Implement ParentPanel with responsive sticky sidebar / toggle overlay"
commit 4: "docs: Web Week 1 Days 2-3 components complete - responsive verified at 600/800/1024px"
```

**Branch:** `origin/claude/vibrant-thompson-mwwucr`

---

## ⚠️ Blockers & Help

**If you hit:**

1. **Responsive grid not responding to viewport width:**
   - Check Tailwind breakpoint configuration in `web/tailwind.config.ts`
   - Verify `md:`, `lg:`, `xl:` prefixes match breakpoints (md:600px, lg:800px, xl:1024px)

2. **Touch targets not meeting 48px minimum:**
   - Add `min-h-12` (48px) or `min-h-14` (56px) class
   - Add padding around buttons if needed
   - Verify on actual device or DevTools touch simulation

3. **Web Speech API not working:**
   - Add feature detection: `if ('speechSynthesis' in window)`
   - Fallback to simple volume increase or visual feedback
   - Test in Chrome/Safari (some browsers have limitations)

4. **Parent Panel toggle not responsive:**
   - Consider using a context hook to track viewport width
   - Or pass viewport width as prop from parent App component
   - Calculate: `window.innerWidth >= 1024` on resize event

---

## ✅ Success Criteria

By end of Days 2-3:
- ✅ TalkSurface renders responsive 2x3 → 3x4 → 4x5
- ✅ CollectionSurface shows progress tracking with responsive layout
- ✅ ParentPanel sticky sidebar on desktop, toggle overlay on mobile
- ✅ All responsive layouts verified at 600px, 800px, 1024px
- ✅ All touch targets ≥48px
- ✅ No red UI elements (warm palette only)
- ✅ 4 new commits pushed to branch
- ✅ Zero console errors

**Next:** Days 4-5 will be Service Worker + integration testing

---

**Timeline:** Sept 16-17 (2 days)  
**Expected Hours:** ~10 hours  
**Ready to start:** After Day 1 completion
