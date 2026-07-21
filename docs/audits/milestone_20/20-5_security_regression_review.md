# Milestone 20-5 Security & Regression Review

狀態：Reviewed / Closed。

## Scope

本review涵蓋secret exposure、OTP race matrix、authenticated commit boundary、Session invalidation、navigation、Protected Route、generated code、full regression、Android release artifact與baseline decision。

## Security Findings

- Password、OTP code、Token與raw challenge identity均有transport、Domain或App event sentinel coverage。
- Production source search未發現`print`、`debugPrint`或logger輸出上述敏感值。
- `OtpChallenge.toString()`只輸出type identity，不輸出challengeId或masked destination。
- OTP code只存在UI controller與一次性Bloc event，不寫入SharedPreferences、SQLite、Secure Storage或Session。
- Repository generation仍是credential、User與Session commit authority；Bloc不承擔side-effect rollback。

## Regression Evidence

- Workspace analyze：五個packages全部通過。
- Flutter tests：Core 4、Design System 43、API Client 55、Auth 144、App 339，共585項全部通過。
- Race coverage：Login/Login、Verify/Login、Verify/Resend、Verify/Verify、Resend/Resend、Verify/Logout、account switch、external clear與Session null → null clear。
- Navigation coverage：Login challenge → OTP、replacement停留OTP、Verify success → Profile、clear → Login、OTP pending Protected Route拒絕。

## Android Artifact Evidence

- Command：`flutter build apk --release --dart-define=API_MODE=mock`
- Artifact：`apps/flutter_architecture/build/app/outputs/flutter-apk/app-release.apk`
- Size：59,042,017 bytes。
- SHA-256：`4ce541f5553979549ccd5a940cfd1c93da4abb7e6f7dca4c5a1fbbe8b395bc4e`。
- Android 15 / API 35 emulator：install成功、MainActivity成功啟動且無fatal exception。
- Device text-input automation未作為SMS delivery或full journey證據；完整journey由deterministic Mock、Repository、Bloc、widget與mounted router integration tests證明。

## Security Claim

本baseline只提供server-issued OTP step-up flow。它不宣稱防止SIM swap、SMS interception、provider compromise、rooted-device memory extraction或server compromise；Real API contract也不等同SMS provider delivery assurance。

## Conclusion

無Open P0 / P1。Milestone 20具備封存與MINOR baseline提升條件。
