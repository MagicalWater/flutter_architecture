# Milestone 20 OTP Step-Up Authentication Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立server-issued OTP challenge flow，確保OTP完成前不保存credential、不建立Session且所有舊response不能覆蓋最新Auth intent。

**Architecture:** 延伸既有Auth-specific Clean Architecture與`AuthStateMutationCoordinator`，以typed wire/domain unions、authenticated-only commit helper及App-owned navigation組成。Mock提供deterministic state machine；Real API只實作Retrofit contract，不引入provider SDK或Generic Authentication State Machine。

**Tech Stack:** Dart、Flutter、Freezed、json_serializable、Retrofit、Dio、flutter_bloc、auto_route、Melos。

---

## File Structure

- `packages/api_client/lib/src/models/`：Login union、OTP request / response與challenge DTO。
- `packages/api_client/lib/src/api/auth_retrofit_api.dart`：Login、Verify、Resend HTTP contract。
- `packages/api_client/lib/src/mocks/mock_auth_api.dart`：Auth-specific stateful deterministic Mock。
- `packages/auth/lib/src/domain/entities/`：`AuthLoginResult`、`AuthAuthenticatedResult`、`OtpChallenge`。
- `packages/auth/lib/src/domain/use_cases/`：Verify與Resend use cases。
- `packages/auth/lib/src/data/`：DTO mapping、remote calls、repository authenticated commit boundary與OTP failure mapping。
- `apps/flutter_architecture/lib/features/auth/presentation/`：OTP-aware Bloc、Page與localization。
- `apps/flutter_architecture/lib/app/navigation/`與`router/`：App-owned challenge navigation與OTP route。
- 對應package / app tests：serialization、repository side-effect、concurrency、navigation、widget與secret sentinel。

---

### Task 1: Typed Auth Wire Contract

**Files:**
- Modify: `packages/api_client/lib/src/api/auth_retrofit_api.dart`
- Replace: `packages/api_client/lib/src/models/login_response_dto.dart`
- Create: `packages/api_client/lib/src/models/authenticated_response_dto.dart`
- Create: `packages/api_client/lib/src/models/otp_challenge_dto.dart`
- Create: `packages/api_client/lib/src/models/verify_otp_request_dto.dart`
- Create: `packages/api_client/lib/src/models/resend_otp_request_dto.dart`
- Create: OTP backend error envelope / details DTO files under `packages/api_client/lib/src/models/`
- Test: `packages/api_client/test/auth_otp_contract_test.dart`

- [ ] Write failing serialization tests for both Login variants、Verify request、Resend replacement response、invalid-code attempts metadata與cooldown retry timestamp。
- [ ] Run `cd packages/api_client && flutter test test/auth_otp_contract_test.dart` and verify failure before source creation。
- [ ] Implement discriminated DTO union；credential / password / code-bearing models使用`@Freezed(toStringOverride: false)`。
- [ ] Add `/auth/otp/verify` and `/auth/otp/resend` Retrofit methods。
- [ ] Define a stable backend error envelope contract; do not require Presentation to parse message text。
- [ ] Run build runner for`packages/api_client` and verify generated files are produced only from source changes。
- [ ] Run targeted tests and `dart run melos run analyze`。
- [ ] Commit: `feat(auth): 建立OTP typed API contract`。

### Task 2: Stateful Deterministic Mock

**Files:**
- Modify: `packages/api_client/lib/src/mocks/mock_auth_api.dart`
- Test: `packages/api_client/test/mock_auth_otp_state_machine_test.dart`

- [ ] Write failing tests for direct authentication、challenge issuance、invalid code、expiration、attempt exhaustion、cooldown、replacement與predecessor invalidation。
- [ ] Implement an Auth-specific in-memory challenge registry with injectable UTC clock and deterministic delay controls。
- [ ] Ensure Resend always returns a new challengeId and invalidates predecessor。
- [ ] Run targeted Mock tests and API selector regression。
- [ ] Commit: `feat(auth): 新增Stateful OTP Mock流程`。

### Task 3: Domain Models and Use Cases

**Files:**
- Replace: `packages/auth/lib/src/domain/entities/auth_result.dart`
- Create: `packages/auth/lib/src/domain/entities/auth_authenticated_result.dart`
- Create: `packages/auth/lib/src/domain/entities/otp_challenge.dart`
- Create: `packages/auth/lib/src/domain/use_cases/verify_otp_use_case.dart`
- Create: `packages/auth/lib/src/domain/use_cases/resend_otp_use_case.dart`
- Modify: `packages/auth/lib/src/domain/repositories/auth_repository.dart`
- Modify: `packages/auth/lib/auth.dart`
- Test: `packages/auth/test/auth_otp_domain_contract_test.dart`

