# Praxia Design Specification v1
## Complete Design System, Screen Designs & Accessibility Spec

**Version:** 1.0  
**Date:** 2026-09-11  
**Audience:** Engineering, product, content, SLP advisory board  
**Status:** Ready for design-system implementation + screen wireframes  

---

## PART 1: DESIGN SYSTEM FOUNDATION

### 1.1 Design Philosophy & Constraints

**Core principles applied to every decision:**
- **Zero reading anywhere in the child zone.** All child-facing content is photograph, video, icon, or speech.
- **Low-stimulation defaults, not high-stimulation-with-an-off-switch.** Calm desaturated palette; no background music by default; no idle animation; one element moves at a time.
- **Errorless-learning visual structure.** Maximal support → fading support → no support. Backing off produces zero child-visible signal.
- **Identical session skeleton every time.** Predictability over novelty. Novelty lives inside slots, not in structure.
- **Depth ≤2 in the child zone.** No nested menus; no modals over the child's task.
- **Always-reachable sensory panel** from the adult surface for sound, music, animation, brightness, dark mode, haptics, model playback speed, reward intensity.
- **≥64pt touch targets** (child zone); ≥16dp spacing; nothing in thumb-rest or edge zones.

**Design to Aisha (P2 — minimally verbal, co-occurring autism, demand-avoidant, sound-sensitive).** Every decision trading excitement for predictability is correct.

---

### 1.2 Color Palette — Full Light & Dark Themes

**Design philosophy:** Desaturated, high-contrast where it carries meaning. No saturated red/yellow at scale. Full light and dark implemented as first-class variants, not an accessibility afterthought.

#### Light Theme (Default)

| Token | RGB / HEX | Usage | Notes |
|---|---|---|---|
| **Background** | #FAFAF7 | App background (child & adult) | Warm white, not pure #FFF |
| **Surface-Primary** | #FFFFFF | Card, button backgrounds | Clean white |
| **Surface-Secondary** | #F0EFE8 | Disabled states, subtle containers | Very light grey-brown |
| **Text-Primary** | #1A1815 | All body text (adult); labels | Nearly black, warm tone |
| **Text-Secondary** | #6B6560 | Secondary copy, metadata | Medium grey |
| **Text-Tertiary** | #9E9894 | Disabled text, hints | Light grey |
| **Accent-Success** | #4A7C59 | Only on adult surface; never child-visible | Muted forest green |
| **Accent-Caution** | #8B7355 | Progress indicators, optional signals | Muted warm brown |
| **Neutral-Border** | #E2DDD6 | Divider lines, subtle borders | Light taupe |
| **Touch-Feedback** | rgba(0,0,0,0.08) | Tap highlight (child & adult) | Subtle darkening |
| **Companion-BG** | #E8E4DC | Companion character zone background | Neutral, recedes |

#### Dark Theme

| Token | RGB / HEX | Usage |
|---|---|---|
| **Background** | #1A1815 | App background |
| **Surface-Primary** | #2A2520 | Card, button backgrounds |
| **Surface-Secondary** | #3A342F | Disabled states |
| **Text-Primary** | #F5F1ED | Body text |
| **Text-Secondary** | #B5AFAA | Secondary copy |
| **Text-Tertiary** | #8A8480 | Disabled text |
| **Accent-Success** | #7BB88A | Progress, success (muted lighter green) |
| **Accent-Caution** | #C5A88A | Progress indicators (muted lighter brown) |
| **Neutral-Border** | #3A342F | Divider lines |
| **Touch-Feedback** | rgba(255,255,255,0.10) | Tap highlight |
| **Companion-BG** | #332D28 | Companion character zone background |

**Theme implementation:**
- Light is the default.
- Dark theme honors `prefers-color-scheme: dark` automatically.
- Settings > Sensory Panel includes explicit "Dark Mode" toggle.
- Transition between themes is instant (no animation).

---

### 1.3 Typography

#### Family & Scaling

| Use | Family | Size (iOS pt) | Weight | Line Height | Notes |
|---|---|---|---|---|---|
| **Adult Display** | -apple-system (San Francisco) | 28 | 700 (Bold) | 1.2 | Progress screen headings, portal headings |
| **Adult Heading** | -apple-system | 20 | 700 | 1.3 | Section headers, card titles |
| **Adult Body** | -apple-system | 16 | 400 (Regular) | 1.5 | Main body copy, paragraphs |
| **Adult Small** | -apple-system | 14 | 400 | 1.4 | Helper text, metadata, timestamps |
| **Adult Micro** | -apple-system | 12 | 400 | 1.3 | Captions, legal fine print |
| **Child UI Labels** | -apple-system | 18 | 500 (Medium) | 1.2 | Screen labels (adult-visible only; never child-visible) |

**Dyslexia accessibility:**
- Default system font (San Francisco) is acceptable; OpenDyslexic or similar not required by research in this population but user-selectable in Settings.
- Adequate line spacing (1.4–1.5) baked in.
- No all-caps for emphasis.
- >4.5:1 contrast on all body text (WCAG AA floor; we typically exceed this).

**No text hierarchy in the child zone.** Text appears only as adult labels, never as child-facing content.

---

### 1.4 Spacing & Rhythm

**8pt base grid.** All spacing in multiples of 8pt for consistency and alignment.

| Token | Value | Usage |
|---|---|---|
| **Gutter** | 16pt | Outer margin on child & adult screens |
| **Spacing-XS** | 8pt | Tight spacing (icon padding, internal card space) |
| **Spacing-S** | 12pt | Between adjacent elements |
| **Spacing-M** | 16pt | Standard spacing between components |
| **Spacing-L** | 24pt | Larger separation (between sections) |
| **Spacing-XL** | 32pt | Major section breaks |
| **Spacing-XXL** | 48pt | Between major layout regions |

**In the child zone, spacing is always ≥16dp (≥12pt visual) to prevent accidental touches.**

---

### 1.5 Corner Radius & Shadows

| Element | Radius | Shadow | Usage |
|---|---|---|---|
| **Card** | 12pt | 0 4pt 8pt rgba(0,0,0,0.08) | Practice session cards, collection items |
| **Button (child)** | 8pt | None (flat) | Touch targets; no depth illusion |
| **Button (adult)** | 8pt | Subtle on press | Tappable UI elements |
| **Input Field** | 8pt | None | Text input, selection |
| **Modal / Sheet** | 16pt top | 0 -4pt 16pt rgba(0,0,0,0.15) | Modal dialog baseline |
| **Companion Mouth** | 0pt (circle) | None | Clean, geometric |

**No drop shadows in the child zone that suggest depth.** Keep visual hierarchy flat and clear.

---

### 1.6 Icons

**Icon library:** SF Symbols (native iOS) for consistency with Apple HIG and platform integration.

| Icon | Symbol | Size (child zone) | Size (adult) | Usage |
|---|---|---|---|---|
| **Home** | house.fill | 40pt | 24pt | Tab/nav return |
| **Repeat** | repeat | 40pt | 24pt | Play model again |
| **Pause** | pause.fill | 40pt | 24pt | Pause session (rare) |
| **AAC/Talk** | bubble.left.fill | 40pt | 24pt | Jump to AAC board |
| **Collection/Earn** | star.fill | 40pt | 24pt | Collected items (unlabeled in child zone) |
| **Settings** | gearshape.fill | 32pt | 24pt | Adult-zone only |
| **Chevron Right** | chevron.right | 32pt | 16pt | Navigation hint (adult only) |
| **Check** | checkmark.circle.fill | 40pt | 24pt | Success signal (adult only, never child-visible) |
| **Info** | info.circle.fill | 32pt | 20pt | Help, optional labels (adult only) |
| **Mic** | mic.fill | 40pt | 24pt | Recording indicator |
| **Volume** | speaker.fill | 32pt | 20pt | Sound control |
| **Close/X** | xmark | 32pt | 20pt | Dismiss (adult only; child uses home button only) |

**Icon color:** Always text-primary color; never decorative reds, yellows, or high-saturation hues in the child zone.

**No emoji or illustration icons in the child zone.** Use real photographs and video for nouns and actions.

---

### 1.7 Buttons & Touch Targets

#### Child Zone Buttons
- **Minimum size:** 64×64pt (WCAG 2.5.8 is 24px floor; this is 2.7× larger)
- **Spacing:** ≥16dp between targets
- **Shape:** Rectangular or circular; corners ≥8pt
- **Background:** Distinct from background; sufficient contrast (≥3:1 minimum, typically ≥4.5:1)
- **Tap feedback:** Brief 100ms slight darkening (touch-feedback color) + optional haptic (disabled by default; configurable)
- **No hold-to-interact** (except for rare, explicitly signaled destructive actions like "clear session data")
- **Debouncing:** 500ms minimum between repeat taps on same target

#### Adult Zone Buttons
- **Minimum size:** 44×44pt (Apple HIG floor)
- **Primary buttons:** Filled with Accent-Success background, white text
- **Secondary buttons:** Outlined (1pt border Neutral-Border), text in Text-Primary
- **Tertiary/text buttons:** Text only, no background
- **Hover state (web portal):** Subtle background change (Surface-Secondary)
- **Focus indicator (portal):** 2pt outline in Accent-Success, 2pt offset

---

### 1.8 Feedback & Haptics

**Haptic strategy in the child zone:**
- Default: **Disabled.** Build with haptics as an opt-in.
- When enabled, use `.impactOccurred()` (light) only, never transient.
- **No haptic on failure or ambiguous states.** Haptic = positive signal only.
- Optional haptic schedule: on trial correct (if enabled), on reward reveal (if enabled).

**Audio feedback in the child zone:**
- **No background music by default.** Music is opt-in in Sensory Panel.
- **Short, human-voice audio prompts only** — no synthesized beeps or musical tones.
- **Every audio independently mutable** in Sensory Panel (voice, effects, music).
- **Latency guarantee:** Audio playback starts ≤50ms from trigger.

---

## PART 2: COMPONENT LIBRARY

### 2.1 Session Card (Child Zone)

```
┌─────────────────────────────────────┐
│ [Icon] Target Name                  │
│ (NO TEXT — icon + speech label only)│
│                                     │
│        [Large Icon/Photo]           │
│        (referent object)            │
│                                     │
│      ✓ [Select me / Tap to go]     │
│                                     │
│     Current cue level shown          │
│    (adult-only label, small)         │
└─────────────────────────────────────┘
```

**Specs:**
- Width: Full-bleed with 16pt gutter
- Height: Varies (≥180pt min for tall touch target)
- Background: Surface-Primary
- Shadow: Card shadow
- Tap target: Full card is tappable, ≥64pt min height
- Referent image: Centered, ≤280pt wide, fills available width
- Label: SF Symbols icon (40pt) + text label (adult-only, 14pt, Text-Secondary)
- Cue-level indicator: Small badge bottom-right, "L1" or similar (adult-only, 12pt)

---

### 2.2 Trial State Container

**During practice, the main content area contains:**

```
┌────────────────────────────────────┐
│  [Companion mouth close-up]        │
│  (slowed video on press)           │
│                                    │
│  [Repeat button - 40pt]            │
│  ────────────────────────────────  │
│                                    │
│  [Open-ended attempt window]       │
│  "Your turn" — spoken + visual     │
│  (companion turns to look, mic     │
│   ring pulses slowly)              │
│                                    │
│  [Parent three-tap score buttons]  │
│  ✓  ○  ✗  (optional, <1s)         │
│                                    │
│  [Coaching strip — parent only]    │
└────────────────────────────────────┘
```

