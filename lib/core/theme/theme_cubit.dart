import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'meet_radius_theme_mode';

/// Persists user choice of light vs dark appearance.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_readInitial(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_kThemeModeKey);
    return raw == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == ThemeMode.system) return;
    emit(mode);
    await _prefs.setString(
      _kThemeModeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }
}
