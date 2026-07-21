# Milestone 20-3 Bloc Concurrency Review

狀態：Completed / Reviewed。

## Scope

- AuthBloc explicit OTP presentation state machine。
- Verify / Resend events and UseCase wiring。
- Latest presentation intent and active challenge ordering。
- Session clear invalidation, including null → null authority transition。
- Existing Login / Restore / Logout and navigation coordinator regression。

## Implemented Authority

`AuthPresentationStatus`明確區分：

```txt
unauthenticated
submitting
otpRequired
verifying
resending
authenticated
```

Bloc不再以nullable challenge推導流程authority。`OtpChallenge`只在OTP相關狀態保留，authenticated與authoritative clear都會移除challenge。

## Concurrency Boundary

- Repository lifecycle generation：唯一credential、AuthUser與Session side-effect authority。
- Bloc presentation generation：阻擋舊Login / Verify / Resend結果覆蓋較新UI intent。
- Active challenge identity：阻擋predecessor challenge response修改replacement challenge metadata。
- Bloc不嘗試回滾Repository已完成的Session commit。

## Review Findings and Fixes

1. 初版直接擴充AuthBloc constructor造成既有tests與DI大量破壞；修正為App-owned provider明確注入OTP UseCases，同時保留既有test construction compatibility。
2. 初版移除`isLoading`欄位會讓既有UI與navigation tests全面改寫；修正為保留compatibility field，但authority由`AuthPresentationStatus`明確決定。
3. DI generation一度因RegisterModule缺少AuthBloc import而產生InvalidType；已修正並重新生成configuration。
4. 補上Session原本為null時再次clear仍清除active OTP的regression。

## Evidence

- OTP Bloc targeted tests：9項通過。
- API Client：55項通過。
- Auth：144項通過。
- Core：4項通過。
- Design System：43項通過。
- App：333項通過。
- Workspace合計：579項tests通過。
- Workspace analyze：5 packages全部通過。
- `git diff --check`：通過。

## Conclusion

20-3完成並通過implementation review，無Open P0 / P1。20-4可在獨立工作中開始OTP UI、Route與Navigation整合；本階段未加入OTP Page、route或localization production implementation。
