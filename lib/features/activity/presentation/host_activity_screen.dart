import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../map/data/activity_geo.dart';
import '../../map/presentation/meeting_spot_map_picker_screen.dart';
import '../data/create_activity.dart';
import '../domain/activity_categories.dart';

/// Host flow: step-by-step post to Firestore (`activities` collection).
class HostActivityScreen extends StatefulWidget {
  const HostActivityScreen({super.key});

  @override
  State<HostActivityScreen> createState() => _HostActivityScreenState();
}

class _HostActivityScreenState extends State<HostActivityScreen> {
  final _titleCtrl = TextEditingController();
  final _spotCtrl = TextEditingController();
  int _typeIndex = 0;
  int _maxCapacity = 6;
  bool _capacityUnlimited = false;
  static const int _absMin = 2;
  static const int _absMax = 30;
  bool _goLive = true;
  late DateTime _startsAt;
  bool _posting = false;
  int _step = 0;
  late LatLng _meetingPin;

  static const _stepLabels = ['What', 'When & where', 'Publish'];

  static IconData _iconForCategory(String label) {
    return switch (label) {
      'Sports' => Icons.sports_basketball_outlined,
      'Coffee' => Icons.local_cafe_outlined,
      'Social' => Icons.groups_2_outlined,
      'Outdoor' => Icons.terrain_outlined,
      'Gym' => Icons.fitness_center_outlined,
      'Study' => Icons.menu_book_outlined,
      'Food' => Icons.restaurant_outlined,
      'Music' => Icons.music_note_outlined,
      'Other' => Icons.more_horiz,
      _ => Icons.label_outline,
    };
  }