**Specs:**
- **Model video:** Full-width, 240–320pt height, mouth close-up, centered, no letterbox
- **Repeat button:** 40pt icon, centered below video
- **Attempt window:** Visual prompt (companion turns head left or looks toward mic) + soft audio cue ("ready")
- **Scoring buttons (parent-visible only):** Three large buttons (64pt each), horizontal layout, ≥16pt spacing
  - Left button: Green (Accent-Success) checkmark — "Got it"
  - Center button: Gray (Neutral-Border) circle — "Close" / "Approximation"
  - Right button: Muted warm (Accent-Caution) minus — "Not yet" / "Try again"
- **Coaching strip:** 1–2 lines max, 14pt type, Text-Secondary, background Surface-Secondary, always visible to parent

---

### 2.3 Transition Countdowns (Concrete Tokens)

**NO abstract timer bars. Instead: physical, disappearing tokens.**

```
┌─────────────────────────────────┐
│  Two more, then we're done      │  ← Verbal
│                                 │
│  ●  ●  (filled circles)        │  ← Visual tokens
│                                 │
│  [Continue with practice]       │
└─────────────────────────────────┘

→ After trial 1:
│  ●     (one filled, one empty)  │

→ After trial 2:
│        (both empty)             │  → Celebration
```

**Specs:**
- Tokens: 16pt filled circles (Accent-Caution color), 16pt spacing
- Text: Literal, concrete language (e.g., "Two more, then snack time" if parent set that)
- No abstract bar; no progress percentage
- Tokens disappear on-screen as countdown progresses (not fading; actual removal)

---

### 2.4 End-of-Session Ritual (Identical Every Time)

```
STEP 1: CELEBRATION (3–5 seconds)
┌──────────────────────┐
│  🎉 Great work!     │  ← Spoken + visual
│                      │
│  [Animated sequence  │
│   of earned items    │
│   revealing]         │
└──────────────────────┘

STEP 2: COLLECTION SHELF (2–4 seconds, scrollable)
┌──────────────────────────┐
│  Your collection        │  ← Label (adult-visible)
│                          │
│ [Item] [Item] [Item]    │  ← Recently earned items
│ [Item] [Item] [Item]    │     scroll horizontally
│                          │
└──────────────────────────┘

STEP 3: GOODBYE (2–3 seconds)
┌──────────────────────┐
│  See you tomorrow!  │  ← Spoken + visual
│  (companion waves)   │
│                      │
│  [Fade to home]     │
└──────────────────────┘

→ App closes to home automatically (never remains in-session)
```

**Specs:**
- Celebration animation: ≤2.5s total, respects reduce-motion (no animation, just reveal)
- Collection reveal: Items appear in sequence, scrollable horizontally, ≥120×120pt items
- Goodbye sequence: Spoken by companion, repeats on tap (optional)
- No "continue?" prompt; no upsell

---

### 2.5 AAC Core Board (Talk Surface)

**40-cell fixed grid, never reorganizes.**

```
┌──────────────────────────────────┐
│ TALK (AAC Board)                 │
│ [Close/Home] [Settings]          │  ← Breadcrumb (optional)
│                                  │
│  ┌────┬────┬────┬────┬────┐     │
│  │    │    │    │    │    │     │
│  │ [1]│[2] │[3] │[4] │[5] │     │  40 cells
│  │    │    │    │    │    │     │  organized in
│  ├────┼────┼────┼────┼────┤     │  8 rows × 5 cols
│  │    │    │    │    │    │     │
│  │[6] │[7] │[8] │[9] │[10]│    │
│  │    │    │    │    │    │     │
│  ...  ... cells ...  ...  ...   │
│  │    │    │    │    │    │     │
│  │[36]│[37]│[38]│[39]│[40]│    │
│  │    │    │    │    │    │     │
│  └────┴────┴────┴────┴────┘     │
│                                  │
│ When tapped:                     │
│  • Voice model plays (0.5s)      │
│  • Icon button stays pressed     │
│  • No modal or popup             │
└──────────────────────────────────┘
```

**Specs:**
- Grid: 5 columns × 8 rows = 40 cells
- Cell size: ≥56×56pt (child-zone minimum 64pt, but AAC allows slightly smaller for 40-cell grid density)
- Spacing: 12pt between cells
- Background: Surface-Primary (matches session cards)
- Cell content: 
  - Icon or real photograph (32pt in center)
  - Text label below icon (12pt, Text-Secondary; adult-only)
  - No text in child's primary view
- Tap feedback: Slight color invert for 200ms (button press effect)
- Audio: Plays current speech target's voice model; child can hear what the word sounds like
- Position: **Absolutely fixed.** Targets assigned to fixed positions; positions never shuffle

**Current speech targets auto-populate:** When an SLP adds a new target (e.g., "up, on, mama"), the app places it in an available AAC button at a fixed position. That position stays constant for that target's lifetime.

**Mirror mode:** If family has Proloquo2Go/LAMP/TouchChat installed, a toggle in Settings enables "Mirror mode" — Praxia mirrors the target word and image but defers playback to the family's AAC app.

---

### 2.6 Collection View (Collection Surface)

```
┌────────────────────────────────────┐
│ COLLECTION (Earned items)         │
│                                    │
│ [Category 1] >  (e.g., "Animals") │  ← Tappable category
│ [Category 2] >  (e.g., "Vehicles")│
│ [Category 3] >  (e.g., "Food")    │
│ [Category 4] >  (e.g., "Actions") │
│                                    │
│ When category tapped:              │
│ ┌───────────────────────────────┐  │
│ │ [Item] [Item] [Item]          │  │
│ │ [Item] [Item] [Item]          │  │
│ │ [Item] [Item] [Item]          │  │
│ │ (scrollable, never lost)      │  │
│ └───────────────────────────────┘  │
└────────────────────────────────────┘
```

