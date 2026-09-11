# Praxia Visual Design Reference
## Detailed Layouts, Component States & Engineering Handoff Checklist

**Version:** 1.0  
**Date:** 2026-09-11  
**Purpose:** Visual reference for engineering implementation; detailed component anatomy and layout patterns

---

## SECTION 1: CHILD ZONE LAYOUT PATTERNS

### Pattern 1: Full-Screen Modal (Practice Session)

```
┌──────────────────────────────────────────────────────────┐
│ STATUS BAR (OS)                      100%  9:41  🔋     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │  [Model Video — Real Mouth, Slowed]             │ │
│  │  16:9 aspect ratio, 240–320pt height            │ │
│  │  Centered, full width (with 16pt gutters)        │ │
│  │                                                  │ │
│  │  ┌──────────────────────────────────────────┐   │ │
│  │  │  [Close-up: Mouth articulating "ma"]    │   │ │
│  │  │  Bright lighting, neutral background     │   │ │
│  │  └──────────────────────────────────────────┘   │ │
│  │                                                  │ │
│  └────────────────────────────────────────────────────┘ │
│                    (16pt margin)                        │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  [REPEAT BUTTON — 40pt icon, centered]          │ │
│  │          🔄                                       │ │
│  └────────────────────────────────────────────────────┘ │
│                   12pt spacing                          │
│                                                          │
│  ╔════════════════════════════════════════════════════╗ │
│  ║ ATTEMPT WINDOW (open-ended)                        ║ │
│  ║                                                    ║ │
│  ║ [Companion turns toward mic icon]                 ║ │
│  ║          ◀                                         ║ │
│  ║                                                    ║ │
│  ║ "Your turn"  [soft audio: ready tone]             ║ │
│  ║                                                    ║ │
│  ║ [Mic ring, slow pulse]                            ║ │
│  ║        ⭕ ← slowly pulses in/out                   ║ │
│  ║                                                    ║ │
│  ║ (No timer. No countdown. Open-ended.)             ║ │
│  ║                                                    ║ │
│  ║ After 10s silence: "Need more time?"              ║ │
│  ║ [Ready for next] [Try again?] (soft, optional)    ║ │
│  ║                                                    ║ │
│  ╚════════════════════════════════════════════════════╝ │
│                   12pt spacing                          │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ [PARENT 3-TAP SCORE BUTTONS] — 64pt each         │ │
│  │                                                    │ │
│  │      ✓            ○            ✗               │ │
│  │   (Got it)    (Close)      (Try again)           │ │
│  │    64pt        64pt           64pt                │ │
│  │                                                    │ │
│  │ (OPTIONAL; app works at 0% scoring)              │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                   16pt spacing                          │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ COACHING STRIP (parent-visible below buttons)   │ │
│  │ Background: Surface-Secondary                    │ │
│  │ "Wait — give him 8 seconds before re-prompting" │ │
│  │ (14pt text, Text-Secondary, 1–2 lines max)       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ PROGRESS TOKENS (Transition warning)             │ │
│  │ "Two more, then we're done"                      │ │
│  │ ●  ●  (filled circles, Accent-Caution color)   │ │
│  │ (Disappear as trials complete; no bar)          │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ BOTTOM SAFE ZONE (Quick Access)                 │ │
│  │                                                    │ │
│  │  [🗣️ TALK]    [🌟 COLLECTION]    [🏠 HOME]      │ │
│  │   (AAC)         (Earned Items)    (Return)       │ │
│  │   40pt icons                                     │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Key measurements:**
- Video: Full width − 32pt (16pt gutters), aspect 16:9, max 320pt height
- Repeat button: 40pt icon, 64pt tap target, centered
- Attempt window: 16pt gutters, min 120pt height, centered text
- Score buttons: 64×64pt each, 16pt spacing, full-width layout (fit 3 across with gutter)
- Coaching strip: Full width − 32pt, 16pt horizontal padding, 12pt top/bottom
- Quick access bar: Full width, 56pt height, 3 equal buttons

**Safe zones (avoid placing UI here):**
- Top 44pt (status bar + notch)
- Bottom 56pt (home indicator on newer iPhone + safe zone padding)
- Left/right 16pt gutters throughout

---

### Pattern 2: Child Home Screen

```
┌──────────────────────────────────────────────────────────┐
│ STATUS BAR                           100%  9:41  🔋     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│                    16pt gutter                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │  [Companion Greeting — 240pt square]           │ │
│  │                                                    │ │
│  │  ┌──────────────────────────────────────────┐   │ │
│  │  │                                          │   │ │
│  │  │  [Companion mouth still + wave animation]│   │ │
│  │  │  "Hi! Ready to practice?"  (spoken)      │   │ │
│  │  │                                          │   │ │
│  │  └──────────────────────────────────────────┘   │ │
│  │                                                    │ │
│  │  (or: if reduce-motion, just still image)        │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                  24pt spacing                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │  [Session Card 1: "ma"]                         │ │
│  │  ┌──────────────────────────────────────────┐   │ │
│  │  │  [Referent image: mouth, 280pt wide]    │   │ │
│  │  │                                          │   │ │
│  │  │          [Icon: M sound]                 │   │ │
│  │  │                                          │   │ │
│  │  │      Cue Level: L1 (label)              │   │ │
│  │  │      [Tap to choose me]                  │   │ │
│  │  └──────────────────────────────────────────┘   │ │
│  │  Full card is tappable (≥180pt height)          │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                  12pt spacing                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │  [Session Card 2: "ba"]                         │ │
│  │  (same structure)                                │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                  12pt spacing                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │  [Session Card 3: "up"]                         │ │
│  │  (same structure)                                │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│              (Cards scrollable vertically)               │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ QUICK ACCESS BAR (Fixed Bottom)                  │ │
│  │                                                    │ │
│  │  [🗣️ TALK]    [🌟 COLLECTION]    [🏠 HOME]      │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Measurements:**
- Greeting: 240×240pt, centered, 24pt top margin
- Session cards: Full width − 32pt, ≥180pt height, 12pt vertical spacing
- Referent image: ≤280pt wide, centered in card
- Card padding: 16pt all sides
- Quick access bar: Fixed bottom, full width, 56pt height

