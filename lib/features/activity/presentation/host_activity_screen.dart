import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/create_activity.dart';

/// Host flow: posts an activity to Firestore (`activities` collection).
class HostActivityScreen extends StatefulWidget {
  const HostActivityScreen({super.key});

  @override
  State<HostActivityScreen> createState() => _HostActivityScreenState();
}

class _HostActivityScreenState extends State<HostActivityScreen> {
  final _titleCtrl = TextEditingController(text: 'Pickup basketball — 2 spots');
  final _spotCtrl = TextEditingController(text: 'City Gym courts');
  int _typeIndex = 0;
  int _capacity = 6;
  bool _goLive = true;
  late DateTime _startsAt;
  bool _posting = false;

  static const _types = <(String label, IconData icon)>[
    ('Sports', Icons.sports_basketball_outlined),
    ('Coffee', Icons.local_cafe_outlined),
    ('Social', Icons.groups_2_outlined),
    ('Outdoor', Icons.terrain_outlined),
    ('Other', Icons.more_horiz),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, 18, 30);
    if (!candidate.isAfter(now)) {
      candidate = now.add(const Duration(hours: 1));
    }
    _startsAt = candidate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _spotCtrl.dispose();
    super.dispose();
  }

  String _startsPickerLabel() {
    final d = _startsAt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dDay = DateTime(d.year, d.month, d.day);
    final diff = dDay.difference(today).inDays;
    final dayPart = switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => '${d.month}/${d.day}/${d.year}',
    };
    final h24 = d.hour;
    final hour = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = h24 >= 12 ? 'PM' : 'AM';
    return '$dayPart · $hour:$min $ampm';
  }

  Future<void> _pickStarts() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final last = first.add(const Duration(days: 365));
    var initialDate = DateTime(_startsAt.year, _startsAt.month, _startsAt.day);
    if (initialDate.isBefore(first)) initialDate = first;
    if (initialDate.isAfter(last)) initialDate = last;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: first,
      lastDate: last,
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _startsAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _postActivity() async {
    final title = _titleCtrl.text.trim();
    final spot = _spotCtrl.text.trim();
    if (title.isEmpty || spot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and meeting spot.')),
      );
      return;
    }
    if (!_startsAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a start time in the future.')),
      );
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to post an activity.')),
      );
      return;
    }

    setState(() => _posting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await createActivity(
        title: title,
        spot: spot,
        category: _types[_typeIndex].$1,
        capacity: _capacity,
        isLive: _goLive,
        startsAt: _startsAt,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Activity posted — check the Feed tab.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(text: 'ACTIVITY TYPE', textTheme: textTheme),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_types.length, (i) {
                    final selected = i == _typeIndex;
                    final (label, icon) = _types[i];
                    return GestureDetector(
                      onTap: () => setState(() => _typeIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.chipSelectedBorder
                                : AppColors.chipBorder,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: selected
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: textTheme.labelLarge?.copyWith(
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),
                _SectionLabel(text: 'TITLE', textTheme: textTheme),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _fieldDecoration(
                    hint: 'Short headline, e.g. Need one more for doubles',
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: 'STARTS', textTheme: textTheme),
                const SizedBox(height: 8),
                _StaticPickerRow(
                  icon: Icons.schedule_outlined,
                  label: _startsPickerLabel(),
                  onTap: _pickStarts,
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: 'MEETING SPOT', textTheme: textTheme),
                const SizedBox(height: 8),
                TextField(
                  controller: _spotCtrl,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _fieldDecoration(
                    hint: 'Place name or address detail',
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel(text: 'MAX PEOPLE', textTheme: textTheme),
                const SizedBox(height: 4),
                Text(
                  '$_capacity (including you)',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Slider(
                  value: _capacity.toDouble(),
                  min: 2,
                  max: 12,
                  divisions: 10,
                  activeColor: AppColors.liveAccent,
                  inactiveColor: AppColors.chipBorder,
                  label: '$_capacity',
                  onChanged: (v) => setState(() => _capacity = v.round()),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.streakCalloutBg.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.streakCalloutBorder.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live activity',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.streakCalloutTitle,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Highlights on the feed for things starting soon.',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _goLive,
                        activeThumbColor: AppColors.liveAccent,
                        activeTrackColor: AppColors.liveAccent.withValues(
                          alpha: 0.35,
                        ),
                        onChanged: (v) => setState(() => _goLive = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _posting ? null : _postActivity,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.joinLive,
                      foregroundColor: AppColors.joinLiveForeground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _posting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.joinLiveForeground,
                            ),
                          )
                        : const Text('Post activity'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.chipBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.chipBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.liveAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.textTheme});

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.labelLarge?.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StaticPickerRow extends StatelessWidget {
  const _StaticPickerRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.chipBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
