# Clinician Portal Specification

## Overview

The Praxia Clinician Portal is a web-based dashboard (Next.js + React) for Speech-Language Pathologists (SLPs) to monitor child progress, manage therapy programs, review session data, and export reports. It enforces FERPA compliance, provides Tier-1 signal analysis, and supports async messaging with guardians.

**Design Principle:** Adult zone prioritizes data density over child-friendliness. Professional, accessible, focused on actionable insights.

---

## Core Pages

### 1. Dashboard / Home

**Purpose:** At-a-glance overview of active children and this week's activity.

**Layout:**
- Header: Clinic name, SLP name, date, quick links (Messages, Reports, Settings)
- Grid (3 columns on 1200px+, 1 column mobile):
  - **Active Caseload:** Card grid showing 4-6 children with:
    - Child avatar/emoji
    - Child name (initials only if FERPA restricted)
    - Status indicator (Green=recently active, Yellow=due for session, Red=overdue)
    - Last session: "2 days ago • 27 attempts"
    - Current target: "ball (L2 cue)"
  - **This Week's Activity:** Stacked bar chart (Mon–Sun) showing:
    - Total attempts per child (different colors)
    - Target: 5 sessions/week minimum
  - **Inbox:** Latest 3 messages from guardians (unread count badge)
  - **Session Queue:** 3-row quick view of today's scheduled sessions

**Interactions:**
- Click any child card → open Child Progress detail page
- Click "View All" on activity chart → drill into Session History
- Click message → open Messaging page

---

### 2. Child Progress

**Purpose:** Deep dive into one child's therapy arc — data-forward, no assumptions.

**URL:** `/child/:childId`

**Sections:**

#### A. Summary Strip (Top)
- Child name • Age 4y2m • Active since 3/2025
- Program: "Vowel Inventory Expansion" • SLP: [SLP name]
- Next session: Tuesday 2:30 PM (or "No session scheduled")

#### B. Weekly Attempts (Interactive Chart)
- Line chart: Last 12 weeks of attempt counts
- Goal zone shaded (5–7 sessions/week)
- Hover: "Week of 1/6: 27 attempts across 5 sessions"
- Trend indicator: ↑ +2 attempts vs prior week

#### C. Cue Level Trajectory
- Area chart over time (L0–L5 on y-axis, weeks on x-axis)
- Color per level (success=green, tactile=red)
- Shows advancement/back-off patterns
- Indicator: "Progressing through L2 (1 week) → advancement in 3 attempts out of last 10"

#### D. Target Inventory Table
- Columns: Word | L0 Success % | L1 Success % | L2 Success % | Status | Notes
- Example row: `ball | — | 82% | 73% | Active | Solidifying at L2. Trial audio available.`
- Filter/sort by status (Active, Mastered, Retired)
- Click word → open Target Detail modal

#### E. Session Log (Paginated)
- Date • Duration • Attempts • Accuracy• Cue Level at End • Audio Clip Count
- Click row → expand trial-by-trial breakdown (timestamps, cue levels, audio clips playable)

#### F. Clinician Notes
- Rich text editor (markdown or WYSIWYG)
- Auto-saved to server
- History/versioning visible on hover
- Linked to specific targets or sessions

---

### 3. Target Word Deep Dive (Modal/Sub-page)

**Triggered by:** Clicking word in inventory, or "Edit Target" from session view.

**Sections:**

#### A. Target Metadata
- Word: "ball"
- Stimulability: "7/10 correct trials on L0" (pre-therapy assessment)
- Phonetic features: /b/ onset, /ɔ/ nucleus, /l/ coda (IPA shown for SLPs)
- Priority: High / Medium / Low
- Assigned date: 1/8/2025

#### B. Cue Hierarchy for This Target
- L0 (Minimal): [Model video thumbnail] [Play] ← Current
- L1 (Visual): [Mouth shape diagram] [Play]
- L2 (Gestural): [Gesture video] [Play]
- L3 (Rhythmic): [Metronome icon] Rhythm pattern shown [Play]
- L4 (Verbal): [Script] "Say it with me: bah-uhl"
- L5 (Tactile): [Diagram] Tactile cues shown

