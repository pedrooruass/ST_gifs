import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif_app/core/get_controllers/gifs_controller.dart';
import 'package:gif_app/screens/presentation_screen.dart';
import 'package:gif_app/screens/widgets/list_of_gifs.dart';
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
      body: Column(
        children: [
          TextFormField(
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
                  hintStyle:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: widget.onPressedSearch,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
          ListOfGifs(
            onPressedFavorite: gifsController.clickFavorite(index),
            enableShowMore: true,
          ),
        ],
      ),
    );
  }
}
