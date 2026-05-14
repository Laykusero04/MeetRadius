import 'dart:math' show max, min;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../map/data/activity_geo.dart';
import '../../map/presentation/meeting_spot_map_picker_screen.dart';
import '../data/delete_activity.dart';
import '../data/update_activity.dart';
import '../domain/activity.dart';
import '../domain/activity_categories.dart';

/// Single-screen edit for an activity the current user hosts.
class EditActivityScreen extends StatefulWidget {
  const EditActivityScreen({super.key, required this.activity});

  final Activity activity;

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _spotCtrl;
  late int _typeIndex;
  late int _maxCapacity;
  late bool _capacityUnlimited;
  late bool _goLive;
  late DateTime _startsAt;
  bool _busy = false;
  late LatLng _meetingPin;

  static const int _capacityMax = 30;

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

  int get _maxCapacityHostFloor {
    final j = widget.activity.joinedCount;
    return j < 2 ? 2 : j;
  }

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    _titleCtrl = TextEditingController(text: a.title);
    _spotCtrl = TextEditingController(text: a.spot);
    final idx = kActivityCategoryValues.indexOf(a.category);
    _typeIndex = idx >= 0 ? idx : kActivityCategoryValues.indexOf('Other');
    _goLive = a.isLive;
    _startsAt = a.startsAt;
    _capacityUnlimited = a.capacityUnlimited;
    final floor = _maxCapacityHostFloor;
    _maxCapacity = max(floor, min(_capacityMax, a.capacity)).clamp(
      floor,
      _capacityMax,
    );
    _meetingPin = (a.latitude != null && a.longitude != null)
        ? LatLng(a.latitude!, a.longitude!)
        : ActivityGeo.jitterFromActivityId(a.id);
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
    if (_busy) return;
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

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final spot = _spotCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (title.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add a title for your activity.')),
      );
      return;
    }
    if (spot.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add where people should meet.')),
      );
      return;
    }
    if (!_goLive && !_startsAt.isAfter(DateTime.now())) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'For upcoming activities, pick a start time in the future.',
          ),
        ),
      );
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Sign in to save changes.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await updateActivity(
        activityId: widget.activity.id,
        title: title,
        spot: spot,
        latitude: _meetingPin.latitude,
        longitude: _meetingPin.longitude,
        category: _types[_typeIndex].$1,
        capacity: _capacityUnlimited
            ? max(_maxCapacityHostFloor, _maxCapacity)
            : _maxCapacity,
        capacityUnlimited: _capacityUnlimited,
        isLive: _goLive,
        startsAt: _startsAt,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Activity updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final p = context.palette;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: p.card,
          title: Text(
            'Delete activity?',
            style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'This removes it for everyone on the feed and map. This cannot be undone.',
            style: TextStyle(color: p.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: p.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: p.liveAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await deleteActivity(widget.activity.id);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Activity deleted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
  }) {
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.scaffold,
      appBar: AppBar(
        title: const Text('Edit activity'),
        backgroundColor: p.scaffold,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              Text(
                'Update details anytime. Max attendees cannot go below how many people already joined.',
                style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 20),
              const _EditSectionLabel(text: 'ACTIVITY TYPE'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_types.length, (i) {
                  final selected = i == _typeIndex;
                  final (label, icon) = _types[i];
                  return GestureDetector(
                    onTap: _busy ? null : () => setState(() => _typeIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
              const _EditSectionLabel(text: 'TITLE'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                enabled: !_busy,
                textInputAction: TextInputAction.next,
                style: textTheme.bodyLarge?.copyWith(color: p.textPrimary),
                decoration: _fieldDecoration(context, hint: 'Short headline'),
              ),
              const SizedBox(height: 20),
              const _EditSectionLabel(text: 'STARTS'),
              const SizedBox(height: 8),
              _EditPickerRow(
                icon: Icons.schedule_outlined,
                label: _startsPickerLabel(),
                onTap: _busy ? null : _pickStarts,
              ),
              const SizedBox(height: 20),
              const _EditSectionLabel(text: 'MEETING SPOT'),
              const SizedBox(height: 8),
              TextField(
                controller: _spotCtrl,
                enabled: !_busy,
                textInputAction: TextInputAction.done,
                style: textTheme.bodyLarge?.copyWith(color: p.textPrimary),
                decoration: _fieldDecoration(
                  context,
                  hint: 'Place name or address detail',
                ),
              ),
              const SizedBox(height: 10),
              _EditPickerRow(
                icon: Icons.map_outlined,
                label: 'Pin on map · ${_meetingPinShortLabel()}',
                onTap: _busy ? null : _pickMeetingSpotOnMap,
              ),
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _capacityUnlimited,
                onChanged: _busy
                    ? null
                    : (v) => setState(() {
                          _capacityUnlimited = v;
                          if (!v && _maxCapacity < _maxCapacityHostFloor) {
                            _maxCapacity = _maxCapacityHostFloor.clamp(
                              2,
                              _capacityMax,
                            );
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
                  'Unlimited joins; max still stored for when you turn this off.',
                  style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
                ),
                activeThumbColor: p.liveAccent,
                activeTrackColor: p.liveAccent.withValues(alpha: 0.35),
              ),
              if (!_capacityUnlimited) ...[
                const SizedBox(height: 12),
                const _EditSectionLabel(text: 'MAX ATTENDEES'),
                const SizedBox(height: 8),
                Text(
                  'At least $_maxCapacityHostFloor (joined). Tap − or + up to $_capacityMax.',
                  style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Material(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _busy || _maxCapacity <= _maxCapacityHostFloor
                            ? null
                            : () => setState(() => _maxCapacity--),
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.remove,
                            color: _maxCapacity > _maxCapacityHostFloor && !_busy
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
                            'max',
                            style: textTheme.labelSmall?.copyWith(
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _busy || _maxCapacity >= _capacityMax
                            ? null
                            : () => setState(() => _maxCapacity++),
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.add,
                            color: _maxCapacity < _capacityMax && !_busy
                                ? p.textPrimary
                                : p.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
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
                            'Shows prominently on the feed.',
                            style: textTheme.bodySmall?.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _goLive,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _goLive = v),
                      activeThumbColor: p.liveAccent,
                      activeTrackColor: p.liveAccent.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: TextButton.icon(
                  onPressed: _busy ? null : _confirmDelete,
                  icon: Icon(Icons.delete_outline, color: p.liveAccent),
                  label: Text(
                    'Delete activity',
                    style: textTheme.titleSmall?.copyWith(
                      color: p.liveAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: GradientCtaButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditSectionLabel extends StatelessWidget {
  const _EditSectionLabel({required this.text});

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

class _EditPickerRow extends StatelessWidget {
  const _EditPickerRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

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
