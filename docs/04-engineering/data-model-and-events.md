# Data Model & Event Log

---

## 1. Design commitments

1. **The trial log is event-sourced, append-only and immutable.** Derived tables are projections, always rebuildable.
2. **`CueLevel` is a first-class field on every trial** — the critical variable in CAS treatment and the thing most apps omit entirely.
3. **A trial carries multiple `Score` rows, never one.** Machine scores are just another rater.
4. **Identifiers are minimised.** Pseudonymous child IDs everywhere; identity mapping isolated in a separate schema with separate access controls.
5. **Two tenant modes are enforced in the model, in code** — not in policy documents.

---

## 2. Entities

| Entity | Notes |
|---|---|
| **Guardian** | Identity, versioned parental-consent records, notification prefs |
| **Child** | Pseudonymous ID. **Minimal identifiers — first name + DOB month/year.** No full DOB, no geolocation, no advertising ID, no contact list. Linked guardians and clinicians; consent state |
| **Clinician** | Credentials (ASHA CCC-SLP #), licensure state, org, role |
| **Organization / Tenant** | Clinic or district. **`tenant_mode ∈ {consumer, institutional}`** — data-residency, retention policy, and *training eligibility* attach here |
| **Stimulus / Target** | IPA transcription, syllable shape (V/CV/VC/CVCV/CVC/CVCVC), phoneme inventory, word vs non-word, image asset, model audio, model video, stress pattern, sequence length |
| **Program / Hierarchy** | Ordered target set + mastery criteria + cue hierarchy definition + engine bounds |
| **Goal** | Child × skill, baseline, criterion, target date, IEP linkage, status |
| **Session** | Child, date, setting (home/clinic/tele), administrator, duration, device |
| **Trial** | Session × stimulus × ordinal. **The atomic unit. Immutable.** |
| **Attempt / Recording** | Trial × audio blob ref, duration, SNR, device/mic metadata, retention class |
| **CueLevel** | The cue *actually* provided — temporal level L0–L5 plus visual / gestural / rhythmic / frame dimensions |
| **Score** | Trial × rater × value × confidence × rubric version. `rater ∈ {parent, slp, model:vX}` |
| **InventorySnapshot** | Child's syllable-shape and phonetic inventory over time |
| **Probe** | Type (generalisation / maintenance / ICS), schedule, items, results |
| **Consent** | Child × purpose × granted × timestamp × policy version × verification method. **Independently revocable per purpose** |
| **Report** | Generated artifact, snapshotted inputs, immutable, integrity hash |
| **AudioAccessLog** | Who played which clip, when. **Visible to the parent.** |

---

## 3. The event log

Append-only `trial_events`:

```jsonc
{
  "event_id":        "uuidv7",
  "child_id":        "pseudonymous",
  "session_id":      "uuid",
  "trial_id":        "uuid",
  "event_type":      "…",
  "payload":         { /* jsonb */ },
  "client_ts":       "ISO8601",
  "server_ts":       "ISO8601",
  "device_id":       "…",
  "app_version":     "…",
  "protocol_version":"…",   // lets us A/B intervention parameters honestly
  "model_version":   "…",   // null in v1 — no machine scoring
  "schema_version":  "…"
}
```

**`event_type`** ∈
`stimulus_presented` · `cue_given` · `vocalization_detected` · `attempt_recorded` · `parent_scored` · `slp_scored` · `model_scored` · `reinforcement_delivered` · `trial_aborted` · `cue_advanced` · `cue_backed_off` · `target_retired_safety` · `aversion_detected` · `session_capped`

### Why event sourcing here specifically

1. **Research-grade reproducibility** — any session can be replayed.
2. **Retrospective re-scoring.** We can run a new model version against historical audio and compare to human labels *without a prospective trial.* This is how Tier-3 models get validated.
3. It is **the audit log** regulators and IRBs ask for.
4. `protocol_version` lets us A/B intervention parameters honestly rather than silently.

**Derived projections** (mastery %, trials-to-criterion, cue-level fading curves, modality ratio) are always rebuildable from the log.

---

## 4. Scoring model

```
Trial ──┬── Score(rater: parent,      value: got_it|close|not_yet)
        ├── Score(rater: slp,         value: …, ipa: …, cue_needed: …)   [sampled]
        └── Score(rater: model:v1.2,  value: …, confidence: …)           [v1.5+]
```

**Never collapse to a single score.** Parent-vs-model agreement is surfaced **only to the clinician**. Clinician overrides feed active learning — disagreements are the highest-value labelling signal we have.

Every machine score carries an explicit **confidence tier**, its `model_version`, and **the ability to abstain.** Suppress display below threshold; route ambiguity to the adult. **Optimise for precision and abstention, never coverage** — a false "correct" teaches an error motor pattern, which is clinical harm rather than merely bad UX.

---

## 5. Tenant enforcement

```
consumer      → COPPA, parent-consented, model training PERMITTED under separate opt-in
institutional → FERPA/IDEA, district DPA, model training DISABLED and not toggleable
```

Under FERPA's school-official exception, district-sourced data generally **may not** train our models without separate district *and* parent consent. This is enforced at the tenant boundary in code, with training-pipeline queries filtered on `tenant_mode = 'consumer' AND consent.training = true`.

See [risk register](../05-compliance/risk-register.md) RR-09 — this is a permanent structural feature of the business, not a phase.

---

## 6. Retention classes

| Class | Default | Location | Consent |
|---|---|---|---|
| **Trial events & scores** | Indefinite (research value, no audio) | Server | Core service |
| **Raw audio** | **90 days** | **On-device, `NSFileProtectionComplete`** | On-device recording |
| **Uploaded audio** | 90 days | Server, SSE-KMS per-tenant key | Cloud storage + clinician sharing |
| **Keepsake clips** | Indefinite | On-device + optional cloud | Separate, revocable opt-in |
| **Training corpus** | Per published schedule | Server, isolated | **Separate opt-in — never bundled** |
| **Per-child voice embedding** | Per BIPA destruction schedule | **On-device where possible** | Treated as biometric |

**Derived features and scores can outlive the audio.** Deletion honoured within 30 days, cascading to backups within a documented expiry window, with a deletion receipt.
