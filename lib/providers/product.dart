import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavStatus(String token, String userId) async {
    var cachedFav = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://shopdemo-45b2d.firebaseio.com/userFav/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(url,
          body: json.encode({
            isFavorite,
          }));
      if (response.statusCode >= 400) {
        isFavorite = cachedFav;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = cachedFav;
      notifyListeners();
    }
    cachedFav = null;
  }
}