**Specs:**
- Category structure: 4–6 high-level categories (Animals, Vehicles, Actions, Food, People, Objects)
- Category rows: 64pt height, tappable, tap indicator arrow (chevron)
- Tap animation: Smooth slide-in of item grid below category (≤300ms)
- Items: 120×120pt thumbnails, 3-column grid on phone (scales to 4–5 on tablet)
- Item display: Real photograph or illustration (from the child's practice targets or generic category items)
- Item labels: None in child view; text labels visible to parent if they open
- Completion: No "finish collecting" endpoint; collection is infinite and low-pressure
- Progression: Items earned contingent on attempts made, not accuracy (every 5–10 practice trials, one random item unlocks)

---

## PART 3: SCREEN DESIGNS — CHILD ZONE

### 3.1 Home Screen (Child Zone)

```
┌─────────────────────────────────┐
│                                 │
│  [Companion greeting, wave]     │  ← Real mouth, short video
│  "Hi! Ready to practice?"       │    or still image
│                                 │
│  ─────────────────────────────  │
│                                 │
│  Today:                         │
│  [Session Card 1: "ma"]        │  64pt + card
│  [Session Card 2: "up"]        │  layout
│  [Session Card 3: "ba"]        │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  Quick Access (always visible):│
│  [TALK] [COLLECTION] [HOME]    │  40pt icons
│                                 │
└─────────────────────────────────┘
```

**Specs:**
- Greeting: Animated companion mouth (if enabled; still image if reduce-motion), one sentence max, spoken audio
- Session cards: 3–5 available targets, scrollable vertically
- Quick access bar: Always bottom-anchored, 3 buttons: Talk (AAC), Collection, Home
- Layout: Single column, depth = 1 (no nested navigation)
- Entry point: App launches directly to this screen (no splash, no loading)

---

### 3.2 Practice Session Screen (Play)

**This is the core loop. Every session follows this identical skeleton:**

```
PHASE 1: SETUP (5–10 seconds)
┌─────────────────────────┐
│ [Companion]             │
│ "Choose your voice:"    │
│ [Voice A] [Voice B]     │  ← 2–3 voice options
│ (and/or target order?)  │
│                         │
│ [Ready? Tap here]       │  ← Large button
└─────────────────────────┘

PHASE 2: GREETING (3–5 seconds)
┌─────────────────────────┐
│ [Companion]             │
│ "Great! Let's go!"      │  ← Spoken, real-mouth
│ [Any key to begin]      │
└─────────────────────────┘

PHASE 3: TRIAL LOOP (60–80 trials, ~10 minutes)
┌─────────────────────────────────┐
│ [Model video — real mouth, L0–L5]
│ Close-up, slowed if L1, loop on tap
│                                 │
│ [Repeat button]                 │
│                                 │
│ ──── ATTEMPT WINDOW ────        │
│ [Companion looks toward mic]    │
│ Soft "ready" audio              │
│ Mic ring pulse (slow)           │
│                                 │
│ [Optional: Parent 3-tap score]  │
│ ✓ (got it) ○ (close) ✗ (try)   │
│                                 │
│ [Coaching note, 1 line]         │
│                                 │
│ Progress: "2 more, then done"   │
│ ●  ●  (token countdown)         │
└─────────────────────────────────┘

PHASE 4: END RITUAL (5–8 seconds)
[See Section 2.4]

PHASE 5: CLOSE
Auto-dismiss to home screen
```

**Specs:**
- Each phase transitions with no prompt (except "Ready? Tap" for setup)
- Timing: Setup (auto 5–10s) → Greeting (auto 3–5s) → Trials (10 min max or trial target) → Ritual (5–8s auto) → Home
- No session can run >10 minutes
- Session never ends on a failed trial; always ends during celebration ritual
- All timing is background (no countdown visible to child)

---

### 3.3 AAC Board (Talk Surface) — Detailed

```
┌──────────────────────────────────┐
│ [Close to Home]  [Settings/Menu]│  ← Breadcrumb only if needed
│                                  │
│ TALK                             │  ← Icon + word label
│                                  │
│  ┌────┬────┬────┬────┬────┐    │
│  │    │    │    │    │    │    │
│  │ up │ on │ ma │ ba │ go │    │
│  │ [↑]│ [●]│[m@]│[b@]│[→]│    │
│  │    │    │    │    │    │    │
│  ├────┼────┼────┼────┼────┤    │
│  │    │    │    │    │    │    │
│  │ eat│ dog│baby│ bye│ hi │    │
│  │[∨] │ [🐕]│[👶]│[👋]│[👋]│    │
│  │    │    │    │    │    │    │
│  └────┴────┴────┴────┴────┘    │
│                                  │
│ When tapped:                      │
│ • Voice model plays (0.5–1s)     │
│ • Button highlights for 200ms    │
│ • No modal; return to grid       │
│                                  │
│ [Play again?  Tap any button]   │  ← Spoken prompt
└──────────────────────────────────┘
```

**User journey:**
1. Child taps Talk icon (anywhere in app)
2. AAC board loads (no transition animation, instant reveal)
3. Child taps word/image
4. Voice model plays
5. Button brief highlight
6. Optional: Child taps same or different word
7. Tap Home icon to return to session or main screen
8. AAC never closes on its own; child controls exit

---

### 3.4 Collection (Collection Surface) — Detailed

```
┌──────────────────────────────────┐
│ [Home]               [Settings]  │
│                                  │
│ COLLECTION                       │
│ (Your things)                    │
│                                  │
│ • Animals                    >   │  ← Category row
│ • Vehicles                   >   │
│ • Actions                    >   │
│ • Food                       >   │
│ • People                     >   │
│ • Objects                    >   │
│                                  │
│ When "Animals" tapped:           │
│                                  │
│  [< Animals]                     │  ← Back button
│                                  │
│  [Cat] [Dog] [Bird]             │  120×120pt items
│  [Fish] [Bunny] [Cow]           │
│  [Bird] [Squirrel] [Duck]       │
│  [Lion] [Tiger] ...             │
│  (scrollable, endless)           │
│                                  │
│ Tap an item to see it full-     │
│ screen (if implemented)         │
│                                  │
└──────────────────────────────────┘
```

**Specs:**
- 6 top-level categories (fixed)
- Category rows: 56pt height, full-width, tappable, chevron icon right-aligned
- Tap transitions to filtered grid
- Grid: 3 columns on phone, 4 on tablet; 120×120pt items, 12pt spacing
- Back button: Top-left, tappable, returns to category list
- Items: Real photographs (not illustrations), neutral backgrounds
- Scroll: Vertical scroll within category; collection never "completes"
- Long-term: Items accumulate over weeks/months (never lost)

---

## PART 4: SCREEN DESIGNS — ADULT ZONE (Parent & Clinician Surfaces)

### 4.1 Parent Today Screen

**Purpose:** "What do we practice today, and how am I doing?"

```
┌──────────────────────────────────────┐
│ Today          [← Praxia name/home]  │
│ [Date: Fri, Sep 11]                  │
│                                      │
│ READY TO PRACTICE                    │
│ This session is loaded and ready.   │
│ [Current session: "ma", "ba", "up"]  │
│ [Complexity: easy]                   │
│                                      │
│ ┌──────────────────────────────────┐│
│ │ [Hand device to child]            ││  ← Action card
│ │ Child opens and starts.           ││  Coaching strip in-session
│ └──────────────────────────────────┘│
│                                      │
│ ─────────────────────────────────── │
│                                      │
│ THIS WEEK                            │
│ • Mon: ✓ (40 trials)                │  ← Week heatmap
│ • Tue: ✓ (65 trials)                │     (non-streak, neutral re-entry)
│ • Wed: ✗ (0 trials)                 │
│ • Thu: ✓ (55 trials)                │
│ • Fri: [Today]                      │
│ • Sat: –                            │
│ • Sun: –                            │
│                                      │
│ Goal this week: 4 days  [Progress]  │  ← Bucket goal (not consecutive)
│ (currently: 3 days)                 │    Loss-free reframing
│                                      │
│ ─────────────────────────────────── │
│                                      │
│ LAST SESSION (Yesterday)             │
│ 62 trials completed                 │
│ Cue levels: mostly L2–L3            │
│ [View video clip] [View transcript] │
│                                      │
│ ────────────────────────────────────│
│                                      │
│ COACHING TIP OF THE DAY             │
│ "Approximations count as words."   │
│ [Why? (tap for ≤90s lesson)]        │
│                                      │
└──────────────────────────────────────┘
```

**Specs:**
- Header: Simple "Today" label, date (if helpful, optional)
- Ready-to-practice card: Minimal friction; shows session targets and complexity
- Hand-to-child prompt: Encourages the parent to launch the session
- Week heatmap: 7-day grid with checkmarks (not a streak). 4 days is the goal. No "lost" state; missed day is neutral (blank)
- Bucket goal: "4 days this week" — achievable even after a miss. Shows progress against goal (e.g., "3 of 4")
- Last session summary: Brief stats (trial count, cue-level distribution), optional clip/transcript viewer
- Coaching tip: Context-sensitive micro-lesson (≤90s video or audio)
- Navigation: Bottom tabs (Today, Progress, Clips, Learn, My SLP, Settings)

---

### 4.2 Parent Progress Screen

**Purpose:** "How is my child progressing over 12 weeks?"

```
┌──────────────────────────────────────┐
│ Progress       [← Back]              │
│ [Date range: 12 weeks]   [Pick range]│
│                                      │
│ CUES & DIFFICULTY (Primary)         │
│ ┌────────────────────────────────┐  │
│ │         Chart: % by cue level  │  │
│ │ L0 ▓▓░░░░  (8%)               │  │
│ │ L1 ▓▓▓▓▓░░  (28%)             │  │
│ │ L2 ▓▓▓▓▓▓▓░ (38%)  ← highest  │  │
│ │ L3 ▓▓▓░░░░  (18%)             │  │
│ │ L4 ▓░░░░░░  (4%)              │  │
│ │ L5 ░░░░░░░  (2%)              │  │
│ │                                │  │
│ │ Trend: Moving toward less     │  │
│ │ support. That's progress!     │  │
│ └────────────────────────────────┘  │
│                                      │
│ ────────────────────────────────── │
│                                      │
│ SOUNDS YOUR CHILD USES             │
│ Consonants: m, b, p, h, w         │  ← Inventory
│ Vowels: /ɑ/ /i/ /u/ /o/           │
│ Syllable shapes: V, CV, VC        │
│                                      │
│ 12 weeks ago:                      │
│ Consonants: m, b                   │  Shows growth
│ Vowels: /ɑ/ /i/                   │
│ Syllable shapes: V                 │
│                                      │
│ ────────────────────────────────── │
│                                      │
│ COMMUNICATION MODE                  │
│ AAC-only  ▓░░░░ (20%)             │  ← Modality ratio
│ AAC + voice ▓▓▓░░ (40%)           │
│ Voice-only ▓▓▓░░ (40%)            │
│                                      │
│ 12 weeks ago: AAC-only (100%)     │
│                                      │
│ ────────────────────────────────── │
│                                      │
│ TARGETS STATUS                      │
│ ✓ Mastered: "up" (3 wks ago)      │  ← Target list
│ ◐ Progressing: "ba", "ma", "on"   │  Scrollable
│ ◑ Stuck: "go" (3+ wks no move)   │  (stuck flags clinician)
│ ◯ On hold: (per SLP request)      │
│                                      │
│ [IEP-ready report]  [Export data]   │
│                                      │
└──────────────────────────────────────┘
```

**Specs:**
- Date range: Default 12 weeks; swipe or tap to change (4w, 8w, 12w, all-time)
- Cue-level chart: Stacked bar or horizon chart, showing distribution shift over time (movement right = progress)
- Inventory map: Consonants, vowels, syllable shapes listed and compared to baseline
- Modality ratio: Pie or donut chart showing AAC-only vs. mixed vs. voice-only over time
- Targets table: Sortable by status (Mastered, Progressing, Stuck, On Hold); clicking each shows attempts, accuracy %, cue fading, and dates
- Stuck target flag: Visual indicator ("⚠" or "flag") on targets ≥3 weeks without upward movement; one-tap message to SLP
- Export: IEP-ready report + raw data CSV

**Key principle:** Every metric is clinically meaningful (cue-level distribution, inventory, modality) and measurable without requiring ML. No PCC, no magic scores.

---

### 4.3 Parent Clips Screen

**Purpose:** "Show me my child's voice progression."

```
┌──────────────────────────────────────┐
│ Clips              [Filter]          │
│                                      │
│ BEFORE & AFTER (Primary)            │
│ ┌──────────────────────────────────┐│
│ │ [Week 2 — "ma" progression]      ││
│ │ │ ▶ 6 weeks ago: "m..." (0.3s)  ││  Auto-curated comparison
│ │ │ ▶ Today: "mama" (0.8s)        ││
│ │ │ Child improved clearly        ││
│ │ [Download / Share]              ││
│ └──────────────────────────────────┘│
│                                      │
│ ┌──────────────────────────────────┐│
│ │ [Week 5 — "up" progression]      ││
│ │ │ ▶ 9 weeks ago: [silence]      ││
│ │ │ ▶ Today: "uh" (0.5s)          ││
│ │ [Download / Share]              ││
│ └──────────────────────────────────┘│
│                                      │
│ ────────────────────────────────── │
│                                      │
│ KEEPSAKES (Manual)                  │
│ These clips are saved beyond 90 days│
│                                      │
│ ┌──────────────────────────────────┐│
│ │ [Personal favorite: "mama"]      ││  ← Parent-favorited clip
│ │ 2 weeks ago                      ││
│ │ ▶ [0:00] ────●──── [0:01]       ││  Player with timeline
│ │ [Download / Delete]              ││
│ └──────────────────────────────────┘│
│                                      │
│ ┌──────────────────────────────────┐│
│ │ [Milestone: First "hi" attempt]  ││
│ │ 8 weeks ago                      ││
│ │ ▶ [0:00] ────●──── [0:02]       ││
│ │ [Download / Delete]              ││
│ └──────────────────────────────────┘│
│                                      │
│ ────────────────────────────────── │
│                                      │
│ All clips can be deleted at any time│
│ per-clip delete button always shown │
│                                      │
└──────────────────────────────────────┘
```

**Specs:**
- Before/after: Auto-curated, populated by day 10 of use (first baseline vs. best attempt at week 2)
- New before/after pairs generated every 2 weeks
- Keepsakes: Manually starred by parent; retained beyond 90-day default
- Clip player: Play controls, 0.5×/1.0×/1.5×/2.0× speed control, timeline scrubbing
- Download: Option to save locally or share (audio file only, no metadata)
- Delete: Per-clip delete button, no undo (but clips can be re-generated from server backup)
- Filtering: By target, date, or manually starred
- Consent: Clips only exist if parent consented to on-device retention and (optional) cloud storage

---

### 4.4 Parent Learn Screen

**Purpose:** "Short, contextual education about CAS and practice."

```
┌──────────────────────────────────────┐
│ Learn              [Search]          │
│                                      │
│ PERSONALIZED FOR YOU                │
│ (based on targets + stage)           │
│                                      │
│ ┌──────────────────────────────────┐│
│ │ ► "Approximations count as words"││  ← Micro-lesson
│ │   2:15  Why? How? Examples       ││     (≤90s video or audio)
│ │   [Watched]                      ││
│ └──────────────────────────────────┘│
│                                      │
│ ┌──────────────────────────────────┐│
│ │ ► "Wait time: why long pauses    ││
│ │    help your child try harder"   ││
│ │   4:30  This week's recommendation
│ │   [Not watched]                  ││
│ └──────────────────────────────────┘│
│                                      │
│ ┌──────────────────────────────────┐│
│ │ ► "AAC does not delay speech"    ││
│ │   6:45  Research & your child    ││
│ │   [Watched]                      ││
│ └──────────────────────────────────┘│
│                                      │
│ ─────────────────────────────────── │
│                                      │
│ LIBRARY (All lessons)               │
│ [CAS basics] [Practice tips]        │  ← Categories
│ [AAC]       [Managing frustration]  │
│ [Progress]  [Handling setbacks]     │
│                                      │
│ ┌──────────────────────────────────┐│
│ │ ► "What is Childhood Apraxia"    ││
│ │   5:10                           ││
│ └──────────────────────────────────┘│
│                                      │
│ ┌──────────────────────────────────┐│
│ │ ► "The stages of practice"       ││
│ │   3:45                           ││
│ └──────────────────────────────────┘│
│                                      │
│ ... (scrollable)                    │
│                                      │
│ Note: Every lesson rated by parents.│
│ We improve the most useful ones.   │
│                                      │
└──────────────────────────────────────┘
```

**Specs:**
- Personalized section: Shows 3–5 lessons tailored to current targets and practice stage (Phase 0, early acquisition, refining, generalising)
- Micro-lessons: ≤90 seconds each; video preferred with captions; audio acceptable
- Categories: 6–8 high-level categories (CAS basics, Practice tips, AAC, Behavior, Progress, Setbacks, etc.)
- Watched/unwatched indicator: Visual checkmark or "New" badge
- Optional: Parent can mark lesson as "not helpful" to improve recommendation
- Access: No paywall; all lessons free
- Sourcing: Created by SLP advisory board; new lessons added every 2–4 weeks

---

### 4.5 Parent My SLP Screen

**Purpose:** "Link to my child's clinician, receive coaching, see videos."

```
┌──────────────────────────────────────┐
│ My SLP            [Link/Unlink]      │
│                                      │
│ YOUR CLINICIAN                       │
│ ┌──────────────────────────────────┐│
│ │ Karen Chen, CCC-SLP              ││  ← SLP name
│ │ Pediatric Speech Clinic          ││
│ │ karen@clinic.example.com         ││
│ │ [Last contact: 2 days ago]       ││
│ └──────────────────────────────────┘│
│                                      │
│ ─────────────────────────────────── │
│                                      │
│ MESSAGES & VIDEO REPLIES (Async)   │
│ ┌──────────────────────────────────┐│
│ │ [2 days ago]                     ││
│ │ Karen: "Nice progress on 'ma'!"  ││  ← Text message
│ │ [Watch 45s video]  [Reply]       ││
│ │ (embedded video thumbnail)       ││
│ └──────────────────────────────────┘│
│                                      │
│ ┌──────────────────────────────────┐│
│ │ [4 days ago]                     ││
│ │ You (Danielle): "Is 'ba' close   ││
│ │ enough to count? He's frustated."││
│ │ [Send to SLP] [View SLP reply]    ││  ← Parent-initiated message
│ │ (pending response from Karen)     ││
│ └──────────────────────────────────┘│
│                                      │
│ ────────────────────────────────── │
│                                      │
│ TARGETS & CUES (SLP Controls)       │
│ "Your SLP controls the practice    │
│  targets. Current targets:"         │
│ • "ma" – Level 1 (simultaneous)    │  ← Read-only for parent
│ • "ba" – Level 2 (together, normal)│
│ • "up" – Level 3 (imitation)       │
│ • "on" – Level 1                   │
│ [Request a new target]             │  One-tap message
│                                      │
│ ────────────────────────────────── │
│                                      │
│ SEND A MESSAGE                      │
│ [Text message to SLP]              │  Quick message form
│ "How much practice is enough?"     │  (max 160 chars, like SMS)
│ [Send]                             │
│                                      │
│ Note: Karen typically replies     │
│ within 1–2 business days.         │
│                                      │
└──────────────────────────────────────┘
```

**Specs:**
- SLP profile: Name, credential, clinic/location, last-contact timestamp
- Messages: Threaded, chronological (newest first option available)
- Video replies: 20–60 second async videos from SLP; embedded thumbnail, tap to play in modal
- Parent messages: Max 160 characters (SMS-like), text or emoji
- Sent messages: Show pending/read/replied status
- Targets read-only: Parent sees what SLP set; cannot modify (SLP controls via portal)
- One-tap message: "Request a new target" or "Target is stuck" — pre-filled template to SLP
- Notification: Parent gets push notification on new SLP message (if opted in)

---

### 4.6 Parent Settings — Sensory Panel

**Purpose:** "Adjust sounds, motion, brightness, haptics, consent."

```
┌──────────────────────────────────────┐
│ Settings           [Back]            │
│                                      │
│ SENSORY SETTINGS (Child experience) │
│ These affect what your child sees   │
│ and hears during practice.          │
│                                      │
│ ── AUDIO ──                         │
│ [🔊] Voice models              [ON] │  Toggle switches
│ [🎵] Background music          [OFF]│  (defaults shown)
│ [🔔] Session sounds/effects    [ON] │
│ [Adjust volume slider]  ◄─────────► │  Dedicated volume control
│                                      │
│ ── MOTION ──                        │
│ [✨] Animations & transitions  [ON] │
│ [⚡] Haptics (tap feedback)    [OFF]│
│ [🎬] Reward animations speed:      │
│       [Low] ───●─── [High]         │
│                                      │
│ Model playback speed:               │
│ [Slow] ───────●──── [Normal]       │
│                                      │
│ ── DISPLAY ──                       │
│ [🌓] Dark mode                  [OFF]│
│ [◐] Brightness       ───●──────────│
│ [↔] Contrast          ───●──────────│
│                                      │
│ ── ACCESSIBILITY ──                │
│ [⏱] Automatically honor            │
│     OS "Reduce Motion" setting  [ON]│
│ [⏱] Automatically honor            │
│     OS "Reduce Transparency"    [ON]│
│ [⏱] Automatically honor            │
│     OS "Reduce Contrast" setting[ON]│
│                                      │
│ ────────────────────────────────── │
│                                      │
│ PRACTICE SETTINGS                   │
│                                      │
│ Practice duration (default 10 min)  │
│ [5 min]  [10 min] [15 min] [Custom]│  Radio buttons
│                                      │
│ Session ends on:                    │
│ [Auto end at time/trial target] [ON]│
│                                      │
│ Parent scoring:                     │
│ [Show 3-tap scoring buttons]    [ON]│  (app works at OFF)
│                                      │
│ Variable rewards:                   │
│ "Your child gets a surprise        │
│  about every 4 attempts."           │
│ [Adjust frequency]     ◄───●────►  │  Disable / 2 / 4 / 6 / 10 attempts
│ [Disable rewards entirely]         │
│                                      │
│ ────────────────────────────────── │
│                                      │
│ CONSENT & PRIVACY                   │
│                                      │
│ [📝] On-device recording       [✓]  │  Layered consent
│ [☁️] Upload to cloud           [✗]  │  (each independent)
│ [👩‍⚕️] Share with SLP            [✓]  │
│ [🧠] Model training          [✗]  │
│ [📊] Research publication    [✗]  │
│                                      │
│ [Detailed consent forms]            │
│ (link to full terms + withdrawal)   │
│                                      │
│ ────────────────────────────────── │
│                                      │
│ DATA & AUDIT                        │
│ [📊] View my data               →   │  CSV export
│ [📋] Audit log (who listened)   →   │  Full history of access
│ [🗑️] Delete my child's data     →   │  One-tap, 30-day deletion
│ [⬇️] Download my child's data   →   │  ZIP of all files
│                                      │
│ ────────────────────────────────── │
│                                      │
│ ACCOUNT                             │
│ Child: Mateo (3y2m)                │
│ Guardian: Danielle Torres          │
│ Email: danielle@example.com        │
│ [Change password]                  │
│ [Manage child profiles]            │
│ [Logout]                           │
│                                      │
│ ── ABOUT ──                         │
│ Version 1.0 (Build 1)              │
│ [Support/Help]  [Privacy Policy]   │
│ [Terms]         [Acknowledgments]  │
│                                      │
│ "CAS progress is measured in       │
│  months, not days. We're with you."│
│                                      │
└──────────────────────────────────────┘
```

**Specs:**
- Sensory panel: Always accessible (not hidden behind a settings tab)
- Defaults: Low-stimulation (music off, animations on but slow, haptics off, dark mode off)
- Automatic honors OS settings: If device has "Reduce Motion" enabled, app disables all animations regardless of in-app setting
- Consent toggles: Independent; each records timestamp, policy version, verification method
- Data export: CSV of trial log; ZIP of all media
- Audit log: Parent can see every instance of "clinician reviewed clips" + timestamp + SLP name
- Delete: One-tap delete initiates 30-day countdown (compliance with COPPA); deletion cascades to cloud + backups

---

## PART 5: CLINICIAN PORTAL — WEB (Next.js)

### 5.1 Portal Home — Triage Queue

**Purpose:** "Show me which of my 8 kids need my attention most this week."

```
┌────────────────────────────────────────┐
│ Praxia Clinician Portal                │
│ [Logout] [Settings]                    │
│                                        │
│ YOUR CASELOAD (8 children)             │
│ Sorted by: "Needs You Most"            │
│                                        │
│ 1. Mateo Chen (3y2m)                  │  ← Triage row
│    ⚠ Target "ma" stuck 4 weeks       │  ← Signal: red flag
│    Practice: 5/5 this week (goal: 5) │  ← Practice volume
│    Last review: 6 days ago           │
│    [View child] [Review clips]       │
│    ─────────────────────────────────  │
│                                        │
│ 2. Aisha Lopez (5y7m)                 │
│    ✓ Progressing well ("ba" → L3)    │  ← Signal: good progress
│    Practice: 3/5 this week           │
│    Last review: 2 days ago           │
│    [View child] [Review clips]       │
│    ─────────────────────────────────  │
│                                        │
│ 3. Kai Washington (4y1m)              │
│    ⚠ Over-practicing (9 sessions)    │  ← Signal: caution flag
│    Practice: 7/5 this week (goal: 5) │
│    Last review: 5 days ago           │
│    [View child] [Review clips]       │
│    ─────────────────────────────────  │
│                                        │
│ 4. Sofia Rossi (3y9m)                 │
│    ─ No activity this week           │  ← Signal: neutral
│    Practice: 0/5 this week           │
│    Last review: 10 days ago          │
│    [View child] [Contact parent]     │
│    ─────────────────────────────────  │
│                                        │
│ 5. ... (more children)                │
│                                        │
└────────────────────────────────────────┘
```

**Specs:**
- Triage sorting: Custom sort options (Needs You, Practice Volume, Last Reviewed, Alphabetical)
- Signals:
  - ⚠ Red: Stuck target (≥3 weeks no progress), Over-practice, Safety flag, or Aversion signal
  - ✓ Green: Good progress, target advancing
  - ─ Gray: No activity, off schedule
- Per-child row shows: Name & age, primary signal, practice volume vs. goal, last review date, action buttons
- Time budget: Each row is one scannable line; entire queue ≤2 min to assess
- Action buttons: [View child] (opens child detail), [Review clips] (opens clip review), [Contact parent] (email/message)

---

### 5.2 Child Detail — Targets & Cue Control

**Purpose:** "Adjust targets and cue levels for one child."

```
┌────────────────────────────────────────┐
│ ← Back to Caseload                     │
│                                        │
│ Mateo Chen (3y2m) · Cincinnati clinic │
│ [Edit program]  [View progress]       │
│                                        │
│ TARGET LIST                            │
│ [+ Add target]                         │
│                                        │
│ ┌────────────────────────────────────┐│
│ │ "ma" [Edit] [Retire]               ││  ← Active target row
│ │ Level: L1 → L2 → L3 (current: L1)  ││  ← Cue progression
│ │ Status: Advancing (3 attempts at L2││
│ │ after 5 at L1)                     ││
│ │ Last model: 8 days ago (re-record?)││
│ │ Home practice: 42 attempts last week││
│ │ Accuracy (parent score): 71%       ││
│ │ [View clip gallery for "ma"]       ││
│ └────────────────────────────────────┘│
│                                        │
│ ┌────────────────────────────────────┐│
│ │ "ba" [Edit] [Retire]               ││
│ │ Level: L1 (current)                ││
│ │ Status: Learning (57 attempts)     ││
│ │ Last model: 15 days ago (UPDATE!)  ││
│ │ Home practice: 65 attempts last week
│ │ Accuracy: 58%                      ││
│ │ [View clip gallery]                ││
│ └────────────────────────────────────┘│
│                                        │
│ ┌────────────────────────────────────┐│
│ │ "up" [Edit] [Retire]               ││
│ │ Level: L1 → L2 → L3 (current: L3)  ││
│ │ Status: Refining (36 attempts at L3││
│ │ over 2 weeks)                      ││
│ │ Ready to probe (untreated items)?  ││  ← SLP decision point
│ │ [Add generalisation probe]         ││
│ │ [View clip gallery]                ││
│ └────────────────────────────────────┘│
│                                        │
│ Retired targets (past 3 months):       │
│ • "on" (retired 5 weeks ago, L3)     │  ← Collapsed section
│ • "ee" (retired 7 weeks ago, L2)     │
│ [View maintenance probe for "on"]    │
│                                        │
│ ────────────────────────────────────  │
│                                        │
│ SETTINGS                               │
│ Session duration:     [10 min]        │  ← Clinician-adjustable
│ Trial target per session: [70 attempts]
│ Minimum weekly sessions: [2]          │
│ Practice schedule:     [Blocked] v    │  ← Fading options
│ Feedback type:       [Performance-KP] v
│ Intensive mode:       [Off]           │
│   (or: [On: 3x/wk for 4 weeks])      │
│                                        │
│ [Save changes] [Reset to defaults]   │
│                                        │
│ Advanced audio settings (if tuning):  │
│ [SNR threshold] [Latency target]     │
│                                        │
└────────────────────────────────────────┘
```

**Specs:**
- Active target rows: Show level progression, accuracy, practice volume, and status at a glance
- Edit button: Pops modal to change target, cue bounds, add/remove orthogonal dimensions
- Retire button: Marks target as complete; if still needed, can be re-added
- Model status: Flag if model video is outdated (e.g., >10 days without update) — suggests re-recording
- Settings: Global per-child configuration (session length, feedback type, intensive mode)
- Minimal UI: Every piece of information is actionable or diagnostic; no vanity metrics
- Keyboard navigation: Tab through rows, arrow keys to expand/collapse, Enter to edit

---

### 5.3 Clip Review — Keyboard-Driven

**Purpose:** "Review & score 10–20 clips per child in ~3 minutes."

```
┌────────────────────────────────────────┐
│ ← Back to Child                        │
│                                        │
│ CLIP REVIEW · Mateo Chen              │
│ [Filter: New targets] [Random] [All]  │
│ Clips to review: 12                   │
│                                        │
│ ┌────────────────────────────────────┐│
│ │ Clip 1 / 12   [Playing]            ││
│ │                                    ││
│ │ Target: "ba"  |  Cue Level: L1    ││  ← Clip metadata
│ │ Date: Sep 10, 3:45 PM              ││
│ │ Duration: 0.6s                     ││
│ │ Parent score: [✓ Got it]           ││  ← Parent's call
│ │                                    ││
│ │ ┌──────────────────────────────┐  ││
│ │ │     [Audio waveform player]   │  ││  ← Embedded player
│ │ │ ▶ [─────●────────] 0.6s       │  ││
│ │ │ [Slow] [Normal] [Fast]        │  ││
│ │ │ [Repeat]  [Mark for later]    │  ││
│ │ └──────────────────────────────┘  ││
│ │                                    ││
│ │ MY ASSESSMENT (keyboard scoring)   ││
│ │ ┌──────────────────────────────┐  ││
│ │ │ IPA transcription: [ba]       │  ││  ← Text input
│ │ │ Cue level actually needed: L1 │  ││  ← Dropdown
│ │ │ Correctness:  [1] Got it      ││  Keyboard: 1=✓, 2=○, 3=✗
│ │ │              [2] Approximation││
│ │ │              [3] Not yet      ││
│ │ │ Notes: [Voiced, good attempt] ││
│ │ └──────────────────────────────┘  ││
│ │                                    ││
│ │ [SPACE=Play] [1=✓] [2=○] [3=✗]   ││  ← Keyboard legend
│ │ [Enter=Next] [S=Slow] [N=Normal]  ││
│ │                                    ││
│ │ [Submit] [Mark for double-rate]  ││
│ └────────────────────────────────────┘│
│                                        │
│ ┌────────────────────────────────────┐│
│ │ Clip 2 / 12   [Queued]             ││  ← Next clip queued
│ │ Target: "ma"  |  Duration: 0.8s    ││
│ │ [Play]                             ││
│ └────────────────────────────────────┘│
│                                        │
│ ────────────────────────────────────  │
│                                        │
│ STATS                                  │
│ Clips reviewed: 1/12 (8%)            │  ← Progress bar
│ Time spent: 0:47                      │
│ Avg time per clip: 0:47               │
│ Est. time for batch: 9 minutes        │
│                                        │
│ Estimated completion: 3:52 PM        │
│                                        │
│ [Pause review] [Exit review]         │
│                                        │
└────────────────────────────────────────┘
```

**Specs:**
- Clip queue: Sorted by priority (new targets first, then high-uncertainty parent scores, then random)
- Keyboard scoring: 1=✓, 2=○, 3=✗; Space=play; Enter=next; this is ~5 seconds per clip
- Audio player: Embedded waveform, play/pause, speed control (0.75×, 1×, 1.25×), repeat, mark for later
- Scoring form: IPA transcription (text input), cue level needed (dropdown: L0–L5), correctness (radio), notes (optional)
- Interrater reliability: ~10% of clips are double-rated; Cohen's κ tracked and reported
- Batch estimates: "12 clips remaining, ~8 minutes at this pace"
- Pause/resume: Session persists; can close and return
- Analytics: Time-per-clip, clips-per-session trends used to improve filtering

---

### 5.4 Progress Charts — Accuracy × Cue Level

**Purpose:** "See the progress and interpret it correctly."

```
┌────────────────────────────────────────┐
│ ← Back to Child                        │
│                                        │
│ PROGRESS · Mateo Chen · Last 12 weeks│
│ [Target: All] v  [Metric: Accuracy] v │
│                                        │
│ ACCURACY & CUE LEVEL                   │
│ ┌────────────────────────────────────┐│
│ │ Accuracy (%)                       ││
│ │ 100%├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  ││  Chart key:
│ │     │                             ││  Red   = L0
│ │  80%├─────●─────────●────────    ││  Orange = L1
│ │     │      ╲       ╱              ││  Gold  = L2
│ │  60%├────────●───●────●──────    ││  Green = L3
│ │     │          ╲ ╱                ││  Blue  = L4
│ │  40%├──────────────────●────────││  Indigo= L5
│ │     │                     ╲       ││
│ │  20%├─────────────────────●──────││
│ │     │                            ││
│ │   0%└────┴──────┴──────┴──────┘  ││
│ │     Sep 4   Sep 11  Sep 18  Sep 25  ││
│ │                                    ││
│ │ COLOR BY CUE LEVEL (not by target) ││
│ │ Notice:                            ││
│ │ • Early data mostly L1 (orange)   ││
│ │ • Accuracy ~70% at L1             ││
│ │ • Recent data includes L2 (gold)  ││
│ │   Accuracy dropped to ~50% at L2  ││
│ │   — that's PROGRESS (harder level)││
│ │                                    ││
│ │ KEY INSIGHT:                       ││
│ │ "Moving to harder cues (less      ││
│ │  support) is progress, even if    ││
│ │  accuracy temporarily drops."     ││
│ │                                    ││
│ └────────────────────────────────────┘│
│                                        │
│ ────────────────────────────────────  │
│                                        │
│ INVENTORY GROWTH                       │
│ ┌────────────────────────────────────┐│
│ │ Consonants in use:                 ││
│ │ Week 1:     m, b                  ││
│ │ Week 4:     m, b, p, h            ││
│ │ Week 8:     m, b, p, h, w, n      ││  Growing inventory
│ │ Week 12:    m, b, p, h, w, n, g   ││
│ │                                    ││
│ │ Syllable shapes:                   ││
│ │ Week 1: V                         ││
│ │ Week 4: V, CV                     ││
│ │ Week 8: V, CV, VC, CVCV          ││
│ │                                    ││
│ └────────────────────────────────────┘│
│                                        │
│ ────────────────────────────────────  │
│                                        │
│ MODALITY RATIO                        │
│ ┌────────────────────────────────────┐│
│ │ Week 1:  AAC-only (100%)          ││
│ │ Week 4:  AAC+vocal (70%), AAC     ││  Shift over time
│ │          (20%), Vocal (10%)       ││
│ │ Week 12: AAC+vocal (50%), Vocal   ││
│ │          (35%), AAC (15%)         ││
│ │                                    ││
│ │ Trend: Shifting toward vocal      ││
│ │ (& fewer AAC-only attempts)       ││
│ │ while maintaining AAC access.     ││
│ │                                    ││
│ └────────────────────────────────────┘│
│                                        │
│ [Export as PDF] [Export as CSV]      │
│                                        │
└────────────────────────────────────────┘
```

**Specs:**
- Primary chart: Accuracy vs. time, color-coded by cue level (NOT by target)
- Key insight: Dropping accuracy when moving to lower cue levels is progress; the chart must make this obvious
- Secondary charts: Inventory growth (consonants, vowels, syllable shapes), Modality ratio trend
- Interactivity: Hover over points to see details (date, target, trials, accuracy)
- Filters: By target, by date range (2w, 4w, 8w, 12w, all-time)
- Export: PDF for IEP documentation, CSV for research

---

### 5.5 IEP-Ready Report

**Purpose:** "Generate IEP-compliant, clinician-editable report in one click."

```
PRAXIA PROGRESS REPORT
Mateo Chen · DOB: Jun 2023
Date prepared: Sep 11, 2026
Provider: Karen Chen, CCC-SLP
Clinic: Cincinnati Pediatric Speech Clinic

────────────────────────────────

BASELINE
Initial assessment: Sep 1, 2026
Child vocalizations: ~8 word approximations (m, b, occasional p)
Intelligibility: Unintelligible to unfamiliar listeners
AAC: Minimal (using app only)
Family readiness: Mother motivated, father occasional
Hearing status: Normal audiogram (Aug 2026)

────────────────────────────────

GOALS (Measurable, editable)
1. Increase consonant inventory to 8+ distinct consonants (from current 3)
   Target: 12 weeks
   Benchmark: By session X, [clinician-editable criteria]

2. Increase volitional production (L4–L5 without model) to 20% of trials
   Target: 12 weeks
   Benchmark: [editable]

3. Maintain AAC usage ≥20% of communication attempts (dual-modality)
   Target: Ongoing
   Benchmark: [editable]

4. Reduce aversion behaviors (hand-biting, resistance) to zero/week
   Target: Ongoing
   Benchmark: [editable]

────────────────────────────────

DATA & MEASUREMENT (Auto-populated)

Trials delivered:
  Week 1–4:   237 trials (avg 59/session)
  Week 5–8:   312 trials (avg 78/session)
  Week 9–12:  289 trials (avg 72/session)
  Total:      838 trials over 12 weeks

Practice frequency:
  Goal: 5 days/week (≥2 mandatory)
  Actual: 4.1 days/week (range: 3–6)
  Sessions below minimum: 1 week (Week 7, illness)

Cue-level progression:
  Phase 1 (Wk 1–4):  L1–L2 (simultaneous support)
  Phase 2 (Wk 5–8):  L2–L3 (transition to imitation)
  Phase 3 (Wk 9–12): L3–L4 (increasing independence)
  Current level: L3 (majority of trials)

Targets:
  "ma" — Mastered (L3, 85% accuracy) — Ready to probe
  "ba" — Progressing (L2–L3, 68% accuracy)
  "up" — Progressing (L1–L2, 74% accuracy)
  "on" — Learning (L1, 55% accuracy)

Inventory growth:
  Consonants acquired: m, b, p, h, w (5 total, from 3)
  Syllable shapes: V, CV, VC, CVCV (from V only)
  [See charts below]

Modality ratio:
  Week 1:  AAC-only 100%
  Week 12: Vocal 35%, AAC+vocal 50%, AAC 15%
  Interpretation: Child shifting toward speech while retaining AAC

Accuracy (parent-scored):
  Overall: 68% (weighted by cue level)
  At L1: 78% (high support)
  At L3: 62% (imitation)

Probes (if conducted):
  Generalisation (untreated items, Week 8): [data if available]
  Maintenance ("ma" at 1 wk post-mastery): [data if available]

────────────────────────────────

INTERPRETATION (Clinician-editable)

Mateo has shown solid progress over 12 weeks, particularly in:
• Consonant inventory expansion (3 → 5 consonants)
• Willingness to attempt longer utterances (CV → CVCV)
• Adaptive modality (using both AAC and vocal attempts)

Cue-level progression is appropriate; "ma" is ready for mastery
probe and spontaneous contexts. "ba" and "up" are progressing at
expected rate. "on" remains at L1 and may need re-evaluation if
no progress in the next 2 weeks.

Mother's coaching quality has improved; she is more consistent
with cueing and more accepting of approximations. Father has
engaged inconsistently but sessions with him show adequate
fidelity.

Aversion behaviors have not emerged; session engagement remains
high. No safety concerns.

Recommendation: Continue current program. Consider adding a
functional (integrative) target (e.g., "mommy" or "go") to
increase semantic relevance and generalisation. Family would
benefit from clarification on when to introduce L4 (delayed
imitation).

[All sections editable by clinician before export]

────────────────────────────────

CHARTS (Embedded, static)
[Accuracy × Cue Level chart]
[Inventory growth table]
[Modality ratio pie chart]
[Practice frequency heatmap]

────────────────────────────────

NEXT STEPS & ACTION ITEMS
[ ] Review probe results for "ma"
[ ] Discuss new target selection in next session
[ ] Adjust mother's use of wait time (≥5s)
[ ] SLP to re-record video models for Week 13 targets

Prepared by: Karen Chen, CCC-SLP
Date: Sep 11, 2026
Status: Ready to export or share with IEP team

────────────────────────────────

[Export to PDF] [Export to Word] [Share with IEP team]
```

**Specs:**
- Auto-populated sections: Trial counts, practice frequency, cue progression, target status, inventory, modality ratio
- Editable sections: Goals, interpretation, next steps, recommendations
- Measurement: Uses clinically meaningful metrics (cue level, inventory, modality) — no PCC
- Charts: Embedded as static images (not interactive in PDF export)
- One-click flow: SLP clicks "Export IEP Report", form pre-fills with all available data, SLP edits interpretation/goals, clicks PDF/Word
- Template: State-specific IEP formats can be added later (Phase 2)

---

## PART 6: ONBOARDING & CONSENT FLOWS

### 6.1 Red-Flag Screening (Hard Interrupt)

```
SCREEN 1: Account Setup
┌─────────────────────────────┐
│ Welcome to Praxia          │
│                             │
│ You're helping your child  │
│ practice speech between    │
│ therapy sessions.          │
│                             │
│ [Create account]          │
│ Email: [ ]                 │
│ Password: [ ]              │
│ [Next]                     │
└─────────────────────────────┘

SCREEN 2: Child Profile
┌─────────────────────────────┐
│ Tell us about your child   │
│                             │
│ First name: [Mateo]        │
│ Birth month/year: [June]   │
│                             │
│ Note: We collect minimal   │
│ information to protect     │
│ privacy.                   │
│                             │
│ [Next]                     │
└─────────────────────────────┘

SCREEN 3: RED-FLAG SCREENING (Modal, mandatory)
┌──────────────────────────────────┐
│ IMPORTANT SAFETY CHECK           │
│                                  │
│ Before we start, we need to      │
│ know about a few medical signs.  │
│ This helps us make sure Praxia   │
│ is safe and right for your       │
│ child.                           │
│                                  │
│ Answer each question honestly.   │
│ There's no right or wrong        │
│ answer. Your responses are       │
│ private.                         │
│                                  │
│ ────────────────────────────────│
│                                  │
│ 1. Has your child ever choked   │
│    or coughed during meals,     │
│    or had a wet/gurgly voice   │
│    after drinking?               │
│    ○ Yes  ○ No  ○ Unsure       │
│                                  │
│ 2. Has your child lost words,   │
│    sounds, or actions they      │
│    used to do?                   │
│    ○ Yes  ○ No  ○ Unsure       │
│                                  │
│ 3. Does your child have         │
│    hearing loss or has it ever  │
│    been tested?                  │
│    ○ Normal hearing (tested)   │
│    ○ Hearing loss (known)      │
│    ○ Never tested              │
│                                  │
│ 4. Has your child had seizures │
│    or any neurological seizure-│
│    like events?                 │
│    ○ Yes  ○ No  ○ Unsure      │
│                                  │
│ 5. Is your child's voice        │
│    noticeably different         │
│    (very hoarse, breathy)?     │
│    ○ Yes  ○ No  ○ Unsure      │
│                                  │
│ [Next] [< Back]                 │
│                                  │
└──────────────────────────────────┘

IF "Yes" or suspicious answer to Q1, Q2, Q4, Q5:

SCREEN 4A: HARD INTERRUPT
┌──────────────────────────────────┐
│ ⚠ We need to pause here.        │
│                                  │
│ Your answer suggests your       │
│ child may need medical          │
│ evaluation before starting      │
│ speech practice with an app.    │
│                                  │
│ This is not a diagnosis — it's  │
│ a safety precaution.            │
│                                  │
│ Please contact:                 │
│ • Your pediatrician, OR         │
│ • A speech-language pathologist,│
│   OR                            │
│ • Your local hospital           │
│                                  │
│ [Print referral form]           │
│ [Contact SLP directory] (link)  │
│ [Exit app]                      │
│                                  │
│ If you have questions, email:  │
│ clinical@praxia.app            │
│                                  │
│ — We're here to help your child │
│   get the right care. —         │
│                                  │
└──────────────────────────────────┘

(Account is NOT created; flow stops here.)

IF "Never tested" to Q3 (hearing):

SCREEN 4B: GATE (Hearing Status)
┌──────────────────────────────────┐
│ Hearing screening needed        │
│                                  │
│ Before we start speech          │
│ practice, your child's          │
│ hearing needs to be checked.    │
│                                  │
│ This is a standard first step   │
│ in speech evaluation.           │
│                                  │
│ • Many pediatricians can do a   │
│   quick screening at a regular  │
│   visit.                        │
│ • An audiologist can do a full  │
│   evaluation.                   │
│                                  │
│ Once you have results:          │
│ Return here and we'll add them. │
│                                  │
│ [Schedule audiologist (link)]   │
│ [Upload screening results]      │
│ [Use Praxia anyway — skip speech│
│  targets for now (AAC only)]    │
│                                  │
│ [← Back]                        │
│                                  │
└──────────────────────────────────┘

(Skip speech pathway; AAC remains fully available.)

IF all screens pass (or hearing is "Normal"):

SCREEN 5: Ready to continue to Consent
┌──────────────────────────────────┐
│ Great!                          │
│                                  │
│ Your child is ready to get      │
│ started. Next, we'll ask about  │
│ recording and data sharing.    │
│                                  │
│ [Next → Consent Flows]          │
│                                  │
└──────────────────────────────────┘
```

**Specs:**
- Red-flag items: Dysphagia, regression, seizures, breathing/voice change, unconfirmed hearing
- Hard interrupt: Positive screen on dysphagia/regression/seizures/breathing → flow stops, referral guidance shown, NO account created
- Hearing gate: Unconfirmed hearing status gates the speech pathway (AAC accessible, speech targets blocked)
- Re-screening: Every 90 days, a reminder prompt asks parent to update red-flag status (or skip)
- Data: Red-flag responses stored securely, never shared with analytics; clinician can see via portal

---

### 6.2 Layered Consent (5 Independent Toggles)

```
SCREEN 1: Consent Introduction
┌──────────────────────────────────┐
│ Privacy & Recording             │
│                                  │
│ Praxia records your child's     │
│ voice during practice to track  │
│ progress and help your SLP      │
│ provide feedback.               │
│                                  │
│ You control where that data    │
│ goes. Each setting is           │
│ independent.                    │
│                                  │
│ Read the full terms:            │
│ [Privacy Policy] [Terms]        │
│                                  │
│ [Next → Consent Choices]        │
│                                  │
└──────────────────────────────────┘

SCREEN 2: The Five Consent Toggles
┌──────────────────────────────────┐
│ Choose what you're comfortable  │
│ with. All of this happens on   │
│ the device by default; cloud   │
│ upload is opt-in.              │
│                                  │
│ ────────────────────────────────│
│                                  │
│ 🔵 CORE SERVICE (required)      │
│ [✓] Use Praxia to practice &   │
│     track progress. Recordings  │
│     stay on the device only.   │
│                                  │
│ (This one is required to use   │
│  the app. You can't uncheck it.)│
│                                  │
│ ────────────────────────────────│
│                                  │
│ 🔵 ON-DEVICE RECORDING          │
│ [✓] I agree to audio recording │
│     on my child's device.       │
│                                  │
│ [Learn more] (≤60s video)      │
│                                  │
│ ────────────────────────────────│
│                                  │
│ 🔵 CLOUD STORAGE               │
│ [✗] Upload recordings to       │
│     Praxia's secure cloud.     │
│     (Allows SLP async review & │
│      before/after clips)        │
│                                  │
│ Default: OFF (data stays local) │
│ [Learn more]                   │
│                                  │
│ ────────────────────────────────│
│                                  │
│ 🔵 SHARE WITH SLP              │
│ [✓] Let my child's SLP see     │
│     clips and progress data.    │
│                                  │
│ (Only relevant if SLP is       │
│  linked. Requires cloud upload.)│
│                                  │
│ ────────────────────────────────│
│                                  │
│ 🔵 MODEL TRAINING (Separate!)  │
│ [✗] Help improve Praxia by     │
│     letting us train AI models  │
│     on my child's recordings.  │
│                                  │
│ This is SEPARATE from above.   │
│ Toggling cloud storage OFF does│
│ NOT affect this toggle.        │
│                                  │
│ [Learn more] [View legal terms]│
│                                  │
│ ────────────────────────────────│
│                                  │
│ 🔵 RESEARCH PUBLICATION        │
│ [✗] My child's anonymised     │
│     data may appear in         │
│     published studies.         │
│                                  │
│ (Names & identifiers removed)  │
│                                  │
│ [Learn more]                   │
│                                  │
│ ────────────────────────────────│
│                                  │
│ VERIFICATION REQUIRED           │
│ We need to verify you're the   │
│ parent/guardian. Choose one:   │
│                                  │
│ [✓] Credit/debit card auth     │
│     (we won't charge; just     │
│      verify identity)          │
│                                  │
│ [ ] Upload signed consent form │
│     (mail-in, print & sign)    │
│                                  │
│ ────────────────────────────────│
│                                  │
│ [I agree to Core Service only  │
│  — proceed] [Next → Review]    │
│                                  │
└──────────────────────────────────┘

SCREEN 3: Review & Confirm
┌──────────────────────────────────┐
│ Review your choices             │
│                                  │
│ Core Service:      ✓ ON        │
│ On-device recording: ✓ ON       │
│ Cloud storage:     ✗ OFF       │
│ Share with SLP:    ✓ ON        │
│ Model training:    ✗ OFF       │
│ Research:          ✗ OFF       │
│                                  │
│ Your data plan:                 │
│ • Recordings kept locally,      │
│   encrypted, for 90 days       │
│ • SLP can't see clips (no cloud)│
│                                  │
│ Wait, that doesn't match!      │
│ (Warn if conflicts detected)    │
│                                  │
│ [Edit choices] [Confirm & done]│
│                                  │
└──────────────────────────────────┘

SCREEN 4: Child Assent (Pictorial)
┌──────────────────────────────────┐
│ One more thing...               │
│                                  │
│ [Image: Child's face, smiling]  │
│                                  │
│ "We're going to record your    │
│  voice so you can hear yourself│
│  practice."                    │
│                                  │
│ (Spoken audio + simple image)  │
│                                  │
│ [Tap once if your child heard  │
│  that and is okay with it]     │
│                                  │
│ [Your child says: "OK!"]       │
│                                  │
│ [Next → Create account & home] │
│                                  │
└──────────────────────────────────┘
```

**Specs:**
- Five toggles: Core (required), On-device, Cloud, SLP share, Model training (separate), Research
- Model training is SEPARATE and explicitly stated as independent from cloud toggle (COPPA compliance)
- Verification: Card authorization OR signed form (email-plus insufficient)
- Each consent records: timestamp, policy version, verification method
- Revocation: Parent can toggle on/off anytime in Settings
- Child assent: Simple pictorial screen; child taps to indicate understanding (not binding, but participatory)

---

### 6.3 SLP Linking (Optional in Onboarding)

```
SCREEN 1: Link Option
┌──────────────────────────────────┐
│ Do you have a speech therapist? │
│                                  │
│ [✓] Yes, I know my SLP's code  │
│ [ ] No, I need help finding one │
│ [ ] I'll link later             │
│                                  │
│ (All three paths are OK)        │
│                                  │
└──────────────────────────────────┘

IF "Yes":
┌──────────────────────────────────┐
│ Link to your SLP                │
│                                  │
│ Ask your SLP for their         │
│ Praxia code:                   │
│                                  │
│ Code: [  ABCD1234  ]            │
│                                  │
│ [Link] [Cancel / do it later]  │
│                                  │
│ Once linked, your SLP will see│
│ clips and progress data (if    │
│ you allowed cloud upload).     │
│                                  │
└──────────────────────────────────┘

IF "No":
┌──────────────────────────────────┐
│ Find a speech-language         │
│ pathologist                    │
│                                  │
│ [Directory search] (ASHA, local)│
│ [Article: How to find an SLP]  │
│                                  │
│ Once you have one, ask for     │
│ their Praxia code and link in  │
│ Settings → My SLP.             │
│                                  │
│ Families without an SLP:        │
│ Praxia works on its own, but   │
│ you'll get most out of it with│
│ an SLP guiding targets.        │
│                                  │
│ [Proceed without SLP]          │
│                                  │
└──────────────────────────────────┘
```

**Specs:**
- SLP code: Six-character alphanumeric code generated by SLP in portal; one-time use per child
- Linking: Parent enters code; system verifies and creates link
- Data access: Once linked, SLP can see clips/progress (if parent allowed cloud upload) and send async messages/videos
- Unlink: Parent can unlink anytime; SLP loses access to clips (but their prior reviews remain in audit log)

---

## PART 7: COMPANION CHARACTER SPECIFICATION

### 7.1 Design Intent

**One consistent, low-arousal companion.** Not a cast; not a mascot that changes. The companion is **also learning**, so the child is a peer rather than a subject. No disappointment reactions. No guilt lines. Never appears in notifications.

**Customizable appearance:** The child can choose a simple variation (hair color, outfit) for cheap agency and mild personalization.

---

### 7.2 Visual Specs

| Attribute | Spec | Rationale |
|---|---|---|
| **Form** | Gender-neutral humanoid, age ~7–10 (peer, not authority) | Relatable; avoids gendered assumptions |
| **Style** | Illustration (not photorealistic) | Consistent, simplified, on-model |
| **Mouth** | Visible, detailed enough to see articulation (teeth, lips, tongue tip if relevant) | Core job is to model speech targets |
| **Facial expression** | Calm, interested, neutral-to-warm (never exaggerated) | Autistic children avoid exaggerated faces |
| **Eyes** | Looking toward the child or the task; never sad/disappointed | No guilt signalling |
| **Hands** | Visible for gestural cueing if used; generally relaxed | Conveys openness and learning |
| **Clothing** | Simple, consistent, not branded | Repeatable, predictable |
| **Skin tone, hair** | Customizable; user chooses at setup or in Settings | Mild agency; representation |
| **Scale** | Fills ~60–70% of model video frame | Draws attention without overwhelming |

**Color palette:** Within the app's desaturated palette (no saturated primary colors); clothing/hair can use muted accents (soft green, soft blue) if chosen by parent.

**Animation:** Minimal. Head turns, blinks, occasional smiles. No idle loops. No complex choreography.

---

### 7.3 Behaviors & Moments

| Moment | Companion Action | Audio | Duration |
|---|---|---|---|
| **Greeting (start of session)** | Waves, gentle smile, looks toward camera | Warm, clear voice: "Hi! Ready to practice?" | 2–3s |
| **Modeling a target** | Mouth close-up (you see just mouth), clear articulation, slow if L1 | Target spoken normally or slowed (no exaggeration) | 0.8–2s |
| **Repeat button** | Companion nods, repeats mouth model | Repeats audio (same as model audio) | 0.8–2s |
| **Attempt window (your turn)** | Companion looks toward mic, subtle interest (raises eyebrow or tilts head) | "Your turn" or soft breath sound (≤1s) | Ongoing until child responds or times out |
| **Correct attempt** | Warm smile, small nod or thumbs-up | Warm, approving tone: "Good!" or "Yes!" or just smiles (≤1s) | 1–2s |
| **Approximation** | Interested expression, smile; models again (shows acceptance) | Neutral or encouraging: "I like that attempt. Let me show you again." (≤2s) | 2–3s |
| **Failed attempt / backing off cue** | No signal whatsoever; simply continues to next trial | Silence | — |
| **Encouragement (mid-session)** | Occasional smile, looks at child | Optional coaching note reads; no character voice | N/A |
| **Celebration (end session)** | Big smile, waves, gives thumbs-up or claps | Warm, genuine: "Great work today! See you tomorrow!" | 2–3s |
| **Goodbye (app close)** | Companion waves, smile fades gently | "See you soon." | 2–3s |

**Rules:**
- No disappointment reactions (frown, head-shake, sigh)
- No guilt lines ("I'm sad you left" or "Mateo didn't come back")
- No notifications (companion never appears in iOS notifications or alerts)
- Repeat on tap: If parent or child taps repeat, companion repeats without question; no eye-roll or sigh
- Never appears outside the app (no marketing, no push notifications, no Apple Watch)

---

### 7.4 Customization

**In Settings, child/parent can choose:**
- Hair color: Brown, Black, Blonde, Red, or "surprise" (random)
- Hair length/style: Short, Medium, Curly (3 simple options)
- Shirt color: Muted blue, muted green, muted orange, neutral grey (4 options)
- Pronouns: He/him, She/her, They/them (optional display; no behavior change)

**No complexity beyond these.** No clothing changes per session, no earned accessories, no cosmetic unlocks.

---

## PART 8: MOTION & REWARD SPECIFICATION

### 8.1 Animation Principles

**General rules:**
- All animations ≤2.5 seconds
- Always return directly to the next trial or the next meaningful state
- Respect `prefers-reduce-motion` (on iOS, if enabled, NO animations except state changes)
- One element moves at a time (no parallel animation of multiple objects)
- No parallax or depth effects
- No idle loops or in-between transitions

| Element | Animation | Duration | Trigger | Notes |
|---|---|---|---|---|
| **Page transition** | Slide from right (screen-to-screen) | 300ms | Tap navigation button | Subtle; respects reduce-motion |
| **Model video play** | Fade in mouth close-up | 200ms | Model button tapped | Quick, doesn't distract |
| **Attempt window open** | Companion head turns toward mic + slow pulse ring | 500ms | Trial begins | Draws attention gently |
| **Successful trial** | Mild highlight of target word (background color shift) | 500ms | Correct attempt scored | Brief, returns to next trial |
| **Collection item reveal** | Item slides in from bottom | 300–500ms per item | Item earned | Sequence 3–5 items with 200ms stagger |
| **Session end celebration** | Sequence of earned items appearing + companion wave | 3–5s total | All trials complete | Longest animation; caps session |
| **Goodbye** | Companion smile, fade, then home screen | 2s | Celebration ends | Smooth departure |
| **Error / backing off** | NO animation; silent, instant transition to next trial | 0ms | Failed trial → re-cued | This is intentional; no signal to child |

**Easing:** Use ease-out curves (decelerating) for most animations to feel natural. No bounces, springs, or complex beziers.

---

### 8.2 Reward Strategy (Ethical Variable Reinforcement)

**Principle:** Rewards are a **vehicle for the next trial, not a destination.** Magnitude decreases as competence increases.

**Timeline:**
- **Week 1–2 (novel, high arousal):** Rewards every 2–3 attempts. Large, colorful item reveal.
- **Week 3–6 (establishing practice):** Rewards every 4–6 attempts. Slightly smaller, same pace.
- **Week 7+:** Rewards every 8–10 attempts. Subtle item reveal (or skipped entirely if child loses interest).

**Reward mechanics:**
- Every trial receives identical, warm acknowledgement: "Good try!" or just a smile from the companion
- ~Every 4th attempt (adjustable by parent): Bonus item awarded → brief animation (≤1.5s) → return to next trial
- No "near-miss" effect (e.g., a slot machine almost-win); it either unlocks or it doesn't
- No loss, no expiry, no resets; collected items never disappear
- Items unlock story progress in Collection (not in child's view, but parent sees a heatmap: "x items earned this week")

**Parent control:**
- In Settings, parent can see variable-reward frequency: "Your child gets a surprise about every 4 attempts"
- Adjustable: Disable rewards, or change frequency (2 / 4 / 6 / 8 / 10 attempts)
- No paywall or monetary path to rewards

**Safety gates:**
- No reward animations that resemble slot-machine behavior (spinning wheels, coins, etc.)
- No "almost-won" near-miss frames
- No streak-based rewards (e.g., "bonus on day 5 of a streak")

---

### 8.3 Collection as Low-Arousal Progression

**Why collection, not levels or points?**
- Completion is achievable in months without grinding
- Items are never lost (low stress)
- No visible failure or "you're behind"
- Tapping an item is self-paced; not time-pressured

**Unlocking:**
- Item earned every 5–10 practice trials (on average)
- No accuracy requirement (contingent on attempts only)
- Parent sees frequency in Settings: "Your child is earning about 1 item every X trials"

**Display:**
- Collection tab shows 4–6 categories (Animals, Vehicles, etc.)
- Within each category, 30–40 items (infinite depth)
- Items show as 120×120pt photographs or illustrated icons
- No "collection meter" or "10/100 complete"

**Optional: Keepsake highlights**
- Parent can mark favorite items (e.g., "This is Mateo's favorite animal")
- Marked items get a small star or heart (visual, not a ranking)

---

## PART 9: ACCESSIBILITY ANNOTATIONS

### 9.1 WCAG 2.2 AA Compliance Checklist

| Criterion | Implementation | Notes |
|---|---|---|
| **1.4.1 Use of Colour** | Color + icon + text/shape redundancy everywhere. No red/green alone for pass/fail. | Child zone uses color minimally; always paired with icon or shape |
| **2.3.1 Flashing** | No content flashes >3× per second. No seizure risk. | Tested on all assets |
| **1.4.1 Contrast (Min)** | 4.5:1 for text; 3:1 for graphics/UI components | Verified in light & dark themes |
| **2.5.8 Target Size (Min)** | 64×64pt minimum in child zone; 44×44pt in adult zone | Tested with actual device viewport |
| **2.5.7 Dragging Movements** | Every drag has single-pointer alternative (button, toggle, etc.) | No drag-to-delete or drag-to-reorder in child zone |
| **2.2.1 Timing Adjustable** | No timing dependency in child zone (no countdowns, no auto-advance) | Manual "next" button or parent/app decision |
| **2.4.7 Focus Visible** | 2pt outline on web portal; platform default on iOS | Keyboard nav on web portal only |
| **3.2.3 / 3.2.4 Consistency** | Identical button placement across all child screens (home, repeat, pause in same location) | Enforced in design system |
| **3.3.4 Error Prevention** | No destructive actions without confirmation (e.g., delete child data requires 2-tap) | Validation on all inputs |

### 9.2 iOS Accessibility API Integration

| Feature | Implementation | Testing |
|---|---|---|
| **VoiceOver support** | Proper `accessibilityLabel`, `accessibilityHint`, and `accessibilityValue` on all elements | Tested with VoiceOver enabled; announced clearly |
| **Dynamic Type** | Text scales with system font size setting; tested up to largest setting | No truncation; layout adapts |
| **Switch Control** | Every action reachable via single-switch scanning or dwell | Path: Home → Activity → Scoring → Next Trial |
| **Guided Access** | App compatible with Guided Access (app stays open, child can't escape) | Tested; no hard exits that break Guided Access |
| **Reduce Motion** | Automatically disables all animations if `prefers-reduce-motion` enabled | Tested on device; animations OFF when motion reduced |
| **Reduce Transparency** | backgrounds remain opaque; no layered semi-transparent overlays | Tested in Settings |
| **High Contrast** | Increased contrast mode supported; text remains readable | Verified at highest contrast setting |

### 9.3 Motor & Cognitive Accessibility

| Requirement | Implementation | Rationale |
|---|---|---|
| **No time pressure** | No visible timers; response window is open-ended (auto-prompt after 10s silence, but no penalty) | Children with apraxia have variable response latency |
| **Large touch targets** | ≥64pt in child zone; ≥16pt spacing | Reduces accidental touches; accommodates poor motor control |
| **No drag-and-drop** | Single-pointer alternatives for all interactions | Drag-and-drop is hostile for motor-planning disorders |
| **Literal language** | No metaphor, idiom, or cultural reference in child-facing prompts | Critical for autism co-occurrence |
| **Predictable layout** | Identical screen structure every session | Reduces cognitive load; aids prediction |
| **No animation surprises** | All motion is user-triggered or expected (app-initiated motion is minimal) | Unexpected motion is distressing |
| **Choice & agency** | Child chooses activity, target order, reward, companion appearance | Demand avoidance reduced by framing as choice |

### 9.4 Auditory & Sensory Accessibility

| Feature | Implementation |
|---|---|
| **Captions** | All spoken instructions have text captions (even though no reading required in child view; adult can read) |
| **Independent audio controls** | Voice, music, effects are separately mutable in Sensory Panel |
| **Visual + auditory redundancy** | "Your turn" signal is both audio + visual (companion turns head + soft chime) |
| **No audio-alone instructions** | Every audio instruction has a visual counterpart |
| **Adjustable playback speed** | Model videos can be played at 0.75× / 1× / 1.25× / 2× speed |

### 9.5 Procurement Artifacts

| Artifact | Timing | Owner |
|---|---|---|
| **VPAT (Voluntary Product Accessibility Template)** | Before first district RFP | Eng + Design |
| **ITI Accessibility Report** | Same | Eng + Design |
| **EN 301 549 Mapping** | Before EU launch (Phase 2) | Regulatory + Eng |
| **WCAG 2.2 AA Self-assessment** | Before App Store submission | QA + Design |

---

## PART 10: COPY DECK & CLAIMS COMPLIANCE

### 10.1 Key Copy Strings (All Vetted Against Claims Register)

#### Onboarding & Consent

**✅ Permitted:**
- "Structured, high-repetition speech practice between therapy sessions."
- "Built on published motor-learning principles."
- "Helps you practise at home with confidence."
- "Tracks how much practice your child is getting."
- "Designed with speech-language pathologists."
- "Communication tools that are always available, free."

**❌ Banned:**
- "Teach your non-verbal child to talk" (no evidence any app does this)
- "Treats CAS" / "therapy" / "treatment for apraxia" (regulatory device claim)
- "Clinically proven" [applied to our product] (not proven until study reports)
- "Replaces speech therapy" (harmful; destroys distribution channel)
- "Cure," "fix," "unlock your child's voice," "guaranteed results"

#### In-Session Coaching Tips (Micro-lessons)

| Lesson | Copy | Evidence Level |
|---|---|---|
| **CAS is a motor problem, not a "won't talk" problem** | "Childhood apraxia is a difficulty planning and coordinating movements for speech, not a behavioral issue. Your child wants to talk but his mouth and brain aren't connecting yet." | 🟡 Consensus |
| **Approximations count** | "Ba for ball, ap for apple — these ARE words. Accept them, reinforce them, and shape over time. Never make your child feel he has to say the adult version." | 🟡 K-SLP clinical philosophy |
| **Wait time** | "After you model, wait 5–8 seconds before repeating. This gives his brain and mouth time to plan. Silence is not failure; it's thinking." | 🟡 Motor-learning principle |
| **AAC doesn't delay speech** | "Research shows AAC doesn't reduce speech — it often increases it. (Millar, Light & Schlosser 2006 — but gains were modest.)" | 🟢 Strong, with caution note |
| **Short, frequent is better than long** | "10 minutes 5 days a week beats 30 minutes once a month. Dose is frequency, not duration." | 🟡 n=2 in literature, but directionally sound |
| **Dysregulation matters** | "If he's upset, frustrated, or crying, stop. A few minutes of real practice is better than 30 minutes of aversion. You're building love for communication, not punishment." | 🔴 Clinical consensus |

#### Adult Zone Labels (Non-Clinical, Reassuring Tone)

| Screen / Element | Copy |
|---|---|
| **Today (opening)** | "You're helping your child get 60–80 speech attempts this week. That's the real win." |
| **Progress screen (cue-level chart)** | "Moving to harder cues (less support) is progress, even if accuracy temporarily drops. Notice how "ma" improved over time as we stepped back our help." |
| **Stuck target message** | "This target hasn't moved in 3 weeks. That's common, and it usually means the target needs changing — not more practice. Here's a message to send Karen." |
| **Settings (sensory panel intro)** | "Adjust these to fit your child. Low-stimulation works for most kids with apraxia; high energy can actually backfire." |
| **Data export** | "Your data is yours. Download it any time, or delete it permanently." |

#### Clinician Portal Labels

| Screen / Element | Copy |
|---|---|
| **Triage queue** | "Sorted by 'Needs You Most.' Stuck targets, over-practice, and missed sessions float to the top." |
| **Accuracy × cue-level chart** | "**Accuracy without cue level is meaningless.** A drop in accuracy at a *lower* cue level is progress." |
| **IEP report intro** | "Editable report. Auto-populated with data; customize the interpretation." |

#### Error Messages & Edge Cases

| Scenario | Tone | Example |
|---|---|---|
| **Couldn't detect vocalization (SNR too low)** | Neutral, no blame | "Noisy environment. Move to a quieter room if you can." |
| **Hearing status unconfirmed** | Supportive, not alarmist | "We need hearing confirmation before starting speech targets. AAC and play are still available." |
| **Child not responding (mid-session)** | Compassionate to parent | "He seems tired. Stopping now was the right call. Try again tomorrow." |
| **No internet connection (non-critical path)** | Informational | "You're offline. Practice works great offline; clips will upload when you reconnect." |

### 10.2 Claims Register Review Process

**All strings pass through:**

1. **PM review** — Is this claim true and evidence-aligned?
2. **Regulatory reviewer** — Does this claim require a regulatory pathway we haven't taken?
3. **Log** — String, version, date, reviewer name stored in [claims-register.md](../05-compliance/claims-register.md)

**Strings requiring regulatory review:**
- Any efficacy claim ("improves," "increases," "helps," "supports")
- Any medical framing ("diagnosis," "screening," "measurement," "severity")
- Any AI/ML capability ("understands," "recognizes," "detects")
- Any emotion inference ("measures anxiety," "predicts engagement")
- Anything involving the child's voice data or model training

---

## PART 11: DESIGN SYSTEM IMPLEMENTATION CHECKLIST

### Before Handoff to Engineering

- [ ] **Color palette** — Confirmed in light & dark theme, tested for 4.5:1 contrast
- [ ] **Typography scale** — All sizes, weights, line-heights finalized
- [ ] **Spacing tokens** — 8pt grid locked; all spacers defined
- [ ] **Button styles** — Child zone (large, flat), adult zone (primary/secondary/tertiary)
- [ ] **Icon set** — SF Symbols mapped; no custom icons in child zone
- [ ] **Component library** — Card, session card, trial container, AAC grid, end-of-session ritual
- [ ] **Accessibility audit** — WCAG 2.2 AA compliance verified on all screens
- [ ] **Motion spec** — All animations ≤2.5s, respect reduce-motion, no parallax
- [ ] **Copy deck** — Every string run through claims register; all approvals logged
- [ ] **Child screens wireframes** — Home, Practice, AAC, Collection (detailed)
- [ ] **Adult screens wireframes** — Today, Progress, Clips, Learn, My SLP, Settings
- [ ] **Clinician portal wireframes** — Triage, child detail, clip review, progress, IEP
- [ ] **Onboarding flows** — Red-flag screening, consent, SLP linking, child assent
- [ ] **Companion spec** — Visual specs, behaviors, customization, animations
- [ ] **Accessibility annotations** — VoiceOver, Switch Control, Guided Access, motor paths

---

## Appendix A: Responsive Design Notes

### Phone (390px–430px)

- 16pt gutters on all sides
- Single column layout in all views
- Bottom tab bar: 5 icons + label (child zone: Talk, Play, Collection + Home; adult: Today, Progress, etc.)
- Touch targets remain ≥64pt (child zone) / ≥44pt (adult)
- Session cards: Full width, vertical scroll
- AAC grid: 5 columns (56pt cells + 12pt spacing fits)
- Charts: Responsive; bars stack on small screens

### Tablet (768px–1024px)

- 20pt gutters
- Multi-column layouts available (two-column on tablet)
- Sidebar navigation on clinician portal (left sidebar, main content right)
- AAC grid: 8 columns (more cells visible at once)
- Charts: Fully interactive; hover for details
- Adult zone: Progress chart can be side-by-side with settings

### Notes on Child Zone Scaling

- Child zone behavior is **identical on phone and tablet** — no difference in depth, structure, or controls
- Only difference: Screen real estate — tablet shows more items at once (more AAC cells, wider cards)
- No responsive breakpoints change the fundamental layout

---

## Appendix B: Dark Mode & Theming

### Light Theme (Default)

Applied at app startup unless `prefers-color-scheme: dark` detected or user toggles Dark Mode.

### Dark Theme

Automatically applied if:
1. Device has `prefers-color-scheme: dark` (system setting), **OR**
2. User toggles "Dark Mode" in Settings → Sensory Panel

Dark theme overrides system preference if explicitly toggled.

### Testing Dark Mode

- [ ] All text meets 4.5:1 contrast in dark theme
- [ ] Images don't invert (use asset-based images, not CSS filters)
- [ ] Icons remain visible (not transparent white on light background)
- [ ] Session cards have visible borders in dark theme (help separation)
- [ ] Animations work at reduced brightness

---

## Appendix C: Video Asset Specs

### Model Videos (Real Mouth, Slowed)

- **Resolution:** 1920×1080 (Full HD)
- **Framerate:** 30fps (slowed to 0.75× in playback = slow-mo effect)
- **Codec:** H.264 (broad compatibility)
- **Framing:** Mouth close-up, lips & teeth visible, neutral background (light gray or white)
- **Duration:** 0.8–2s normal playback (depending on target)
- **Lighting:** Bright, even, no shadows on mouth
- **Audio:** Natural voice, clear articulation, no background noise
- **Per-target:** 1 primary model (adult female or neutral voice), 1 alternative (adult male or different accent)

### Companion Animation Videos

- **Resolution:** 1080×1920 (portrait, for head/face close-up on phone)
- **Framerate:** 24fps (smooth but efficient)
- **Duration:** 2–5 seconds per behavior (greeting, celebration, goodbye)
- **Codec:** H.264
- **Audio:** Integrated (companion voice)

---

## Appendix D: Design Debt & Future Enhancements

**Explicitly out of v1 scope (deferred):**
- Detailed formant charts or vowel-space visualization (Phase 2+)
- Forced alignment or vowel intrinsic pitch analysis (Phase 2+)
- Multi-language/bilingual target interface (Phase 2+; bias audit first)
- Customizable AAC grid reorganization (Mirror mode only; fixed grid in core)
- Custom video model recording by SLP in Portal (v1.5+)
- Parent-to-SLP direct video messaging (v1.5; async only in v1)
- Maintenance probe auto-scheduling (v1.5; manual for now)

---

**Document Owner:** UI/UX Designer  
**Last Updated:** 2026-09-11  
**Version:** 1.0 (Design System & Specifications Ready for Build)

---

**END OF DESIGN SPECIFICATION**
