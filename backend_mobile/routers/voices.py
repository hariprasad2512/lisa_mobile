from fastapi import APIRouter
from services.llm_service import ALLOWED_VOICES, DEFAULT_VOICE

router = APIRouter(tags=["Voices"])

META = {
    "en-US-AvaNeural": {"label": "Ava — warm assistant", "locale": "en-US", "gender": "Female"},
    "en-US-AriaNeural": {"label": "Aria — natural news", "locale": "en-US", "gender": "Female"},
    "en-US-JennyNeural": {"label": "Jenny — friendly", "locale": "en-US", "gender": "Female"},
    "en-US-MichelleNeural": {"label": "Michelle — pleasant", "locale": "en-US", "gender": "Female"},
    "en-US-AnaNeural": {"label": "Ana — cute chat", "locale": "en-US", "gender": "Female"},
    "en-IN-NeerjaNeural": {"label": "Neerja — Indian English", "locale": "en-IN", "gender": "Female"},
}


@router.get("/voices")
async def list_voices():
    voices = [
        {"id": v, **META.get(v, {"label": v, "locale": "en-US", "gender": "Female"})}
        for v in sorted(ALLOWED_VOICES)
    ]
    return {"default": DEFAULT_VOICE, "voices": voices}