- [ ] Write failing tests that reject invalid challenge timestamps / blank identity and verify union exhaustiveness。
- [ ] Implement `AuthLoginResult.authenticated` / `otpChallenge` and immutable challenge model。
- [ ] Add narrow repository methods and one-use-case-per-business-action classes。
- [ ] Run package tests and analyze。
- [ ] Commit: `feat(auth): 建立OTP domain與use case contract`。

### Task 4: Remote Mapping and Failure Taxonomy

**Files:**
- Modify: `packages/auth/lib/src/data/data_sources/auth_remote_data_source.dart`
- Replace: `packages/auth/lib/src/data/mappers/login_response_dto_mapper.dart`
- Create: `packages/auth/lib/src/data/mappers/otp_challenge_dto_mapper.dart`
- Modify: relevant Core/Auth exception and failure identity files only where required by Decision 020 conventions。
- Test: `packages/auth/test/auth_otp_remote_mapping_test.dart`

- [ ] Write failing tests for malformed union、blank challengeId、invalid timestamp、invalid code with / without attempts metadata、expired、too many attempts、cooldown retryAt與invalidated backend codes。
- [ ] Implement endpoint-aware mapping; do not classify every401 aspassword invalid。
- [ ] Add typed OTP failure details for `attemptsRemaining` and `retryAt`; never encode transition metadata in free-form messages。
- [ ] Preserve unknown error identity and caught stack; expose onlysafe diagnostic codes。
- [ ] Run targeted tests and secret sentinel tests。
- [ ] Commit: `feat(auth): 定義OTP failure與mapping`。

### Task 5: Authenticated-only Repository Commit Boundary

**Files:**
- Modify: `packages/auth/lib/src/data/repositories/auth_repository_impl.dart`
- Modify: `packages/auth/lib/src/domain/use_cases/login_use_case.dart`
- Test: `packages/auth/test/auth_repository_otp_test.dart`
- Test: existing secure lifecycle and latest-intent tests。

- [ ] Write failing tests proving challenge Login performs zero Secure/User/Session writes。
- [ ] Write failing Verify success tests proving order isSecure credential → User → Session。
- [ ] Write failure / superseded tests proving no partial Session and Milestone 19 cleanup semantics remain intact。
- [ ] Write Verify → Resend、Verify → Login與Verify → Logout reversed-completion tests at Repository level, proving stale authenticated Verify cannot persist credentials before Bloc sees the response。
- [ ] Extract one private authenticated commit helper shared by direct Login and Verify。
- [ ] Begin a lifecycle operation before each Verify / Resend remote call; check operation current before entering commit and between Secure、User、Session steps。
- [ ] Implement Resend as pure challenge replacement with no persistence side effects。
- [ ] Run repository, migration, secure login and refresh regression suites。
- [ ] Commit: `feat(auth): 封閉OTP credential成功邊界`。

### Task 6: Bloc OTP State Machine and Concurrency

**Files:**
- Modify: `apps/flutter_architecture/lib/features/auth/presentation/bloc/auth_event.dart`
- Modify: `apps/flutter_architecture/lib/features/auth/presentation/bloc/auth_state.dart`
- Modify: `apps/flutter_architecture/lib/features/auth/presentation/bloc/auth_bloc.dart`
- Modify: app DI registration for new use cases。
- Test: `apps/flutter_architecture/test/features/auth/presentation/bloc/auth_otp_bloc_test.dart`

- [ ] Write transition tests forLogin challenge、Verify、Resend、terminal failures and account switch。
- [ ] Write reversed-completion tests forLogin/Login、Verify/Resend、Verify/Verify、Resend/Resend and Logout/external clear。
- [ ] Model explicit unauthenticated / submitting / otpRequired / verifying / resending / authenticated authority; do not inferchallenge from nullable fields。
- [ ] Reuse lifecycle generation before every Repository side-effect commit; apply active challenge identity checks only to Bloc presentation metadata and state transitions。
- [ ] Treat generation as Repository credential-commit authority and challenge identity as Bloc UI-metadata authority; do not rely on a post-Repository Bloc check to undo Session creation。
- [ ] Add an authoritative external-clear regression where Session is already null but OTP challenge is active; active challenge and in-flight operations must still be invalidated。
- [ ] Keepnetwork calls outside exclusive persistence section and keep countdown timer non-authoritative。
- [ ] Run Auth Bloc, SessionManager, navigation coordinator and latest-intent regressions。
- [ ] Commit: `feat(auth): 實作OTP Bloc state machine`。

