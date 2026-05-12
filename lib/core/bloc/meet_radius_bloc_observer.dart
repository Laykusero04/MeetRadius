import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs BLoC lifecycle in debug builds to speed up tracing state issues.
final class MeetRadiusBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<Object?> bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      debugPrint('[bloc] created ${bloc.runtimeType}');
    }
  }

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[bloc] error in ${bloc.runtimeType}: $error\n$stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }
}
