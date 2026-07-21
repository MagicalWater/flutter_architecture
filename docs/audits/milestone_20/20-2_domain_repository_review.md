# Milestone 20-2 Domain、Repository與UseCase Implementation Review

狀態：Completed / Reviewed。

Review範圍：OTP Domain union、challenge validation、Verify / Resend use cases、RemoteDataSource endpoint-aware failure mapping、typed OTP failure metadata、Repository authenticated-only commit boundary、latest-intent generation、Secure credential / User / Session side-effect ordering及既有Auth regression。

---

## 1. Implemented Contract

- Password Login回傳`AuthLoginResult.authenticated`或`AuthLoginResult.otpChallenge`，不以nullable欄位推斷variant。
- `AuthAuthenticatedResult`是唯一credential-bearing Domain payload；`OtpChallenge`不包含password、OTP code、完整destination或provider identity。
- `OtpChallenge`拒絕blank identity、blank masked destination、non-UTC timestamps與negative attempts metadata。
- Repository公開狹窄`login`、`verifyOtp`與`resendOtp`行為；UseCase維持一個business action一個class。
- OTP backend failure以typed `OtpFailureDetails`攜帶`attemptsRemaining`或authoritative `retryAt`，Presentation不得解析free-form message。

## 2. Credential Commit Boundary

Direct Login authenticated與Verify success共用同一authenticated commit helper：

```txt
lifecycle operation current
  → Secure credential write
  → lifecycle operation current
  → AuthUser write
  → lifecycle operation current
  → SessionManager.setAuthenticated
```

Login challenge與Resend replacement不進Secure credential、AuthUser或Session mutation。既有Milestone 19 cleanup / compensation policy維持不變。

## 3. Concurrency Review

Repository在Login、Verify與Resend remote call前取得共用lifecycle operation。Review已驗證：

- Verify → newer Login：舊Verify不得保存credential或覆蓋新Session。
- Verify → newer Resend：舊Verify不得保存credential或建立Session。
- Verify → newer Logout：舊Verify不得在Logout後復活Session。
- Resend只回傳replacement challenge，不產生persistence side effect。

Bloc active challenge identity仍留待20-3，且只保護presentation metadata；Repository generation已在credential commit前封鎖stale authenticated response。

## 4. Failure and Security Review

- `otp_invalid_code`支援有或無`attemptsRemaining`。
- `otp_challenge_expired`、`otp_too_many_attempts`、`otp_resend_cooldown`及`otp_challenge_invalidated`均有stable typed identity。
- Malformed cooldown metadata進`AppExceptionKind.protocol`，不降級成一般transport failure。
- Unknown error保留原始identity與stack。
- Domain result、challenge與failure details的`toString()`不展開credential、challenge identity或transition metadata。

## 5. Review Findings

| ID | Severity | Finding | Resolution |
|---|---|---|---|
| M20-2-R01 | P1 | 初版只在Bloc接收Verify結果後判斷challenge，可能已來不及阻止Repository side effect。 | Repository在remote call前取得generation，並於Secure、User、Session每個commit boundary前驗證。Closed。 |
| M20-2-R02 | P1 | 既有Login tests仍假設單一`AuthResult`，無法驗證challenge zero-side-effect contract。 | 全部遷移至`AuthLoginResult`並新增challenge、Verify及Resend Repository tests。Closed。 |
| M20-2-R03 | P2 | Optional attempts metadata若以message承載，UI將依賴不穩定字串。 | 新增typed `OtpFailureDetails`，invalid code可明確表達known或unknown attempts。Closed。 |
| M20-2-R04 | P2 | Orphan Freezed generated file可能讓已改為manual sealed union的source of truth不清楚。 | 移除`auth_result.freezed.dart`，Domain union只保留單一手寫authority。Closed。 |

Final Review結論：無Open P0 / P1。20-2可標記Completed / Reviewed；下一步為20-3 Bloc Concurrency與Latest Challenge Ordering。本階段未新增OTP route、UI、provider SDK、Native設定或VERSION變更。

## 6. Verification

- OTP Domain / Remote Mapping / Repository targeted：16項tests通過。
- Workspace五個packages analyze：通過。
- Workspace完整Flutter tests：api_client 55、auth 144、core 4、design_system 43、flutter_architecture 324，共570項通過。
- `git diff --check`：通過。
