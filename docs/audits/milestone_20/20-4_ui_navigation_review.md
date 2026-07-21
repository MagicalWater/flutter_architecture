# Milestone 20-4 UI、Navigation與Protected Route Review

狀態：Reviewed / Closed。

## Scope

- OTP page、localized failure presentation與resend countdown。
- App-owned Login / OTP / Profile navigation integration。
- Protected Route在OTP pending狀態的Session authority regression。

## Review Findings

1. OTP code只存在TextEditingController與event payload，不寫入persistence、不記錄log。
2. 輸入限制為digits-only並提供`AutofillHints.oneTimeCode`；Verify / Resend busy時按鈕停用。
3. Countdown只根據authoritative `resendAvailableAt`顯示，不成為domain authority。
4. OTP failure copy只讀typed `OtpFailureDetails`，不解析backend message。
5. Navigation由App composition layer依AuthState決定；OTP Page不持有Shell tab或跨feature route決策。
6. Replacement challenge destination仍是OTP，因此不重複replace route。
7. OTP pending的Session為null；既有AuthGuard仍拒絕Protected Route並導向Login。

## Verification

- OTP page與navigation targeted tests：14項通過。
- Workspace五個packages analyze：通過。
- Full tests：API Client 55、Auth 144、Core 4、Design System 43、App 338，共584項通過。
- `git diff --check`：通過。
- VERSION維持1.3.0。

Milestone 20-4 review結論：無Open P0 / P1，可進入20-5 Security Review、Regression與封存。