---

### Pattern 3: AAC Grid (Talk Surface)

```
┌──────────────────────────────────────────────────────────┐
│ STATUS BAR                           100%  9:41  🔋     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│            [Close/Home] [Settings menu]                │
│            (breadcrumb, optional)                      │
│                                                          │
│            16pt gutter                                 │
│  ┌────────────────────────────────────────────────────┐ │
│  │ 5 COLUMNS × 8 ROWS = 40 CELLS                    │ │
│  │                                                    │ │
│  │ Cell size: 56pt × 56pt (+ 12pt spacing)          │ │
│  │ Total grid: ~388pt wide, ~576pt tall             │ │
│  │                                                    │ │
│  │  ┌──┬──┬──┬──┬──┐                                 │ │
│  │  │up│on│ma│ba│go│                                 │ │
│  │  ├──┼──┼──┼──┼──┤                                 │ │
│  │  │[Icon]                                          │ │
│  │  │ ↑  ●  m@ b@ →                                 │ │
│  │  │    (40pt)                                      │ │
│  │  ├──┼──┼──┼──┼──┤                                 │ │
│  │  │eat dog baby bye hi                            │ │
│  │  │ ∨  🐕  👶  👋  👋                              │ │
│  │  │    (32pt icons/images)                        │ │
│  │  ├──┼──┼──┼──┼──┤                                 │ │
│  │  │...more cells...                               │ │
│  │  ├──┼──┼──┼──┼──┤                                 │ │
│  │  │ [36] [37] [38] [39] [40]                      │ │
│  │  │                                                │ │
│  │  └──┴──┴──┴──┴──┘                                 │ │
│  │                                                    │ │
│  │ (Scrollable if needed; typically fits)           │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  When cell tapped:                                     │
│  • Voice model plays (0.5–1s)                         │ │
│  • Cell briefly highlights (200ms)                   │ │
│  • No modal; return to grid                          │ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ [🏠 HOME]  [🌟 COLLECTION]  [🗣️ TALK]            │ │
│  │ (Fixed bottom quick access)                       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Cell anatomy (each 56×56pt):**
```
┌────────────┐
│   [Icon]   │  ← 32pt icon/image, centered
│            │
│  (Label)   │  ← 12pt text (adult-only), below icon
└────────────┘
```

**Positioning:**
- Grid: Full width − 32pt (16pt gutters left/right)
- 5 columns: (Grid width − 4 × 12pt spacing) ÷ 5 = ~56pt per cell
- 12pt spacing between cells
- Rows: 8 rows to fit ~40 cells
- Label: 12pt sans-serif, Text-Secondary color, no child visibility

---

### Pattern 4: Collection (Category Grid)

```
┌──────────────────────────────────────────────────────────┐
│ STATUS BAR                           100%  9:41  🔋     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│                    16pt gutter                          │
│  COLLECTION                                            │
│  (Your things)                                         │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Animals                                     >   │ │
│  │ (64pt tall row, tappable, chevron right)          │ │
│  └────────────────────────────────────────────────────┘ │
│               8pt spacing                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Vehicles                                    >   │ │
│  └────────────────────────────────────────────────────┘ │
│               8pt spacing                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Actions                                     >   │ │
│  └────────────────────────────────────────────────────┘ │
│               8pt spacing                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Food                                        >   │ │
│  └────────────────────────────────────────────────────┘ │
│               8pt spacing                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • People                                      >   │ │
│  └────────────────────────────────────────────────────┘ │
│               8pt spacing                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Objects                                     >   │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  When category tapped (e.g., "Animals"):               │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ [< Animals]                                       │ │
│  │ (Back button, 40pt, top-left)                     │ │
│  │                                                    │ │
│  │ [Cat]  [Dog]  [Bird]                             │ │
│  │ 120pt  120pt   120pt    (3-column grid)          │ │
│  │ 12pt spacing                                      │ │
│  │                                                    │ │
│  │ [Fish] [Bunny] [Cow]                             │ │
│  │                                                    │ │
│  │ [Bird] [Squirrel] [Duck]                         │ │
│  │                                                    │ │
│  │ ...scrollable...                                  │ │
│  │                                                    │ │
│  │ [Lion] [Tiger] [Monkey]                          │ │
│  │ ...                                                │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ [🏠 HOME]  [🌟 COLLECTION]  [🗣️ TALK]            │ │
│  │ (Fixed bottom)                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Category row:** 64pt tall, full width, padding 16pt left/right
**Item grid:** 3 columns on phone; 4+ on tablet; 120×120pt items; 12pt spacing

