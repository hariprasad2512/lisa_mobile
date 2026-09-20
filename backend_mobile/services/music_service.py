import logging
import yt_dlp

logger = logging.getLogger(__name__)


def get_top_youtube_video(query: str) -> str | None:
    try:
        opts = {
            "quiet": True,
            "no_warnings": True,
            "extract_flat": "in_playlist",
            "skip_download": True,
            "noplaylist": True,
        }
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(f"ytsearch5:{query}", download=False)
            for entry in (info.get("entries") or []):
                if not entry:
                    continue
                vid = entry.get("id")
                page = entry.get("webpage_url")
                if vid:
                    return f"https://www.youtube.com/watch?v={vid}"
                if page:
                    return page
        return None
    except Exception as e:
        logger.error(f"YouTube lookup failed: {e}")
        return None
