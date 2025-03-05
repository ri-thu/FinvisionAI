import whisper
import tempfile
import os
from fastapi import FastAPI, UploadFile, File, HTTPException

# Initialize FastAPI app
app = FastAPI()

# Load Whisper model
try:
    device = "cpu"
    whisper_model = whisper.load_model("small").to(device)  # You can change to other models like "base" or "medium"
except Exception as e:
    raise RuntimeError(f"Error loading Whisper model: {e}")

# Helper function to extract text from audio
async def extract_text_from_audio(file: UploadFile) -> str:
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
        temp_audio.write(await file.read())
        temp_audio.flush()
        audio_path = temp_audio.name

    try:
        # Use Whisper to transcribe audio
        result = whisper_model.transcribe(audio_path)
        os.remove(audio_path)  # Cleanup the temporary audio file
        return result["text"].strip() if result["text"].strip() else "Unable to recognize speech"
    except Exception as e:
        os.remove(audio_path)
        raise HTTPException(status_code=500, detail=f"Audio transcription error: {str(e)}")
# API endpoint to analyze the audio and transcribe it
@app.post("/analyze_audio")
async def analyze_audio_endpoint(file: UploadFile = File(...)):
    """
    Extract text from uploaded audio file using Whisper.
    """
    text = await extract_text_from_audio(file)
    return {"transcribed_text": text}
   
