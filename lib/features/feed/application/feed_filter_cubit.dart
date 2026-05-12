import 'package:flutter_bloc/flutter_bloc.dart';

/// Category chip labels on the feed (future: drive filtering / API queries).
const List<String> kFeedCategoryLabels = [
  'All',
  'Sports',
  'Social',
  'Outdoor',
];

/// Selected feed category chip index.
final class FeedFilterCubit extends Cubit<({int chipIndex})> {
  FeedFilterCubit() : super((chipIndex: 0));

  void selectChip(int index) {
    if (index < 0 || index >= kFeedCategoryLabels.length) return;
    if (index == state.chipIndex) return;
    emit((chipIndex: index));
  }
}