---

## SECTION 2: END-OF-SESSION RITUAL SEQUENCE

```
PHASE 1: CELEBRATION (3–5 seconds)
┌──────────────────────────────────────────────────────────┐
│                                                          │
│             🎉 GREAT WORK! 🎉                          │
│                                                          │
│             [Animated sequence]                        │
│             ✨ Confetti or lights fade in             │
│             ✨ (respects reduce-motion)                │
│                                                          │
│        [Companion applauds or waves]                   │
│                                                          │
│        "That was awesome!" (spoken)                    │
│                                                          │
└──────────────────────────────────────────────────────────┘
              ↓ Auto-transition (3–5s)

PHASE 2: COLLECTION SHELF (2–4 seconds, auto-scroll)
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  Your Collection                                        │
│  (label, adult-only)                                  │
│                                                          │
│  ◄ [Item 1] [Item 2] [Item 3] ►                       │
│     ▸        ▸        ▸                                 │
│   120×120pt  120×120pt  120×120pt                       │
│   Items slide in sequentially (200ms stagger)         │
│                                                          │
└──────────────────────────────────────────────────────────┘
              ↓ Auto-transition (2–4s)

PHASE 3: GOODBYE (2–3 seconds)
┌──────────────────────────────────────────────────────────┐
│                                                          │
│        See you tomorrow!                               │
│   (spoken + visible text for adult)                   │
│                                                          │
│        [Companion waves goodbye]                       │
│                                                          │
│  ✨ Gentle fade to black                              │
│                                                          │
└──────────────────────────────────────────────────────────┘
              ↓ Auto-dismiss

HOME SCREEN
┌──────────────────────────────────────────────────────────┐
│ (App returns to home; never stays in-session)          │
└──────────────────────────────────────────────────────────┘
```

**Total duration:** 7–12 seconds, all automatic, no interaction required.
**Key rule:** Never end on a failed trial. Always end during celebration.

---

## SECTION 3: ADULT ZONE LAYOUT PATTERNS

### Pattern A: Today Screen (Parent)

```
┌────────────────────────────────────────┐
│ PRAXIA              [Menu]    [Profile]│
├────────────────────────────────────────┤
│                                        │
│ TODAY (Fri, Sep 11)                   │
│                                        │
│ ┌────────────────────────────────────┐│
│ │ ✓ READY TO PRACTICE               ││  ← Status card
│ │ This session is loaded and ready.  ││
│ │ Targets: "ma", "ba", "up"          ││
│ │ Complexity: Easy                   ││
│ │                                    ││
│ │ [🎮 Hand to Child]                 ││
│ └────────────────────────────────────┘│
│                                        │
│ ────────────────────────────────────  │
│                                        │
│ THIS WEEK                              │
│ Mon ✓  (40 trials)                    │  ← Heatmap (no streaks)
│ Tue ✓  (65 trials)                    │
│ Wed ✗                                 │
│ Thu ✓  (55 trials)                    │
│ Fri [Today]                           │
│ Sat –                                 │
│ Sun –                                 │
│                                        │
│ Goal: 4 days this week                │
│ Progress: 3 of 4 ✓                   │
│                                        │
│ [Missed a day? No problem. You're still│
│  on track. Pick it up whenever.]      │
│                                        │
│ ────────────────────────────────────  │
│                                        │
│ LAST SESSION (Yesterday, Sep 10)      │
│ ✓ 62 trials completed                 │
│ • Cue levels: L2–L3 (mostly)         │
│ [View video] [View stats]             │
│                                        │
│ ────────────────────────────────────  │
│                                        │
│ COACHING TIP                           │
│ "Approximations count as words."      │
│ [Learn more ≤90s]                    │
│                                        │
├────────────────────────────────────────┤
│ [Today] [Progress] [Clips] [Learn]   │  ← Tab bar (5 tabs)
│ [My SLP] [Settings]                   │  (scroll if needed)
└────────────────────────────────────────┘
```

