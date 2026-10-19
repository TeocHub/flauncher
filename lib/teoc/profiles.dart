/*
 * Teoc Launcher — perfiles (Teoc / Skynook).
 */

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'teoc_config.dart';

class ProfileService extends ChangeNotifier {
  static const _currentKey = "teoc_current_profile";

  final SharedPreferences _prefs;
  String? _currentId;
  bool _selectedThisSession = false;

  ProfileService(this._prefs) {
    _currentId = _prefs.getString(_currentKey);
  }

  List<TeocProfile> get profiles => TeocConfig.profiles;

  TeocProfile get current => profiles.firstWhere(
        (profile) => profile.id == _currentId,
        orElse: () => profiles.first,
      );

  /// true cuando hay que mostrar "¿Quién está viendo?".
  bool get needsPicker => !_selectedThisSession;

  void select(TeocProfile profile) {
    _currentId = profile.id;
    _selectedThisSession = true;
    _prefs.setString(_currentKey, profile.id);
    notifyListeners();
  }

  void requestPicker() {
    _selectedThisSession = false;
    notifyListeners();
  }

  // --- Apps favoritas por perfil ---

  String _favoritesKey(TeocProfile profile) => "teoc_favorites_${profile.id}";

  List<String> favoritesOf(TeocProfile profile) =>
      _prefs.getStringList(_favoritesKey(profile)) ?? List<String>.from(profile.defaultFavorites);

  List<String> get currentFavorites => favoritesOf(current);

  bool isFavorite(String packageName) => currentFavorites.contains(packageName);

  Future<void> toggleFavorite(String packageName) async {
    final favorites = currentFavorites;
    if (favorites.contains(packageName)) {
      favorites.remove(packageName);
    }
    else {
      favorites.add(packageName);
    }
    await _prefs.setStringList(_favoritesKey(current), favorites);
    notifyListeners();
  }

  Future<void> moveFavorite(String packageName, int delta) async {
    final favorites = currentFavorites;
    final index = favorites.indexOf(packageName);
    final newIndex = index + delta;
    if (index < 0 || newIndex < 0 || newIndex >= favorites.length) {
      return;
    }
    favorites.removeAt(index);
    favorites.insert(newIndex, packageName);
    await _prefs.setStringList(_favoritesKey(current), favorites);
    notifyListeners();
  }
}
