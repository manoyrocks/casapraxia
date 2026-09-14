# Praxia Parent Onboarding Flow

## Overview

Onboarding guides a parent (or guardian) through Praxia setup on their child's iOS device. It covers consent, device configuration, first-session orientation, and ongoing support.

**Duration:** 8–12 minutes (first session)
**Tone:** Warm, jargon-free, strength-based (celebrates child's voice, not deficits)
**Outcome:** Parent understands their role (scoring, not teaching), knows how to start a session, and has SLP contact info

---

## Flow Diagram

```
[Install App]
    ↓
[Splash Screen: "Welcome to Praxia"]
    ↓
[COPPA Consent: Parent confirms child age <13]
    ↓
[Guardian Information: Name, email, relationship]
    ↓
[Therapy Program Link: Scan QR from SLP or manual code entry]
    ↓
[Device Configuration: Child profile, companion character, sensory settings]
    ↓
[COPPA Training Opt-In: Consent for voice data improvement (optional)]
    ↓
[Audio Permission: Camera/Microphone access request]
    ↓
[Orientation Video: Parent's role (scored, not taught)]
    ↓
[Test Session: Demo with placeholder audio]
    ↓
[SLP Contact: Phone, messaging, office hours]
    ↓
[Ready to Practice: "Let's start!"]
```

---

## Screen-by-Screen Specification

### Screen 1: Splash / Welcome

**Visual:**
- Large Praxia logo (🎤)
- Warm, welcoming headline: "Welcome to Praxia"
- Subtext (2–3 lines):
  ```
  Help your child practice speech at home.
  Structured activities. No pressure. Done in 10 minutes.
  ```
- Large "Get Started" button (≥64pt)

**Accessibility:**
- Headline: font size 28pt, Poppins 700, dark gray
- Subtext: font size 16pt, Inter 400, medium gray
- Button: min-width 120pt, min-height 64pt, rounded 8pt
- Color: Accent blue (#5b9ef5)
- Dark mode: light text on dark background

**Next:** → Screen 2 (COPPA Consent)

---

### Screen 2: COPPA Consent & Age Gate

**Purpose:** Verify child's age and obtain guardian consent (required by COPPA Amended Rule 2024).

**Layout:**
```
┌──────────────────────────────────────────┐
│  Legal Compliance                        │
├──────────────────────────────────────────┤
│                                          │
│  ⚠️ Before we start:                    │
│                                          │
│  Is your child under 13 years old?       │
│                                          │
│  [ Yes ]  [ No ]                         │
│                                          │
│  (If No: redirect to parent-only app)    │
│                                          │
│  ✓ I'm the parent/guardian of this child │
│                                          │
│  Legal disclosure (collapsible):        │
│  [+ Read privacy & consent details]     │
│                                          │
│  [ Next ]                                │
└──────────────────────────────────────────┘
```

**Disclosure (collapsed by default, expandable):**
```
Praxia collects voice recordings from your child to deliver speech practice 
services. Under COPPA (Children's Online Privacy Protection Act), we need 
your consent:

1. **Voice Recordings:** Captured on your device and encrypted before upload.
   Retained for 90 days to allow your SLP to review practice quality.

2. **Training Consent (Optional):** You can separately consent to allow Praxia 
   to improve its models using your child's voice data (anonymized, never 
   shared). This is entirely optional and does not affect access to the app.

3. **Deletion:** You can request deletion of all voice data at any time.

4. **Our Commitment:** 
   - No third-party ads or tracking
   - No machine scoring shown to your child
   - Your child's voice is treated with care and confidentiality
   - SLP oversight of all data

[I understand and consent] [ Decline and exit ]
```

**Interaction:**
- If "No" → redirect message: "Praxia is designed for children under 13. Please contact your SLP if you have questions."
- If "Yes" + "I'm the parent" unchecked → disable Next button
- If "Yes" + "I'm the parent" checked → enable Next button

**Next:** → Screen 3 (Guardian Information)

---

### Screen 3: Guardian Information

**Purpose:** Capture parent/guardian contact for account recovery and SLP communication.

**Layout:**
```
┌──────────────────────────────────────────┐
│  Your Information                        │
├──────────────────────────────────────────┤
│                                          │
│  Your Name *                             │
│  [_______________________]               │
│                                          │
│  Your Email *                            │
│  [_______________________]               │
│                                          │
│  Your Relationship to Child *            │
│  [ Mother ] [ Father ] [ Other ]         │
│  [ Other: ____________________ ]         │
│                                          │
│  Phone (optional)                        │
│  [_______________________]               │
│  (Helps SLP reach you)                   │
│                                          │
│  [ Back ]  [ Next ]                      │
└──────────────────────────────────────────┘
```

**Validation:**
- Email: must be valid format (regex)
- Name: non-empty
- Relationship: required
- Phone: optional but formats to E.164 if provided

**Privacy Note (small text):**
```
Your information is used only for account recovery and SLP communication. 
We never share it with third parties or use it for marketing.
```

**Next:** → Screen 4 (Therapy Program Link)

---

### Screen 4: Therapy Program Link

**Purpose:** Connect child's app to their SLP's therapy program (cue hierarchy, targets, AAC).

**Context:**
- SLP provides a QR code or 6-digit code at first appointment
- Code links child to their personalized program

**Layout (Two Options):**

**Option A: Scan QR Code (Preferred)**
```
┌──────────────────────────────────────────┐
│  Link to Your SLP                        │
├──────────────────────────────────────────┤
│                                          │
│  Your SLP gave you a code. Let's use it. │
│                                          │
│  [ Scan QR Code ]                        │
│  (Camera permissions required)           │
│                                          │
│  ─── or ───                              │
│                                          │
│  [ Enter Code Manually ]                 │
│  Input: [______] [______] [______]       │
│         (6-digit code)                   │
│                                          │
│  [ Back ]  [ Next ]                      │
└──────────────────────────────────────────┘
```

**Option B: Manual Code Entry**
```
Enter the 6-digit code your SLP provided:

[  ][  ][  ][  ][  ][  ]

(Format: XXSSPP where XX = clinic, SS = SLP, PP = patient)
```

**Validation:**
- On scan: parse QR, validate format, verify against backend
- On manual entry: format check, request backend verification
- On success: load program data (targets, AAC config)
- On failure: show friendly error ("Code not found. Check with your SLP.")

**Behind the Scenes:**
- API call: ConfigService.GetProgram(code)
- Returns: program_id, targets, cue_hierarchy, aac_board
- Caches locally (SQLCipher)

**Next:** → Screen 5 (Device Configuration)

---

### Screen 5: Device Configuration

**Purpose:** Personalize the app for this child (name, companion character, sensory settings).

**Layout:**
```
┌──────────────────────────────────────────┐
│  Meet Your Child                         │
├──────────────────────────────────────────┤
│                                          │
│  Child's First Name *                    │
│  [_______________________]               │
│  (Used only on this device)              │
│                                          │
│  Companion Character                     │
│  "Who will practice with your child?"    │
│                                          │
│  [ 👧 Default ]  [ 👦 Boy ]  [ ⭐ Star ] │
│  [ 🦋 Custom ]                           │
│                                          │
│  Preview: [Companion floating]           │
│                                          │
│  Sensory Preferences                     │
│  (Customize later in Settings)           │
│                                          │
│  ☑ Animations on                         │
│  ☑ Sound on                              │
│  ☑ Celebrate with sparkles               │
│                                          │
│  [ Back ]  [ Next ]                      │
└──────────────────────────────────────────┘
```

**Interaction:**
- Child's name: default to placeholder "Alex" if parent skips
- Companion: each option shows preview in real-time
- Sensory: toggles persist to device settings (can change later)

**Next:** → Screen 6 (COPPA Training Opt-In)

---

### Screen 6: COPPA Training Opt-In (Optional)

**Purpose:** Separate consent for model training (optional, not required to use app).

**Layout:**
```
┌──────────────────────────────────────────┐
│  Help Us Improve (Optional)              │
├──────────────────────────────────────────┤
│                                          │
│  📊 Improve Praxia for all children      │
│                                          │
│  We can use voice recordings from your   │
│  child's practice sessions to improve    │
│  Praxia. Your child's voice will be:     │
│                                          │
│  ✓ Anonymized (no name or ID)            │
│  ✓ Never shared (stays with Praxia)      │
│  ✓ Encrypted (protected always)          │
│                                          │
│  This is entirely optional and does NOT  │
│  affect your child's access to Praxia.   │
│                                          │
│  [ ✓ Yes, help us improve ]              │
│  [ ☐ No, just use the app ]              │
│                                          │
│  Legal: [Read full training consent]     │
│                                          │
│  [ Back ]  [ Next ]                      │
└──────────────────────────────────────────┘
```

**Interaction:**
- This is a separate consent checkbox (can be changed anytime in Settings)
- Default: unchecked (opt-in, not opt-out)
- Legal text expandable (COPPA-compliant language)

**Next:** → Screen 7 (Audio Permissions)

---

### Screen 7: Audio Permissions

**Purpose:** Request iOS microphone access (required for speech capture).

**Layout:**
```
┌──────────────────────────────────────────┐
│  Microphone Access                       │
├──────────────────────────────────────────┤
│                                          │
│  🎤 We need microphone access            │
│                                          │
│  Praxia captures your child's voice to   │
│  detect attempts. We use 16 kHz mono     │
│  audio (speech-only frequency).          │
│                                          │
│  Tap "Allow" when prompted by iOS.       │
│                                          │
│  ✓ Audio is encrypted on your device     │
│  ✓ Never leaves without your permission  │
│  ✓ Deleted after 90 days                 │
│                                          │
│  [ Request Microphone Access ]           │
│                                          │
│  Not ready? You can enable it later in   │
│  iOS Settings > Praxia > Microphone      │
│                                          │
│  [ Skip for now ]  [ Next ]              │
└──────────────────────────────────────────┘
```

**Technical:**
- Calls `AVAudioSession.requestRecordPermission()`
- iOS shows native permission dialog
- On approval: continue to Screen 8
- On denial: offer "Skip" option (but note: app won't capture audio without permission)

**Next:** → Screen 8 (Orientation Video)

---

### Screen 8: Orientation Video

**Purpose:** Show parent their role in scoring (not teaching), expected session length, warm contingency approach.

**Layout:**
```
┌──────────────────────────────────────────┐
│  Your Role in Praxia                     │
├──────────────────────────────────────────┤
│                                          │
│  [Video player, 90 seconds]              │
│                                          │
│  Title: "How to Support Your Child"      │
│  (With captions + sign language option)  │
│                                          │
│  Key points (text under video):          │
│  ✓ You observe and score (no teaching)   │
│  ✓ Sessions are 10 minutes, pressure-free│
│  ✓ Every attempt is celebrated           │
│  ✓ Follow your child's lead              │
│                                          │
│  Transcript: [Collapsible text]          │
│  [+ Read transcript]                     │
│                                          │
│  [ Back ]  [ Next ]                      │
└──────────────────────────────────────────┘
```

**Video Script (~90 sec):**
```
[Upbeat, warm music]

NARRATOR (calm parent voice):
"Welcome to Praxia. You're about to help your child 
practice speech at home—without pressure or judgment.

Your child will see a model, attempt a sound or word, 
and you'll score what you observed. Not 'right' or 'wrong'—
just 'Got It,' 'Close,' or 'Not Yet.' Every attempt 
is an achievement.

Sessions are short: 10 minutes. Your child leads the pace. 
If they want to stop, that's okay. If they want more, 
that's okay too.

The companion character will celebrate effort. Not accuracy—effort.

Your SLP is in the loop. They see the practice data and can 
adjust the program based on progress.

Let's start."

[Fade to app interface]
```

**Accessibility:**
- Captions: required (English + Spanish options)
- Audio description: optional
- Sign language: optional (if available)
- Keyboard accessible (play/pause)

**Next:** → Screen 9 (Test Session)

---

### Screen 9: Test Session (Demo)

**Purpose:** Parent experiences the app with simulated child audio (no real recording).

**Context:**
- Pre-recorded "child" audio files (example vocalizations)
- Parent scores 5 trials to get a feel
- No real data persisted
- All confidential—can't share demo recordings

**Layout:**
```
┌──────────────────────────────────────────┐
│  Try It Out                              │
├──────────────────────────────────────────┤
│                                          │
│  Let's do a short practice session.      │
│  You'll see how scoring works.           │
│                                          │
│  [Demo Session Loads]                    │
│                                          │
│  Trial 1/5:                              │
│  Model: 🎬 [Video shows "Say: ball"]     │
│  Waveform: [Animated bars]               │
│  Prompt: "Your turn!"                    │
│                                          │
│  Your Score:                             │
│  [ ✓ Got it ]  [ ~ Close ]  [ ⏸ Not yet]│
│                                          │
│  [Demo runs 5 trials, then summary]      │
│                                          │
│  Summary:                                │
│  "You scored 5 attempts in ~2 minutes.   │
│   Ready? Let's practice for real."       │
│                                          │
│  [ Back ]  [ Let's Go ]                  │
└──────────────────────────────────────────┘
```

**Interaction:**
- Demo audio is pre-recorded (not live capture)
- Parent taps scoring buttons 5 times
- Demo progresses automatically
- No data saved (cleared on exit)

**Next:** → Screen 10 (SLP Contact)

---

### Screen 10: SLP Contact Information

**Purpose:** Establish trust by showing clear SLP communication pathway.

**Layout:**
```
┌──────────────────────────────────────────┐
│  Your SLP                                │
├──────────────────────────────────────────┤
│                                          │
│  Dr. Jane Smith, MS-CCC-SLP              │
│  Licensed Speech-Language Pathologist    │
│                                          │
│  Clinic: Voices Speech Center            │
│  Phone: (555) 123-4567                   │
│  Email: jane@voicesspeech.com            │
│                                          │
│  Office Hours:                           │
│  Mon–Thu: 9 AM – 5 PM (PT)               │
│  Fri: 9 AM – 12 PM (PT)                  │
│                                          │
│  How to Reach Out:                       │
│  ☐ Call during office hours             │
│  ☐ Email (response in 24 hrs)            │
│  ☐ Messaging in-app (async)              │
│                                          │
│  Emergency Questions:                    │
│  Contact your pediatrician or call 911.  │
│  (Praxia is not emergency care.)         │
│                                          │
│  [ Message SLP ]  [ Done ]               │
└──────────────────────────────────────────┘
```

**Data Source:**
- SLP info pulled from linked program (ConfigService)
- Timezone detection (auto-adjust office hours to local)
- Messaging button pre-fills greeting: "Hi Dr. Smith, I have a question about Praxia..."

**Next:** → Screen 11 (Ready to Practice)

---

### Screen 11: Ready to Practice

**Purpose:** Celebration + call-to-action for first real session.

**Layout:**
```
┌──────────────────────────────────────────┐
│  You're All Set! 🎉                      │
├──────────────────────────────────────────┤
│                                          │
│  Everything is ready for your first      │
│  practice session with [Child Name].     │
│                                          │
│  Quick Checklist:                        │
│  ✓ Consent completed                     │
│  ✓ Program linked                        │
│  ✓ Microphone ready                      │
│  ✓ Sensory settings saved                │
│                                          │
│  Pro Tips:                               │
│  • Pick a quiet time of day              │
│  • Sit together (audio capture best at   │
│    arm's length)                         │
│  • Let your child set the pace           │
│  • Celebrate every attempt               │
│                                          │
│  Ready?                                  │
│                                          │
│  [ Start Your First Session ]             │
│                                          │
│  [ Settings ]  [ Contact SLP ]           │
└──────────────────────────────────────────┘
```

**Next:** → Launch ChildViewController (live session)

---

## Post-Onboarding: First Session Tips

After "Start Your First Session," parent sees:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 First Session Tips

These tips will help your first session go smoothly.
You can dismiss this anytime.

1. Audio Quality: Sit arm's-length from your child.
   Minimize background noise (toys, TV, fan).

2. Scoring: Be generous with "Close"—it counts effort.
   Don't overthink right/wrong.

3. Pacing: If your child wants to stop before 10 min,
   that's fine. Sessions can be shorter.

4. Questions? Message your SLP. They'll see the
   session data and can guide you.

[ Got it, let's begin ]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Settings Access (Ongoing)

After onboarding, parent can revisit settings anytime:

```
⚙️ Settings

Guardian
  • Name: [editable]
  • Email: [editable]
  • Phone: [editable]

Child
  • Name: [editable]
  • Companion: [selector]
  • Sensory Preferences: [toggles]

Program
  • Current Program: [linked SLP info]
  • Link New Code: [QR scan / manual entry]

Privacy & Consent
  ☑ Training Consent: [toggle]
  • View Privacy Policy
  • View COPPA Consent

Account
  • Download My Data (GDPR)
  • Delete All Data (irreversible)
  • Sign Out
```

---

## Tone & Design Principles

1. **Strength-Based:** Celebrate child's voice, not deficits
2. **No Jargon:** Avoid "phonology," "motor planning," "cue level"
3. **Transparent:** Explain data usage clearly, upfront
4. **Accessible:** Large buttons, high contrast, captions
5. **Warm:** Conversational, reassuring, supportive
6. **Quick:** 8–12 minutes total (parents have limited time)

---

## Compliance Checkpoints

- ✅ COPPA age gate + consent
- ✅ Separate training consent (optional)
- ✅ Privacy disclosure (expandable, not required to read)
- ✅ Audio permission (iOS native, can't skip entirely)
- ✅ Data retention explained (90 days, SLP review)
- ✅ Deletion pathway (Settings > Delete All Data)
- ✅ SLP contact (trust, not isolation)

---

## A/B Testing (Post-Launch)

Recommended experiments:
1. **Video vs. Text:** Does 90-sec video improve parent understanding vs. text guide?
2. **Demo Session:** Does test session with 5 trials reduce support requests vs. no demo?
3. **Companion Selection:** Do certain characters correlate with higher parent engagement?
4. **Training Consent:** What % opt-in to training? Does messaging change opt-in rate?

---

## Success Metrics

- **Completion Rate:** >90% of parents complete onboarding
- **First Session Start:** >85% start first session within 48 hours
- **Support Tickets:** <5% reach out with "how do I..." questions (indicates clarity)
- **Consent Audit:** 100% of users pass COPPA validation
- **Accessibility:** 0 reported accessibility issues (WCAG AA minimum)

---

## Implementation Notes

- Screens 1–7: Build as SwiftUI ViewControllers
- Screens 8–9: Video + demo session (interactive)
- Screen 10–11: Post-launch
- Persistence: Save state at each screen (resume if interrupted)
- Localization: English + Spanish (future: Mandarin, Vietnamese)
- Accessibility: VoiceOver tested, captions required on all video

---

**Target Delivery:** Weeks 9–10 (after core app stable)
**Estimated Build Time:** 2–3 dev weeks + QA
**Dependencies:** ConfigService (program data), TrialStore (demo session), video editing