**Specs:**
- Header: "TODAY" + date (optional)
- Status card: Full width − 32pt, 16pt padding, Accent-Success or Neutral
- Week heatmap: 7-day grid, checkmarks (✓/✗/–), no streak numbers
- Goal text: "4 of 4" format, never "Day 3 of a streak"
- Re-entry framing: Neutral, compassionate language if day missed
- Tab bar: 5 tabs (Today, Progress, Clips, Learn, My SLP), Settings as gear icon in top-right

---

### Pattern B: Progress Screen (Parent)

```
┌────────────────────────────────────────┐
│ ← PRAXIA              [Menu]           │
├────────────────────────────────────────┤
│ PROGRESS (12-week view)                │
│ [Date range: 12w] [4w] [8w] [all]     │
│                                        │
│ ════════════════════════════════════ │
│ CUES & DIFFICULTY (Primary)            │
│                                        │
│ L0 ▓▓░░░░  (8%)                       │  ← Horizon chart
│ L1 ▓▓▓▓▓░░  (28%)                     │
│ L2 ▓▓▓▓▓▓▓░ (38%) ← highest         │
│ L3 ▓▓▓░░░░  (18%)                     │
│ L4 ▓░░░░░░  (4%)                      │
│ L5 ░░░░░░░  (2%)                      │
│                                        │
│ Interpretation:                        │
│ "Moving toward less support.           │
│  That's progress!"                    │
│                                        │
│ ════════════════════════════════════ │
│ SOUNDS YOUR CHILD USES                 │
│                                        │
│ Consonants: m, b, p, h, w            │  ← Inventory list
│ Vowels: /ɑ/ /i/ /u/ /o/              │
│ Syllable shapes: V, CV, VC, CVCV     │
│                                        │
│ 12 weeks ago:                          │  ← Baseline comparison
│ Consonants: m, b                      │
│ Vowels: /ɑ/ /i/                      │
│ Syllable shapes: V                    │
│                                        │
│ ════════════════════════════════════ │
│ COMMUNICATION MODE                     │
│ AAC-only  ▓░░░░ (20%)                │  ← Modality ratio
│ AAC+voice ▓▓▓░░ (40%)                │
│ Voice     ▓▓▓░░ (40%)                │
│                                        │
│ 12 weeks ago: AAC-only (100%)         │
│                                        │
│ ════════════════════════════════════ │
│ TARGETS STATUS                         │
│ ✓ Mastered: "up" (3 wks ago)          │  ← Target summary
│ ◐ Progressing: "ba", "ma", "on"       │
│ ◑ Stuck: "go" (3+ wks)               │
│ [View all targets] [IEP report]       │
│                                        │
│ ════════════════════════════════════ │
│                                        │
│ [Export data] [Download PDF]          │  ← Actions
│                                        │
└────────────────────────────────────────┘
```

**Chart types:**
- Cue-level distribution: Horizon/bar chart (% of trials at each level)
- Inventory: List or word cloud
- Modality ratio: Pie or donut chart
- Targets: List with status indicators

---

## SECTION 4: CLINICIAN PORTAL PATTERNS

### Pattern C: Triage Queue

