# Praxia Audio Test Fixtures

Fixture audio clips for regression testing Tier-1 DSP (vocalization detection, latency, SNR, syllable estimation).

**Source:** Recordings from children with Childhood Apraxia of Speech (CAS) and typical speech development, collected during pilot studies with informed consent.

**Format:** 16-bit PCM, 16 kHz mono, Opus-encoded for storage efficiency.

---

## Fixture Categories

### 1. Clear Vocalizations (Low SNR Challenge)
- `fixture_clear_ball_001.opus` — Child says "ball" clearly, L0-equivalent (baseline)
- `fixture_clear_up_001.opus` — Child says "up" clearly, 1 syllable
- `fixture_clear_mama_001.opus` — Child says "mama", 2 syllables (repetition)

**Expected Tier-1 Signals:**
- Vocalization Detected: TRUE
- Latency: 50–100 ms
- SNR: >24 dB
- Syllable Estimate: 1–2

### 2. Weak/Quiet Vocalizations (High SNR Challenge)
- `fixture_weak_attempt_001.opus` — Whispered/very quiet attempt
- `fixture_weak_attempt_002.opus` — Barely perceptible vocalization
- `fixture_weak_attempt_003.opus` — At noise floor (~18 dB SNR boundary)

**Expected Tier-1 Signals:**
- Vocalization Detected: TRUE (if SNR ≥ 18 dB), FALSE (if SNR < 18 dB)
- Latency: 80–150 ms
- SNR: 16–20 dB (boundary testing)
- Syllable Estimate: 1 (lower confidence)

### 3. Background Noise (False Positive Prevention)
- `fixture_silence_001.opus` — Pure silence (no vocalization)
- `fixture_noise_toys_001.opus` — Toy sounds only, no child vocalization
- `fixture_noise_parent_speech_001.opus` — Parent speaking in background, no child vocalization
- `fixture_noise_mixed_001.opus` — Mixed speech + toys, child vocalization present but overlaid

**Expected Tier-1 Signals:**
- Vocalization Detected: FALSE (except mixed)
- Latency: N/A or very high (onset detection fails)
- SNR: Varies (low for toys, high for parent speech)
- Syllable Estimate: 0 or false positives (testing robustness)

### 4. Apraxic-Specific Patterns (CAS Characteristics)
- `fixture_cas_repeated_syllable_001.opus` — "buh-buh-buh" (repetitive syllable, searching)
- `fixture_cas_irregular_voicing_001.opus` — Inconsistent voicing onset ("b-b-b" with timing variance)
- `fixture_cas_incomplete_001.opus` — Incomplete attempt ("ba" instead of "ball", shortened)
- `fixture_cas_prolongation_001.opus` — Prolonged sound ("bbbbaaaa", motor control difficulty)

**Expected Tier-1 Signals:**
- Vocalization Detected: TRUE
- Latency: Highly variable (reflects motor planning difficulty)
- SNR: Variable (depends on voicing consistency)
- Syllable Estimate: Often 1–2 even when target is multi-syllabic (testing robustness)

### 5. Latency Boundary Tests
- `fixture_latency_instant_001.opus` — Child responds immediately (<50 ms)
- `fixture_latency_slow_001.opus` — Child responds after delay (200+ ms, motor planning)
- `fixture_latency_variable_001.opus` — Same child, multiple attempts with varying latencies

**Expected Tier-1 Signals:**
- Latency: Should scale correctly (verification of timestamp accuracy)
- Vocalization Detected: TRUE
- SNR: Normal
- Syllable Estimate: Should not vary with latency (independence check)

---

## Test Protocol

### Audio Capture Regression Test
```swift
func testAudioCaptureFixtures() {
  let fixtures = [
    ("fixture_clear_ball_001.opus", expectedVocalization: true, expectedSNR: 24...),
    ("fixture_weak_attempt_001.opus", expectedVocalization: true, expectedSNR: 18...22),
    ("fixture_silence_001.opus", expectedVocalization: false),
    ("fixture_cas_repeated_001.opus", expectedVocalization: true, expectedSyllables: 1...2),
  ]
  
  for (fixture, expectations) in fixtures {
    let audio = loadFixture(fixture)
    let signals = audioCapture.computeTier1(audio)
    
    XCTAssertEqual(signals.vocalicationDetected, expectations.expectedVocalization)
    if let expectedSNR = expectations.expectedSNR {
      XCTAssert(signals.snr_db.range.overlaps(expectedSNR))
    }
  }
}
```

### Property-Based Test (Random Fixture Sequences)
```swift
func testAudioCaptureBattery() {
  property("Multiple fixtures in sequence") <- forAll { (indices: [Int]) in
    let selectedFixtures = indices.map { fixtures[$0 % fixtures.count] }
    
    for fixture in selectedFixtures {
      let signals = audioCapture.computeTier1(loadFixture(fixture))
      
      // Invariant: latency > 0 if vocalization detected
      if signals.vocalizationDetected {
        return signals.latency_ms > 0
      }
      return true
    }
  }
}
```

---

## Consent & Attribution

All audio fixtures were collected under IRB approval (Protocol #2025-CAS-001, approved by [Clinic Name]'s Institutional Review Board). Families provided informed consent for research use.

**Attribution:**
- Clear vocalizations: Pilot study cohort (N=8), ages 3–5
- Weak vocalizations: Controlled noise challenge study (N=4), ages 4–6
- CAS-specific patterns: Expert elicitation from certified SLP (Dr. Jane Smith, MS-SLP)

**Privacy:**
- All identifiable information removed
- Clips anonymized (fixture_001, fixture_002, etc.)
- Stored in encrypted research repository (HIPAA-compliant S3)
- Retention: 5 years (per IRB protocol)

---

## Expected Validation Results

| Fixture Category | Vocalization Detect Rate | False Positive Rate | Latency Accuracy | Syllable Recall |
|---|---|---|---|---|
| Clear Vocalizations | >95% | <1% | ±10 ms | >85% |
| Weak Vocalizations | >80% (>18 dB) | <2% | ±15 ms | >70% |
| Background Noise | >99% (silent) | <5% (toys) | N/A | >90% |
| CAS-Specific | >90% | <3% | ±20 ms (high variance expected) | >75% |

**Pass Criteria:** All categories meet >90% of metrics. CAS-specific allows higher latency variance (motor planning reflection).

---

## Usage in CI/CD

```yaml
# .github/workflows/test.yml
- name: Run Audio Fixture Regression Tests
  run: |
    cd tests
    swift test -c release \
      --test-product PraxiaChildTests \
      --filter AudioCaptureTests
  env:
    AUDIO_FIXTURES_PATH: tests/audio-fixtures/
```

---

## Contributing New Fixtures

**Requirements:**
1. IRB approval for new collection
2. Informed consent from families
3. Audio anonymization protocol
4. Clinician review (SLP validation of expected signals)
5. Commit message: `fixtures: add [category] fixture from [study/elicitation]`

**Submission:**
- Create pull request to `fixtures/` branch
- Include IRB protocol number + approval date
- Include expected Tier-1 signals (SLP-labeled)
- Pass all existing regression tests

---

## Maintenance Schedule

- **Monthly:** Validate fixture integrity (checksums, format)
- **Quarterly:** Review for new CAS patterns (clinical updates from advisor board)
- **Annually:** Audit consent records, update attribution

Last updated: Feb 2025
Maintained by: iOS Development Team
