# Praxia Multi-Platform: Week 1-2 Sprint Coordination
**Date:** Sept 15, 2026 (Sprint Kick-off)  
**Duration:** 2 weeks (Sept 15-28, 2026)  
**Target:** All platforms core-complete, testing in progress, responsive verified

---

## 🚀 Team Assignments & Deliverables

### Web Developer (React + Next.js PWA)
**Session:** session_01Ms8SMiphjv2JDNuUw2uRaX  
**Target:** Production-ready PWA by Sept 28

#### Week 1 (Sept 15-21)
- ✅ **Day 1 Complete:** Core infrastructure (AudioCapture, TrialEngine, TrialStore, BackendClient)
- ✅ **Day 1 Complete:** PlaySurface component with responsive grid
- ⏳ **Days 2-3:** TalkSurface (AAC board, 2x3 → 3x4 → 4x5 grid)
- ⏳ **Days 2-3:** CollectionSurface (progress tracking, responsive table/cards)
- ⏳ **Days 3-4:** ParentPanel (sticky sidebar desktop, toggle overlay mobile)
- ⏳ **Days 4-5:** Service Worker (offline sync, background trials upload)
- ⏳ **Days 6-7:** Jest unit tests (20+, ~400 LOC)
- ⏳ **Days 6-7:** Playwright E2E tests (5+, ~250 LOC at 600px/800px/1024px)

**Week 1 Deliverables:**
- [ ] 4 React components + PlaySurface (450+ LOC)
- [ ] Service Worker (150 LOC)
- [ ] 25+ tests passing
- [ ] Responsive verified at 600px (7"), 800px (10"), 1024px
- [ ] Touch targets ≥48px verified
- [ ] All commits pushed

#### Week 2 (Sept 24-28)
- [ ] Responsive testing on physical tablets (7", 10")
- [ ] Performance profiling (Lighthouse >90, <2s page load on 4G)
- [ ] Compliance audit (all 19 constraints verified)
- [ ] PWA manifest + icon generation
- [ ] Production build optimization
- [ ] WEB.md documentation (100 LOC)
- [ ] COMPLIANCE-AUDIT-WEB.md

**Week 2 Deliverables:**
- [ ] Production PWA ready for deployment
- [ ] All 19 constraints audit complete
- [ ] <2s page load verified
- [ ] 100% responsive design tested

---

### Android Developer (Kotlin + Jetpack Compose)
**Session:** session_01X9D2BFXVp5vPv5hGmExSZ2  
**Target:** Functional app with responsive layout by Sept 28

#### Week 1 (Sept 15-21)
- ⏳ **Days 1-2:** Gradle project setup + AudioCaptureManager.kt (300 LOC)
- ⏳ **Days 2-3:** TrialEngine.kt (350 LOC, port from iOS)
- ⏳ **Days 2-3:** TrialDatabase.kt (350 LOC, Room + SQLCipher)
- ⏳ **Days 3-4:** PlaySurfaceView (150 LOC, responsive Jetpack Compose)
- ⏳ **Days 3-4:** TalkSurfaceView (100 LOC, AAC board)
- ⏳ **Days 4-4:** CollectionSurfaceView (100 LOC, progress tracking)
- ⏳ **Days 4-5:** ParentPanelView (50 LOC)
- ⏳ **Days 4-5:** TrialServiceClient.kt (200 LOC, gRPC-kotlin)
- ⏳ **Days 5-7:** Unit tests (26+, ~250 LOC)
- ⏳ **Days 6-7:** Integration tests (7+, ~100 LOC)

**Week 1 Deliverables:**
- [ ] Gradle project builds cleanly
- [ ] 4 surfaces functional (Play/Talk/Collection/Parent)
- [ ] 26+ unit tests passing
- [ ] 7+ integration tests passing
- [ ] AudioCaptureManager <50ms latency verified
- [ ] Responsive layout at 600dp, 800dp, 1024dp+
- [ ] Touch targets ≥48dp verified
- [ ] No red UI (warm colors throughout)

#### Week 2 (Sept 24-28)
- [ ] gRPC-kotlin client integrated with backend
- [ ] Offline mode: record trials → sync when online
- [ ] Responsive testing on physical tablets (7", 10")
- [ ] Compliance audit (all 19 constraints)
- [ ] Debug APK signed + deployable
- [ ] ANDROID.md documentation (150 LOC)
- [ ] COMPLIANCE-AUDIT-ANDROID.md

**Week 2 Deliverables:**
- [ ] Full gRPC integration working
- [ ] Offline sync tested and working
- [ ] APK ready for Google Play beta
- [ ] All 19 constraints audit complete

---

### iOS Developer (Swift + Xcode)
**Status:** Production-ready app complete (Sept 14)  
**Focus Week 1-2:** Integration testing + TestFlight prep

#### Week 1 (Sept 15-21)
- ⏳ **Days 1-3:** Docker Compose integration test with backend
- ⏳ **Days 3-4:** End-to-end session test (10 trials)
- ⏳ **Days 4-5:** gRPC client verification + latency benchmarks
- ⏳ **Days 5-7:** Responsive testing (iPad Pro, iPad mini, iPhone)

