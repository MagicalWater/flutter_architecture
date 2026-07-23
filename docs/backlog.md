# Backlog

本文件只記錄尚未承諾、延後處理或明確不在目前baseline範圍內的工作。已完成能力由Roadmap、Project Context、Architecture Decisions與CHANGELOG保存，不再重複列入Backlog。

## Future ideas

- WebSocket application example。
- Notification feature。
- Payment feature。
- Analytics adapter與事件治理範例。
- Firebase Crashlytics production adapter；目前僅有App-owned error reporting boundary，不引入Firebase dependency。

## Deferred commitments

- Production CI/CD extension：Milestone 24只建立repository quality gates與verification-only Android artifact；Store發布、production signing、release channel與environment promotion仍維持Deferred。
- Web、Windows、macOS與Linux runner、artifact與runtime support；目前Android與iOS為Supported，其餘平台維持Dependency-ready。
- Cryptographic Device Binding與Passkey；目前Baseline 1.7.0已提供credential-at-rest hardening、Server-issued OTP與Android／iOS local user-presence foundation，但仍未承諾rooted／jailbroken device、runtime memory或server compromise防護。
- Production signing與Store distribution：Android keystore、Apple Team／provisioning、AAB、IPA、TestFlight、App Store與Play Store workflow不由Milestone 26 native environment mapping承擔。

## Explicitly not planned in current baseline

- Generic Navigation Service或通用Coordinator framework。
- Generic Cache／Generic Pagination framework。
- 所有API自動寫入SQLite的generic HTTP cache。
- 未經產品需求支持的Firebase、支付、通知或analytics依賴。

## Scope rule

新項目若尚未進入正式Roadmap、沒有明確acceptance criteria或會擴大platform／infrastructure承諾，先放在本文件，不直接修改baseline。

完整 Feature 指南、通用 Troubleshooting 與 Architecture Evolution 不再以重複 idea 保留於 Backlog。這些方向已由正式 audit 判定目前不成立；未來只有在出現新的 confirmed gap 與獨立 evidence 時，才重新建立候選項目。
