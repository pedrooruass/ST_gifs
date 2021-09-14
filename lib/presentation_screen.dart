import 'package:flutter/material.dart';
import 'package:share/share.dart';

class PresentationScreen extends StatelessWidget {
  final String gifUrl;

  const PresentationScreen({
    this.gifUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text("Presentation"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(gifUrl);
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Image.network(gifUrl),
      ),
    );
  }
}