Each level has toggle: "Used in last 5 sessions?" showing frequency heatmap.

#### C. Trial History (This Target)
- Filtered trial log (all attempts on "ball" only)
- Columns: Date | Time | Cue Level | Child Score | Tier-1 Signals | Audio
- Sparkline per column showing trend
- Download all audio clips for this target (ZIP)

#### D. Generalization Probes (if applicable)
- Probe results table: Date | Context | Result | Notes
  - Example: "2/10 • Conversation with parent • Correct • Unprompted in play"
- Chart: % generalization attempts over time

---

### 4. Session Review

**Triggered by:** Clicking session row in progress page.

**Sections:**

#### A. Session Summary
- Date/Time | Duration | Attempts Count | Cue Advancement? | Clinician Notes
- Child avatar + status (calm/engaged/tired/disengaged) — parent-reported or SLP inference if allowed

#### B. Trial-by-Trial Breakdown (Expandable Table)
- Columns: Trial # | Timestamp | Target Word | Cue Level | Score | Tier-1 Signals | Audio (if ≤90 days old)
- Example row:
  ```
  1 | 2:45:12 | ball | L1 | Got it | ↓ Voc: Yes | Latency: 142ms | SNR: 24dB | Syl: 1–2 | [Play]
  ```
- Click [Play] → audio playback modal with waveform
- Tier-1 badge colors: Latency (blue), SNR (green if >18dB, gray if gated), Syllable count (cyan)

#### C. Cue Level Progression Chart
- Timeline of cue level for this session only
- Shows 3-up/2-down rule applied: "Success on L1 → candidate for L0 advancement" or "Failure on L2 → back to L3"

#### D. Notable Moments
- Automatic callouts generated server-side:
  - ✅ Advancement milestone: "Achieved 3 consecutive successes on L2"
  - ⚠️ Back-off: "Returned to L3 after 2 failures on L2"
  - 📊 Outlier: "Latency spike (287ms) in trial 6—check audio quality?"
  - 🎯 Generalization: "Unprompted attempt on 'ball' during AAC selection"

#### E. Clinician Action Panel (Right Sidebar)
- [ ] Mark session as billable (default: auto)
- [ ] Flag for follow-up (alert SLP next login)
- [ ] Archive session (hide from default view but retain data)
- Add private note (for SLP only, not shared with family)

---

### 5. Messaging / Async Communication

**Purpose:** GDPR/FERPA-compliant async parent–SLP communication (no real-time chat to avoid distractions).

**Layout:**
- Thread list (left, 300px) with unread count badges
- Conversation view (main)

**Features:**
- Incoming message banner: "New message from Jane (parent of Alex)"
- SLP reply template suggestions:
  - "Great progress this week! Alex is solidifying the [word] at [cue level]."
  - "I noticed [observation]. At next session, let's try [plan]."
- Rich text (bold, italic, links) but no emoji reaction/threads (keep it clinical)
- Message audit log visible to SLP (timestamp, read status)

**Privacy:**
- No child data embedded in messages (reference by session date only)
- Option to attach redacted session summary PDF (curated data only)

---

### 6. Reports & Export

**Purpose:** Generate clinical documentation (IEP updates, progress reports, data sheets for research).

**Report Templates:**
1. **Weekly Progress Summary** (PDF)
   - Charts: attempts/week, cue level trend, target inventory status
   - Narrative: "Alex showed consistent improvement in [targets] with advancement from L2 to L1 on 'ball'."
   - Recommendations: "Continue current cue hierarchy. Ready to introduce 'dog' at L3."

2. **Monthly Clinical Summary** (PDF)
   - Same as weekly but aggregated over 30 days
   - Includes generalization probe results if available
   - Clinician sign-off line

3. **IEP Goal Progress** (PDF)
   - Aligned to IEP target: "Produce [X] consonant clusters in [Y] phonetic contexts"
   - Data table: date, context, accuracy, clinician notes
   - Recommendation section

