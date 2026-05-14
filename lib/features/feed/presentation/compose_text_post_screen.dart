import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../data/create_text_post.dart';

/// Text-only post composer (stored in Firestore `users/{uid}/textPosts`).
class ComposeTextPostScreen extends StatefulWidget {
  const ComposeTextPostScreen({super.key});

  @override
  State<ComposeTextPostScreen> createState() => _ComposeTextPostScreenState();
}

class _ComposeTextPostScreenState extends State<ComposeTextPostScreen> {
  final _bodyCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in to post text.')));
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await createTextPost(body: _bodyCtrl.text);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Text post published.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Text post'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: p.brandCyan,
                    ),
                  )
                : Text(
                    'Post',
                    style: textTheme.titleSmall?.copyWith(
                      color: p.brandPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text only — write your update below.',
                style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _bodyCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: textTheme.bodyLarge?.copyWith(color: p.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Write something…',
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: p.textMuted,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: p.cardBorderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: p.cardBorderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: p.chipSelectedBorder),
                    ),
                    filled: true,
                    fillColor: p.card,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
