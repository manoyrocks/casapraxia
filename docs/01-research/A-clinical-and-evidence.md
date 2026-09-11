# RESEARCHER A — CLINICAL & EVIDENCE LEAD
## Childhood Apraxia of Speech (CAS), with emphasis on the non-verbal / minimally-verbal child

**Date:** 2026-09-11
**Scope:** Clinical reality of CAS; diagnosis, differential diagnosis, evidence-based treatment, the zero-speech starting point, AAC, dose, prognosis, measurement, ethics, competitive landscape, and implications for app design.

**A note on method and honesty.** During this research pass, direct WebFetch access to asha.org, pubmed, PMC, Springer, RCSLT and apraxia-kids.org was blocked by the network egress proxy. Everything below is sourced from web search result summaries of primary literature plus my own domain knowledge. Where I am confident of a specific number or finding I cite it; where I am reconstructing from memory and could not verify the exact figure in this session, I flag it explicitly as **[UNVERIFIED IN THIS PASS]**. Anyone building on this document should re-verify flagged numbers against the primary source before putting them into clinical-facing copy. **The single most important rule for this project: do not let a product claim outrun the evidence line.**

---

## 1. DEFINITION & DIFFERENTIAL DIAGNOSIS

### 1.1 The ASHA 2007 definition

The field's anchor document is the American Speech-Language-Hearing Association's 2007 Position Statement and accompanying Technical Report on Childhood Apraxia of Speech (ASHA, 2007; https://www.asha.org/practice-portal/clinical-topics/childhood-apraxia-of-speech/). CAS is defined as a **neurological childhood speech sound disorder in which the precision and consistency of movements underlying speech are impaired in the absence of neuromuscular deficits** (i.e., absence of abnormal reflexes, abnormal tone). The core impairment is in **planning and/or programming the spatiotemporal parameters of movement sequences**, resulting in errors in speech sound production and prosody.

Three segmental and suprasegmental features are the most commonly cited diagnostic markers (ASHA, 2007):

1. **Inconsistent errors on consonants and vowels** in repeated productions of the same syllable or word.
2. **Lengthened and disrupted coarticulatory transitions** between sounds and syllables.
3. **Inappropriate prosody**, especially in the realisation of lexical or phrasal stress.

Crucially, ASHA's own 2007 statement acknowledged that **no single feature or set of features had at that time been validated as diagnostically sufficient**. This is still substantially true. Diagnosis remains expert perceptual judgment (Murray, McCabe, Heard & Ballard, 2015, *JSLHR*; https://pubs.asha.org/doi/10.1044/2014_JSLHR-S-12-0358). The RCSLT's 2024 UK position paper reaches a similar conclusion (RCSLT, 2024; https://www.rcslt.org/wp-content/uploads/2024/02/RCSLT-Childhood-Apraxia-of-Speech-CAS-Position-Paper-2024.pdf).

### 1.2 Additional perceptual features clinicians actually use

Beyond the ASHA triad, features repeatedly reported as discriminative include:

- **Articulatory groping / silent posturing** before initiation.
- **Intrusive schwa** (e.g., "bə-lue" for *blue*).
- **Syllable segregation** — audible pauses between syllables of a word.
- **Disproportionate difficulty with multisyllabic words** relative to single syllables.
- **Difficulty achieving initial articulatory configurations** and transitional movement gestures.
- **Vowel distortions and vowel errors** (unusual in purely phonological disorder).
- **Better automatic than volitional speech** — a child may produce "uh-oh" or a song lyric fluently but cannot produce the same syllables on demand. This is arguably the single most diagnostically striking feature in the non-verbal child, and it is the clinical hook that a lot of early therapy exploits.
- **Reduced phonetic and syllable-shape inventory** — heavily restricted to V, CV, or reduplicated CVCV.

Murray et al. (2015) found that a discriminant model combining **syllable segregation, lexical stress matches, percentage of phonemes correct on a polysyllabic picture-naming task, and articulatory accuracy on repetition of /pətəkə/** reached **91% diagnostic accuracy** against expert diagnosis, and distinguished CAS from dysarthria at 100%/100% sensitivity/specificity in their sample. Note the obvious limitation for our target population: **every one of those measures requires the child to produce polysyllables and DDK sequences.** They are not usable with a child who has no volitional speech. This is a real and recurring problem — the best-validated diagnostic procedures exclude the most severe children.

### 1.3 Differential diagnosis

**vs. phonological disorder / articulation disorder.** Phonological disorder involves rule-governed, *consistent*, developmentally-patterned simplifications (fronting, stopping, cluster reduction) with typically intact prosody and normal vowel production. CAS is characterised by *inconsistency*, vowel errors, prosodic disruption, and difficulty with the *transition* between sounds rather than the sounds themselves. A child with phonological disorder produces errors reliably; a child with CAS produces the same target five different ways in five attempts, often getting worse as word length increases. **Treatment implication: phonological disorder responds to linguistic/contrast-based therapy (minimal pairs, cycles); CAS requires motor-based therapy with high repetition. The two require structurally different apps.**

**vs. dysarthria.** Dysarthria is an execution disorder arising from neuromuscular impairment — weakness, spasticity, incoordination, altered tone. Its markers include **hypernasality, audible inspiration, loudness decay, breathiness, consistently imprecise articulatory contacts, and slow/imprecise but *consistent* DDK**. CAS errors are inconsistent and there is no neuromuscular deficit. Iuzzini-Seigel and colleagues have developed differential checklists that separate features unique to CAS (syllable segregation, lexical stress errors) from those unique to dysarthria (audible inspiration, loudness decay) and features shared by both (Iuzzini-Seigel et al., 2022; Marquette e-Publications https://epublications.marquette.edu/cgi/viewcontent.cgi?article=1058&context=spaud_fac). **CAS and dysarthria co-occur frequently**, particularly in children with cerebral palsy or genetic syndromes — they are not mutually exclusive.

**vs. ASD-related speech delay / minimally verbal autism.** This is the highest-stakes confusion for our target user. Findings:
- CAS does **not** appear to be elevated above population base rate (~1 in 1,000) in *verbal* autistic children.
- But among **minimally verbal autistic individuals, motor speech disorder prevalence is markedly elevated**; estimates of apraxia-consistent features in minimally verbal ASD run roughly **25–35%** (see Chenausky, Brignell, Morgan & Tager-Flusberg, 2019, *Autism & Developmental Language Impairments*; https://doi.org/10.1177/2396941519856333, and Iuzzini-Seigel et al., 2024, *AJSLP*, "Exploring Motor Speech Disorders in Low and Minimally Verbal Autistic Individuals"; https://pubs.asha.org/doi/10.1044/2024_AJSLP-23-00237).
- Chenausky et al. (2019) found **motor speech impairment predicted expressive language in minimally verbal but not low-verbal autistic individuals** — i.e., in the most severe group, the motor speech bottleneck is a real and independent constraint on language.
- Differentiating factor: ASD-related non-speech typically involves reduced *communicative intent, joint attention, and imitation*, with speech that when it appears may be well-articulated (echolalia, scripting can be phonetically precise). CAS involves preserved (often desperate) communicative intent with catastrophic motor output. A child with both has neither advantage.

**vs. severe DLD / global developmental delay.** Language-level impairment produces reduced utterance length and vocabulary but usually intact phonetic accuracy on what *is* produced. In CAS, expressive output is limited by motor capacity while comprehension may be far ahead — the "receptive-expressive gap" is a classic CAS parent report.

### 1.4 Diagnostic instruments

| Instrument | What it does | Fit for non-verbal child |
|---|---|---|
| **DEMSS** — Dynamic Evaluation of Motor Speech Skill (Strand & McCauley; Brookes Publishing, https://brookespublishing.com/product/demss/) | Criterion-referenced **dynamic** assessment: clinician provides cues and measures *responsiveness to cueing*, not just spontaneous accuracy. Scores overall accuracy, vowel accuracy, prosody, consistency. | **Best-in-class for this population.** Explicitly designed for children with severely restricted inventories, poor intelligibility, and/or "little to no verbal communication." Validity paper: Strand, McCauley, Weigand, Stoeckel & Baas (2013), *JSLHR* 56(2), https://pubs.asha.org/doi/pdf/10.1044/1092-4388(2012/12-0094) — test–retest 89%, intrajudge 89%, interjudge 91% agreement; cluster analysis separated CAS vs mild CAS vs other SSD. |
| **MPA** — Madison Speech Assessment Protocol (Shriberg et al.) | Research-grade multi-task battery with acoustic and perceptual analysis; feeds the Speech Disorders Classification System. | Research tool; heavy; requires substantial speech output. Not clinically routine. |
| **KSPT** — Kaufman Speech Praxis Test for Children | Norm-referenced, ages 2–6; scores oral movement, simple/complex phonemic/syllabic level, spontaneous length/complexity. Pairs with the Kaufman treatment protocol. | Usable relatively low down, but floors out fast for a truly non-verbal child. |
| **GFTA-3** — Goldman-Fristoe Test of Articulation | Single-word articulation inventory; norm-referenced. | **Poor fit.** Measures phoneme inventory, not motor planning; gives no information on consistency, cueing responsiveness or prosody; unscoreable for a child with no words. Useful only as a broad severity/inventory snapshot. |
| **CAS checklists** (e.g., Apraxia-Kids feature checklists, Iuzzini-Seigel CAS/dysarthria differential checklist, Strand's 10-feature list) | Feature-presence checklists supporting expert judgment. | Useful as clinician-facing decision support. **Not validated as standalone diagnostics** — do not build a diagnostic claim on one. |
| **Inconsistency Severity Instrument / DEAP inconsistency subtest** | 25 words × 3 trials; ≥40% inconsistency flags inconsistent phonological disorder or CAS. | Requires ~25 producible words. Out of reach for the non-verbal child. |

**Key gap to exploit:** for the truly non-verbal child, the only clinically defensible assessment paradigm is **dynamic** (DEMSS-style): present a target, apply escalating cues, record what level of cue is needed to elicit an approximation. That is a structure an app can actually mirror.

---

## 2. EVIDENCE-BASED TREATMENT PRINCIPLES

### 2.1 Principles of Motor Learning (PML)

The foundational tutorial is **Maas, Robin, Austermann Hula, Freedman, Wulf, Ballard & Schmidt (2008), "Principles of Motor Learning in Treatment of Motor Speech Disorders," *AJSLP* 17(3), 277–298** (https://gwulf.faculty.unlv.edu/wp-content/uploads/2014/05/Maas-et-al_AJSLP-2008_PML-tutorial.pdf). PML is imported from limb motor learning (Schmidt & Lee) and divides into **pre-practice** and **practice** conditions, and within practice into **practice structure** and **feedback**.

**Pre-practice** (must come first): establish motivation, understanding of the task, a stimulable target, and reliable elicitation of *at least one* correct/near-correct production. You cannot run a practice schedule on a movement the child has never once produced. In severe CAS this phase can take weeks and is where the "non-verbal starting point" work in §3 lives.

**Practice conditions:**
- **Amount of practice:** more is better. This is the least contested principle.
- **Practice distribution:** *distributed* practice (shorter sessions, more often) generally favours long-term retention over *massed*. Evidence in speech is weaker than in limb motor learning. **[Evidence thin — flag]**
- **Practice variability:** *variable* practice (varying phonetic context, rate, loudness, prosody) improves generalisation vs *constant* practice.
- **Practice schedule:** **blocked practice (AAAA BBBB) improves within-session acquisition; random practice (ABBA BAAB) improves retention and transfer** — and retention/transfer are the true indices of learning. Maas & Farinella (2012), "Random Versus Blocked Practice in Treatment for Childhood Apraxia of Speech," *JSLHR* (https://pubs.asha.org/doi/10.1044/1092-4388%282011/11-0120%29) tested this directly in CAS and found **individual variability — random practice was not uniformly superior in children**, in contrast to the adult AOS findings. **This is an important caveat: do not hard-code "random is always better" for children.** The defensible design is blocked during acquisition/pre-practice, shifting toward random once a target is stable.

**Feedback:**
- **Knowledge of Performance (KP)** = information about *how* the movement was made ("your tongue needs to touch behind your teeth"). Better during acquisition / early learning.
- **Knowledge of Results (KR)** = information about *outcome* ("that was right / not quite"). Better for retention once the movement exists.
- **Frequency:** high-frequency feedback (~100%) aids acquisition; **reduced-frequency feedback (e.g., ~60% or lower) aids retention** by preventing dependency on external feedback. Maas, Butalla & Farinella (2012), "Feedback Frequency in Treatment for Childhood Apraxia of Speech," *AJSLP* (https://pubs.asha.org/doi/10.1044/1058-0360(2012/11-0119)) tested this in CAS; again results were **mixed/individually variable** rather than a clean win for low-frequency feedback. **[Evidence thin — flag]**
- **Timing:** delayed and summary feedback favour retention over immediate trial-by-trial feedback.

**The honest synthesis:** PML is a coherent and widely adopted framework, but the *child* CAS evidence for the fine-grained feedback and schedule principles is genuinely equivocal, and largely rests on small single-case-experimental designs. Only "more practice trials" and "adequate intensity" are strongly supported. An app should implement PML as **configurable, clinician-adjustable parameters with sensible defaults**, not as immutable dogma.

### 2.2 The named protocols

#### DTTC — Dynamic Temporal and Tactile Cueing (Strand)
- **Population:** young children (roughly 2–6+) with **moderate-to-severe CAS**, including children with very small inventories. **This is the protocol of choice for the severe / barely-verbal child.**
- **Structure:** an *integral stimulation* approach — "Watch me, listen to me, do what I do" — with a **movement-based temporal hierarchy of support**:
  1. **Simultaneous production** (child and clinician produce together, often at slowed rate)
  2. **Simultaneous with fading of clinician voice / mouthing**
  3. **Direct (immediate) imitation**
  4. **Direct imitation with delay** (1–3 s)
  5. **Spontaneous production** (elicited by question/picture, no model)
  Layered onto these: **slowed rate → normal rate**, and **added tactile, gestural and visual cues → faded**. Prosodic variation is added at the top of the hierarchy.
- **Fading rule:** the clinician moves *up* the hierarchy (less support) when the child is accurate, and drops *back down* immediately on error — the "dynamic" part. Movement is trial-by-trial, not session-by-session. Rate is normalised *before* the cue level is fully faded at the lower levels.
- **Stimuli:** small set of **functional, motivating whole words** (not isolated phonemes), selected from the child's achievable syllable shapes, often 5–10 targets at a time. Targets are chosen to be *slightly* beyond current capability.
- **Dose:** the ongoing dose-frequency RCT (Namasivayam/Maas/Iuzzini-Seigel-adjacent group; protocol paper, *BMC Pediatrics* 2023, https://link.springer.com/article/10.1186/s12887-023-04066-2; ClinicalTrials NCT05675306) compares **1-hour sessions 4×/week for 6 weeks (high dose) vs 2×/week for 12 weeks (low dose)** — equated total dose, differing frequency. Field convention is **~100 production trials per session minimum**.
- **Evidence:** multiple single-case experimental designs plus a 2024 multiple single-case design (*JSLHR*/pubmed 38512002) and a 2019 *AJSLP* tutorial (Strand, 2020, "Dynamic Temporal and Tactile Cueing: A Treatment Strategy for Childhood Apraxia of Speech," https://pubs.asha.org/doi/10.1044/2019_AJSLP-19-0005). **Evidence strength: strong for a Level III/IV base — arguably the best-supported approach for severe young CAS — but no large RCT has yet reported.** Community-clinician fidelity training is an active research area (AJSLP 2025, https://pubs.asha.org/doi/10.1044/2025_AJSLP-24-00239), which tells you fidelity is hard even for trained SLPs.

#### ReST — Rapid Syllable Transition Treatment (Ballard, McCabe, Murray — University of Sydney)
- **Population:** children **~4–12 years with mild-to-severe CAS who already have a reasonable phonetic inventory**. **Not appropriate for the non-verbal child** — it requires production of three-syllable nonsense words.
- **Stimuli:** **pseudo-words** (e.g., /bɪdəgu/) with controlled syllable structure and varied lexical stress (SWW vs WSW). Nonsense words are used deliberately so that no lexical representation exists and the child must plan the movement sequence afresh — targeting *transitions* and *prosody* directly.
- **Structure:** explicit **pre-practice** phase (establish ~5–10 correct productions with maximal cueing and KP feedback) followed by **practice** (high-volume, random/variable, low-frequency KR feedback only, delayed).
- **Dose:** original RCT — **1-hour sessions, 4×/week for 3 weeks (12 sessions)**, ~100 trials/session. Murray, McCabe & Ballard (2015), *JSLHR* (https://pubs.asha.org/doi/10.1044/2015_JSLHR-S-13-0179).
- **Findings:** vs NDP3, **NDP3 produced larger within-treatment gains but poorer retention; ReST was superior in retention and generalisation to untreated items.** A lower-dose variant (2×/week) was moderately effective (Thomas et al., *JCD* 2014, https://www.sciencedirect.com/science/article/abs/pii/S0021992414000550).
- **Evidence:** RCT-level. **Strongest RCT evidence of any CAS treatment**, but for a population our target child is not yet in.

#### NDP3 — Nuffield Dyspraxia Programme, Third Edition
- **Population:** wide age/severity range; explicitly includes **very severe, near-non-verbal children**, starting at single sounds.
- **Structure:** **bottom-up, phonetically-driven**: single sounds → CV/VC → CVC → two-syllable → phrases. Uses picture cards, oral-motor/sound-production cues, and extensive repetition drill. Ships with assessment, therapy manual and a large card resource.
- **Dose:** in the Murray 2015 RCT it was delivered at the same intensity as ReST (1 hr, 4×/week × 3 weeks). Clinical use is usually 2–3×/week.
- **Evidence:** **two RCTs plus multiple case series**; rated "moderate evidence" on the UK *What Works* database (NDP3 evidence page: https://www.ndp3.org/evidence-base/). Caveat from Murray 2015: gains showed **diminishing retention**.
- **Honest critique:** NDP3's bottom-up start from isolated sounds sits uneasily with the motor-learning view that the *movement gesture across a syllable*, not the isolated phoneme, is the unit of planning. That may explain the retention findings.

#### PROMPT — Prompts for Restructuring Oral Muscular Phonetic Targets
- **Population:** children with **speech motor delay / severe motor speech disorder**, including CAS and dysarthria; usable with minimally verbal children.
- **Structure:** clinician provides **manual tactile-kinaesthetic prompts on the face, jaw and neck** to shape place, jaw height, lip rounding, timing and voicing. Organised by a **Motor Speech Hierarchy** (tone → phonatory control → mandibular control → labial-facial control → lingual control → sequenced movement → prosody), treating the lowest unstable stage first.
- **Dose:** RCT — **45-minute sessions, 2×/week for 10 weeks** (Namasivayam et al., 2020, *Pediatric Research*, https://www.nature.com/articles/s41390-020-0924-4).
- **Evidence:** that RCT (n=49, intervention vs waitlist) found **notable gains in speech motor control, articulation and word-level intelligibility; weak effects on sentence-level intelligibility and functional communication.** Level II evidence.
- **Critical limitation for an app:** **PROMPT is inherently a hands-on physical technique. An app cannot deliver it.** Any app claiming to "do PROMPT" is misrepresenting. An app can at best *coach a trained caregiver*, and even that is ethically dubious without certification.

#### Integral Stimulation (Milisen, 1954; Rosenbek's 8-step continuum)
- The parent framework from which DTTC descends. "Watch me, listen to me, do what I do." Rosenbek's 8-step continuum (integral stimulation → simultaneous → immediate imitation with model → immediate imitation without model → successive repetitions → written cue → spontaneous elicitation → role play) was developed for **adult** AOS; DTTC is the child adaptation and should be preferred for children.
- **Evidence:** the general integral stimulation framework is well-supported; the specific 8-step continuum in children is not.

#### Kaufman Speech to Language Protocol (K-SLP)
- **Population:** young children with CAS and limited verbal output, including comorbid presentations. Widely used in the US.
- **Structure:** **successive approximation / verbal shaping** — teach the closest *phonetically simplified but consistent* approximation the child can actually produce ("ba" for *bottle*, "ap" for *apple*), reinforce it as functional communication, then systematically shape toward the full form. Combined with PML and reinforcement. This is philosophically important: **it accepts approximations as legitimate words, which is exactly the right stance for a non-verbal child.**
- **Dose:** varies; commonly 2×/week, high trial counts.
- **Evidence:** a **Phase I pilot** (Gomez, McCabe et al., 2018, *LSHSS*, https://pubs.asha.org/doi/10.1044/2018_LSHSS-17-0100), a single-case experimental design study of an operationalised version (Gomez et al., 2023, *IJSLP*, https://www.tandfonline.com/doi/full/10.1080/17549507.2023.2211750), and a 2024 dyadic/group-format study (*AJSLP*, https://pubs.asha.org/doi/10.1044/2024_AJSLP-24-00098). Authors' own conclusion: effective for *some* children; **"additional replication… needed to support a recommendation of clinical use."** **Evidence strength: suggestive/emerging, not established.**

#### Melodic Intonation Therapy (MIT) and rhythmic-musical cueing / AMMT
- **MIT** is an adult nonfluent-aphasia treatment (intoned melodic patterns + left-hand tapping). Its direct paediatric use is **not** evidence-based.
- The relevant paediatric adaptation is **Auditory-Motor Mapping Training (AMMT)** (Wan, Bazen, Baars, Libenson, Zipse, Zuk, Norton & Schlaug; Chenausky et al.). Child and clinician **sing** bisyllabic words/phrases while tapping tuned electronic drums in time with each syllable, co-activating auditory and motor networks. Chenausky et al. (2016, *PLOS ONE*, https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0164930; 2022, *Annals NYAS*, https://nyaspubs.onlinelibrary.wiley.com/doi/abs/10.1111/nyas.14817): **23 minimally verbal autistic children, ≥25 sessions**, outcome measures Percent Syllables Approximated, PCC, PVC on two sets of 15 bisyllabic stimuli, probed at baseline and after 10/15/20/25 sessions; 7 matched to a Speech Repetition Therapy control.
- **Evidence:** promising, small-n, mostly from one lab, in minimally verbal ASD rather than idiopathic CAS. **Evidence strength: emerging.** But note: **rhythm and pitch scaffolding are genuinely useful for eliciting first vocalisations in children who will not imitate speech**, and this is very implementable in an app.

#### Ultrasound visual biofeedback (UVB)
- **Population:** **older children (~8–15) with persisting/residual CAS errors**, particularly lingual targets (/r/, /s/, /l/, sequences).
- **Structure:** real-time ultrasound image of the tongue as knowledge-of-performance feedback; combined with motor-learning practice structure.
- **Evidence:** Preston, Brick & Landi (2013), *AJSLP* (https://pubs.asha.org/doi/10.1044/1058-0360(2013/12-0139)) — 6 children aged 9–15, 18 sessions, multiple-baseline; **all met 80%-accuracy criterion on ≥2 treated sequences**, variable generalisation to untreated sequences, most gains maintained at 2 months. Also Preston et al. (2016, *Front Hum Neurosci*), Preston et al. (2017, *AJSLP*, variable practice), and a pilot RCT comparing ReST vs UVB (*AJSLP* 2022, https://pubs.asha.org/doi/10.1044/2022_AJSLP-22-00144).
- **Relevance here: essentially none for the non-verbal child.** Requires equipment, cooperation, and existing speech. Listed for completeness.

### 2.3 Summary evidence ranking (my judgment)

| Approach | Evidence level | Fit for non-verbal child |
|---|---|---|
| DTTC | Strong Level III/IV, RCT in progress | **Excellent — first choice** |
| NDP3 | 2 RCTs, "moderate" | Good (starts low), retention concerns |
| PROMPT | 1 RCT (Level II) | Good but **not deliverable by app** |
| K-SLP | Phase I / SCED, suggestive | Good philosophically; weak evidence |
| AMMT / rhythmic cueing | Emerging, small-n | Useful for elicitation |
| ReST | **Strongest RCT evidence** | **No — requires existing speech** |
| UVB | Good for residual errors | No |
| NSOMEs (non-speech oral motor) | **Not supported** | **No — avoid** |

---

## 3. THE NON-VERBAL STARTING POINT

This is the hardest and least-well-evidenced part of the field, and the most important for this project. **Flag honestly: the transition from zero volitional speech to first approximations is largely described in clinical/tutorial literature and expert consensus, not in controlled trials.** There is no RCT of "how to get a non-verbal child to first vocalise." Design accordingly — with humility.

### 3.1 Pre-practice: what actually happens

Before any motor-learning practice schedule is meaningful, the clinician must establish **one reliably elicitable production**. The sequence clinicians use, roughly in order:

1. **Joint attention and communicative intent.** No speech target is worth anything if the child is not oriented to a partner. Establish turn-taking with non-speech (banging, peekaboo, ball roll) before sound.
2. **Vocal play and contingent imitation — the "babbling ladder."** The adult **imitates the child's own spontaneous vocalisations** first (this is the reversal that gets traction: the child learns their sound causes an adult sound). Then the adult adds a small variation and waits. This builds a vocal turn-taking loop without demand.
3. **Exploit automatic-to-volitional transfer.** Target sounds the child *already* produces involuntarily: laughter, crying vowels, "uh-oh," raspberries, environmental sound-effects ("mmmm," "brrrm," "oooo" for a slide, "ah" for a yawn). **Sound effects and exclamations are the standard clinical entry point** because they are high-affect, meaningful, and already in the child's motor repertoire. Move from the automatic context toward volitional elicitation in the same context, then a different context.
4. **Vowel-first targets.** Vowels are the nucleus of the syllable and easier to shape visually (jaw and lip position). Common first set: /ɑ/ (open), /i/ (spread), /u/ (rounded), /oʊ/, /aɪ/. Contrastive jaw height and lip rounding are visible and prompt-able.
5. **CV and VC.** Add a bilabial or glottal onset — /b, m, p, h, w/ — because they are **maximally visible**. "ma," "ba," "mo," "bee," "up," "on," "eat." VC is sometimes easier than CV for children who can phonate but cannot initiate a consonant.
6. **Reduplicated syllables (CVCV).** "mama," "baba," "papa," "bubble" → "buh-buh." Reduplication is a real motor simplification: one plan repeated. It is the natural bridge to bisyllables.
7. **Vary the vowel, hold the consonant, then vary the consonant** (CV1CV2 → C1VC2V). This is where syllable-shape inventory genuinely expands.
8. **Shape toward true words (K-SLP logic).** Accept and reinforce the approximation as a word. Never withhold reinforcement waiting for the adult form.

### 3.2 Imitation building

Many severe CAS children — especially with ASD — **cannot imitate on demand at all**. The clinical ladder is: imitate gross motor (clap, tap table) → imitate oral-facial non-speech (unclear evidence, see below) → imitate vocalisation → imitate specific phoneme → imitate syllable. Note that **this ladder is convention, not evidence**, and step 2 is contested.

### 3.3 The oral-motor debate — why NSOMEs are NOT evidence-based

Non-speech oral motor exercises (NSOMEs) — blowing whistles, tongue push-ups, horn hierarchies, straw hierarchies, cheek puffing, "oral-motor warm-ups" — remain widely used and are **not supported**.

- **McCauley, Strand, Lof, Schooling & Frymark (2009), "Evidence-Based Systematic Review: Effects of Nonspeech Oral Motor Exercises on Speech," *AJSLP*** (https://pubmed.ncbi.nlm.nih.gov/19638484/) searched 1960–2007 and found **insufficient evidence to support the use of NSOMEs to improve speech production**, recommending clinicians use treatments of established efficacy instead.
- **Lof** has argued extensively that NSOMEs fail on theoretical grounds: speech movements are **task-specific**, faster, and differently organised than non-speech oral movements; strength is not the limiting factor in CAS (there is by definition no neuromuscular weakness); and there is no evidence of transfer from non-speech to speech motor control. See Lof's summaries (https://www.speechpathology.com/articles/20q-non-speech-oral-motor-20430) and Bowen's reading list (https://www.speech-language-therapy.com/index.php?option=com_content&view=article&id=49:omtreadings&catid=11&Itemid=101).
- **Narrow, legitimate exceptions:** feeding/swallowing intervention (a different goal), and brief *speech-adjacent* placement cueing (showing lip rounding immediately before producing a rounded vowel) — that is a cue, not an exercise.

**Design consequence: an app for CAS must not ship blowing games, tongue-wagging games, or "oral-motor warm-ups" as speech therapy.** Many commercial apps do. This is the clearest differentiator available.

### 3.4 The role of AAC at the non-verbal starting point

**AAC should be introduced immediately, not after speech therapy "fails."** For a child with no functional verbal communication, the ethical and clinical baseline is that the child needs a way to communicate *today*. Delaying AAC to "give speech a chance" is not supported by evidence (see §4) and imposes months or years of communicative deprivation, with downstream effects on behaviour, language and relationships.

---

## 4. AAC AS A BRIDGE, NOT A REPLACEMENT

### 4.1 The core evidence: AAC does not impede speech

**Millar, Light & Schlosser (2006), "The Impact of Augmentative and Alternative Communication Intervention on the Speech Production of Individuals With Developmental Disabilities: A Research Review," *JSLHR* 49(2)** (https://pubs.asha.org/doi/10.1044/1092-4388(2006/021); PubMed 16671842). Literature 1975–2003; 23 studies meeting criteria, **67 individuals** in the subset with adequate data. Findings:
- **Speech production increased in ~89% of participants.**
- **No participant showed a decrease in speech.**
- Gains were **modest** — the authors explicitly caution against overclaiming and call for realistic stakeholder expectations.

This is the single most important citation for parent-facing copy. The fear that "the device will stop them talking" is the dominant parental objection and it is **empirically unfounded**. Later reviews (Schlosser & Wendt, 2008, on AAC and speech in ASD) reached the same conclusion. **[Schlosser & Wendt 2008 — UNVERIFIED IN THIS PASS, cited from memory.]**

### 4.2 Core vocabulary

A small set of high-frequency, largely non-noun words (*go, stop, more, want, my, you, it, put, turn, help, all done, no, different, look*) accounts for the large majority of everyday utterances across speakers and ages. Core-vocabulary AAC design places these in **stable, motor-consistent locations** and supplements them with fringe vocabulary organised by topic. For a CAS child, core vocabulary is doubly valuable: the same words are the highest-frequency *speech* targets, so AAC targets and speech targets can be the same list.

### 4.3 LAMP and motor planning for AAC

**LAMP (Language Acquisition through Motor Planning)**, Center for AAC & Autism / Prentke Romich (https://www.aacandautism.com/lamp/research/). Principles: readiness to learn, joint engagement, consistent and unique **motor patterns** for each word (motor automaticity via invariant icon sequences on a fixed grid), auditory signals, and natural consequences.

- **Evidence:** a 2015 evidence-based evaluation (Cogent Education, https://www.tandfonline.com/doi/full/10.1080/2331186X.2015.1045807) and a small manufacturer-linked study — 8 participants, 5 weeks; all showed vocabulary increase, all requesting symbolically, 100% developing commenting. **Small n, short duration, non-independent sponsorship.**
- **Honest assessment: LAMP's motor-planning rationale is theoretically attractive and coheres with CAS's motor framing, but the evidence base is thin and largely vendor-adjacent.** Criticism noted in the literature: it teaches words as building blocks rather than supporting analytic language construction.
- **The transferable design principle is solid regardless of LAMP's evidence:** **do not move buttons.** Icon position must be invariant so motor automaticity can develop. Dynamic/reorganising grids destroy this.

### 4.4 Multimodal communication and how an app should blend AAC + speech

Real communication in these children is **multimodal**: vocal approximation + gesture + sign + device + pointing, simultaneously. Total Communication is the working model. Notably, **supplementary sign use is common in school-aged children with CAS** (see *PMC9913131*, "Concurrent Predictors of Supplementary Sign Use in School-Aged Children With Childhood Apraxia of Speech," https://pmc.ncbi.nlm.nih.gov/articles/PMC9913131/).

**The blend that is clinically defensible:**
- Every speech practice target is **also** an AAC button. Same word, same picture, same voice model.
- When the child selects the AAC button, the device **models the spoken word** (aided language stimulation) — this is auditory input, not a substitute for the child's attempt.
- The child's vocal approximation is **accepted and reinforced alongside** the button press, never instead of it. "Buh" + button press = success.
- AAC access is **never gated behind speech performance**. No "say it to unlock." That is communicative coercion.
- Over time the app can track the ratio of button-only → button+vocalisation → vocalisation-only, which is a genuinely meaningful longitudinal metric.

---

## 5. DOSE, INTENSITY AND HOME-PRACTICE REALITY

### 5.1 What intensity produces gains

- **Namasivayam, Pukonen, Goshulak et al. (2015), "Treatment intensity and childhood apraxia of speech," *IJLCD*** (https://onlinelibrary.wiley.com/doi/abs/10.1111/1460-6984.12154). n=37, ages 32–54 months, motor speech treatment **1×/week vs 2×/week, 60 min, 10 weeks** in community clinics. **2×/week produced significantly better articulation and functional communication outcomes.** This establishes **2×/week as the practical evidence-based minimum.**
- **Edeal & Gildersleeve-Neumann (2011), "The Importance of Production Frequency in Therapy for Childhood Apraxia of Speech," *AJSLP* 20(2), 95–110** (https://www.semanticscholar.org/paper/1a40a154ed06b4cf77cd6a8b94fcde191181c977). Alternating-treatments design, 2 children. **High-frequency condition: 100+ productions in 15 minutes. Moderate condition: 30–40 productions in the same 15 minutes.** Both were effective, but **the high-frequency condition produced more rapid gains and better generalisation to untrained words.** This is the origin of the "100+ trials" heuristic. **Caveat: n=2. It is a heuristic with weak empirical footing, universally adopted because it is directionally obviously right (more practice = more learning), not because it is well-powered.**
- Most published CAS treatment protocols use **3–5 sessions/week and ~100 production trials per session** during the active treatment block.
- The **DTTC dose-frequency RCT** (NCT05675306 / NCT04642053) is explicitly testing whether *frequency* matters when total dose is equated. **Results not available as of this pass — watch for them.**

**Clinically, the picture is: total number of correct(-ish) practice trials is the active ingredient; frequency ≥2×/week is the floor; intensive burst models (4×/week × 3–6 weeks) followed by maintenance are the emerging structure.**

### 5.2 Parent/caregiver-delivered practice — the uncomfortable finding

This is where the app thesis meets its strongest counter-evidence, and it must be stated honestly.

- **Thomas, McCabe & Ballard (2017), "Combined clinician-parent delivery of Rapid Syllable Transition (ReST) treatment for childhood apraxia of speech"** (https://pubmed.ncbi.nlm.nih.gov/28443686/). 5 children, 12 sessions (6 clinic + 6 parent-delivered at home), with fidelity measurement. **Result: the half-parent-delivered model was less effective than clinician-delivered, and parents were disinclined to continue.** The Sydney group's own evidence summary states that, on current evidence, **parent training / homework alone is not established practice for ReST.**
- **Thomas et al. (2017) parent-experience study** (https://pubmed.ncbi.nlm.nih.gov/28534689/) found parents reported **telehealth more favourably than doing therapy themselves.**

**Interpretation.** The problem in the parent-delivered condition was **fidelity and adherence**, not the concept of home practice per se. Parents struggled to (a) judge accuracy reliably, (b) deliver feedback at the right frequency and timing, and (c) sustain motivation. **This is precisely and specifically the gap a well-built app could close** — an app can count trials, schedule practice, keep feedback frequency constant, and remove the burden of accuracy judgment from the parent. But the app must be honest that **it is compensating for a known failure mode, and the evidence that this compensation works does not yet exist.**

### 5.3 Telepractice

- **Thomas, McCabe, Ballard & Lincoln (2016), "Telehealth delivery of Rapid Syllable Transitions (ReST) treatment for childhood apraxia of speech," *IJLCD*** (https://onlinelibrary.wiley.com/doi/10.1111/1460-6984.12238). **Telehealth-delivered ReST produced outcomes broadly comparable to in-person delivery** and was well received by parents. This is a genuinely encouraging result: **clinician-delivered-at-a-distance works; clinician-replaced-by-parent works less well.**
- Design implication: the strongest evidence-aligned product is **not** "app replaces SLP" but **"app is the high-volume practice engine between clinician sessions, with the clinician setting targets and reviewing data."**

---

## 6. PROGNOSIS, COMORBIDITY AND RED FLAGS

### 6.1 Comorbidity

- **≥50% of children with CAS have co-occurring impairments** — receptive and/or expressive language disorder, literacy difficulties, and fine/gross motor deficits (see *PMC8880782*, "Differences and Commonalities in Children with Childhood Apraxia of Speech and Comorbid Neurodevelopmental Disorders," https://pmc.ncbi.nlm.nih.gov/articles/PMC8880782/).
- **Language impairment is the most common comorbidity.**
- **Literacy:** phonological awareness, decoding and spelling are frequently impaired — CAS is a literacy risk condition, not only a speech condition.
- **Dysarthria co-occurs**, especially in syndromic and CP populations.
- **ASD:** as above, 25–35% of minimally verbal autistic children show apraxia-consistent features.
- **Genetic aetiologies:** FOXP2 (the first molecularly identified cause; CAS is the core phenotype of FOXP2-related speech and language disorder — MedlinePlus, https://medlineplus.gov/download/genetics/condition/foxp2-related-speech-and-language-disorder.pdf), plus copy-number variants and a growing list of other genes (e.g., WAC variants associated with self-limited focal epilepsy *and* CAS — https://www.sciencedirect.com/science/article/abs/pii/S1090379820302348). Whole-exome work supports substantial genetic heterogeneity (*PMC3851280*).
- **Idiopathic CAS is the largest group** — most children have no identified cause.

### 6.2 Prognosis

- CAS is generally **a persistent condition requiring long-term intervention**, measured in years, not weeks. Most children improve substantially with appropriate treatment; a subset achieve fully typical speech; a subset retain residual errors into adolescence.
- Poorer long-term outcomes associate with: **comorbid language impairment, early motor difficulties, poor oral motor skills, and persistent speech sound errors**. Adolescents with persistent SSD show higher rates of comorbid language impairment and reading disability (Lewis et al., Cleveland Family Speech and Reading Study; https://pmc.ncbi.nlm.nih.gov/articles/PMC12614917/; and https://pubmed.ncbi.nlm.nih.gov/25569242/). Persistent cases also show more auditory-perceptual dysarthria features.
- **Honest parent-facing framing: "steady, hard-won progress over years, with AAC supporting communication throughout" — not "we can fix this."**

### 6.3 Red flags requiring immediate human SLP / medical referral

An app **must** detect and escalate these. Non-negotiable:

1. **Dysphagia / feeding and swallowing difficulty** — coughing or choking on food or liquid, wet/gurgly voice after drinking, recurrent chest infections, food refusal by texture, prolonged mealtimes. **Aspiration risk. Immediate referral. No app should ever engage with feeding.**
2. **Regression or loss of previously acquired skills** — loss of words, gestures, or social engagement. Raises Landau-Kleffner syndrome, epileptic encephalopathy, metabolic and neurodegenerative differentials. **Urgent medical referral.**
3. **Suspected or confirmed hearing loss** — no response to name, failed or absent newborn screening, recurrent otitis media with effusion, fluctuating responsiveness. **Audiological assessment is a prerequisite to any speech diagnosis, full stop.**
4. **Seizures or suspected seizure activity** — staring spells, unexplained drops, nocturnal events. Neurology referral.
5. **Other neurological signs** — tremor, ataxia/imbalance, asymmetry, abnormal tone, drooling beyond developmental expectation, dysarthria features without prior diagnosis.
6. **Dysmorphology, family history of neurodevelopmental disorder, or structural anomaly** (submucous cleft, bifid uvula) — genetics/ENT referral.
7. **Stridor, voice quality change, or breathing difficulty during speech attempts.**
8. **Safeguarding / distress signals** — sustained aversion, self-injury during practice, caregiver distress.

---

## 7. MEASUREMENT: WHAT ACTUALLY COUNTS AS PROGRESS

### 7.1 Meaningful outcome measures

| Measure | Definition | Notes for severe/non-verbal |
|---|---|---|
| **PCC / PVC / PPC** | Percentage of consonants / vowels / phonemes correct in a sample or on a probe list | Standard severity metric. **Floors out near zero in the non-verbal child** — poor sensitivity at the bottom. |
| **Percent Syllables Approximated** | Proportion of target syllables produced with a recognisable approximation | **Much better bottom-of-range sensitivity.** Used as a primary outcome in AMMT work (Chenausky et al., 2016/2022). **Adopt this.** |
| **Whole-word accuracy / Proportion of Whole-Word Proximity (PWP)** | Word-level match to target, weighted | Captures the motor-plan-as-unit view better than phoneme counting. |
| **Syllable-shape / phonetic inventory** | Count of distinct syllable shapes (V, CV, VC, CVC, CVCV, CVCVC) and distinct phonemes produced across contexts | **The single most sensitive early metric for a non-verbal child.** Going from {V} to {V, CV} is enormous clinical progress that PCC would barely register. |
| **Vowel accuracy** | PVC specifically | Diagnostically important in CAS; often ignored by apps. |
| **Lexical stress accuracy / syllable segregation count** | Prosodic markers | Automatable to a degree (see Brain Sciences 2021 automated lexical stress classifier, https://doi.org/10.3390/brainsci11111408 — >80% agreement for SW words in TD children but **~60% for WS words in CAS speech**). |
| **Intelligibility in Context Scale (ICS)** | McLeod, Harrison & McCormack, 7 items × 5-point scale, mean score 1–5, parent-report (https://pubs.asha.org/doi/10.1044/1092-4388(2011/10-0130)) | **Free, quick, validated, functional, multiple translations.** Correlates with PCC/PPC in CAS. **The obvious choice for an app's periodic functional outcome.** |
| **Generalisation probes** | Accuracy on **untreated** items sharing structure with treated items | **This is where real learning shows.** Must be untreated and unpractised. |
| **Maintenance probes** | Accuracy on treated items after a no-treatment interval (1 week, 1 month, 3 months) | **Retention, not acquisition, is the index of learning (Maas et al., 2008).** Within-session accuracy is the *least* meaningful number. |
| **Functional communication / utterance count** | Number of spontaneous communicative acts, modality-coded | Captures the thing parents actually care about. |
| **Cue level required** | DEMSS-style: the lowest level of support at which the child is accurate | **Ideal app-native metric.** Objective, sensitive, and meaningful from the very bottom. |

### 7.2 What a valid app progress metric looks like

A defensible progress dashboard would report, per target and per period:
1. **Trials attempted** (dose delivered — this the app knows with certainty).
2. **Cue level distribution** — % of trials at simultaneous / immediate imitation / delayed imitation / spontaneous. **Movement down this distribution over time is the primary progress signal.**
3. **Percent syllables approximated** on a fixed probe set, rated by caregiver or clinician (or ASR-assisted, never ASR-alone).
4. **Syllable-shape inventory** — a growing set, displayed as a shape map.
5. **Generalisation probe score** on untreated items, run every N sessions.
6. **Maintenance probe score** at fixed intervals after a target is retired.
7. **ICS** every 8–12 weeks.
8. **Modality ratio** — AAC-only vs AAC+vocal vs vocal-only.

**What it must NOT report as "progress":** minutes in app, streaks, stars earned, games completed, or within-session accuracy on the currently-cued target. Those are engagement metrics masquerading as clinical outcomes, and the entire consumer app category is built on exactly that conflation.

### 7.3 The ASR problem — be honest

Automatic scoring of disordered child speech is **hard and not solved**. Relevant work: Tabby Talks (*Speech Communication* 2015, https://www.sciencedirect.com/science/article/abs/pii/S0167639315000382), Shriberg et al.'s ASR diagnostic work (PubMed 17066124), the automated lexical stress classifier above, and Hair et al. (2019), "Evaluating Automatic Speech Recognition for Child Speech Therapy Applications" (https://psi.engr.tamu.edu/wp-content/uploads/2019/08/hair2019evaluating.pdf). Findings converge: **ASR trained on typical adult speech degrades severely on child speech, and catastrophically on disordered child speech**, especially at the severe end where acoustic targets are most deviant. The 2024 *JSLHR* CAS treatment review explicitly lists optimisation of ASR for reliable automatic feedback as **future work**, not current capability.

**Consequence: an app must not present ASR-derived scores as ground truth to a parent.** Wrong feedback in a motor-learning paradigm doesn't just fail to help — it actively trains the wrong motor plan and destroys trust. Use ASR for *low-stakes* jobs (voice-activity detection, did-the-child-attempt detection, syllable counting, loudness/duration, flagging clips for human review) and keep accuracy judgment with a human.

---

## 8. ETHICAL AND CLINICAL RISKS OF AN APP

1. **Over-claiming.** "Teach your non-verbal child to talk." There is no evidence any app does this. Regulatory exposure (FTC health claims in the US; MHRA/EU MDR software-as-a-medical-device questions if the app claims to diagnose or treat). **Claims must be about practice delivery, not outcomes.**
2. **Replacing the SLP.** CAS requires differential diagnosis, target selection, and dynamic cueing judgment that an app cannot make. An app that positions itself as a substitute causes real harm by delaying proper assessment — and the children most at risk are those in under-served areas whose families have the fewest alternatives. **Positioning must be "between sessions," and the app should actively help families find and work with an SLP.**
3. **Drilling non-evidence-based exercises.** Blowing games, tongue exercises, straw hierarchies, "oral-motor warm-ups." Popular, engaging, monetisable, and contradicted by McCauley et al. (2009). Shipping them because they demo well is the category's original sin.
4. **Wrong target selection.** Targeting phonemes the child cannot approximate, or working top-down from adult forms, produces failure loops. Target selection must be inventory-driven and stimulability-driven.
5. **Frustration and aversion.** The deepest risk. A child with severe CAS experiences repeated communicative failure daily. An app that demands productions and marks them wrong can create **speech aversion** — the child stops trying. Once established this is very hard to reverse. **Error-reduced learning (DTTC's core design philosophy: cue enough that the child succeeds) is not just pedagogically preferable, it is a safety requirement.** Hard stops, adaptive backing-off, and "end on success" rules are mandatory.
6. **Gating communication behind speech performance.** Never make AAC a reward.
7. **Data privacy of child voice.** Under COPPA, a child's voice recording is personal information, and the amended COPPA Rule (FTC final rule April 2025, effective June 2025, full compliance April 2026) **explicitly adds biometric identifiers including voiceprints** (see https://www.fenwick.com/insights/publications/ftcs-new-coppa-guidance-on-recording-childrens-voices-five-tips-for-app-developers-and-toymakers-to-comply). Under GDPR, voice is personal data and voiceprints are Article 9 biometric data requiring an explicit lawful basis. **Verifiable parental consent, data minimisation, auto-deletion when no longer needed for the stated purpose, no training of third-party models on child voice without separate explicit consent, no ad-tech SDKs, and on-device processing wherever technically possible.** Storing derived scores and discarding audio removes most risk while preserving most product value.
8. **Bias and equity.** ASR underperforms on non-mainstream dialects and accents; a scoring app will systematically under-credit children who are already under-served. Any automatic scoring must be validated across dialects or disclaimed.
9. **False reassurance / delayed referral.** A progress dashboard that shows "improvement" while a child is actually regressing, or that pacifies a family whose child needs neurology, is an active harm. **Red-flag screening must be built in and must interrupt, not merely inform.**
10. **Caregiver burden and guilt.** Dose targets that no working parent can hit produce guilt and abandonment. The evidence (Thomas et al., 2017) says parents disengage from therapy delivery. Design for realistic, short, frequent, low-friction sessions — and never shame.

---

## 9. EXISTING APPS AND TOOLS — HONEST GAP ANALYSIS

**Caveat:** I could not fetch app store pages or independent reviews in this pass (egress blocked). The assessments below combine search findings with domain knowledge; treat feature claims as needing verification before use in competitive copy. A relevant general finding: SLPs overwhelmingly use apps (≈77% report using apps in treatment sessions — *LSHSS* 2022, https://pubs.asha.org/doi/10.1044/2022_LSHSS-21-00150) but as *adjuncts*, and a content analysis of App Store reviews (*PMC8817219*) found stakeholders value structure and progress visibility and complain about cost and lack of individualisation.

| Tool | What it is | Strengths | Gaps / honest critique |
|---|---|---|---|
| **Apraxia Therapy (Tactus Therapy)** | Adult AOS app with VAST-style video modelling, unison repetition, recording and playback (https://tactustherapy.com/app/apraxia/) | Genuinely well-designed; video model + hand-tapping + unison practice is real integral-stimulation logic; recording/playback is correct KP support; SLP-authored | **Built for adult acquired AOS, not children.** Content and interface are wrong for a 3-year-old. No AAC. No caregiver coaching. No adaptive cue hierarchy. No dynamic difficulty. |
| **Apraxia Ville (Smarty Ears)** | Child CAS practice app — sounds, syllables, words; video mouth models; data tracking | Child-appropriate; mouth-model videos are the right idea; clinician data tracking | Essentially a **flashcard deck with videos**. No true cueing hierarchy or fading logic, limited adaptivity, no generalisation/maintenance probes, no AAC integration. Ageing. |
| **Apraxia Therapy apps (NACD / Blue Whale Apps)** | Apraxia Picture Sound Cards and related titles; CV/VC/CVC hierarchies | Stimuli organised by syllable shape — **correct structural instinct** and rare among consumer apps; low cost | Static card decks. **NACD as an organisation promotes practices outside mainstream evidence** — proceed carefully before citing it as clinical authority. No feedback mechanism, no probes, no data model. |
| **Speech Blubs** | Consumer video-modelling app: child sees peer-video models of sounds/words and imitates, with AR effects | Very high engagement; peer video models exploit imitation; large consumer reach; low cost | **The clearest example of the category's problems.** Marketing is outcome-claiming and consumer-targeted; content includes non-evidence-based oral-motor-style activities; **no accuracy feedback at all** (it does not know what the child said); no target individualisation by inventory; no probes; no clinician loop. Engaging ≠ therapeutic. |
| **Articulation Station (Little Bee Speech)** | Best-in-class articulation drill app; word/sentence/story levels per phoneme; excellent data recording | Superb execution, huge stimulus library, reliable SLP-scored data capture, strong clinician trust | **Wrong disorder.** Built for articulation/phonological targets, phoneme-by-phoneme, position-in-word. Does not address motor planning, transitions, prosody, or syllable shape. **Not a CAS tool**, though widely misapplied as one. No AAC. |
| **Proloquo2Go (AssistiveWare)** | Leading symbol-based AAC app; Crescendo core vocabulary | Mature, research-informed core vocabulary, excellent customisation, strong accessibility, well-supported, AssistiveWare publishes genuinely good practice guidance | **Pure AAC — no speech practice component at all.** Expensive. Steep configuration burden on families. Nothing connects device use to speech targets. |
| **TouchChat (with WordPower)** | Symbol AAC with WordPower vocabularies | Flexible, widely funded, good vocabulary sets, scanning/switch access | Same gap: **no speech-production bridge**. Interface dated. Configuration burden. |
| **LAMP Words for Life (PRC-Saltillo)** | AAC app implementing LAMP principles — fixed motor patterns, consistent icon locations | **Motor-planning-consistent design is exactly right for CAS** — invariant button locations build automaticity; strong vocabulary depth | Evidence base thin and vendor-adjacent (§4.3). Expensive. Steep learning curve. **Again: no speech practice loop.** The motor-planning philosophy stops at the screen and never reaches the mouth. |
| **Speech FIRST / similar structured-practice tools** | Structured articulation/motor practice with hierarchies | Structured hierarchy is the right shape | Limited independent evidence; limited reach; verify current status. **[UNVERIFIED IN THIS PASS]** |
| **Constant Therapy** | Adult neuro rehab (aphasia, AOS, cognition) with adaptive difficulty and large published evidence base | **Best-in-class adaptivity and data science in this space**; genuine peer-reviewed outcome publications; automatic task-level difficulty adjustment | **Adult-only.** Not designed for children, CAS, or AAC. But the *product model* — adaptive hierarchy + clinician dashboard + published outcomes — is the correct template to emulate. |

### The gap, stated plainly

**Nothing on the market does the following combination:**

1. Implements a **real, dynamic, trial-by-trial cue hierarchy** (DTTC-style) with automatic escalation and fading, rather than static flashcards.
2. Selects targets from the **child's actual syllable-shape and phonetic inventory**, and updates that inventory as it grows.
3. Runs **high-volume practice with reliable trial counting** toward evidence-referenced dose (~100 trials/session, ≥2 sessions/week).
4. Integrates **AAC and speech practice in one system**, sharing targets, with AAC never gated.
5. Runs **generalisation and maintenance probes** rather than reporting within-session accuracy.
6. Coaches the **caregiver** as the delivery agent — the known weak link (Thomas et al., 2017) — and reduces their judgment burden.
7. Produces a **clinician-facing dataset** an SLP can actually use to adjust targets.
8. Refuses to ship **non-speech oral motor exercises**.
9. Handles the **truly non-verbal starting point** — vocal play, sound effects, automatic-to-volitional transfer, vowel-first — rather than assuming the child can already say words.

The consumer apps have engagement and no clinical spine. The clinical apps have stimulus libraries and no adaptivity. The AAC apps have communication and no speech bridge. **The unoccupied position is a clinically-spined, caregiver-delivered, AAC-integrated practice engine for the severe end — explicitly scoped as an adjunct to an SLP.**

---

## IMPLICATIONS FOR APP DESIGN

Twenty-two requirements the app must satisfy to be clinically defensible.

1. **Ship an explicit cue hierarchy as a first-class state machine, not a content tag.** Minimum five states, ordered most-to-least support: (0) *elicit-only / vocal play, no target*, (1) *simultaneous production with slowed model*, (2) *simultaneous at normal rate*, (3) *immediate imitation*, (4) *delayed imitation (1–3 s pause)*, (5) *spontaneous (picture/question prompt, no model)*. Every trial is logged with the cue level at which it occurred. This is the DTTC spine (Strand, 2020) and the app's core IP.

2. **Fade and back off dynamically, trial-by-trial, not session-by-session.** Rule: **3 consecutive accurate productions at level *n* → advance to level *n+1*. 2 consecutive inaccurate at level *n* → drop to level *n−1* immediately.** Never leave a child failing repeatedly at a level.

3. **Enforce error-reduced learning as a safety rule.** If a target produces <40% success across 10 consecutive trials even at the lowest cue level, the app **automatically retires the target** and flags it for clinician review. Never let a child fail 20 times in a row. Aversion is the worst outcome in this population and is effectively irreversible.

4. **Target selection is inventory-driven.** Maintain a live **syllable-shape inventory** (V, CV, VC, CVCV-reduplicated, CVCV-varied, CVC, CVCVC) and **phonetic inventory** per child. New targets must use shapes at or one step beyond the current inventory. Never offer a CVC target to a child with a V-only inventory.

5. **Start the non-verbal pathway below the word level.** Phase 0 content must include: contingent imitation of the child's own vocalisations, sound effects and exclamations (uh-oh, mmm, brrm, wheee, ahh), vowel-only targets (/ɑ i u oʊ aɪ/), then bilabial/glottal CV (/ma ba pa ha wa/), then VC, then reduplicated CVCV. **Do not require the child to say a word to enter the app.**

6. **Exploit automatic-to-volitional transfer explicitly.** Build routines where a target is embedded in a highly predictable, high-affect frame (song, ritual, cloze: "ready, steady… ___") and then systematically strip the frame. Log the frame level as a cue dimension alongside the temporal hierarchy.

7. **Target ~100 production trials per practice block and count them accurately.** Show the trial count to the caregiver in real time as the primary in-session metric. Default block: **15 minutes, 5–8 targets, 100+ trials** (Edeal & Gildersleeve-Neumann, 2011). If the app cannot reliably count attempts, it cannot claim dose.

8. **Default schedule: ≥2 sessions/week; recommend 4–5 short sessions/week; support intensive blocks.** Namasivayam et al. (2015) establishes 2×/week as the floor. Offer a 3-to-6-week intensive block (4–5×/week) followed by a maintenance phase, mirroring the published protocols. Never present a single weekly session as adequate.

9. **Blocked practice during acquisition, mixed toward random on stabilisation.** While a target is below 60% at its current cue level, present it in blocks. Above 80% for two sessions, interleave it randomly with other stable targets. **Make this clinician-overridable** — the child CAS evidence for random superiority is genuinely mixed (Maas & Farinella, 2012).

10. **Feedback: KP early, KR late, and reduce frequency as targets stabilise.** During acquisition give specific, immediate, performance-oriented feedback on ~100% of trials. Once a target reaches 80%, switch to outcome-only feedback on ~60% of trials, delivered after a short delay or as a summary at block end. Make the transition explicit in the data model.

11. **Never let ASR be the sole arbiter of accuracy.** Use on-device audio processing for attempt detection, syllable counting, duration and loudness only. Accuracy judgment is made by the caregiver (one tap: *got it / close / not yet*) or the clinician reviewing flagged clips. **State this honestly in the UI.** ASR on severe disordered child speech is not reliable (Hair et al., 2019; Shriberg et al.).

12. **Primary outcome metric is Percent Syllables Approximated plus cue-level distribution, not PCC.** PCC floors at zero in this population. Report the **distribution of trials across cue levels over time** as the headline progress chart — movement toward less support is the clinically meaningful signal.

13. **Run generalisation probes on untreated items every 5 sessions, uncued, unreinforced, unpractised.** Report them separately and prominently. Within-session accuracy on cued targets is not learning.

14. **Run maintenance probes at 1 week, 1 month and 3 months after a target is retired.** Retention is the index of learning (Maas et al., 2008). No app currently does this. It is a genuine differentiator and it is cheap to implement.

15. **Administer the Intelligibility in Context Scale every 8–12 weeks** as a free, validated, parent-reported functional outcome (McLeod, Harrison & McCormack, 2012). Track the 1–5 mean over time.

16. **Integrate AAC on equal footing, sharing the target list.** Every practice target is also a button. Button layout is **positionally invariant** (LAMP's one defensible principle) with a core-vocabulary spine. **AAC access is never gated, delayed, earned or removed.** No "say it to unlock" mechanic, ever.

17. **Count and report the modality ratio** — AAC-only / AAC+vocalisation / vocalisation-only, per target and overall. This is the single most meaningful longitudinal measure of the speech-AAC bridge and directly operationalises Millar, Light & Schlosser (2006).

18. **Ship zero non-speech oral motor exercises.** No blowing, whistles, straws, tongue push-ups, cheek puffing, or "oral-motor warm-ups." Say so publicly, cite McCauley et al. (2009), and make it a marketing position. Visual *placement cues* delivered immediately before a speech target are permitted; standalone non-speech drills are not.

19. **Build red-flag screening into onboarding and re-screen every 3 months, with hard interrupts.** Screen for: feeding/swallowing difficulty or coughing on liquids, loss of previously acquired skills, unconfirmed hearing status, suspected seizures, breathing/voice change, dysmorphology or family genetic history, and practice-related distress or self-injury. A positive screen **blocks further onboarding** and routes to explicit referral guidance. Hearing screening status is a mandatory gate before any speech pathway starts.

20. **Position as an adjunct and behave like one.** No claim to diagnose, no claim to treat, no claim to replace an SLP, no "teach your child to talk." Approved claim shape: *"structured, high-repetition speech practice between therapy sessions, built on published motor-learning principles."* Provide an SLP-locator and an SLP-facing export from day one, and prompt for clinician involvement repeatedly.

21. **Ship a clinician dashboard with target-level control.** An SLP must be able to set and retire targets, set cue-level ceilings and floors, set feedback frequency, set the practice schedule, review flagged audio, and export a session-by-session CSV/PDF. The evidence-aligned model is *clinician sets, app delivers volume, clinician reviews* — which is the telepractice finding (Thomas et al., 2016) generalised.

22. **Child-voice data handling must exceed baseline compliance.** Verifiable parental consent before any recording (COPPA amended rule, biometric identifiers including voiceprints, full compliance April 2026); GDPR Article 9 basis for voiceprint data in the EU; on-device processing by default; **audio auto-deleted within a short, stated retention window (default: discard after scoring, opt-in retention ≤30 days for clinician review)**; derived scores retained, raw audio not; **no third-party model training on child voice without separate explicit opt-in**; zero advertising or analytics SDKs with access to audio; full parent-initiated export and delete.

**And one meta-requirement:** every clinical claim in the product, marketing and onboarding should be traceable to a citation in this document or a better one. Where the evidence is thin — the non-verbal starting point, caregiver-delivered fidelity, app-delivered practice outcomes — **say so in the product**. A CAS parent has usually been sold false hope several times already. Being the product that is honest about uncertainty is both the ethical position and, in this market, the differentiated one.

---

### Source list (as accessed 2026-09-11)

- ASHA (2007). *Childhood Apraxia of Speech* [Position Statement & Technical Report] / ASHA Practice Portal — https://www.asha.org/practice-portal/clinical-topics/childhood-apraxia-of-speech/
- RCSLT (2024). *Position Paper on Childhood Apraxia of Speech* — https://www.rcslt.org/wp-content/uploads/2024/02/RCSLT-Childhood-Apraxia-of-Speech-CAS-Position-Paper-2024.pdf
- Murray, McCabe, Heard & Ballard (2015). Differential diagnosis of children with suspected CAS. *JSLHR* — https://pubs.asha.org/doi/10.1044/2014_JSLHR-S-12-0358
- Strand, McCauley, Weigand, Stoeckel & Baas (2013). A motor speech assessment for children with severe speech disorders. *JSLHR* 56(2) — https://pubs.asha.org/doi/pdf/10.1044/1092-4388(2012/12-0094) ; DEMSS — https://brookespublishing.com/product/demss/
- Iuzzini-Seigel et al. (2022). Differential diagnosis of CAS compared to other SSD: systematic review — https://epublications.marquette.edu/cgi/viewcontent.cgi?article=1058&context=spaud_fac
- Iuzzini-Seigel et al. (2024). Exploring motor speech disorders in low and minimally verbal autistic individuals. *AJSLP* — https://pubs.asha.org/doi/10.1044/2024_AJSLP-23-00237
- Chenausky, Brignell, Morgan & Tager-Flusberg (2019). Motor speech impairment predicts expressive language in minimally verbal ASD. *ADLI* — https://doi.org/10.1177/2396941519856333
- Maas, Robin, Austermann Hula, Freedman, Wulf, Ballard & Schmidt (2008). Principles of motor learning in treatment of motor speech disorders. *AJSLP* 17(3) — https://gwulf.faculty.unlv.edu/wp-content/uploads/2014/05/Maas-et-al_AJSLP-2008_PML-tutorial.pdf
- Maas & Farinella (2012). Random versus blocked practice in treatment for CAS. *JSLHR* — https://pubs.asha.org/doi/10.1044/1092-4388%282011/11-0120%29
- Maas, Butalla & Farinella (2012). Feedback frequency in treatment for CAS. *AJSLP* — https://pubs.asha.org/doi/10.1044/1058-0360(2012/11-0119)
- Strand (2020). Dynamic Temporal and Tactile Cueing: a treatment strategy for CAS. *AJSLP* — https://pubs.asha.org/doi/10.1044/2019_AJSLP-19-0005
- DTTC dose-frequency RCT protocol (2023). *BMC Pediatrics* — https://link.springer.com/article/10.1186/s12887-023-04066-2 ; trials NCT05675306, NCT04642053
- DTTC community-clinician training pathway (2025). *AJSLP* — https://pubs.asha.org/doi/10.1044/2025_AJSLP-24-00239
- Murray, McCabe & Ballard (2015). RCT comparing ReST and NDP3. *JSLHR* — https://pubs.asha.org/doi/10.1044/2015_JSLHR-S-13-0179
- Thomas, McCabe & Ballard (2014). ReST at lower dose-frequency. *JCD* — https://www.sciencedirect.com/science/article/abs/pii/S0021992414000550
- Thomas, McCabe, Ballard & Lincoln (2016). Telehealth delivery of ReST. *IJLCD* — https://onlinelibrary.wiley.com/doi/10.1111/1460-6984.12238
- Thomas, McCabe & Ballard (2017). Combined clinician-parent delivery of ReST — https://pubmed.ncbi.nlm.nih.gov/28443686/ ; parent experiences — https://pubmed.ncbi.nlm.nih.gov/28534689/
- NDP3 evidence base — https://www.ndp3.org/evidence-base/
- Namasivayam et al. (2020). PROMPT for children with severe speech motor delay: RCT. *Pediatric Research* — https://www.nature.com/articles/s41390-020-0924-4
- Namasivayam, Pukonen, Goshulak et al. (2015). Treatment intensity and CAS. *IJLCD* — https://onlinelibrary.wiley.com/doi/abs/10.1111/1460-6984.12154
- Edeal & Gildersleeve-Neumann (2011). Importance of production frequency in therapy for CAS. *AJSLP* 20(2) — https://www.semanticscholar.org/paper/1a40a154ed06b4cf77cd6a8b94fcde191181c977
- Gomez, McCabe et al. (2018). K-SLP Phase I pilot. *LSHSS* — https://pubs.asha.org/doi/10.1044/2018_LSHSS-17-0100 ; SCED (2023) — https://www.tandfonline.com/doi/full/10.1080/17549507.2023.2211750 ; dyadic/group format (2024) — https://pubs.asha.org/doi/10.1044/2024_AJSLP-24-00098
- Chenausky et al. (2016). AMMT vs control for minimally verbal children with autism. *PLOS ONE* — https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0164930 ; (2022) *Ann NY Acad Sci* — https://nyaspubs.onlinelibrary.wiley.com/doi/abs/10.1111/nyas.14817
- Preston, Brick & Landi (2013). Ultrasound biofeedback for persisting CAS. *AJSLP* — https://pubs.asha.org/doi/10.1044/1058-0360(2013/12-0139) ; ReST vs UVB pilot RCT (2022) — https://pubs.asha.org/doi/10.1044/2022_AJSLP-22-00144
- McCauley, Strand, Lof, Schooling & Frymark (2009). Evidence-based systematic review: effects of NSOMEs on speech. *AJSLP* — https://pubmed.ncbi.nlm.nih.gov/19638484/ ; Lof 20Q — https://www.speechpathology.com/articles/20q-non-speech-oral-motor-20430 ; Bowen reading list — https://www.speech-language-therapy.com/index.php?option=com_content&view=article&id=49:omtreadings&catid=11&Itemid=101
- Millar, Light & Schlosser (2006). Impact of AAC intervention on speech production. *JSLHR* 49(2) — https://pubs.asha.org/doi/10.1044/1092-4388(2006/021)
- LAMP evidence-based evaluation (2015). *Cogent Education* — https://www.tandfonline.com/doi/full/10.1080/2331186X.2015.1045807 ; Center for AAC & Autism — https://www.aacandautism.com/lamp/research/
- Supplementary sign use in school-aged children with CAS — https://pmc.ncbi.nlm.nih.gov/articles/PMC9913131/
- Comorbid neurodevelopmental disorders in CAS — https://pmc.ncbi.nlm.nih.gov/articles/PMC8880782/
- Lewis et al., Cleveland Family Speech and Reading Study — https://pmc.ncbi.nlm.nih.gov/articles/PMC12614917/ ; adolescent outcomes — https://pubmed.ncbi.nlm.nih.gov/25569242/
- FOXP2-related speech and language disorder — https://medlineplus.gov/download/genetics/condition/foxp2-related-speech-and-language-disorder.pdf ; WAC variants, epilepsy and CAS — https://www.sciencedirect.com/science/article/abs/pii/S1090379820302348 ; whole-exome heterogeneity — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3851280/
- McLeod, Harrison & McCormack (2012). Intelligibility in Context Scale. *JSLHR* — https://pubs.asha.org/doi/10.1044/1092-4388(2011/10-0130)
- Hair et al. (2019). Evaluating ASR for child speech therapy applications — https://psi.engr.tamu.edu/wp-content/uploads/2019/08/hair2019evaluating.pdf ; Tabby Talks — https://www.sciencedirect.com/science/article/abs/pii/S0167639315000382 ; automated lexical stress classifier — https://doi.org/10.3390/brainsci11111408
- SLP app use survey (2022). *LSHSS* — https://pubs.asha.org/doi/10.1044/2022_LSHSS-21-00150 ; App Store review content analysis — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8817219/
- FTC amended COPPA Rule guidance on children's voice recordings — https://www.fenwick.com/insights/publications/ftcs-new-coppa-guidance-on-recording-childrens-voices-five-tips-for-app-developers-and-toymakers-to-comply
- Tactus Therapy Apraxia Therapy app — https://tactustherapy.com/app/apraxia/