**Week 1 Deliverables:**
- [ ] Docker integration test passing
- [ ] gRPC client connectivity verified
- [ ] 10-trial session e2e test passing
- [ ] Latency <30ms confirmed
- [ ] Responsive layout verified on all devices

#### Week 2 (Sept 24-28)
- [ ] Security audit (TLS certs, API keys, S3 permissions)
- [ ] Performance benchmarking (Instruments)
- [ ] Final compliance audit (all 19 constraints signed off)
- [ ] TestFlight submission package ready
- [ ] Documentation finalized

**Week 2 Deliverables:**
- [ ] Security audit complete
- [ ] TestFlight submission ready (Oct 1 target)
- [ ] All 19 constraints final sign-off
- [ ] Production deployment checklist complete

---

### Backend Engineer (Go gRPC Services)
**Status:** Production-ready services complete (Sept 14)  
**Focus Week 1-2:** Multi-client testing + hardening

#### Week 1 (Sept 15-21)
- ⏳ **Days 1-3:** Deploy gRPC-Web proxy (if needed)
- ⏳ **Days 2-4:** Test TrialService endpoints with Web, Android, iOS clients
- ⏳ **Days 3-5:** Audio upload S3 integration testing
- ⏳ **Days 4-6:** Performance testing (concurrent trials)
- ⏳ **Days 6-7:** Docker stack stability verification

**Week 1 Deliverables:**
- [ ] gRPC-Web proxy running and tested
- [ ] All 3 clients (iOS, Android, Web) can connect
- [ ] UploadSession RPC working across clients
- [ ] Audio S3 upload verified
- [ ] Docker Compose stack stable under load

#### Week 2 (Sept 24-28)
- [ ] TLS certificate configuration
- [ ] Rate limiting + API authentication setup
- [ ] Monitoring + alerting configuration (Prometheus)
- [ ] Database backup + recovery procedures
- [ ] Production deployment checklist

**Week 2 Deliverables:**
- [ ] TLS certificates deployed
- [ ] Monitoring + alerts active
- [ ] Production ready with security hardening
- [ ] Deployment procedures documented

---

## 📊 Progress Tracking

### Metrics (Updated Daily)

| Platform | Week 1 Progress | Week 2 Progress | Status |
|----------|-----------------|-----------------|--------|
| **Web** | 0% → 100% | Testing → Production | 🔄 In Progress |
| **Android** | 0% → 100% | Integration → Production | 🔄 In Progress |
| **iOS** | 100% Complete | Integration → Beta | 🔄 In Progress |
| **Backend** | 100% Complete | Testing → Hardening | 🔄 In Progress |

### Daily Standup Checklist

**Each morning (9:00 UTC):**
- [ ] Web Developer: Components completed, tests status
- [ ] Android Developer: Build status, responsive screenshots
- [ ] iOS Developer: Integration test results
- [ ] Backend Engineer: gRPC proxy + client connectivity
- [ ] Coordinator: Cross-platform blocker review

### Weekly Review Gates

**Friday, Sept 21 (Week 1 Review):**
- [ ] Web: 4 components + 25+ tests ✅
- [ ] Android: Core app + 26+ tests ✅
- [ ] iOS: Integration tests passing ✅
- [ ] Backend: Multi-client tested ✅
- [ ] Cross-platform: Responsive verified ✅

**Friday, Sept 28 (Week 2 Review):**
- [ ] Web: Production PWA ready ✅
- [ ] Android: APK + full integration ✅
- [ ] iOS: TestFlight submission ready ✅
- [ ] Backend: Security + monitoring ✅
- [ ] All: 19/19 constraints audit complete ✅

---

## 🔄 Dependency Map

### Critical Path (Week 1)

```
Backend Deploy (Day 1)
    ↓
gRPC-Web Proxy Ready (Day 2)
    ↓
Web/Android gRPC Clients (Days 3-4) ← iOS Client Already Works
    ↓
Multi-Platform Integration Tests (Days 5-7)
    ↓
WEEK 1 GATE: All Platforms Responsive ✅
```

### Critical Path (Week 2)

```
All Platforms Tests Passing (Day 1)
    ↓
Compliance Audit (Days 1-3)
    ↓
Responsive Testing Physical Devices (Days 3-5)
    ↓
Production Build Optimization (Days 5-7)
    ↓
WEEK 2 GATE: Production Ready ✅
```

---

## 🎯 Success Criteria

### Week 1 Complete (Sept 21)
- ✅ Web: PlaySurface + TalkSurface + CollectionSurface + ParentPanel + Service Worker
- ✅ Android: All 4 surfaces + Room database + gRPC stubs compiled
- ✅ iOS: Docker integration test passing
- ✅ Backend: Multi-client connectivity verified
- ✅ All Platforms: Responsive at 600px (7"), 800px (10"), 1024px tested
- ✅ All Platforms: Touch targets ≥48px/48dp verified
- ✅ 57+ tests passing across all platforms (Web 25+, Android 26+, iOS tests)
- ✅ No red UI (therapeutic colors verified)
- ✅ Zero critical blockers

