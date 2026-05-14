import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Google / Apple maps for an exact coordinate pin.
Future<void> showActivityMapsActionSheet(
  BuildContext context, {
  required double latitude,
  required double longitude,
  required String placeLabel,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.directions_outlined),
                title: const Text('Directions in Google Maps'),
                subtitle: const Text('Turn-by-turn from your location'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await _openUri(
                    Uri.parse(
                      'https://www.google.com/maps/dir/?api=1'
                      '&destination=$latitude,$longitude&travelmode=driving',
                    ),
                  );
                  if (!ok && context.mounted) {
                    messenger?.showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Google Maps.'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Open pin in Google Maps'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await _openUri(
                    Uri.parse(
                      'https://www.google.com/maps/search/?api=1'
                      '&query=$latitude,$longitude',
                    ),
                  );
                  if (!ok && context.mounted) {
                    messenger?.showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Google Maps.'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_rounded),
                title: const Text('Open in Apple Maps'),
                subtitle: const Text('Directions or place on iOS / web'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final q = Uri.encodeComponent(placeLabel);
                  final ok = await _openUri(
                    Uri.parse(
                      'http://maps.apple.com/?daddr=$latitude,$longitude&q=$q',
                    ),
                  );
                  if (!ok && context.mounted) {
                    messenger?.showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Apple Maps.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// When there is no stored pin, search by place name in Google Maps.
Future<void> showActivityMapsSearchSheet(
  BuildContext context, {
  required String placeQuery,
}) async {
  if (placeQuery.trim().isEmpty) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search in Google Maps'),
                subtitle: Text(
                  placeQuery,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final q = Uri.encodeComponent(placeQuery.trim());
                  final ok = await _openUri(
                    Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$q',
                    ),
                  );
                  if (!ok && context.mounted) {
                    messenger?.showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Google Maps.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> _openUri(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
