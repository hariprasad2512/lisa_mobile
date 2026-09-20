from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from routers import transcribe, chat, speak, voices

load_dotenv()

app = FastAPI(title="Lisa Mobile API (free tier)", version="3.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(transcribe.router)
app.include_router(chat.router)
app.include_router(speak.router)
app.include_router(voices.router)


@app.get("/")
async def root():
    return {"message": "Hello from Lisa Mobile! Free backend is running."}


@app.get("/health")
async def health():
    return {"status": "ok"}
