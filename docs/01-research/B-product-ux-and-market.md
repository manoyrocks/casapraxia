# Research B — Product, UX & Behavioral Design
## A mobile app to get a NON-VERBAL child with Childhood Apraxia of Speech (CAS) to first words

*Scope note: clinical/treatment-evidence questions (PROMPT, DTTC, ReST, cueing hierarchies, dosage evidence) are owned by another researcher. This document covers users, UX, engagement design, interaction model, coaching, clinician tooling, market/business and risk. Where clinical facts are load-bearing for a product decision they are stated as constraints, not as an evidence review.*

---

## 0. The one-sentence product thesis

**The app is not a speech teacher. It is a practice-delivery and coaching system that makes a parent into a competent, consistent, non-anxious practice partner — and makes the SLP's target hierarchy executable 6 days a week instead of 1.**

Everything below follows from that. The single most important product insight for CAS is a dosage problem, not a content problem: CAS needs very high-frequency, distributed, motor-based practice (on the order of 60–100+ trials per short session, several sessions a week). No clinic caseload delivers that. Families theoretically can, but they don't, because they are untrained, exhausted, guilty and unsure whether what they're doing is helping or harming. The app's real job is to close that dosage gap without turning the home into a drill lab.

A second, equally important thesis: **for a non-verbal child, the app must never be the only voice.** An app that withholds communication until speech is produced is unethical and clinically wrong. AAC and speech practice must coexist in the same product from day one.

---

## 1. USER ECOSYSTEM & JOBS-TO-BE-DONE

Four users, three of whom never produce the core outcome and all of whom can kill the product.

### 1a. THE CHILD (≈18 months – 8 years, non-verbal / minimally verbal)

Characteristics that drive design: pre-literate (often permanently for the early years — **assume zero reading ability, ever**); receptive language frequently far ahead of expressive (never talk down to them); high rates of co-occurring ASD, ADHD, DCD/motor planning issues, sensory processing differences; extremely low frustration tolerance *specifically around speech* because they have a multi-year history of failing at it in front of adults; many have learned an avoidance response to being asked "say ___"; fine-motor and touch precision may be imprecise; attention span in the 3–8 minute range for a novel task, less for an aversive one.

