# Milestone 21-1 Local User Presence Contract與App Adapter Review

狀態：Reviewed / Closed。

## Scope

- `packages/auth`純Dart `LocalUserPresenceVerifier` contract。
- Auth-owned capability、verification與operational failure taxonomy。
- App-only `local_auth` 3.0.2 dependency與isolated adapter。
- biometric-only、no device credential fallback與no background retry policy。
- App Composition Root lazy registration。
- Targeted tests、workspace analyze與完整regression。

本階段未修改startup restore、Session authority、Android Native configuration、route、UI或VERSION。

## Contract Conclusions

- `packages/auth`不依賴`local_auth`，也不暴露`BiometricType`、`LocalAuthExceptionCode`或platform plugin class。
- Capability只表達available、no hardware、not enrolled與temporarily unavailable。
- Verification只表達verified或typed rejection；plugin回傳`false`使用`notVerified`，不錯標為user cancellation。
- User / system cancel、temporary lockout、permanent lockout、not enrolled、no hardware與temporarily unavailable均有穩定Auth-owned identity。
- Unknown plugin / platform error包裝為`LocalUserPresenceOperationalException`，保留cause與caught stack，但`toString()`不展開plugin description。
- Adapter固定`biometricOnly: true`、`sensitiveTransaction: true`、`persistAcrossBackgrounding: false`；不允許PIN、pattern或passcode fallback。

## Composition Root

- App layer持有`LocalAuthentication`、`PluginLocalAuthGateway`與`LocalAuthUserPresenceVerifier`。
- `LocalUserPresenceVerifier`以lazy singleton註冊。
- 21-1只建立DI shape，startup與Auth navigation尚未消費verifier。

## Implementation Review Finding

| ID | Severity | Finding | Resolution |
|---|---|---|---|
| M21-1-R01 | P2 | `authenticate()`回傳`false`最初被映射為cancelled，但false只代表驗證未成功，不能推論使用者取消。 | 新增`LocalUserPresenceRejectionReason.notVerified`並以red→green regression修正。Closed。 |

無Open P0 / P1。

## Verification

- Contract targeted tests：3項通過。
- Adapter / DI targeted tests：8項通過。
- Workspace analyze：五個packages全部通過。
- Workspace Flutter tests：596項全部通過。
- `git diff --check`：提交前通過。
- Android Native、startup restore與VERSION diff：無變更。

## Finding Reconciliation

- `M21-PR03` package / App boundary：21-1 foundation已實作；完整finding待21-5 final reconciliation關閉。
- `M21-PR04` capability / policy分離：typed capability foundation已完成；enable policy仍屬21-2。
- `M21-PR05` plugin failure taxonomy：21-1 adapter mapping已完成；UI disposition仍屬21-4。
- 其他planning findings仍依原target phase維持Approved disposition，不提前標記Closed。

## Final Decision

Milestone 21-1 implementation與review gate通過。下一步為21-2 Enable / Disable Policy與Persistence；不得提前啟用startup biometric gate或修改Android Native configuration。