4. **Session Data Export** (CSV)
   - Columns: session_date, child_id, target_word, cue_level, score, attempt_count, tier1_latency, tier1_snr, audio_path
   - Retain trial_id for child-level analysis
   - Supports external ML/analysis tools

5. **Attendance / Billing Export** (CSV)
   - Date, Duration, Billable Minutes, Clinician, Notes

**Export Options:**
- Email (via secure delivery, e.g., DocuSign secure email)
- Download (PDF or CSV to local device, encrypted if requested)
- Share with parent via portal (FERPA-compliant, access expires after 30 days)

---

### 7. Settings / Admin

**For SLP:**
- Profile: Name, licensure #, credentials
- Notification preferences: Email on new messages, weekly summary digest, session reminders
- Timezone (affects session display)
- Autosave interval for notes

**For Clinic Admin (if applicable):**
- Add/remove SLPs
- View analytics: SLPs by caseload, sessions per week, progress trends
- Configure clinic name, logo
- Audit log: who accessed what data, when

**Privacy & Security:**
- 2FA toggle (TOTP or SMS)
- Active sessions: list and revoke
- Data retention policy shown: "Session audio deleted after 90 days. Trial events retained indefinitely."
- Export all my data (GDPR Article 20)
- Delete account (irreversible)

---

## Design System (Portal)

### Typography
- Headings: Poppins 600–700 (warm, approachable)
- Body: Inter 400–500 (neutral, legible, dense)
- Monospace: Courier New or Fira Code (for IPA, audio timestamps)

### Color Palette
- Primary: #5b9ef5 (accent, interactive)
- Success: #81c784 (advancement, positive)
- Warning: #ffa726 (back-off, caution)
- Danger: #ef5350 (errors, alarms)
- Neutral: #666666 (secondary text), #999999 (tertiary)
- Background: #ffffff (light), #121212 (dark)

### Components
- Card: 1px border, 8px radius, subtle shadow
- Table: Striped rows (alt row = 2% darker), interactive hover (2% lighter)
- Modal: Overlay + center panel, ~500px wide
- Chart: Chart.js or Recharts, consistent colors per target/child
- Button: 64px min height (accessibility), rounded corners

### Responsive
- Desktop: 3-column grid (caseload, activity, inbox)
- Tablet (768–1024px): 2-column, stacked sections
- Mobile (<768px): Single column, collapsible sections, sticky header

---

## Data Model (Portal-Specific Views)

### Child Object (from backend, curated for SLP)
```json
{
  "child_id": "c_abc123",
  "first_name": "Alex",
  "birth_date": "2020-11-15",
  "current_program": "program_vowels_v1",
  "current_targets": [
    {
      "target_id": "t_ball",
      "word": "ball",
      "cue_level_current": 2,
      "success_rate_l0": null,
      "success_rate_l1": 0.82,
      "success_rate_l2": 0.73,
      "date_assigned": "2025-01-08",
      "date_mastered": null
    }
  ],
  "last_session_date": "2025-02-10",
  "session_count_this_week": 5,
  "attempt_count_this_week": 127,
  "caseload_status": "active"
}
```

### Trial Object (curated for SLP, includes Tier-1)
```json
{
  "trial_id": "tr_xyz789",
  "session_id": "s_session001",
  "child_id": "c_abc123",
  "timestamp_device": "2025-02-10T14:45:12Z",
  "target_word": "ball",
  "cue_level": 2,
  "score": "got_it",
  "tier1_vocalization_detected": true,
  "tier1_latency_ms": 142,
  "tier1_snr_db": 24,
  "tier1_syllable_count_estimate": "1-2",
  "audio_available": true,
  "audio_path": "s3://audio/s_session001/tr_xyz789.wav",
  "audio_retention_expires": "2025-05-11"
}
```

---

## Access Control & Logging

**FERPA Enforcement:**
- SLP sees only their own caseload children + org-shared data (e.g., progress on institutional targets)
- No cross-SLP data access unless explicitly delegated (e.g., co-SLP on IEP team)
- Audit log: Every access to trial data, session data, or child record logged with timestamp and purpose code

