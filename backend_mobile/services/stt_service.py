import os
import shutil
from fastapi import UploadFile, HTTPException
from groq import Groq
from dotenv import load_dotenv

load_dotenv()


async def transcribe_audio_service(file: UploadFile) -> str:
    tmp = f"temp_{file.filename}"
    try:
        with open(tmp, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        with open(tmp, "rb") as audio:
            client = Groq()
            transcription = client.audio.transcriptions.create(
                file=audio,
                model="whisper-large-v3",
                response_format="json",
                language="en",
                prompt="The user is an Indian speaker talking to Lisa, a mobile voice assistant.",
                temperature=0.0,
            )
        return transcription.text
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        try:
            if os.path.exists(tmp):
                os.remove(tmp)
        except Exception:
            pass