### Week 2 Complete (Sept 28)
- ✅ Web: Production PWA, <2s page load, Lighthouse >90
- ✅ Android: APK signed + deployable, full gRPC integration
- ✅ iOS: TestFlight submission ready (Oct 1 target)
- ✅ Backend: TLS, monitoring, security hardening
- ✅ All Platforms: Compliance audit (19/19 constraints signed off)
- ✅ All Platforms: Responsive verified on physical tablets
- ✅ All Platforms: Offline sync tested and working
- ✅ 150+ tests passing across all platforms
- ✅ Zero critical security issues
- ✅ Production deployment checklist complete

---

## 📋 Daily Standup Template

**Time:** 9:00 UTC (adjustable per team preference)  
**Format:** 5-min async updates in Slack/GitHub or 15-min Zoom

**Each team reports:**
1. ✅ What was completed yesterday
2. ⏳ What's planned for today
3. 🚫 Blockers or help needed
4. 📊 Commit count + test results

**Example:**
```
Web Developer (Sept 15):
✅ PlaySurface component complete (280 LOC) + deployed
⏳ Starting TalkSurface today (AAC board, 3x4 grid)
🚫 None - on track
📊 1 commit, PlaySurface tests passing (20+ assertions)

Android Developer (Sept 16):
✅ Gradle project + AudioCaptureManager (300 LOC)
⏳ Port TrialEngine from iOS tomorrow
🚫 Need clarification on JNI linking procedure (brief follow-up needed)
📊 1 commit, audio latency <50ms verified
```

---

## 📞 Communication Channels

- **Daily Standups:** Async Slack updates (each team 5 min max)
- **Blockers:** GitHub Issues (tagged `bug`, `blocker`)
- **Code Review:** Pull requests with auto-review
- **Integration Testing:** Shared Docker Compose + mock backend
- **Weekly Sync:** Friday 10:00 UTC (15 min review)

---

## 🚨 Escalation Path

**If blocker blocks >2 hours:**
1. Post in #blockers channel
2. Tag Coordinator + relevant team
3. Pair programming session if needed
4. Escalate to decision maker (user) if architectural

**Common Blockers & Resolutions:**
- gRPC connectivity: Check docker-compose status
- Responsive layout broken: Verify breakpoint units (px vs dp)
- Tests failing: Check mock fixtures, environment setup
- Performance regression: Profile with Lighthouse/Instruments

---

## 📅 Milestones

| Date | Milestone | Owner | Status |
|------|-----------|-------|--------|
| Sept 15 | Week 1 Sprint Kick-off | Coordinator | ✅ Complete |
| Sept 17 | Mid-week progress check | Coordinator | ⏳ Pending |
| Sept 21 | **Week 1 Gate: All Platforms Core Complete** | All Teams | ⏳ Pending |
| Sept 24 | Week 2 Kick-off + Retrospective | All Teams | ⏳ Pending |
| Sept 28 | **Week 2 Gate: Production Ready** | All Teams | ⏳ Pending |
| Oct 1 | TestFlight Beta Launch (iOS) | iOS + Coordinator | ⏳ Pending |
| Oct 15 | Android + Web Beta Launch | Android + Web + Coordinator | ⏳ Pending |
| Nov 1 | Production Release (All Platforms) | All Teams | ⏳ Pending |

---

## 📖 Reference Materials

**Shared Across All Platforms:**
- `docs/10-multi-platform/ANDROID-DEVELOPER-BRIEF.md` (450 LOC)
- `docs/10-multi-platform/WEB-DEVELOPER-BRIEF.md` (500 LOC)
- `docs/04-engineering/ARCHITECTURE.md` (16,000 words)
- `backend/pkg/gen/praxia/v1/` (Protobuf stubs)
- `client/Sources/PraxiaChild/` (iOS reference implementation)

**Testing Standards:**
- Jest unit tests: Minimum 80% coverage per module
- Playwright E2E: 5+ scenarios at each responsive breakpoint
- Manual testing: Physical devices (7", 10" tablets) by Week 2

**Constraint Verification:**
- All 19 constraints mapped to code locations
- Compliance audit checklist: 19 items × 3 platforms = 57 checks

---

## 🎓 Knowledge Transfer

**By end of Week 2:**
- All teams familiar with TrialEngine logic (identical across platforms)
- Responsive design patterns (sm/md/lg breakpoints standardized)
- gRPC-Web client patterns (shared across Web + Android)
- Offline-first architecture (IndexedDB + Room + Room equivalents)
- Compliance verification process (19 constraints)

---

**Document Authority:** Coordinator (Claude Haiku 4.5)  
**Last Updated:** Sept 15, 2026, 02:00 UTC  
**Next Review:** Sept 17, 2026 (mid-week check-in)  
**Branch:** origin/claude/vibrant-thompson-mwwucr