### Task 7: OTP Route, UI and Localization

**Files:**
- Create: `apps/flutter_architecture/lib/features/auth/presentation/pages/otp_page.dart`
- Modify: `apps/flutter_architecture/lib/app/router/app_router.dart`
- Modify generated router through build runner only。
- Modify: Auth ARB files and generated localization through Flutter gen_l10n only。
- Modify: `apps/flutter_architecture/lib/features/auth/presentation/auth_failure_localization.dart`
- Test: `apps/flutter_architecture/test/features/auth/presentation/pages/otp_page_test.dart`

- [ ] Write widget tests for masked destination、code input、Verify loading、Resend cooldown、invalid / expired / too-many-attempts and retry。
- [ ] Implement accessible numeric/one-time-code input without logging or persisting code。
- [ ] Add English and`zh_TW` localized copy and OTP-specific failure mapping。
- [ ] Verify narrow viewport、2.0 text scale、Default/Ocean and Light/Dark representative coverage。
- [ ] Run gen_l10n / build runner, targeted widget tests and analyze。
- [ ] Commit: `feat(auth): 新增OTP驗證頁面`。

### Task 8: App-owned Navigation and Guard Integration

**Files:**
- Modify: `apps/flutter_architecture/lib/app/navigation/auth_navigation_coordinator.dart`
- Modify: `apps/flutter_architecture/lib/app/router/auth_guard.dart` only if tests require no-behavior-change clarification。
- Test: `apps/flutter_architecture/test/app/navigation/auth_navigation_coordinator_test.dart`
- Test: `apps/flutter_architecture/test/app/router/auth_guard_test.dart`
- Test: app navigation integration tests。

- [ ] Write failing tests for challenge → OTP route、replacement staying on OTP、Verify success → Profile and Logout / account switch leaving OTP。
- [ ] Prove OTP pending hasnull Session and Protected Route redirects to Login/Auth entry。
- [ ] Implement navigation inApp composition layer; OTP Page and Login Page must not import Shell tab or directly own cross-feature navigation。
- [ ] Run mounted router and app integration tests。
- [ ] Commit: `feat(auth): 整合OTP navigation與route guard`。

### Task 9: Security and Regression Gate

**Files:**
- Add or modify secret sentinel tests across `packages/api_client`, `packages/auth` and App。
- Modify: `docs/audits/milestone_20_planning_review.md` finding statuses only after evidence exists。

- [ ] Search production source for password、OTP code、token、raw challenge logging and generated field-toString risks。
- [ ] Run targeted race matrix, Login / Restore / Logout, secure persistence, Refresh single-flight / generation / replay and Protected Route tests。
- [ ] Run `dart pub get`、workspace build runner、analyze and full Flutter tests。
- [ ] Build Android release artifact and perform runtime smoke forMock full OTP journey; Real API evidence validates contract only and does not claimSMS delivery。
- [ ] Record exact test counts, artifact metadata and remaining findings。
- [ ] Commit: `test(auth): 完成Milestone 20安全與regression gate`。

### Task 10: Documentation, Final Review and Baseline Decision

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/project_context.md`
- Modify: `docs/architecture_decisions.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/backlog.md` if deferred scope changes。
- Create: final Milestone 20 review / runtime evidence documents decided by20-5。
- Modify: `VERSION` only if final review approves a new baseline。

- [ ] Reconcile all planning findings against implementation evidence。
- [ ] Confirm noOpen P0 / P1 and document accepted / deferred P2 / P3。
- [ ] Describe security claim narrowly: server-issued OTP step-up flow, notSIM-swap prevention or provider delivery assurance。
- [ ] Decide version only after all gates pass; planning and intermediate phases do not changeVERSION。
- [ ] Commit documentation and release separately when a release is approved。

---

## Plan Self-review

- Spec coverage：API、Domain、Repository、Bloc、Session、ordering、replacement、failure、Mock、Real boundary、UI、Navigation、Guard、security與release gate均有對應Task。
- Boundary consistency：只有`AuthAuthenticatedResult`可進credential / User / Session commit；`OtpChallenge`不進persistence。
- Ordering consistency：所有Auth intents共用既有lifecycle generation，OTP另加active challenge identity validation。
- Commit authority consistency：stale Verify在Repository commit前由generation阻擋；Bloc只負責stale challenge UI metadata，不承擔事後回滾credential。
- Failure metadata consistency：attemptsRemaining與retryAt使用typed details，不解析backend message。
- Scope consistency：未加入Biometric、Device Binding、Passkey、TOTP、Firebase Auth、provider SDK或Generic Authentication State Machine。
