// Central config. No secrets committed — override with --dart-define.
class AppConfig {
  // Defaults to existing lisa-v2 backend so app works immediately for free.
  // Switch to your free backend_mobile URL via --dart-define=LISA_BACKEND_URL=...
  static const backendUrl = String.fromEnvironment(
    'LISA_BACKEND_URL',
    defaultValue: 'https://lisa-v2.onrender.com',
  );

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://faisenguexvmwujyfxio.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhaXNlbmd1ZXh2bXd1anlmeGlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ5NjQ5MjksImV4cCI6MjEwMDU0MDkyOX0.7ZHMkPrVQrU5o9QfMp7F5ajDakxJnKj2A9Y8UHOzcWY',
  );

  // Free on-device wake phrase. Porcupine upgrade path documented in wake_service.
  static const wakePhrase = 'hey lisa';
  static const guestKey = 'lisa_guest_chat';
  static const voiceKey = 'lisa_voice';
  static const themeKey = 'lisa_theme';
  static const defaultVoice = 'en-US-AvaNeural';
}
