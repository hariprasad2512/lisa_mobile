from fastapi import APIRouter, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import Optional
from services.tts_service import generate_speech_service
import os

router = APIRouter(tags=["Voice (TTS)"])


class SpeakRequest(BaseModel):
    text: str
    voice: Optional[str] = None


def cleanup_file(file_path: str):
    if os.path.exists(file_path):
        try:
            os.remove(file_path)
        except Exception as e:
            print(f"Error deleting file: {e}")


@router.post("/speak")
async def speak_text(request: SpeakRequest, background_tasks: BackgroundTasks):
    try:
        # Clamp spoken text so mobile stays snappy.
        text = request.text[:600]
        output_file = await generate_speech_service(text, request.voice)
        background_tasks.add_task(cleanup_file, output_file)
        return FileResponse(output_file, media_type="audio/mpeg")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