```
┌────────────────────────────────────────────┐
│ PRAXIA CLINICIAN PORTAL                    │
│ karen@clinic.example.com  [Logout]         │
├────────────────────────────────────────────┤
│ YOUR CASELOAD (8 children)                 │
│ Sort by: [Needs You] [Volume] [Last Review]
│                                            │
│ ┌──────────────────────────────────────┐  │
│ │ Mateo Chen (3y2m) · Cincinnati       │  │ ← Red flag
│ │ ⚠ Target "ma" stuck 4 weeks         │  │
│ │ Practice: 5/5 this week (goal: 5)   │  │
│ │ Last review: 6 days ago             │  │
│ │ [View] [Review clips] [Message]     │  │
│ └──────────────────────────────────────┘  │
│                                            │
│ ┌──────────────────────────────────────┐  │
│ │ Aisha Lopez (5y7m) · Cincinnati      │  │ ← Green
│ │ ✓ Progressing well ("ba" → L3)      │  │
│ │ Practice: 3/5 this week             │  │
│ │ Last review: 2 days ago             │  │
│ │ [View] [Review clips]               │  │
│ └──────────────────────────────────────┘  │
│                                            │
│ ┌──────────────────────────────────────┐  │
│ │ Kai Washington (4y1m) · Cincinnati   │  │ ← Orange
│ │ ⚠ Over-practicing (9 sessions)      │  │
│ │ Practice: 7/5 this week (goal: 5)   │  │
│ │ Last review: 5 days ago             │  │
│ │ [View] [Contact parent]             │  │
│ └──────────────────────────────────────┘  │
│                                            │
│ ...more rows...                           │
│                                            │
└────────────────────────────────────────────┘
```

**Row anatomy:**
- Name + age + clinic (1 line)
- Primary signal: ⚠ (red), ✓ (green), – (gray)
- Practice volume: "5/5 this week (goal: 5)"
- Last review date: "6 days ago"
- Action buttons: [View], [Review clips], [Message] (context-dependent)
- Row height: ~120pt (3 lines of text + button row)
- Tap anywhere in row to expand or navigate to child detail

**Sort options:**
- "Needs You Most": Red flags first, then oldest reviews
- "Practice Volume": Lowest compliance first
- "Last Reviewed": Longest since last SLP review
- "Alphabetical"

---

### Pattern D: Clip Review