**JTBD statements (child's voice, functional not clinical):**
- "When an adult points at something and looks at me expectantly, I want to make the thing happen that they want, so I can stop feeling watched and get back to what I was doing."
- "When I want something and can't get it, I want a way to make an adult understand me *right now*, so I don't have to melt down."
- "When I try something hard, I want to know immediately whether I did it, so I don't keep guessing."
- "When I'm playing, I want to be the one who chooses what happens next, so it feels like mine and not like a test."
- "When something is about to end or change, I want to know it's coming, so I don't get ambushed."

**Pain points:** being asked to perform on demand; adult disappointment they can read but can't fix; not knowing what "right" sounds like from the inside (impaired auditory-motor self-monitoring is near-definitional in CAS — they genuinely cannot self-score); sensory overload from typical bright/loud kids' apps; being handed a reward they didn't earn and knowing it; being handed a reward and losing it.

**Day in the life:** wakes, points/leads-by-hand for breakfast, gets misunderstood twice before 8am, one 30-min SLP session twice a week where a stranger asks for sounds 80 times, preschool where peers have stopped trying to talk to them, evening where a tired parent tries "homework" from the SLP for four minutes before both give up. **Total speech-motor practice trials on a typical non-therapy day: near zero.** That number is the product's north-star input metric.

### 1b. THE PARENT / CAREGIVER

Characteristics: usually the mother; often mid-diagnostic-odyssey; has read too much internet; oscillates between "he'll catch up" and catastrophizing; financially stretched (private SLP $100–250/session, often 2x/week, often not covered); carries guilt ("did I cause this? am I doing enough?"); has other children; is not a clinician and will not become one; has been handed a photocopied word list and told to "practice at home" with no model of *how*.

**JTBD:**
- "When my SLP gives me homework, I want to know exactly what to do and how to know it's working, so I stop avoiding it out of fear of doing it wrong."
- "When I have 6 spare minutes, I want a practice activity that's already loaded and correct for today, so the decision cost doesn't stop me."
- "When my child makes a tiny improvement, I want someone to *notice it with me*, so I can keep going."
- "When progress is slow, I want honest information rather than reassurance, so I can trust the app when it does say something is working."
- "When I'm out of patience, I want permission to stop, so practice never becomes a fight."

**Pain points:** homework guilt; no feedback loop (did the 5 minutes matter?); fear of "doing it wrong" and reinforcing errors; inability to judge their own child's productions; comparison to milestone charts; cost; the app becoming one more thing they're failing at.

**Day in the life:** 6:45 wake, 3 kids, work, 4:30 pickup, the 5:10 SLP teletherapy slot, dinner, and a 20-minute window at 7pm where the choice is practice vs. bath vs. sitting down for the first time all day. **The app competes with the parent sitting down.** If it takes more than ~90 seconds of setup and doesn't reliably produce a moment of shared joy, it loses that competition forever.

### 1c. THE SLP

Characteristics: caseload of 40–70 in schools (often higher), 8–10 clients/day in private practice; documentation burden already crushing; genuinely skeptical of consumer speech apps because most are language/vocabulary apps mis-marketed as therapy and some actively contradict motor-learning principles; is the **gatekeeper and the distribution channel** — parents overwhelmingly adopt what their SLP endorses; will not use anything that adds documentation work; fiercely protective of scope ("this app is not going to tell parents it's therapy").

**JTBD:**
- "When I set home practice, I want to control the exact targets and cueing level, so the family isn't drilling something outside the hierarchy."
- "When a family comes back in two weeks, I want to see what actually happened at home, so my session starts from data not anecdote."
- "When I write progress notes and IEP goals, I want the numbers to already exist, so I get my evenings back."
- "When a parent is drilling too hard or cueing wrong, I want to see it and correct it asynchronously, so I don't burn session time on it."
- "When I recommend a tool, I want it to not embarrass me, so my professional credibility survives."

**Pain points:** no visibility into home practice; parents who over-drill or under-practice; app vendors overclaiming; another login; tools built for articulation (single-sound drill) being applied to a motor-planning disorder; data that isn't IEP-shaped.

**Day in the life:** 7:30 arrive, 8 back-to-back 30-min sessions, 20-min lunch spent on Medicaid billing, three IEP meetings this week, evenings writing notes. **Any clinician feature that costs more than ~2 minutes per client per week will not be used.**

### 1d. SCHOOLS / IEP TEAMS

**JTBD:** "When I write and defend an IEP goal, I want measurable baseline and progress data in the district's format, so the goal survives the meeting and a due-process challenge." "When I buy a tool for 30 students, I want one invoice, a DPA, COPPA/FERPA compliance, and SSO/roster sync, so procurement approves it."

**Pain points:** procurement cycles (6–12 months, budget years starting July); privacy/DPA review (student data privacy agreements, FERPA, COPPA, state laws like NY Ed Law 2-d, California SOPIPA); device fleet reality (shared iPads, Chromebooks — **a Chromebook/web fallback is a procurement requirement, not a nice-to-have**); need for evidence before purchase; accessibility procurement (VPAT / Section 508 conformance report is routinely requested).

---

## 2. PERSONAS

**P1 — Mateo, 3y2m. "The classic CAS toddler."**
Diagnosed CAS at 2y10m after 14 months of "wait and see." ~8 consistent word approximations, vowel distortions, groping on attempts, highly inconsistent (says "ba" for ball once and can't repeat it). Receptive language age-appropriate — he understands everything and his frustration is proportional to that gap. Bites his own hand when not understood. Loves vehicles, hates loud sudden sounds. Will tolerate an iPad for 10 minutes if he controls it. Product implication: he needs *volume of attempts under low social pressure*, and a way to communicate now.

**P2 — Aisha, 5y7m. "Minimally verbal, co-occurring autism."**
ASD diagnosed at 3, CAS suspected/co-occurring. ~15 words, mostly requests, plus a 60-button AAC grid she uses inconsistently. Strong visual learner, echolalic in bursts, demand-avoidant: any question phrased as a direct request ("say cup") produces immediate withdrawal. Needs predictable sequence, hates transitions, over-responsive to sound (covers ears at cartoon jingles), under-responsive to proprioceptive input. Product implication: **every design decision that trades excitement for predictability is correct.** She is the hardest user and the best design forcing-function. Practice must be embeddable in play and routine, not framed as a demand. Her AAC must never be taken away or gated.

**P3 — Danielle, 34. "The exhausted mother."**
Two kids, works 30hrs/wk, Mateo's mother. Spends $800/mo on private SLP after insurance denied "developmental" claims. Has downloaded 6 speech apps; used 2 of them more than twice. Reads the Apraxia Kids forums at 11pm. Feels guilty every single day. Key quote: "I don't need more exercises. I need to know if what I'm doing is right." Product implication: **coaching and reassurance-with-honesty are features, not content marketing.** She will churn if week 3 produces no visible signal.

**P4 — Ray, 41. "The secondary caregiver / grandparent."**
Mateo's father, does bedtime and weekend mornings. Would practice if told exactly what to do, doesn't read anything longer than a paragraph, won't attend the SLP session. Product implication: multi-caregiver accounts with a **zero-onboarding "just tell me what to do right now" mode**, and consistency guardrails so he doesn't cue differently from Danielle.

**P5 — Karen, 48, CCC-SLP. "The skeptical clinician."**
Private pediatric practice, 8 clients/day, PROMPT-trained, ~6 CAS kids on caseload. Recommends exactly two apps and badmouths the rest. Believes most "speech apps" are vocabulary flashcards with a badge system. Will evaluate the app in 10 minutes and decide forever. Will adopt if: she controls the target list and cue level, the home data is trustworthy, and the marketing doesn't say "therapy" or "cure." Product implication: **she is the distribution channel and the veto.** Build the clinician portal early even though it has few users, because each clinician brings 3–15 families.

*(Secondary: Marcus, 52, school district special-ed director — buys on caseload efficiency, privacy compliance and IEP defensibility, on a July budget cycle.)*

---

## 3. CORE UX PRINCIPLES FOR A NON-VERBAL, NEURODIVERGENT CHILD USER

Design standard baseline: **WCAG 2.2 Level AA** (W3C Recommendation, Oct 2023) plus **W3C COGA "Making Content Usable for People with Cognitive and Learning Disabilities"**, plus Apple *Human Interface Guidelines — Accessibility* and Google's *Material Design accessibility* / Android accessibility guidance. WCAG 2.2 matters here specifically because of **2.5.8 Target Size (Minimum, 24×24 CSS px — we will exceed it substantially)**, **2.5.7 Dragging Movements (every drag must have a single-pointer alternative — for a child with motor planning difficulty, drag-and-drop is close to a hostile interaction)**, **3.2.6 Consistent Help**, **3.3.7 Redundant Entry**, and **2.4.11 Focus Not Obscured**. COGA supplies what WCAG can't: predictable structure, minimal steps, no time limits, clear unambiguous imagery, avoiding distraction.

**The fourteen principles:**

1. **Zero reading required, ever.** Every child-facing control is a photograph, a familiar icon, or a spoken instruction. Text may appear *only* as a redundant layer for adults. Photographs beat illustrations for object recognition in this population; use real photos for nouns and video for actions.
2. **Predictable routines over novelty.** The same session skeleton every time: greeting → choose activity → N trials → celebration → end ritual. Novelty lives *inside* slots, not in the structure. Aisha's principle.
3. **Reduced sensory load by default.** Ship with low-stimulation defaults, not high-stimulation-with-an-off-switch. Calm, desaturated palette (avoid saturated red/yellow at scale); no background music by default; no idle animation; one thing moves at a time; no unexpected audio; no autoplay after the current item.
4. **A visible, always-reachable sensory panel.** Sound on/off, music off independent of voice, animation reduce/off, brightness/contrast, dark mode, haptics on/off, speed of model video, reward intensity slider. Honor OS-level `prefers-reduced-motion` and Reduce Motion / Reduce Transparency settings automatically.
5. **No time pressure.** No countdowns, no timers visible to the child, no "hurry" audio, no score decay. WCAG 2.2.1 (Timing Adjustable) is the floor; the design rule is stricter — *nothing on the child screen ever changes because time passed.* A child with a motor-planning disorder needs long, variable response latency.
6. **No punishing failure states.** No red X, no buzzer, no "try again!" in a disappointed voice, no losing collected items, no health bars, no restart-from-zero. The child has a lifetime of failure feedback around speech already.
7. **Errorless-learning structure.** The first presentation of a target is maximally supported (full model, simultaneous production, tactile/visual cue) and support fades only on success. The design goal is that the child is *right almost all the time*. This is both a motor-learning principle and the single most important emotional-safety feature.
8. **Choice and agency at every turn.** Child picks the activity, the character, the order of the two targets, which reward to open. Choice is the cheapest, strongest engagement lever for demand-avoidant kids and it converts a demand into an offer.
9. **Large touch targets and accidental-touch tolerance.** Minimum 64×64 dp interactive targets for child UI (far above WCAG's 24px floor), ≥16dp spacing, no targets in thumb-rest zones or screen edges, debounce rapid repeat taps, ignore touches during transitions, require a deliberate long-press or a two-step gesture for any destructive/exit action, and a **parent gate** (multi-step, non-numeric-literacy-dependent, e.g. hold-and-drag + adult-level arithmetic) for settings/purchase — also an App Store Kids Category requirement.
10. **Transition warnings.** Visual + auditory "two more, then we're done" with a concrete countable representation (three tokens that disappear), never an abstract timer bar.
11. **Session-end rituals.** Every session ends the same way: a short earned celebration, the collection shelf, a consistent goodbye from the companion, and the app *closes itself out* of the child context. Never end on a failed trial. Never end because a timer expired.
12. **One screen, one job.** No nested menus in the child zone. Depth ≤ 2. No modals over the child's task. Persistent, identical placement of the "home", "repeat the model" and "pause" affordances (COGA + WCAG 3.2.3/3.2.4 consistency).
13. **Multimodal redundancy.** Every instruction carries at least two channels (spoken + visual; visual + haptic). Never rely on color alone (WCAG 1.4.1) or on sound alone — many of these children have fluctuating otitis media, and some will use the app muted.
14. **The child's data is the child's.** No advertising, no third-party analytics SDKs in the child experience, no behavioural profiling. COPPA + App Store Kids Category + Google Play Families policy forbid most of it anyway; treat that as the design floor, not the ceiling.

**Autism-specific design research adds:** literal and concrete language; avoid metaphor and idiom in any spoken prompt; avoid faces with exaggerated emotional expression at high intensity; provide a visual schedule of the session; allow repetition of a preferred item without penalty (repetition is regulation, not a bug); avoid unexpected character speech; and offer a "quiet mode" that strips the app to the bare task.

---

## 4. ENGAGEMENT WITHOUT EXPLOITATION

The engineering target is **60–100+ speech attempts in a 5–10 minute session, 5+ days/week, sustained for months.** That is a brutal engagement requirement in a population with low frustration tolerance — and it is exactly the situation where consumer app playbooks turn predatory. The discipline: **motivate the practice, never the app.**

**Intrinsic vs extrinsic.** Extrinsic rewards are necessary early (the speech act itself is not yet reinforcing; it is currently *aversive*). But the reward must be engineered to decay. Design rule: **the reward is a vehicle for the next trial, not a destination.** Concretely — reward animations ≤ 2.5s, never skippable-into-a-dead-end, always returning directly to the next trial; reward magnitude *decreases* as competence increases while target difficulty rises; and the app actively shifts the reinforcement source from the app to the human ("Look at Mom!" / parent-delivered praise prompts) and then to the communicative effect itself (the word *works*: saying/approximating "go" makes the car go). **Natural/functional reinforcement — the utterance causes the outcome — is the highest form and should be the spine of the design.** That is also the mechanism by which speech generalizes out of the app.

**Errorless learning as engagement.** Success rate is the best engagement metric we have. If the child is succeeding ~80–90% of trials, engagement takes care of itself; if success drops below ~60%, no reward system will save the session. So the adaptive engine's primary objective function is *maintaining success rate inside a band*, not maximizing difficulty.

**Variable reinforcement, ethically.** Variable-ratio schedules are the most powerful behavioural tool available and also the engine of slot machines. Ethical constraints that make it acceptable here: (a) the variability is over *which* reward, never *whether* effort was valued — every trial gets acknowledgement, only the bonus varies; (b) no near-miss simulation, ever; (c) no loss, no expiry, no resets; (d) no monetary or purchasable path to rewards; (e) reinforcement density decreases by design as a target masters; (f) the schedule is transparent to the parent in the settings ("your child gets a surprise about every 4th turn — you can change this to every turn or turn it off").

**Companion character.** One consistent, low-arousal companion (not a menagerie). Its job is (1) modelling — it produces the target with a visible mouth, (2) social scaffolding without social pressure — it is *also* learning, so the child is a peer rather than a subject, and (3) continuity across sessions. Rules: no disappointment reactions; no guilt lines ("you didn't visit me!"); never appears in a notification; never asks the child to come back. Customisable appearance = cheap agency.

**Story-arc progression.** A slow, non-urgent arc (build a town, grow a garden, a journey map) where each practice session advances it a small, guaranteed amount. Key property: **progress is a function of trials attempted, not trials correct.** Effort-contingent, not accuracy-contingent — this removes the incentive for a parent to score generously and removes the child's experience of failure from the visible world-state.

**Collection mechanics.** Collections are excellent here — low arousal, tolerate interruption, support repetition, and are self-paced. Rules: nothing is ever lost; nothing is timed; nothing is duplicate-farmed for hours; no trading/social; completion is achievable in months, not never.

**Parent-visible vs child-visible streaks.** This is the sharpest ethical line in the product. **Streaks are a parent-facing mechanic only, and even then must be defanged.** A child-visible streak converts a missed day into a loss the child can be blamed for. Even parent-facing, unbroken-streak framing manufactures guilt in a population already saturated with it. Solution: replace the streak with a **"practice rhythm"** view — a 4-week heatmap with no "broken" state, plus a goal expressed as "4 days this week" (a bucket, achievable after a miss) rather than "day 23." Missing days produce a neutral, compassionate re-entry ("Welcome back. Let's do three minutes."), never a loss animation, never a red zero.

**Burnout / aversion prevention (the failure mode that kills the outcome, not just the metric):**
- **Cap the session.** The app should *end* practice at the target trial count or at ~8–10 minutes, whichever is first, and resist "one more." Over-drilling creates speech aversion; a child who becomes avoidant of speech attempts is a worse outcome than no practice at all.
- **Detect aversion signals** — rising no-response rate, rising latency, mid-session exits, declining attempt volume within a session — and *proactively drop difficulty, switch to play/AAC mode, or suggest ending*. The app should be willing to say "let's stop here — this was a good day to stop early."
- **Mandate low-demand days.** Build "play days" into the schedule where no elicitation occurs.
- **Novelty budget.** Rotate stimuli within the same structure to fight habituation without breaking predictability.
- **Never blame the child in any copy, ever.** Parent-facing copy attributes slow days to the plan, not the kid.

### DARK PATTERNS TO BAN (explicit, enforceable list)

1. Loss-framed streaks, streak-freeze purchases, or any "you'll lose X" message.
2. Child-facing push notifications, or any notification that speaks in the companion's voice or guilt-trips ("Mateo hasn't practiced!").
3. Near-miss animations, spinning wheels, loot-box mechanics, or any randomized reward the user can buy.
4. Any currency purchasable with money that affects the child's experience or progression.
5. Ads of any kind, cross-promotion, in-child-experience upsells, and third-party ad/analytics SDKs.
6. Countdown timers, limited-time offers, or artificial scarcity anywhere the child can see.
7. Energy/lives/stamina systems that gate practice behind waiting or payment.
8. Interstitials, autoplay-next-video loops, or infinite feeds in the child zone.
9. Social comparison: leaderboards, percentile-vs-peers ("your child is behind 78% of 3-year-olds"), or friend streaks. Milestone comparison to typical development is *particularly* harmful here and must be opt-in and clinically framed if present at all.
10. Confirmshaming ("No thanks, I don't want my child to talk").
11. Dark-pattern cancellation: hidden cancel, cancel-by-email-only, or a retention gauntlet. Cancellation must be as easy as signup; support platform-native subscription management.
12. Trial-to-paid conversion without clear advance notice and an easy pre-charge exit.
13. Pay-to-progress in the story arc, or gating the AAC/communication function behind payment or behind speech performance. **The communication layer is never a paywall and never a reward.**
14. Anthropomorphized guilt ("Pip is sad you left").
15. Misleading efficacy claims, before/after testimonials as primary marketing, or any language implying cure, guaranteed outcome, or replacement of an SLP.
16. Collecting or monetizing the child's voice recordings beyond the stated clinical purpose; any model-training use without explicit, separate, revocable opt-in.

---

## 5. THE INTERACTION MODEL

### The core loop

```
  SET UP (child chooses)  →  MODEL  →  CUE  →  ATTEMPT WINDOW  →  CAPTURE
        ↑                                                            ↓
        └──  NEXT TRIAL  ←  REWARD/OUTCOME  ←  FEEDBACK  ←  JUDGEMENT ─┘
                                   (and, across trials: CUE FADE)
```

**MODEL.** Full-screen, close-up, front-facing video of a real human mouth (or a high-fidelity avatar with accurate articulator animation) producing the target — slowed, with optional repeat-on-tap, optional split-screen showing lips + the referent object. Video modelling with a visible mouth is the highest-leverage single asset in the product; it is expensive to produce and is the real moat.

**CUE.** Cue level is a per-target parameter set by the SLP (or by the adaptive engine within SLP-set bounds), stepping down a hierarchy roughly: simultaneous production → immediate imitation → delayed imitation → cued spontaneous → spontaneous. Cues available in-app: auditory model, slowed model, visual mouth close-up, a **visual gesture/tactile cue card the parent performs** (the app shows the parent a 2-second loop of the hand cue to give), rhythm/prosody beat, and a written-letter cue for older literate children only.

**ATTEMPT WINDOW.** Open-ended. Visual "your turn" signal that is unambiguous, consistent, and non-pressuring (companion turns to look, mic ring pulses slowly). No timeout that punishes; a soft re-prompt after a long silence, then an offer to move on.

**CAPTURE.** Always record audio + optional video of the attempt locally. Recording is the product's most valuable asset — for the SLP, for the parent (hearing progress over 8 weeks is the single most motivating artifact we can produce), and for future ASR. Requires explicit consent, local-first storage, on-device encryption, per-clip delete, and an obvious recording indicator.

### Who judges the attempt?

**Be blunt: ASR cannot be the primary judge.** General ASR is trained on adult, typical speech; child speech is already substantially harder, and *disordered* child speech is harder again. Recent literature shows unadapted models produce catastrophic error rates on children with speech sound disorders (WER around 0.8 on unreconstructed samples), while *fine-tuned, task-constrained* models — closed vocabulary, known target, personalized — can reach phoneme error rates in the 8–12% range and correlate very highly with SLP consonant-accuracy judgements (ICC ~0.98). The design consequence is precise: **ASR is viable as a constrained goodness-of-pronunciation scorer against a known target, and not viable as open recognition.** And even a good scorer is not safe as a *child-facing verdict*.

| Judge | Pros | Cons | Verdict |
|---|---|---|---|
| **On-device ASR / GOP scoring** | Instant, scalable, objective, enables solo practice, generates trial-level data cheaply | Unreliable on this exact population; a false "wrong" is actively harmful; a false "right" reinforces error; latency & battery; privacy if cloud | **Silent co-pilot only.** Use for trial detection (did a vocalization occur? duration? loudness? syllable count?), for flagging clips for SLP review, and for the parent's *suggested* score — never for a child-visible pass/fail. |
| **Parent-tap scoring** | Present anyway; humans are far better than ASR here; scoring keeps the parent attending to the child; trivially fast (3-button: got it / close / not yet) | Reliability varies; scoring fatigue; scoring can make the parent feel like a judge; risk of generous scoring inflating data | **Primary judge**, with heavy design care: 3 buttons max, huge, one-tap, positioned for the non-dominant hand, skippable (tap-through as "attempted"). Train reliability via short calibration exercises with example clips. |
| **SLP async review** | Gold standard accuracy; catches parent cueing errors; creates clinical value | Costly in clinician time; not real-time; doesn't scale to 100 trials/day | **Sampling reviewer.** SLP reviews ~10 auto-selected clips/week (first trial of each new target, highest-uncertainty clips, one random), adjusts hierarchy, records a 20-second async video reply. |
| **Child self-evaluation** | Ultimate goal of motor learning | Impaired by definition in CAS at this stage; premature self-judgement is harmful | **Not at first words.** Introduce a simple "did that feel the same as mine?" only much later. |
| **Hybrid (recommended)** | — | — | **ASR pre-scores → parent confirms with one tap → SLP audits a sample.** Parent's tap is truth; ASR agreement rate is tracked and surfaced only to the clinician. |

### How do you give feedback to a child who cannot self-evaluate?

Four rules.

1. **Separate acknowledgement from evaluation.** *Every* attempt gets immediate, identical, warm acknowledgement (the companion reacts, the world advances). Evaluation — the finer-grained "that one was really close to mine" — is delivered by the human, not the app.
2. **Make the outcome the feedback.** The strongest, least-ambiguous signal for a pre-self-evaluative child is **contingency**: the attempt causes something in the world. Say/approximate "up" → the balloon goes up. This teaches *speech is instrumental* — the actual therapeutic insight — without any judgement. Design the majority of trials this way.
3. **Use knowledge-of-performance sparingly and physically.** When correction is needed, it comes as a *re-model plus a stronger cue on the next trial*, not as a verdict on the last one. The child experiences it as "we're doing it together again," not "you failed." (This also matches motor-learning practice: reduced-frequency, delayed, summary feedback beats constant correction.)
4. **Playback as mirror.** Occasionally play back the child's own attempt right after the model, side by side. This is the beginning of self-monitoring and is often startling and motivating — but it must be opt-in per child, since for some (especially autistic children) hearing their own voice unexpectedly is dysregulating.

**Cue fading** is automated within SLP-set bounds: after N consecutive successes at cue level K, offer level K−1; after M failures, step back up immediately and silently. Stepping back up must never be visible as a demotion.

---

## 6. MULTIMODAL — SIX MODALITIES, ONE APP, NO BLOAT

The anti-bloat rule: **these are not six features, they are six layers of the same trial.** Each attaches to the single core loop rather than living in its own tab. There is one content spine — a *target word* — and each modality is a property of how that word is presented, cued, or used.

| Modality | Role in the loop | How it stays non-bloated |
|---|---|---|
| **AAC board** | Always-present communication layer; also the *stimulus selector* (the child requests what to practice) | Not a separate app-within-an-app. A small, motor-consistent core board (~12–40 cells, fixed positions) that is (a) reachable from any screen with one persistent button, (b) auto-populated with current speech targets, (c) never blocked by a paywall or a trial. If the family already uses Proloquo2Go/LAMP/TouchChat, **do not compete** — mirror the target symbols and defer. |
| **Video modelling** | The MODEL step | It *is* the model step. One asset per target. |
| **Tactile / visual cueing** | The CUE step, executed by the parent | Shown as a 2-second parent-facing loop above the child area; never a separate lesson. Parent training for cues lives in the coaching layer. |
| **Rhythm / music / prosody** | A *mode* of the model (tapped syllables, sung target, metronomic pacing) | A toggle on the trial, not a section. Multisyllabic targets and prosody work turn it on by default. |
| **Mirror / camera self-view** | Optional overlay during the ATTEMPT step + playback after | A small picture-in-picture the child can enlarge; off by default. |
| **Gesture / sign** | A secondary cue and a bridge: total-communication support | Shown alongside the model video as a small looping clip for the same word. Same content spine, no new navigation. |

**Structural principle:** the app has exactly **three child-facing surfaces** — *Talk* (AAC, always available), *Play* (the practice loop), *Collection* (the earned world) — and one adult surface behind a gate. Every feature request must land inside one of those or be rejected. This is the discipline that keeps the product from becoming the usual "speech app with 40 activities and no theory."

---

## 7. PARENT COACHING LAYER

Coaching, not homework. The parent-facing product is a **behaviour-change product aimed at the adult**, and it deserves as much design as the child game.

- **Micro-lessons: ≤ 90 seconds, video, one idea, delivered in context.** Never a curriculum the parent must complete. Sequence: (1) why CAS is a motor problem not a "won't talk" problem; (2) how to model without demanding; (3) wait time — the counter-intuitive 5–10 second pause; (4) accept approximations and why; (5) how to cue and fade; (6) why many short sessions beat one long one; (7) how to embed practice in routines; (8) recognising and respecting dysregulation; (9) AAC does not delay speech (the single highest-value myth to kill); (10) how to stop without a fight.
- **"Why this works" explainers** attached to every activity — one paragraph, plain language, with the clinical principle named. This is what converts a compliant parent into a skilled one, and it is what makes SLPs trust the product.
- **In-the-moment prompts.** During a session, short parent-facing coaching text in a fixed strip: "Wait — give him 8 seconds." / "That was an approximation. Accept it and move on." / "He's losing steam — three more and finish." This is the highest-value coaching surface in the product because it changes behaviour at the point of performance.
- **Weekly goals expressed as *behaviour*, not outcome**: "Practice on 4 days" / "Try the car game in the bath." Never "get 20 correct /p/ productions." Parents cannot control the child's output and should never be held to it.
- **Celebrating small wins, concretely.** Auto-generate a weekly 20-second highlight: two clips of the child's best attempts, with the same target 6 weeks earlier played first. **The before/after audio clip is the single most emotionally powerful artifact this product can create** and the main retention mechanism for the parent. It is also honest — it's the child's actual voice, not a chart.
- **Guilt management, as an explicit design job.** Re-entry after a lapse is neutral and short ("Let's do three minutes"). Parent-facing copy never implies the child's progress depends on the parent's effort alone. Include an explicit "this is not your fault" micro-lesson about CAS aetiology. Offer a "we're in a hard week" mode that reduces the goal instead of nagging.
- **Honest reporting when progress is slow.** Rules: (a) report *effort and process* metrics prominently (trials, days, targets attempted) and *outcome* metrics carefully; (b) never invent progress; (c) use long windows — CAS progress is visible over 8–12 weeks, not 7 days, and the UI should default to a 12-week view so slow weeks are not read as failure; (d) when a target is genuinely stuck (e.g. 3+ weeks no movement), say so plainly and route to the SLP: "This target hasn't moved in 3 weeks. That's common and usually means the target needs changing, not more practice. Here's a message to send Karen." Turning a bad signal into a *concrete next action* is the difference between honesty and despair. (e) Never compare to typical milestones by default.

---

## 8. SLP CLINICIAN PORTAL

Design constraint: **≤2 minutes per client per week.** Web-first (clinicians work on laptops), plus a tablet view for in-session use.

1. **Caseload view.** One row per client with three signals only: practice volume vs. goal (a rhythm bar), targets needing attention (flagged: stuck, mastered, unreviewed clips), and last contact. Sorted by "needs you." Not a dashboard — a triage queue.
2. **Target list & hierarchy control.** The clinician defines the word/phrase set (from a curated library + custom targets with custom recorded models — **custom audio/video model upload in the clinician's or parent's own voice is a high-value, low-cost differentiator**), sets cue level per target, sets complexity (CV, CVC, syllable shape, vowel contexts), sets practice-type mix (blocked vs random, massed vs distributed) and sets the auto-advance bounds the adaptive engine may act within. **Locking the engine's authority inside clinician-set bounds is what makes the product acceptable to SLPs.**
3. **Session review.** Trial-level log with playable clips, filterable (new targets / disagreement between ASR and parent / random sample). Keyboard-driven scoring so 20 clips take 3 minutes. Shows *parent cueing* too (from the optional front-camera or from cue-level logs) so the clinician can catch a parent drifting off-protocol.
4. **Async video feedback.** 20–60 second recorded reply attached to a target or a clip, landing in the parent's app as a card. This is the feature that makes the product feel like extended care rather than software, and it is the basis of any future reimbursable remote-monitoring service line.
5. **Progress charts.** Per-target accuracy over time with cue level overlaid (accuracy is meaningless without cue level — a drop in accuracy at a lower cue level is progress); trials/week; syllable-shape mastery; a word-inventory count (functional words used spontaneously) which is the metric parents and IEP teams actually care about.
6. **IEP-ready reports.** One-click export: baseline, goal statement in measurable form, data table, trend, dates, and cue-level definitions, in PDF/Docx, with an editable narrative draft. Goal templates aligned to how CAS goals are actually written ("Given a verbal model, X will produce CV words with accurate vowel and consonant sequencing in 8/10 trials across 3 consecutive sessions"). **Saving an SLP an hour of IEP paperwork is worth more to them than any child-facing feature.**
7. **Parent messaging + assignment.** Assign this week's plan in two taps; template messages.
8. **Multi-clinician / supervisor view** for districts and for SLPAs under supervision; plus roster import, SSO, audit log, VPAT, DPA-ready privacy documentation.

---

## 9. MARKET & BUSINESS

### Competitor teardown

| Product | What it is | Price | Strength | Gap it leaves |
|---|---|---|---|---|
| **Speech Blubs** (Blub Blub) | Consumer video-modelling app, kids 1–8; peer video models, voice-activated | ~$14.49/mo, ~$59.99/yr (7-day trial on annual) | Best-in-class video modelling; huge consumer reach; kids like it; strong marketing | Language/vocabulary breadth, not motor-speech depth; no clinician control of hierarchy; no cue fading; no trial-level data; SLPs criticise it as not developmentally sequenced and not CAS-appropriate; no AAC; no coaching for the parent; "voice-activated" detection is loose |
| **Speech Therapy for Apraxia** (Blue Whale Apps) | Simple syllable/word drill sets | ~$4.99 each, ~$16.99 4-pack | Cheap, focused on apraxia, one-time price | Dated UX; essentially a flashcard deck; little child motivation; no data; no coaching; no clinician portal |
| **Apraxia Therapy** (Tactus Therapy) | VAST-style video + audio cueing | One-time purchase, no subscription, offline; free Lite | Clinically respected; excellent cueing model; no subscription | **Built for adults post-stroke**, not toddlers; no child engagement layer; no parent coaching; no data sharing |
| **Apraxia Ville** (Smarty Ears) | Child apraxia app — mouth videos, sound/word practice, therapist data | One-time (~$20–30 tier) | Made for kids with CAS; mouth video assets; therapist-oriented | Dated; session-bound; not a home-practice engagement system; no adaptive cue fading; weak parent layer |
| **Articulation Station** (Little Bee) | Articulation drill by phoneme | Free base, IAPs to ~$59.99 full | The default SLP drill app; enormous install base | Articulation ≠ motor planning; wrong theory for CAS; assumes the child can already produce words; no home engagement |
| **Proloquo2Go** (AssistiveWare) | Premium symbol AAC | ~$249.99 (+$149.99 Gateway) | Category standard; deep, respected | Communication only — no speech practice at all; expensive; iOS-only |
| **LAMP Words for Life** (PRC-Saltillo) | Motor-planning AAC | ~$299.99 one-time; 30-day Discover | Motor-plan consistency; strong evidence base in ASD | Same: no speech-production practice, no parent coaching |
| **TouchChat (HD / w. WordPower)** | AAC | ~$149.99 / ~$299.99 | Flexible vocab sets | Same gap |
| **Constant Therapy** | Adult neuro rehab, adaptive, clinician dashboard | ~$30/mo consumer; clinician tiers | **The best structural analogue**: adaptive difficulty + clinician portal + evidence publishing + insurance/enterprise motion | Adults only; no child engagement; no motor-speech-for-kids content |
| **Forbrain / Amble** (Sound For Life) | Bone-conduction auditory-feedback headset (hardware) | ~$300 device | Real, differentiated sensory/feedback mechanism; parents buy it | Hardware not software; no targets, no data, no coaching; a potential **partner/accessory**, not a competitor |

### The honest competitive gap

Every existing product occupies exactly one of three boxes: **(1) AAC** (Proloquo2Go, LAMP, TouchChat — excellent, expensive, communication only); **(2) clinician drill content** (Articulation Station, Apraxia Ville, Tactus — made for the 30-minute session, not the other 167 hours); **(3) consumer engagement** (Speech Blubs — delightful, high-reach, clinically shallow, no clinician in the loop).

**Nothing occupies the intersection: a clinician-governed, parent-coached, child-engaging, data-generating home practice system for pre-verbal CAS, with AAC alongside rather than instead.** That intersection is the product. The closest structural precedent is Constant Therapy, which proves the model (adaptive practice + clinician dashboard + published evidence + payer/enterprise sales) but in adult neuro-rehab.

The second honest gap: **nobody serves the pre-verbal child well.** Almost all "speech therapy apps" assume the child already produces words and needs them corrected. The 18-month-to-4-year non-verbal child — the highest-anxiety, highest-willingness-to-pay moment in the entire parent journey — is served by Speech Blubs and essentially nothing else.

### Pricing & willingness to pay

Two price anchors, and the gap between them is the opportunity:
- Consumer speech apps: **$10–15/mo, $60–120/yr.**
- AAC apps: **$150–300 one-time** (parents and districts *do* pay this).
- The real anchor: **private SLP sessions at $100–250/hr.** A parent paying $800/mo for therapy will pay $20–40/mo for something their SLP endorses that credibly multiplies that therapy's dosage. Willingness to pay in this segment is unusually high and unusually price-insensitive *if the SLP endorses it* — and near zero if the SLP is silent.

Recommended structure:
- **Free forever: the AAC/communication layer + basic practice.** Ethically required and strategically smart (it's the wedge, and it kills the "you're gating a child's voice" objection).
- **Family: $19–29/mo, ~$180–250/yr**, with a no-questions annual discount, a hardship/scholarship tier (loudly advertised — the population is disproportionately financially strained, and goodwill in this community is the marketing channel), and an SLP-referral free/discounted period.
- **Clinician: free for the portal** (the portal is distribution, not revenue) with a **Pro tier ~$15–25/mo** for IEP report generation, caseload analytics and custom model libraries.
- **School/district: per-student or site license, $2–8k/site/yr**, sold on caseload efficiency + IEP documentation + accessibility compliance. Long cycles, July budget year, DPA/VPAT/SSO required.
- Later: **B2B2C via clinic networks and teletherapy providers** (the fastest channel — one contract delivers hundreds of families), and possibly **RTM/RPM billing** (remote therapeutic monitoring codes are the plausible reimbursement path for a data-generating home-practice device, and Constant Therapy-style payer work is the template).

### TAM

CAS point prevalence is on the order of **1–2 per 1,000 children** (~1 in 1,000 for ages 4–8), i.e. roughly **50–100k US children** with idiopathic CAS at any time — genuinely small. That's a $60–120M US TAM at $150/yr for pure idiopathic CAS, which is a viable but not venture-scale niche on its own.

The defensible expansion — and this must be a *product* decision made early, not a marketing afterthought — is the adjacent, much larger population with the same product need: **severe speech sound disorders, late talkers / severe expressive delay (~10–15% of 2-year-olds), minimally verbal autistic children (~25–30% of the ~1-in-31 US autism population), Down syndrome, childhood dysarthria, and suspected-CAS-pre-diagnosis families.** That aggregate is **millions of US children**, with a plausible serviceable segment in the high hundreds of thousands of families actively seeking help, giving a US TAM realistically in the **$500M–1.5B** range and a global multiple of that. Strategy: **build for CAS (hardest case, most credible clinical positioning, most motivated buyers, best SLP endorsement), market outward to severe expressive delay and minimally verbal ASD.** Non-dilutive funding is unusually accessible here: **NIDCD SBIR/STTR** (NIDCD explicitly funds voice/speech/language assessment and rehabilitative strategies in its small-business program), **NIH R41/R43**, **IES SBIR** for the education channel, and **Apraxia Kids research grants** (up to ~$50k, explicitly prioritising early diagnosis/treatment and diverse and co-occurring populations) — the latter is small money but disproportionate credibility and community access.

---

## 10. RISKS

| Risk | Mechanism | Mitigation |
|---|---|---|
| **Abandonment (the #1 risk)** | Consumer health app retention is brutal; most families churn in 2–4 weeks, before CAS progress is even detectable | Ship a visible win inside week 1 (first before/after clip at day 10 from the day-1 baseline recording); SLP-in-the-loop (the SLP relationship, not the app, is the retention mechanism); ultra-low-friction sessions; parent coaching as its own reason to open the app; 12-week default reporting window |
| **False hope / overclaiming** | Desperate parents will read any marketing as a promise; a child who doesn't progress makes the app the villain | Never say cure/therapy/guarantee; publish realistic expectation-setting in onboarding ("CAS progress is measured in months"); no testimonial-led marketing; be explicit that the app supplements, never replaces, an SLP; have the app *refer out* — including recommending evaluation if the family has no SLP |
| **Parent over-drilling → speech aversion** | The most motivated parents are the most dangerous; an app that gamifies volume invites it | Hard session caps; aversion detection; explicit "stopping is a skill" coaching; SLP visibility into home volume with an over-practice flag; never reward high daily volume |
| **Delaying AAC / "app instead of therapy"** | Families may substitute the app for a full evaluation or delay AAC waiting for speech | AAC free and always-on; onboarding actively pushes toward evaluation; refuse to position as a substitute |
| **Screen time concerns** | Under-2 screen guidance (AAP/WHO) directly contradicts an app for 18-month-olds; SLPs and pediatricians will raise it | Position as *joint media engagement* — parent-and-child, adult-mediated, short, interactive, with the app explicitly pushing off-screen generalization ("do this at snack time"); ship off-screen activity cards; cap and *report* daily screen minutes honestly; never autoplay |
| **Store policy** | Apple Kids Category (no third-party ads/analytics, parental gate, no external links without gate) and Google Play Families policy; App Store health-claim scrutiny; COPPA verifiable parental consent; GDPR-K; FERPA for school data; HIPAA if a clinician relationship makes us a business associate; state biometric/voice laws re: voice recordings | Design to Kids Category from day 1; local-first recording with explicit consent and separate opt-in for model training; BAA-ready architecture; COPPA-compliant consent flow; VPAT and DPAs ready before the first school conversation |
| **Clinician rejection** | One influential SLP post can define the product in the community | Co-develop with practising CAS clinicians; publish methodology; give clinicians control and credit; never market around them to parents ("skip therapy, use our app") |
| **ASR failure damaging trust** | A wrong verdict in front of a child or parent is uniquely destructive here | Never surface ASR as a verdict; frame as "suggested"; measure and publish agreement rates |
| **Data honesty vs retention tension** | Honest slow-progress reporting increases churn short-term | Accept it. The long-term asset is SLP trust; a product that flatters parents loses the distribution channel |

---

## IMPLICATIONS FOR APP DESIGN

1. **Ship exactly three child-facing surfaces — Talk (AAC), Play (practice), Collection — and one gated adult surface.** Reject any feature that does not belong to one of them.
2. **The AAC/communication layer is free, always reachable in one tap from any screen, never paywalled, never gated behind speech performance, and never removed as a consequence.**
3. **Zero reading in the child experience.** All child-facing content is photograph, video, icon or speech; text exists only as a redundant adult layer.
4. **Instrument the core loop as: child-chosen stimulus → video model of a real mouth → cue at SLP-set level → open-ended attempt window → audio/video capture → acknowledgement + world-contingent outcome → next trial**, targeting **60–100 attempts in 5–10 minutes**.
5. **Make the dominant feedback mechanism contingency, not evaluation:** the utterance causes something to happen in the world. Reserve verdicts for humans.
6. **Never show the child a failure state.** No red X, no buzzer, no loss, no timers, no restarts. Support fades only after success and steps back up silently.
7. **Drive the adaptive engine to hold success rate in an ~80–90% band** (errorless learning), not to maximise difficulty — and constrain it inside SLP-set bounds it may not exceed.
8. **Hybrid judging: on-device constrained ASR pre-scores → parent confirms with one of three huge buttons → SLP audits a weekly sample of clips.** ASR output is never child-visible and never stated as fact.
9. **Record every attempt locally by default (with explicit consent, visible indicator, per-clip delete), and auto-generate a before/after audio comparison for the parent every 2 weeks.** This artifact is the retention engine.
10. **Ship low-stimulation defaults** (no music, no idle animation, desaturated palette, one moving element) with an always-visible sensory panel: sound, music, animation, haptics, dark mode, model speed, reward intensity. Honour OS reduce-motion settings.
11. **Meet WCAG 2.2 AA as a floor and exceed it for touch:** ≥64dp child targets with ≥16dp spacing, no required drag gestures (2.5.7), no timing dependencies, consistent control placement, accidental-touch debouncing, and a non-literacy-dependent parent gate.
12. **Every session follows an identical skeleton with a transition warning ("two more") and a fixed end ritual.** The app ends the session; the user does not have to.
13. **Cap sessions and detect aversion** (rising latency, no-response rate, mid-session exits) — and when detected, reduce demand, switch to play/AAC, or proactively end the session and tell the parent that stopping early was the right call.
14. **Streaks are parent-facing only and loss-free:** a 4-week rhythm heatmap and a weekly bucket goal ("4 days"), never a consecutive-day counter, never a child-visible streak, never a broken state.
15. **Progression in the story/collection is contingent on attempts made, not accuracy** — so effort always advances the world and no adult is incentivised to score generously.
16. **Variable reinforcement is permitted only under the ethical constraints:** every attempt acknowledged, only the bonus varies; no near-miss, no loss, no expiry, no purchasable reward; density decreases as mastery rises; schedule visible and adjustable by the parent.
17. **Enforce the banned dark-patterns list in code review and store submission**, including no child-facing notifications, no ads/third-party analytics in the child zone, no purchasable progression, no social comparison to milestones, and one-tap cancellation.
18. **Build the in-session parent coaching strip** (wait-time prompts, accept-the-approximation prompts, wind-down prompts) — the highest-leverage coaching surface in the product — plus ≤90-second contextual micro-lessons and a "why this works" explainer on every activity.
19. **Express parent goals as controllable behaviours ("practice on 4 days"), never as child outcomes,** and default all progress reporting to a 12-week window.
20. **Report slow progress honestly and always convert it into an action:** flag a stuck target after ~3 weeks, explain it as normal, and offer a one-tap message to the SLP.
21. **Build the clinician portal in v1** with: target list + custom recorded models, per-target cue-level and complexity control, engine bounds, a triage-style caseload queue, keyboard-fast clip review, async 20-second video replies, accuracy-with-cue-level charts, and one-click IEP-ready exports — all inside a ≤2-minute-per-client-per-week budget.
22. **Treat the SLP as the distribution channel:** free clinician portal, SLP-referral onboarding path, co-development with practising CAS clinicians, and marketing that never positions the app as a substitute for therapy.
23. **Price free-AAC / $19–29 per month family / free-plus-Pro clinician / site license for districts**, with a visible hardship tier, and build for school procurement from the start (web/Chromebook fallback, SSO, roster import, DPA, VPAT, COPPA/FERPA).
24. **Architect for privacy and compliance up front:** local-first encrypted recordings, separate revocable opt-in for any model training, COPPA verifiable parental consent, Apple Kids Category and Google Play Families conformance, BAA-ready infrastructure.
25. **Build for CAS, design the data model for the adjacent populations** (severe SSD, late talkers, minimally verbal ASD, dysarthria, Down syndrome) so the same engine expands the TAM from ~100k children to millions without a rebuild — and pursue NIDCD SBIR / IES SBIR / Apraxia Kids grants for non-dilutive funding and clinical credibility.

---

### Sources
- [ASHA Practice Portal — Childhood Apraxia of Speech](https://www.asha.org/practice-portal/clinical-topics/childhood-apraxia-of-speech/)
- [Research Priorities for Childhood Apraxia of Speech: A Long View (JSLHR)](https://pubs.asha.org/doi/10.1044/2024_JSLHR-24-00196)
- [Estimates of the prevalence of motor speech disorders in children with idiopathic speech delay (PubMed)](https://pubmed.ncbi.nlm.nih.gov/30987467/)
- [Usefulness of Automatic Speech Recognition Assessment of Children With Speech Sound Disorders (JMIR 2025)](https://www.jmir.org/2025/1/e60520/)
- [ASR of Conversational Speech in Individuals With Disordered Speech (JSLHR)](https://pubs.asha.org/doi/10.1044/2024_JSLHR-24-00045)
- [Finding My Voice: Generative Reconstruction of Disordered Speech (arXiv)](https://arxiv.org/pdf/2509.19231)
- [W3C — What's New in WCAG 2.2](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/)
- [WCAG 2.2 AA summary and checklist (Level Access)](https://www.levelaccess.com/blog/wcag-2-2-aa-summary-and-checklist-for-website-owners/)
- [Speech Blubs — App Store listing](https://apps.apple.com/us/app/speech-blubs-language-therapy/id1239522573)
- [Best Speech Therapy Apps for Kids: Honest 2026 Prices](https://littlewords.ai/blog/best-speech-therapy-apps)
- [Tactus Therapy — Apraxia Therapy app](https://tactustherapy.com/app/apraxia/)
- [Blue Whale Apps — Speech Therapy for Apraxia](https://www.amazon.com/Blue-Whale-Apps-Therapy-Apraxia/dp/B009KZVCZ8)
- [Proloquo2Go AAC: real cost, funding, and fit (2026)](https://littlewords.ai/blog/proloquo2go-aac-device)
- [Proloquo2Go vs TouchChat vs LAMP vs Free AAC (2026)](https://www.ezducate.ai/lp/aac-app-comparison)
- [OMazing Kids — App reviews: 4 apraxia apps](https://omazingkidsllc.com/2017/02/22/app-reviews-4-apraxia-apps-from-nacd/)
- [Apraxia Kids Research Grants](https://www.apraxia-kids.org/apraxia-kids-research-grants/)
- [NIDCD Small Business Grants (SBIR/STTR)](https://www.nidcd.nih.gov/funding/types/small-business-grants)
- [Training on Childhood Apraxia of Speech: Experiences of SLPs (PMC 2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12337112/)
- [Differences and Commonalities in Children with CAS and Comorbid Neurodevelopmental Disorders (PMC)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8880782/)
