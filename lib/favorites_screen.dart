// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:gif_app/presentation_screen.dart';
// import 'package:transparent_image/transparent_image.dart';

// class FavoritesScreen extends StatefulWidget {
//   @override
//   _FavoritesScreenState createState() => _FavoritesScreenState();
// }

// class _FavoritesScreenState extends State<FavoritesScreen> {
//   bool isLoading = false;

//   List<dynamic> gifsUrls = [];

//   final box = GetStorage();

//   List<String> favorites = [];

//   bool isFavorited({@required String id}) {
//     for (int i = 0; i < favorites.length; i++) {
//       if (favorites[i] == id) {
//         return true;
//       }
//     }
//     return false;
//   }

//   int getCount() {
//       return gifsUrls.length + 1;   
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Gifs Favorites"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Visibility(
//         visible: !isLoading,
//         child: Column(
//           children: [
//             if (gifsUrls.isEmpty)
//               Expanded(
//                 child: Container(
//                   alignment: Alignment.center,
//                   child: Text(
//                     "Não há nada\n para apresentar",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                   ),
//                   itemCount: getCount(),
//                   itemBuilder: (_, index) {
//                     if (index < gifsUrls.length) {
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (c) => PresentationScreen(
//                                 gifUrl: gifsUrls[index]["images"]
//                                     ["fixed_height"]["url"],
//                               ),
//                             ),
//                           );
//                         },
//                         child: Stack(
//                           children: [
//                             FadeInImage.memoryNetwork(
//                               height: 250,
//                               width: 250,
//                               placeholder: kTransparentImage,
//                               image: gifsUrls[index]["images"]["fixed_height"]
//                                   ["url"],
//                               fit: BoxFit.cover,
//                             ),
//                             Align(
//                               alignment: Alignment.topRight,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     clickFavorite(index);
//                                   });
//                                 },
//                                 child: isFavorited(id: gifsUrls[index]["id"])
//                                     ? Icon(Icons.favorite, color: Colors.white)
//                                     : Icon(Icons.favorite_outline),
//                                 style: ElevatedButton.styleFrom(
//                                   shape: CircleBorder(),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//           ],
//         ),
//         replacement: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 backgroundColor: Colors.black,
//               ),
//               SizedBox(height: 10),
//               Text(
//                 "Please, wait a second...",
//                 style: TextStyle(color: Colors.white, fontSize: 25),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
