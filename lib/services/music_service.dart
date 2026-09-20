import 'package:url_launcher/url_launcher.dart';

/// Spotify first, YouTube fallback. All free, no SDK keys.
class MusicService {
  static Future<void> play(String query, String? youtubeUrl) async {
    final q = Uri.encodeComponent(query);
    final spotifyDeeplink = Uri.parse('spotify:search:$q');
    final spotifyWeb = Uri.parse('https://open.spotify.com/search/$q');

    if (await canLaunchUrl(spotifyDeeplink)) {
      await launchUrl(spotifyDeeplink, mode: LaunchMode.externalApplication);
      return;
    }
    if (await canLaunchUrl(spotifyWeb)) {
      // If Spotify app handles https links it opens the app, else browser.
      // Prefer explicit YouTube only when Spotify truly unavailable below.
      try {
        await launchUrl(spotifyWeb, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {
        // fall through to YouTube
      }
    }
    if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
      final u = Uri.parse(youtubeUrl);
      if (await canLaunchUrl(u)) {
        await launchUrl(u, mode: LaunchMode.externalApplication);
      }
    }
  }
}
