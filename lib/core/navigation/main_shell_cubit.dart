import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom navigation index for the main shell (feed, map, host, chats, menu).
final class MainShellCubit extends Cubit<({int currentIndex})> {
  MainShellCubit() : super((currentIndex: 0));

  static const int tabCount = 5;

  void selectTab(int index) {
    if (index < 0 || index >= tabCount) return;
    if (index == state.currentIndex) return;
    emit((currentIndex: index));
  }
}
