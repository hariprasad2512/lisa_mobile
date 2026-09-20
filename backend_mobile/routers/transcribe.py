from fastapi import APIRouter, UploadFile, File
from services.stt_service import transcribe_audio_service

router = APIRouter(tags=["Speech-to-Text"])


@router.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    text = await transcribe_audio_service(file)
    return {"status": "success", "text": text}
