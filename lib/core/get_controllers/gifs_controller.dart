import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class GifsController extends GetxController {
  final box = GetStorage();
  List<String> favorites = [];
  RxList<dynamic> gifsUrls = List<dynamic>().obs;

  bool isFavorited({@required String id}) {
    for (int i = 0; i < favorites.length; i++) {
      if (favorites[i] == id) {
        return true;
      }
    }
    return false;
  }

  void clickFavorite(int index) {
    if (isFavorited(id: gifsUrls[index]["id"])) {
      favorites.remove(gifsUrls[index]["id"]);
      removeFavoriteFB(gifsUrls[index]["id"]);
    } else {
      favorites.add(gifsUrls[index]["id"]);
      addFavoriteFB(gifsUrls[index]["id"]);
    }
    box.write('favorites', favorites);
  }

  Future<void> addFavoriteFB(String id) async {
    return gifsFavoriteFB
        .doc(id)
        .set({
          'idGif': id,
          'isFavorite': true,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> removeFavoriteFB(String id) async {
    return gifsFavoriteFB
        .doc(id)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  //  Vinculo com FB
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Vinculo com a collection que criamos
  CollectionReference gifsFavoriteFB =
      FirebaseFirestore.instance.collection('gifsFavorite');

  /// Metodo que busca todos os dados da collection
  Future<void> getFavoritesFB() async {
    QuerySnapshot querySnapshot = await gifsFavoriteFB.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    print(allData);
    for (int i = 0; i < allData.length; i++) {
      favorites.add(allData[i]["idGif"]);
    }
  }

  Future<void> getFavorites() async {
    await getFavoritesFB();
    if (favorites.length > 0) {
      return;
    }
    final List<dynamic> f = box.read('favorites');

    if (f != null) {
      if (f != null && f.length > 0) {
        for (var id in f) {
          favorites.add(id);
        }
      }
    } else {
      favorites = [];
    }
  }

  Future<void> getGifs({
    @required String search,
    @required int offset,
  }) async {
    String endpointTrend =
        "https://api.giphy.com/v1/gifs/trending?api_key=71fZ8yW6a6Z4Au0WrG4LfOeD2BZsHvTp";
    String endpointSearch =
        "https://api.giphy.com/v1/gifs/search?api_key=71fZ8yW6a6Z4Au0WrG4LfOeD2BZsHvTp&offset=$offset&limit=49&q=$search";
    String endpoint;

    if (search == null) {
      endpoint = endpointTrend;
    } else {
      endpoint = endpointSearch;
    }

    http.Response response = await http.get(endpoint);

    if (response.statusCode == 200) {
      final convertedToMap = json.decode(response.body);

      gifsUrls = convertedToMap["data"];

      // if (search == null) {
      //   createToast(
      //     "Seja Bem Vindo de Volta aos Trends!!!",
      //     backgroundColor: Colors.green,
      //   );
      // }
    }
  }

  int getCount(String search) {
    if (search == null) {
      return gifsUrls.length;
    } else {
      return gifsUrls.length + 1;
    }
  }
}