**Two-Tenant Model (reflected in portal):**
- **Consumer:** SLP + guardians; training enabled (model fine-tuning on child data permitted)
- **Institutional:** SLP + district admin; training disabled (no model access to child data)

**Audit Event Examples:**
- `portal.session.view | SLP:slp_123 | child:c_abc123 | session:s_session001 | 2025-02-11T10:30Z`
- `portal.audio.download | SLP:slp_123 | session:s_session001 | format:wav | 2025-02-11T10:31Z`

---

## Security & Compliance

### Data Transmission
- HTTPS only (TLS 1.2+)
- Session cookies: HttpOnly, Secure, SameSite=Strict
- CSRF tokens on all POST/PUT/DELETE

### Data Encryption
- Child names: Encrypted at rest using KMS
- Trial data: Encrypted at rest (deterministic hash on trial_id for lookup)
- Audio: Encrypted at rest + in transit

### Compliance Artifacts
- FERPA policy document linked on login
- Privacy notice: Data collected, how it's used, retention periods
- SOP document for SLPs: How to handle confidential information, incident reporting

---

## Wireframe Callouts

### Dashboard (Home)
```
┌─────────────────────────────────────────────────────────────────┐
│  🎤 Praxia Clinic  |  Dr. Sarah SLP  |  Feb 11, 2025            │
│  [Messages: 3]  [Reports]  [Settings]                           │
├─────────────────────────────────────────────────────────────────┤
│ ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│ │ Active Caseload  │  │ This Week        │  │ Inbox            │ │
│ ├──────────────────┤  ├──────────────────┤  ├──────────────────┤ │
│ │ 👧 Alex          │  │ [Bar Chart]      │  │ Jane: "How did   │ │
│ │ Status: 🟢       │  │ Mon-Sun attempts │  │ today go?"  [10] │ │
│ │ Last: 2d ago     │  │ Goal: 5+ days    │  │                  │ │
│ │                  │  │                  │  │ [View All]       │ │
│ │ 👦 Jayden        │  │ 👧 Alex: 127     │  │                  │ │
│ │ Status: 🟡       │  │ 👦 Jayden: 94    │  │                  │ │
│ │ Last: 4d ago     │  │ 👧 Maya: 112     │  │                  │ │
│ └──────────────────┘  └──────────────────┘  └──────────────────┘ │
│ [View All Children]                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Child Progress Page (Alex)
```
┌──────────────────────────────────────────────────────────────────┐
│ 👧 Alex  |  Age 4y2m  |  Active 3/2025  |  Program: Vowels       │
├──────────────────────────────────────────────────────────────────┤
│ SECTION A: Weekly Attempts (Chart)                               │
│ ┌────────────────────────────────────────────────────────────┐   │
│ │ [Line chart: 12 weeks]                                     │   │
│ │ Goal zone: 5–7 sessions/week (shaded)                      │   │
│ │ Trend: ↑ +2 attempts vs prior week                         │   │
│ └────────────────────────────────────────────────────────────┘   │
│                                                                   │
│ SECTION B: Cue Level Trajectory (Area Chart)                     │
│ ┌────────────────────────────────────────────────────────────┐   │
│ │ [Area chart: L0–L5 over 12 weeks]                          │   │
│ │ Indicator: "Progressing through L2 (1w)...advancement"    │   │
│ └────────────────────────────────────────────────────────────┘   │
│                                                                   │
│ SECTION C: Target Inventory Table                                │
│ ┌─────────────────────────────────────────────────────────────┐  │
│ │ Word   │ L0    │ L1   │ L2   │ Status    │ Notes          │  │
│ ├────────┼───────┼──────┼──────┼───────────┼────────────────┤  │
│ │ ball   │ —     │ 82%  │ 73%  │ 🔵 Active │ Solidifying    │  │
│ │ dog    │ —     │ 68%  │ —    │ 🟡 Recent │ Started L1 ...│  │
│ │ up     │ 91%   │ —    │ —    │ 🟢 Ready  │ Mastered      │  │
│ └─────────────────────────────────────────────────────────────┘  │
│                                                                   │
│ SECTION D: Session Log (Paginated Table)                         │
│ ┌─────────────────────────────────────────────────────────────┐  │
│ │ Date      │ Duration │ Attempts │ Accuracy │ Cue Level     │  │
│ ├───────────┼──────────┼──────────┼──────────┼───────────────┤  │
│ │ Feb 10    │ 9:34     │ 27       │ 78%      │ L1→L2         │  │
│ │ Feb 8     │ 10:02    │ 32       │ 71%      │ L2→L3 (back)  │  │
│ │ Feb 6     │ 9:45     │ 28       │ 74%      │ L2            │  │
│ └─────────────────────────────────────────────────────────────┘  │
│                                                                   │
│ SECTION E: Clinician Notes (Rich Text)                           │
│ ┌─────────────────────────────────────────────────────────────┐  │
│ │ Last updated: Feb 11 by Dr. Sarah                          │  │
│ │                                                             │  │
│ │ Alex is showing strong engagement with vowel targets.      │  │
│ │ Consider introducing 'dog' /ɔ/ as next target. Audio       │  │
│ │ suggests strong vocal onset, but syllable clarity          │  │
│ │ variable at L2. Recommend 3–4 more sessions at L2 before   │  │
│ │ advancement.                                               │  │
│ │ [Save]  [Edit History]                                     │  │
│ └─────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

