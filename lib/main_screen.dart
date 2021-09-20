import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gif_app/presentation_screen.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String search;
  int offset = 0;
  bool isLoading = false;
  List<dynamic> gifsUrls = [];
  final box = GetStorage();
  List<String> favorites = [];

  

  final fieldController = TextEditingController();

  void getFavorites() {
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

  bool isFavorited({@required String id}) {
    for (int i = 0; i < favorites.length; i++) {
      if (favorites[i] == id) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getFavorites();
    getGifs();
  }

  Future<void> getGifs() async {
    setState(() => isLoading = true);

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

      setState(() {
        gifsUrls = convertedToMap["data"];
      });
      if (search == null) {
        createToast(
          "Seja Bem Vindo de Volta aos Trends!!!",
          backgroundColor: Colors.green,
        );
      }
    }
    setState(() => isLoading = false);
  }

  int getCount() {
    if (search == null) {
      return gifsUrls.length;
    } else {
      return gifsUrls.length + 1;
    }
  }

  createToast(
    String msg, {
    Color backgroundColor = Colors.red,
    Color textColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: Text("Gifs app"),
          centerTitle: true,
        ),
        body: Visibility(
          visible: !isLoading,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: fieldController,
                  onFieldSubmitted: (value) {
                    if (value.isEmpty) {
                      createToast("Digite algo Pfv!!!");
                      return;
                    }
                    offset = 0;
                    search = value;
                    getGifs();
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Search Gifs",
                    hintStyle: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        // remover a pesquisa
                        fieldController.text = "";

                        // Temos que esconder o teclado
                        FocusScope.of(context).unfocus();

                        // Removendo o conteudo da variavel search
                        search = null;
                        // Setando o offset para 0, para quando buscarmos
                        // pelo nome, vir do começo
                        offset = 0;
                        // voltar pros trends
                        getGifs();
                      },
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              if (gifsUrls.isEmpty)
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Não há nada\n para apresentar",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: getCount(),
                    itemBuilder: (_, index) {
                      if (search == null || index < gifsUrls.length) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (c) => PresentationScreen(
                                  gifUrl: gifsUrls[index]["images"]
                                      ["fixed_height"]["url"],
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              FadeInImage.memoryNetwork(
                                height: 250,
                                width: 250,
                                placeholder: kTransparentImage,
                                image: gifsUrls[index]["images"]["fixed_height"]
                                    ["url"],
                                fit: BoxFit.cover,
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (isFavorited(
                                          id: gifsUrls[index]["id"])) {
                                        favorites
                                            .remove(gifsUrls[index]["id"]);
                                      } else {
                                        favorites.add(gifsUrls[index]["id"]);
                                      }
                                      box.write('favorites', favorites);
                                    });
                                  },
                                  child:
                                      isFavorited(id: gifsUrls[index]["id"])
                                          ? Icon(Icons.favorite,
                                              color: Colors.white)
                                          : Icon(Icons.favorite_outline),
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () {
                            offset += 49;
                            getGifs();
                          },
                          child: Ink(
                            color: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Carregar mais",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.refresh, color: Colors.white),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
          replacement: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
                SizedBox(height: 10),
                Text(
                  "Please, wait a second...",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ],
            ),
          ),
        ));
  }
}
