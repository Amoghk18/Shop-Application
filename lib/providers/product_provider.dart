import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  final _authToken;
  final String userId;

  Products(this._authToken, this.userId, this._items);

  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trouser.jpg',
    ),
  ];

  // var _showFavOnly = false;

  // void showFavoritesOnly(){
  //   _showFavOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavOnly = false;
  //   notifyListeners();
  // }

  List<Product> get items {
    // if(_showFavOnly){
    //   return _items.where((item) => item.isFavorite).toList();
    // }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get getFavs {
    return _items.where((item) => item.isFavorite).toList();
  }

  Future<void> getAndSetProducts([bool filterByUser = false]) async {
    var url =
        'https://shopdemo-45b2d.firebaseio.com/products.json?auth=$_authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      String filterdString = filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
      url =
          'https://shopdemo-45b2d.firebaseio.com/userFav/$userId.json?auth=$_authToken$filterdString';
      final favResponse = await http.get(url);
      final favData = json.decode(favResponse.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          description: prodData['description'],
          title: prodData['title'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          isFavorite: favData == null ? false : favData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shopdemo-45b2d.firebaseio.com/products.json?auth=$_authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId 
        }),
      );
      final newProduct = Product(
        title: product.title,
        imageUrl: product.imageUrl,
        description: product.description,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final indexOfProd = _items.indexWhere((element) => element.id == productId);
    if (indexOfProd >= 0) {
      final url =
          'https://shopdemo-45b2d.firebaseio.com/products/$productId.json?auth=$_authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[indexOfProd] = newProduct;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shopdemo-45b2d.firebaseio.com/products/$id.json?auth=$_authToken';
    final existingProdIndex = _items.indexWhere((element) => element.id == id);
    var existingProd = _items[existingProdIndex];
    _items.removeAt(existingProdIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProd);
      notifyListeners();
      throw HttpException('Delete Failed');
    }
    existingProd = null;
  }
}
