import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif_app/core/get_controllers/gifs_controller.dart';
import 'package:gif_app/favorites_screen.dart';
import 'package:gif_app/presentation_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String search;
  int offset = 0;
  bool isLoading = false;
  final gifsController = Get.find<GifsController>();
  final fieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    gifsController.getFavorites().then((value) async {
      await gifsController.getGifs(search: search, offset: offset);
    });
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
        appBar: AppBar(title: Text("Gifs app"), centerTitle: true, actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => FavoritesScreen(),
                //   ),
                // );
              },
            ),
          ),
        ]),
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
                    gifsController.getGifs(search: search, offset: offset);
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
                        gifsController.getGifs(search: search, offset: offset);
                      },
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              if (gifsController.gifsUrls.isEmpty)
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
                  child: GetX<GifsController>(
                    builder: (){
                      return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: gifsController.getCount(search),
                      itemBuilder: (_, index) {
                        if (search == null ||
                            index < gifsController.gifsUrls.length) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (c) => PresentationScreen(
                                    gifUrl: gifsController.gifsUrls[index]
                                        ["images"]["fixed_height"]["url"],
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
                                  image: gifsController.gifsUrls[index]
                                      ["images"]["fixed_height"]["url"],
                                  fit: BoxFit.cover,
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        gifsController.clickFavorite(index);
                                      });
                                    },
                                    child: gifsController.isFavorited(
                                            id: gifsController.gifsUrls[index]
                                                ["id"])
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
                              gifsController.getGifs(
                                  search: search, offset: offset);
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
                    );
                    }
                     
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
