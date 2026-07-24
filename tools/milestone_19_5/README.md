# Milestone 19.5 Auth Fixture Tooling

本目錄是Milestone 19.5留下的historical manual fixture tooling，不屬於current App runtime、一般CI test discovery或production Auth implementation。

用途：

- 啟動受控Auth fixture server，支援當時的Android／local acceptance流程。
- 驗證fixture server state、request與response contract。
- 保留歷史reproduction能力。

正確測試命令：

```bash
cd tools/milestone_19_5
python3 -m unittest test_auth_fixture_server.py
```

正確啟動方式：

```bash
cd tools/milestone_19_5
python3 auth_fixture_server.py
```

此工具不應由repository root的`python3 -m unittest discover -s tools/ci`執行，也不應被當成current Auth API mock authority。未來只有在刪除對應historical acceptance evidence且已有replacement reproduction方式時，才能移除本目錄。

