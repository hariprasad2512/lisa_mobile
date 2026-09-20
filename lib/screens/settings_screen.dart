import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../models.dart';
import '../services/api_service.dart';
import '../services/assistant_controller.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final AssistantController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _backend = TextEditingController();
  User? _user;

  @override
  void initState() {
    super.initState();
    _backend.text = widget.controller.api.base;
    _user = Supabase.instance.client.auth.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((e) async {
      if (!mounted) return;
      setState(() => _user = e.session?.user);
      final u = e.session?.user;
      if (u != null) {
        final merged = await AuthService.migrateGuest(u.id);
        widget.controller.messages = merged;
        widget.controller.userId = u.id;
      } else {
        widget.controller.userId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Lisa settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Voice (female only)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: c.voiceId,
            onChanged: (id) async {
              if (id != null) {
                await c.setVoice(id);
                setState(() {});
              }
            },
            child: Column(
              children: LisaVoice.all
                  .map((v) => RadioListTile<String>(
                        title: Text(v.label),
                        subtitle: Text(v.id),
                        value: v.id,
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 32),
          const Text('Backend (free tier)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _backend,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'https://your-free-backend...',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Default points to Render free. Deploy backend_mobile/ to Koyeb free '
            'for faster wake, then paste URL here. lisa-v2 is never modified.',
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final ok = await LisaApi(base: _backend.text.trim()).ping();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Backend reachable' : 'Backend not reachable yet')),
                );
              }
            },
            child: const Text('Test backend'),
          ),
          const Divider(height: 32),
          const Text('Account (same as web)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_user == null)
            FilledButton(
              onPressed: () => Supabase.instance.client.auth.signInWithOAuth(
                OAuthProvider.google,
                redirectTo: 'io.supabase.lisamobile://login',
              ),
              child: const Text('Sign in with Google'),
            )
          else
            ListTile(
              title: Text(_user!.email ?? 'Signed in'),
              trailing: TextButton(
                onPressed: () => Supabase.instance.client.auth.signOut(),
                child: const Text('Logout'),
              ),
            ),
          const SizedBox(height: 8),
          Text('Backend URL: ${AppConfig.backendUrl} • Wake: "${AppConfig.wakePhrase}"'),
        ],
      ),
    );
  }
}