```
┌─────────────────────────────────────────────────┐
│ ← MATEO CHEN · CLIP REVIEW                      │
├─────────────────────────────────────────────────┤
│                                                 │
│ [Clip 1 / 12]  [Playing]                       │
│                                                 │
│ Target: "ba"  |  Cue Level: L1                │
│ Date: Sep 10, 3:45 PM  |  Duration: 0.6s      │
│ Parent score: [✓ Got it]                      │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ [Audio player]                          │   │
│ │ ▶ [────────●──────────] 0.6s           │   │
│ │ [0.75×] [1×] [1.5×]  [Repeat]          │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ MY ASSESSMENT                                  │
│ IPA: [ba]  (text input)                       │
│ Cue level needed: [L1] v  (dropdown)           │
│                                                 │
│ Correctness:                                  │
│ [1] ✓ Got it                                  │
│ [2] ○ Approximation                           │
│ [3] ✗ Not yet                                 │
│                                                 │
│ Notes: [Good voiced bilabial plosive]        │
│        (optional text)                        │
│                                                 │
│ [Submit]  [Mark for double-rate]              │
│                                                 │
│ ──────────────────────────────────────────    │
│ KEYBOARD SHORTCUTS                            │
│ [SPACE] Play  [1] ✓  [2] ○  [3] ✗            │
│ [S] Slow [N] Normal [Enter] Next               │
│                                                 │
│ Progress: 1 / 12 (8%)  |  Time: 0:47          │
│ Est. completion: ~9 min                       │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Key design:**
- Clip metadata (target, cue, date) in header row
- Audio player embedded (not external)
- Assessment form: inline, not modal
- Keyboard shortcuts legible at bottom
- Progress & time estimate
- Single-tap submit flow (no confirmation)

---

## SECTION 5: ENGINEERING HANDOFF CHECKLIST

### Pre-Implementation

- [ ] **Typography scale finalized**
  - Body text: 16pt (adult), 14pt (labels)
  - Headings: 20pt (section), 28pt (screen title)
  - Small: 12pt (captions, metadata)
  - All line-heights, weights confirmed in code

- [ ] **Color tokens defined in code**
  - Light theme: 10 color tokens (background, surface, text, accent, border)
  - Dark theme: 10 color tokens (same tokens, different values)
  - Verified 4.5:1 contrast on all text
  - Verified 3:1 contrast on all UI components

- [ ] **Spacing tokens defined**
  - 8pt base grid locked
  - Tokens: XS (8pt), S (12pt), M (16pt), L (24pt), XL (32pt), XXL (48pt)
  - All layouts use these tokens only (no magic numbers)

- [ ] **Component library specs**
  - Button: dimensions, states (default, pressed, disabled), colors
  - Card: padding, radius, shadow, spacing
  - Input: border, height, focus state
  - Each component has light + dark theme variants

- [ ] **Icon set**
  - All SF Symbols confirmed (with fallback names)
  - Size specifications per use (40pt child zone, 24pt adult, etc.)
  - Color specifications (text-primary by default)

- [ ] **Responsive breakpoints locked**
  - Phone: 390px (base), tested up to 430px
  - Tablet: 768px and above
  - Child zone behaves identically; only scales content
  - No significant layout changes between phone and tablet

### Child Zone Implementation

- [ ] **Home screen**
  - Greeting animation ≤2.5s, respects reduce-motion
  - Session cards scrollable, 180pt min height
  - Quick access bar fixed bottom, 56pt height
  - Touch targets ≥64pt everywhere

- [ ] **Practice session loop**
  - Model video: 16:9, full width − 32pt, max 320pt height
  - Repeat button: 40pt centered, tappable area 64×64pt
  - Attempt window: visual (companion turns) + audio ("ready"), 10s timeout with soft re-prompt
  - Score buttons: 64×64pt, 16pt spacing, optional (app works at 0% parent input)
  - Coaching strip: always visible below buttons, 14pt text
  - Transition tokens: concrete, disappearing, not abstract bar

- [ ] **End-of-session ritual**
  - Phase 1 (Celebration): 3–5s, auto-transition
  - Phase 2 (Collection): 2–4s, items slide in sequentially
  - Phase 3 (Goodbye): 2–3s, companion wave, fade to black
  - Auto-dismiss to home (never stays in-session)

- [ ] **AAC board (Talk)**
  - 5×8 grid = 40 cells, never reorganizes
  - Cell size: 56×56pt, 12pt spacing
  - Icons/images: 32pt centered in cell
  - Tap feedback: 200ms highlight, voice plays, returns to grid
  - Positions fixed per target (same position every time)

- [ ] **Collection (earned items)**
  - 6 categories (Animals, Vehicles, Actions, Food, People, Objects)
  - Category rows: 64pt tall, tappable, chevron right
  - Item grid: 3 columns phone, 4 tablet; 120×120pt items
  - Scrollable, never loses items, no completion endpoint

- [ ] **Accessibility (Child Zone)**
  - All touch targets ≥64pt (WCAG 2.5.8 is 24px floor)
  - VoiceOver labels on all elements
  - Switch Control scanning paths tested
  - Guided Access compatibility tested
  - Reduce Motion: all animations disabled automatically
  - Reduce Transparency: no overlays

### Adult Zone Implementation

- [ ] **Today screen**
  - Status card with session info + "Hand to Child" button
  - Week heatmap: 7 days, checkmarks (✓/✗/–), no streaks
  - Bucket goal: "4 days this week", progress shown as "3 of 4"
  - Last session summary: trial count, cue distribution
  - Coaching tip (context-sensitive, ≤90s reference)
  - Tab bar: Today, Progress, Clips, Learn, My SLP; Settings gear icon

- [ ] **Progress screen**
  - Cue-level distribution: horizon chart (% at each L0–L5)
  - Inventory: list + comparison to baseline
  - Modality ratio: pie/donut chart
  - Target status: list with status badges (✓ Mastered, ◐ Progressing, ◑ Stuck)
  - Stuck target: warning indicator + one-tap message to SLP
  - Date range selector: 4w, 8w, 12w, all-time

- [ ] **Clips screen**
  - Before/after section: auto-curated, updated every 2 weeks
  - First before/after by day 10 (day-1 baseline vs. week-2 best)
  - Keepsakes: manual star + long-term retention (beyond 90 days)
  - Player: play/pause, speed control (0.5–2×), timeline scrubbing
  - Per-clip delete button always visible

- [ ] **Learn screen**
  - Personalized section: 3–5 lessons based on current targets
  - Lesson cards: ≤90s video, title, watch status
  - Categories: 6–8 (CAS basics, Practice tips, AAC, Behavior, Progress, etc.)
  - No paywall; all lessons free

- [ ] **My SLP screen**
  - SLP profile: name, credential, clinic, last contact date
  - Messages: threaded, chronological (newest first)
  - Video replies: 20–60s async videos, embedded with play controls
  - Parent messages: 160-char SMS-like messages
  - Targets: read-only display (SLP controls via portal)
  - One-tap templates: "Request new target", "Target stuck"

- [ ] **Settings (Sensory Panel)**
  - Sensory: Sound toggle, Music (independent), Animation toggle, Haptics toggle
  - Motion: Reward animation speed slider, Model playback speed slider
  - Display: Dark mode toggle, Brightness slider, Contrast slider
  - Accessibility: Auto-honor OS Reduce Motion, Reduce Transparency, Reduce Contrast
  - Practice: Duration selector, Session end-on toggle, Score button visibility
  - Rewards: Frequency slider (disabled / 2 / 4 / 6 / 8 / 10 attempts)
  - Consent: 5 independent toggles (Core, On-device, Cloud, SLP, Model training)
  - Data: Export CSV, Audit log (access history), Delete data (30-day countdown), Download ZIP

- [ ] **Accessibility (Adult Zone)**
  - 44×44pt minimum touch targets (Apple HIG)
  - All links & buttons have visible focus state (2pt outline)
  - Form inputs: clear labels, error messages
  - Contrast: 4.5:1 on all text in light + dark

### Clinician Portal (Web) Implementation

- [ ] **Triage queue**
  - One row per child (name, age, clinic)
  - Primary signal: ⚠ (red), ✓ (green), – (gray)
  - Practice volume, last review date
  - Action buttons: [View], [Review clips], [Message] (context-dependent)
  - Sort options: Needs You, Practice Volume, Last Reviewed, Alphabetical
  - Rows ~120pt height; scan entire queue in 2 min

- [ ] **Child detail**
  - Target list: add, edit, retire, status badges
  - Per-target: level progression, accuracy, practice volume, last model date
  - Ready-to-probe indicator (for generalisation)
  - Settings: session duration, trial target, minimum sessions/week, practice schedule
  - Keyboard navigation: Tab through rows, Enter to edit

- [ ] **Clip review**
  - Keyboard-driven: Space=play, 1=✓, 2=○, 3=✗, Enter=next
  - Clip metadata in header (target, cue, date, duration)
  - Audio player: play/pause, speed control, repeat, timeline
  - Assessment form: IPA input, cue level dropdown, correctness radio, notes
  - Batch progress: clip count, time spent, time per clip, est. completion

- [ ] **Progress charts**
  - Accuracy × cue level: line chart, color-coded by level
  - Interpretation text: explains that dropping accuracy at lower level = progress
  - Inventory growth: table (Week 1, 4, 8, 12; consonants, vowels, syllables)
  - Modality ratio: pie or donut chart showing AAC-only → mixed → vocal over time
  - Exports: PDF (static images), CSV (raw data)

- [ ] **IEP report**
  - Auto-populated sections: baseline, goals, data, measurement
  - Editable interpretation & next steps
  - Embedded charts (static in PDF)
  - Export to PDF / Word / share link
  - One-click generation from portal

### Motion & Animation

- [ ] **All animations ≤2.5 seconds**
  - Page transition: 300ms slide
  - Model playback: 200ms fade-in
  - Collection item reveal: 300–500ms per item (200ms stagger)
  - Session end ritual: 7–12s total (all automatic)

- [ ] **Reduce Motion support**
  - All animations disabled when `prefers-reduce-motion` enabled (iOS/web)
  - State changes still instant (no animation, but UI updates immediately)
  - Tested on device with motion reduced

- [ ] **One thing at a time**
  - No parallel animations of multiple objects
  - Items in collection reveal sequentially, not simultaneously
  - No parallax or depth effects

### Accessibility Audit

- [ ] **WCAG 2.2 AA on all screens**
  - Color contrast: 4.5:1 text, 3:1 UI components (verified in light + dark)
  - Touch targets: ≥64pt child zone, ≥44pt adult
  - No flashing >3× per second
  - No timing dependency in child zone

- [ ] **iOS accessibility APIs**
  - VoiceOver: `accessibilityLabel`, `accessibilityHint`, `accessibilityValue` on all elements
  - Dynamic Type: text scales with system font size; tested at largest setting
  - Switch Control: every action reachable via single-switch scanning
  - Guided Access: app compatible (doesn't break Guided Access)

- [ ] **Motor & cognitive accessibility**
  - No drag-and-drop without single-pointer alternative
  - Literal language in child prompts (no idiom or metaphor)
  - Predictable layout (identical structure every session)
  - No animation surprises

- [ ] **Auditory & sensory accessibility**
  - Captions on all audio (even though child zone has no reading)
  - Independent audio controls (voice, music, effects separately mutable)
  - Visual + auditory redundancy (no audio-alone instructions)
  - Adjustable playback speed for models (0.75× / 1× / 1.25× / 2×)

### Data & Backend Integration

- [ ] **Trial log**
  - Each trial: client_ts, server_ts, cue_level (first-class field), attempt data
  - Append-only, immutable, UUIDv7 per trial
  - Multiple score rows (parent, SLP, model:vX) — never collapsed

- [ ] **Audio capture**
  - 16 kHz mono PCM, `AVAudioSession .measurement` (AEC/AGC/noise-suppression OFF)
  - Per-session SNR calibration and gate
  - Raw audio never leaves device without consent
  - Default retention: 90 days, encrypted on-device (`NSFileProtectionComplete`)

- [ ] **Offline functionality**
  - 100% of practice loop works offline (no network call on critical path)
  - Model videos bundled in-app
  - Starter target set bundled
  - Audio upload deferred to wifi + charging + consent

- [ ] **Sync & cloud**
  - Audio uploads: content-addressed (SHA-256), idempotent retry
  - VPC verification: not email-plus (card auth or signed form)
  - Consent toggles: cloud, training, research (all independent)
  - Audit log: every clip playback recorded with timestamp + SLP name

### Data & Privacy

- [ ] **No third-party analytics/ads in child client**
  - First-party, on-device-aggregated telemetry only
  - Zero Firebase Analytics, Amplitude, Mixpanel, Sentry-with-PII
  - No attribution SDKs

- [ ] **Red-flag screening**
  - Hard interrupt on positive dysphagia, regression, seizures, breathing/voice change
  - Hearing status gates speech pathway (AAC remains available)
  - Re-screening every 90 days

- [ ] **Layered consent**
  - 5 independent toggles: Core (required), On-device, Cloud, SLP, Model training
  - Model training SEPARATE (COPPA compliance)
  - Each records timestamp, policy version, verification method
  - Revocation anytime in Settings

### Claims Compliance

- [ ] **All strings vetted against claims register**
  - No "teach your non-verbal child to talk"
  - No "treats CAS" / "therapy" / "treatment"
  - No "clinically proven" (applied to our product)
  - No "replaces speech therapy"
  - No "cure" / "fix" / "guarantee"

- [ ] **Required disclosures visible**
  - "Praxia supports practice between sessions with an SLP. It does not diagnose or treat."
  - Evidence level on Phase 0 (clinical consensus only)
  - "Your clinician decides if an attempt was correct. Praxia does not judge."
  - AI disclosure where algorithmic signals shown

### Performance

- [ ] **NFR-1: ≤150 ms vocalization → reinforcement**
  - Audio capture → vocalization detection → audio playback latency ≤150ms
  - Tested on device

- [ ] **NFR-2: ≤300 ms utterance offset → trial feedback**
  - Audio offset detection → UI update (score buttons visible, coaching note) ≤300ms
  - Tested on device

- [ ] **NFR-3: 100% offline practice**
  - Launch → first trial ≤90s (cold start)
  - No network calls on critical path
  - Tested on airplane mode

- [ ] **NFR-4: 30-minute session without throttle**
  - Thermal management: no CPU limit on 3-year-old iPad
  - Battery: <15% drain over 30 min
  - Tested on actual device

- [ ] **NFR-7: Crash-free rate ≥99.5%**
  - Regression suite of audio fixtures replayed on every beta
  - Crash rate monitored in TestFlight

---

## SECTION 6: FINAL HANDOFF ARTIFACTS

**Deliverables from Design to Engineering:**

1. ✅ **Praxia Design Specification v1.0** (this document + visual reference)
   - Design system (tokens, typography, spacing, components)
   - Screen designs (all 12 child/adult/portal screens)
   - Accessibility specs (WCAG 2.2 AA + iOS + motor)
   - Copy deck (all strings, claims-vetted)

2. ✅ **Component Library Specs**
   - Button (child: 64pt flat; adult: primary/secondary/tertiary)
   - Card (with shadow, radius, padding)
   - Session card (with cue-level badge)
   - Trial state container (video, repeat, attempt window, scoring, coaching)
   - AAC grid (5×8, 56pt cells, fixed positions)
   - Collection (categories + item grid)

3. ✅ **Motion Spec**
   - Animation timings (all ≤2.5s)
   - Easing curves (ease-out)
   - Reduce-motion implementation (automatic OS honor)
   - End-of-session ritual (7–12s total)

4. ✅ **Accessibility Annotations**
   - WCAG 2.2 AA checklist (verified per screen)
   - iOS accessibility API implementation guide
   - Motor & cognitive accessibility specs
   - Auditory & sensory accessibility specs

5. **Color tokens (to be exported as design file / code constants)**
   - Light theme: 10 tokens
   - Dark theme: 10 tokens
   - Verified 4.5:1 contrast on all text

6. **Icon mapping (SF Symbols)**
   - 15 primary icons with specifications
   - Sizes per context (40pt child, 24pt adult)
   - Fallback names for future iOS compatibility

7. **Copy deck (CSV for localization & claims review)**
   - All user-facing strings
   - Each string vetted against claims register
   - Tone guidelines per screen

8. **Engineering Handoff Checklist** (this section)
   - Pre-implementation tasks
   - Feature-by-feature verification items
   - Accessibility audit checklist
   - Performance verification targets

---

**END OF VISUAL REFERENCE & HANDOFF CHECKLIST**

Owner: UI/UX Designer  
Ready for: Engineering implementation, Product review, SLP advisory board validation
