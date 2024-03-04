import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FavoriteImagesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<String> favoriteImages = [];

  FavoriteImagesProvider(this._prefs) {
    // Load favorite images from SharedPreferences when the provider is created.
    favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
  }

  void toggleFavorite(String imageUrl) {
    if (favoriteImages.contains(imageUrl)) {
      favoriteImages.remove(imageUrl);
    } else {
      favoriteImages.add(imageUrl);
    }
    // Save the updated favorite images to SharedPreferences.
    _prefs.setStringList('favoriteImages', favoriteImages);
    notifyListeners();
  }

  void clearFavorites() {
    favoriteImages.clear();
    _prefs.remove('favoriteImages');
    notifyListeners();
  }
}
