/*
TODO:
4.  Set title
------
5.  When i click on an image, I want to see the larger image in a sort of transparent overlay
6.  I want to be able to dismiss the overlay
7.  Replace no data with spinny thing
-------
When we get to 1000 images delete 10%
 */

/*
Next:
Load images into thier own calss
Create image widget from this class
*/

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:random_string/random_string.dart';

class ImageResult {
  final String id;
  final Image image;

  const ImageResult({this.id, this.image});
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      title: 'MediaQuery Demo',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String title = 'Is this it!?';
  @override
  _MyHomePage createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  List<String> dogImages = List<String>();
  ScrollController _gridScrollController = new ScrollController();
  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    rollFive().then((x) {
      if (rouletteImages.length < 50) {
        print('less than 25, rolling again');
        rollFive();
      }
    });

    _gridScrollController.addListener(() {
      if (_gridScrollController.position.pixels == _gridScrollController.position.maxScrollExtent) {
        print('rolling');
        rollFive();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: this.rouletteImages.length,
                controller: _gridScrollController,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                padding: const EdgeInsets.all(5),
                itemBuilder: (context, index) {
                  return Container(
                    constraints: BoxConstraints.tightFor(height: 90),
                    child: FutureBuilder<Widget>(
                      future: rouletteImages[index],
                      builder: (cx, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data;
                        } else {
                          return Text('NO DATA');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Future<ImageResult>> loadedImages = [];
  List<Future<Widget>> rouletteImages = List<Future<Widget>>();

  // TODO:  rename
  Future rollFive() async {
    for (var i = 0; i < 100; i++) {
      getImage();
    }
  }

  Future<Widget> getImage() async {
    final Completer<Widget> completer = Completer();

    var randomId = randomAlphaNumeric(5);
    var url = 'https://i.imgur.com/${randomId}s.jpg';
    var image = new NetworkImage(url);
    var config = await image.obtainKey(new ImageConfiguration());
    var load = image.load(config);

    var listener = new ImageStreamListener((ImageInfo info, isSync) async {
      print(info.image.width);
      print(info.image.height);

      if ((info.image.width == 198 && info.image.height == 160) ||
          (info.image.width == 161 && info.image.height == 81)) {
        //do nothing, except fix this code
        print('bad image');
        //completer.complete(Container(child: Text('AZAZA')));
        //rouletteImages.add(completer.future);
      } else {
        print('ok image');
        completer.complete(
          Container(
              child: Image(
            image: image,
            height: 90,
            width: 90,
            fit: BoxFit.cover,
          )),
        );
        setState(() {
          rouletteImages.add(completer.future);
        });
      }
    });

    load.addListener(listener);
    return completer.future;
  }
}
