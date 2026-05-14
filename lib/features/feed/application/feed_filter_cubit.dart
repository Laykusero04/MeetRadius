import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/domain/activity_categories.dart';

export '../../activity/domain/activity_categories.dart' show kFeedCategoryLabels;

/// Selected feed category chip index.
final class FeedFilterCubit extends Cubit<({int chipIndex})> {
  FeedFilterCubit() : super((chipIndex: 0));

  void selectChip(int index) {
    if (index < 0 || index >= kFeedCategoryLabels.length) return;
    if (index == state.chipIndex) return;
    emit((chipIndex: index));
  }
}