  static final List<(String label, IconData icon)> _types = [
    for (final c in kActivityCategoryValues) (c, _iconForCategory(c)),
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
    _meetingPin = ActivityGeo.davaoAreaCenter;
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

  Future<void> _pickMeetingSpotOnMap() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(
        builder: (ctx) =>
            MeetingSpotMapPickerScreen(initialPosition: _meetingPin),
      ),
    );
    if (picked != null && mounted) setState(() => _meetingPin = picked);
  }

  String _meetingPinShortLabel() {
    final lat = _meetingPin.latitude.toStringAsFixed(4);
    final lng = _meetingPin.longitude.toStringAsFixed(4);
    return '$lat, $lng';
  }

  void _goNext() {
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    if (_step == 0) {
      if (_titleCtrl.text.trim().isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Add a short title for your activity.')),
        );
        return;
      }
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      if (_spotCtrl.text.trim().isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Add where people should meet.')),
        );
        return;
      }
      if (!_startsAt.isAfter(DateTime.now())) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Choose a start time in the future.')),
        );
        return;
      }
      setState(() => _step = 2);
    }
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    if (_step > 0) setState(() => _step--);
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
        latitude: _meetingPin.latitude,
        longitude: _meetingPin.longitude,
        category: _types[_typeIndex].$1,
        capacity: _capacityUnlimited
            ? (_maxCapacity >= _absMin ? _maxCapacity : _absMin)
            : _maxCapacity,
        capacityUnlimited: _capacityUnlimited,
        isLive: _goLive,
        startsAt: _startsAt,
      );
      if (!mounted) return;
      final nav = Navigator.of(context);
      if (nav.canPop()) {
        nav.pop(true);
        return;
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Activity posted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _titleCtrl.clear();
      _spotCtrl.clear();
      setState(() {
        _maxCapacity = 6;
        _capacityUnlimited = false;
        _typeIndex = 0;
        _step = 0;
        _meetingPin = ActivityGeo.davaoAreaCenter;
      });
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
    final p = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.cardBorderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New activity',
                  style: textTheme.titleLarge?.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Step ${_step + 1} of 3 · ${_stepLabels[_step]}',
                  style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / 3,
                    minHeight: 6,
                    backgroundColor: p.chipBorder,
                    color: p.liveAccent,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: KeyedSubtree(
                    key: ValueKey<int>(_step),
                    child: switch (_step) {
                      0 => _buildStepWhat(context, textTheme),
                      1 => _buildStepWhenWhere(context, textTheme),
                      _ => _buildStepPublish(context, textTheme),
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildNavRow(context, textTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepWhat(BuildContext context, TextTheme textTheme) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a category and a clear title so people know what to expect.',
          style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: 16),
        const _SectionLabel(text: 'ACTIVITY TYPE'),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? p.chipSelectedBorder : p.chipBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected ? p.textPrimary : p.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        color: selected ? p.textPrimary : p.textMuted,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 22),
        const _SectionLabel(text: 'TITLE'),
        const SizedBox(height: 8),
        TextField(
          controller: _titleCtrl,
          textInputAction: TextInputAction.next,
          style: textTheme.bodyLarge?.copyWith(color: p.textPrimary),
          decoration: _fieldDecoration(
            context,
            hint: 'Short headline, e.g. Need one more for doubles',
          ),
        ),
      ],
    );
  }

  Widget _buildStepWhenWhere(BuildContext context, TextTheme textTheme) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick a start time and where everyone should gather.',
          style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: 16),
        const _SectionLabel(text: 'STARTS'),
        const SizedBox(height: 8),
        _StaticPickerRow(
          icon: Icons.schedule_outlined,
          label: _startsPickerLabel(),
          onTap: _pickStarts,
        ),
        const SizedBox(height: 20),
        const _SectionLabel(text: 'MEETING SPOT'),
        const SizedBox(height: 8),
        TextField(
          controller: _spotCtrl,
          textInputAction: TextInputAction.done,
          style: textTheme.bodyLarge?.copyWith(color: p.textPrimary),
          decoration: _fieldDecoration(
            context,
            hint: 'Place name or address detail',
          ),
        ),
        const SizedBox(height: 10),
        _StaticPickerRow(
          icon: Icons.map_outlined,
          label: 'Pin on map · ${_meetingPinShortLabel()}',
          onTap: _pickMeetingSpotOnMap,
        ),
      ],
    );
  }

  Widget _buildStepPublish(BuildContext context, TextTheme textTheme) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set size, visibility, then post when you are ready.',
          style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.chipBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick preview',
                style: textTheme.labelLarge?.copyWith(
                  color: p.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _titleCtrl.text.trim().isEmpty ? '—' : _titleCtrl.text.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _startsPickerLabel(),
                style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                _spotCtrl.text.trim().isEmpty ? '—' : _spotCtrl.text.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _capacityUnlimited,
          onChanged: (v) => setState(() {
            _capacityUnlimited = v;
            if (!v && _maxCapacity < _absMin) {
              _maxCapacity = _absMin;
            }
          }),
          title: Text(
            'No max limit',
            style: textTheme.titleSmall?.copyWith(
              color: p.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'Anyone can join until you turn this off.',
            style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          activeThumbColor: p.liveAccent,
          activeTrackColor: p.liveAccent.withValues(alpha: 0.35),
        ),
        if (!_capacityUnlimited) ...[
          const SizedBox(height: 8),
          const _SectionLabel(text: 'MAX ATTENDEES'),
          const SizedBox(height: 8),
          Text(
            'Tap − or + to set the cap. Range $_absMin–$_absMax.',
            style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Material(
                color: p.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _maxCapacity > _absMin
                      ? () => setState(() => _maxCapacity--)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.remove,
                      color: _maxCapacity > _absMin
                          ? p.textPrimary
                          : p.textMuted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$_maxCapacity',
                      style: textTheme.headlineMedium?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'max spots',
                      style: textTheme.bodySmall?.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              Material(
                color: p.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _maxCapacity < _absMax
                      ? () => setState(() => _maxCapacity++)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.add,
                      color: _maxCapacity < _absMax
                          ? p.textPrimary
                          : p.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.streakCalloutBg.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: p.streakCalloutBorder.withValues(alpha: 0.5),
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
                        color: p.streakCalloutTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Highlights on the feed for things starting soon.',
                      style: textTheme.bodySmall?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _goLive,
                activeThumbColor: p.liveAccent,
                activeTrackColor: p.liveAccent.withValues(alpha: 0.35),
                onChanged: (v) => setState(() => _goLive = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavRow(BuildContext context, TextTheme textTheme) {
    final p = context.palette;
    final isLast = _step == 2;

    return Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _posting ? null : _goBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: p.textPrimary,
                side: BorderSide(color: p.chipBorder),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          flex: _step > 0 ? 2 : 1,
          child: isLast
              ? GradientCtaButton(
                  onPressed: _posting ? null : _postActivity,
                  child: _posting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Post activity'),
                )
              : GradientCtaButton(
                  onPressed: _goNext,
                  child: const Text('Continue'),
                ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, {required String hint}) {
    final p = context.palette;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: p.textMuted),
      filled: true,
      fillColor: p.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.chipBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.chipBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: p.liveAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = context.palette;
    return Text(
      text,
      style: textTheme.labelLarge?.copyWith(
        color: p.textMuted,
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
    final p = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.chipBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: p.textSecondary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: p.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
