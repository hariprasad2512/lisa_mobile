# Lisa Mobile Backend (free tier)

Slim fork of lisa-v2 backend. `~/Desktop/lisa-v2` is never touched.
Free-focused: no torch/whisper (~2GB removed), uuid TTS files, `/health`, short answers.

## Endpoints
- `GET /` + `GET /health`
- `POST /transcribe` — Groq Whisper
- `POST /chat` — short-answer LLM + YouTube lookup
- `POST /speak {text, voice}` — female Edge-TTS only
- `GET /voices` — curated female list

## Run free
```bash
cd backend_mobile
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # add GROQ_API_KEY
uvicorn main:app --reload
```

## Deploy free (pick one)
- **Koyeb free**: new service → Dockerfile → `uvicorn main:app --host 0.0.0.0 --port 8000`, set `GROQ_API_KEY`.
- **Fly.io**: `fly launch`, keep 1 machine warm.
- **Render free**: same as before but slim image boots much faster.

## Keep warm free
Create a free cron at cron-job.org hitting `https://YOUR-URL/health` every 5 min.
The Flutter app also pings `/` on launch and shows Waking/Ready.
