# Lisa Mobile 🎙️

Mobile version of [lisa-v2](https://lisa-v2.vercel.app/) — a Google-Assistant-style voice assistant
for Android/iOS, built with Flutter. The `lisa-v2` web project is never modified;
the app talks to its backend over HTTP.

## Features

- **Voice-first chat** — tap mic (or say “Hey Lisa”) → record → Groq Whisper
  transcription → Groq LLM answer → Edge-TTS voice playback.
- **lisa-v2 web look** — sticky header / chat / mic footer ported from
  `https://lisa-v2.vercel.app`, including the Playlist Script wordmark and the
  red `Listening... / PRESS AGAIN TO STOP` mic state.
- **Female voice picker** — Ava, Aria, Jenny, Michelle, Ana + Indian-English
  Neerja, each with a tap-to-play sample (Settings).
- **“Hey Lisa” wake-word** — free on-device listening, triggers the sticky
  footer inline (no overlay).
- **Music** — tries Spotify app first, falls back to the backend’s YouTube link.
- **Memory** — guest chat stored on-device; Google sign-in (Supabase) migrates
  it to the cloud, same as web.
- **Location-aware** — attaches coordinates only for weather/nearby-style
  questions, same keyword gate as web.
- **Short answers** — backend prompt tuned for 1–2 sentence spoken replies.

## Branches

| Branch    | Purpose                                  |
|-----------|------------------------------------------|
| `main`    | Stable releases (this README lives here) |
| `develop` | Active development, merged into `main`   |

## Backend

Default: `https://lisa-v2.onrender.com` (free Render tier — first request after
idle can take ~30–60s to wake; the app shows `Waking up server...`).

`backend_mobile/` is a slim, free-tier-friendly fork (no torch/whisper,
`/health`, `/voices`, voice param, short-answer prompt, `Dockerfile`) ready to
deploy on Koyeb / Fly.io free tiers. Point the app at it via:

```bash
flutter run --dart-define=LISA_BACKEND_URL=https://YOUR-URL
```

## Run (Android)

```bash
flutter pub get
flutter run -d <device-id> --dart-define=LISA_BACKEND_URL=https://lisa-v2.onrender.com
```

Grant microphone + location when prompted.

## Credits

- Playlist Script font by Artimasa (free for personal & commercial use),
  bundled under `assets/fonts/`.
- AI: Groq (Whisper + `openai/gpt-oss-120b`), Microsoft Edge-TTS.
