# Run Seqotia locally

From the project root, use one command:

```powershell
.\scripts\run_seqotia.ps1
```

It targets the only active Flutter entry point, `lib/main.dart`, and confirms
that the local Seqotia API is available at `http://127.0.0.1:8000`. If the API
is not running, it starts it against `backend/seqotia-dev.db`.

After any code change, stop the previous `flutter run` session and run the
command again. A browser refresh alone does not replace a Flutter process that
was launched from an earlier source snapshot.

`FromAI/main.dart` and `Mask/` are reference/prototype files, not a second
Flutter project. Do not pass either file as Flutter's `-t` target.
