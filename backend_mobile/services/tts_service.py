import uuid
import edge_tts
from services.llm_service import ALLOWED_VOICES, DEFAULT_VOICE


async def generate_speech_service(text: str, voice: str | None = None) -> str:
    choice = voice if voice in ALLOWED_VOICES else DEFAULT_VOICE
    output_file = f"lisa_{uuid.uuid4().hex}.mp3"
    communicate = edge_tts.Communicate(text, choice)
    await communicate.save(output_file)
    return output_file