### Session Review Modal
```
┌─────────────────────────────────────────────────────────┐
│ Session: Feb 10, 2025 • 2:45 PM • 27 Attempts • L1→L2  │
├─────────────────────────────────────────────────────────┤
│ Trial-by-Trial:                                         │
│                                                         │
│ Trial 1 | 2:45:12 | ball | L1 | ✓ Got it              │
│ [Tier-1] Latency: 142ms | SNR: 24dB | Syl: 1–2         │
│ [Play Audio]                                            │
│                                                         │
│ Trial 2 | 2:45:41 | ball | L1 | ✓ Got it              │
│ [Tier-1] Latency: 138ms | SNR: 25dB | Syl: 1–2         │
│ [Play Audio]                                            │
│                                                         │
│ Trial 3 | 2:46:10 | ball | L1 | ✓ Got it              │
│ [Tier-1] Latency: 129ms | SNR: 26dB | Syl: 1–2         │
│ [Play Audio]                                            │
│                                                         │
│ ✅ Notable: 3 consecutive L1 successes → advancement   │
│ candidate to L0 next session                            │
├─────────────────────────────────────────────────────────┤
│ Actions (Right Sidebar):                                │
│ [✓] Billable  [Flag for Follow-up]  [Archive]          │
│ [+ Add Private Note]                                    │
│                                                         │
│ [Close]  [Export PDF]                                   │
└─────────────────────────────────────────────────────────┘
```

---

## Implementation Phase

**MVP (Months 1–3):**
- Dashboard with caseload overview
- Child progress page (charts + inventory)
- Session review modal
- Messaging (basic async)

**Phase 2 (Months 4–6):**
- Reports (PDF/CSV export)
- Admin panel
- Audit logging
- SSO integration (for institutional clinics)

**Phase 3+ (Months 7+):**
- Advanced analytics (cohort analysis, progress forecasting)
- Clinician-to-parent video messaging (secure)
- Mobile clinician dashboard (lightweight)

---

## Success Metrics

- **Adoption:** 80% of SLPs log in weekly
- **Data Fidelity:** 95% of sessions have clinician notes within 24 hours
- **Report Generation:** 100% of requested exports delivered within 2 hours
- **Compliance:** 0 FERPA violations, 100% audit trail completeness
- **Satisfaction:** SLP NPS ≥ 50

---

## References

- FERPA 34 CFR § 99.2 (student records definition)
- IEP Documentation Best Practices (NACDL, ASHA)
- Clinical Data Management Standards (ASHA)
- User Research Findings (Phase 1 advisory board interviews)
