# Milestone 20-1 API、DTO與Stateful Mock Implementation Review

狀態：Completed / Reviewed。

## Scope

- Password Login discriminated typed union。
- OTP Verify / Resend Retrofit contract與request / response DTO。
- Sensitive transport model `toString()` boundary。
- Auth-specific stateful deterministic Mock。
- 既有Auth mapper、tests與App API selector的phase-boundary compatibility。

## Implemented contract

- Login wire result只能是`authenticated`或`otpChallenge`。
- Verify成功只回`AuthenticatedResponseDto`。
- Resend成功只回完整replacement `OtpChallengeDto`。
- Challenge使用absolute UTC expiration與resend availability，並攜帶optional attempts metadata。
- Password、OTP code、token與raw challenge identity不會透過Freezed欄位型`toString()`輸出。
- Retrofit新增`/auth/otp/verify`與`/auth/otp/resend`。

## Stateful Mock behavior

- 一般帳號直接authenticated；`otp@example.com`進入OTP challenge。
- Clock、response delay、TTL、cooldown與attempt limit均可注入或設定。
- 支援correct code、invalid code、attempt exhaustion、expiration與cooldown。
- Resend建立新challenge identity並立即invalidate predecessor。
- 已消耗、過期或被替換的challenge不能再次Verify或Resend。
- Mock failure使用HTTP status與stable backend code / typed metadata，供20-2 endpoint-aware mapping使用。

## Review findings and corrections

1. 初版nested union serialization沒有explicit nested mapping，round-trip test失敗；已改為明確`JsonKey` converter。
2. 初版Mock尚未實作Verify / Resend，API package無法compile；已完成stateful implementation。
3. 初版async exception matcher直接比對Future，未驗證throw identity；已改為`throwsA`並重跑。
4. Mock constructor新增duration與attempt invariant assertions，避免建立非法fixture。
5. Typed Login union造成既有Auth mapper與test fixture compile break；已加入authenticated-only phase-boundary mapper與fixture migration。Challenge domain mapping仍明確留在20-2，不會誤進credential persistence。

## Verification

- `packages/api_client`完整55項tests通過。
- Workspace五個packages `flutter analyze`通過。
- Workspace完整tests通過：Core 4、Design System 43、API Client 55、Auth 128、App 324，共554項。
- `git diff --check`通過。

## Gate result

- 無Open P0 / P1 implementation finding。
- `M20-PR05`的Stateful Mock disposition已完成。
- `M20-PR01` wire contract與`M20-PR07` transport sentinel部分已完成；Domain / Repository與完整security closure留在20-2 / 20-5。
- `M20-PR10` wire metadata已完成；Domain failure details與Presentation transition留在20-2 / 20-3。
- VERSION維持1.3.0；未加入UI、Navigation、SMS provider SDK或Native設定。

Milestone 20-1正式Completed / Reviewed。下一步為20-2，不在本階段提前實作。
