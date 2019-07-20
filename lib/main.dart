/*
TODO:
4.  Set title
5.  When swipe left, i want to see the next image
6.  when swipe right, i want to see the previous image
7.  when i click the close button (top) i want to go back to the list
6.  I want to be able to dismiss the overlay
when i pull down i want to refresh my image list
when i reach 1000 images, the next load will reload and take me to the top of the gird
while i am swiping images, i want the grid to match the image i am looking at when i dismiss the overlay

7.  Replace no data with spinny thing
8.  User preferences
      initial load
        what happens if screen doesn't fill
-------

 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:random_string/random_string.dart';

class ImageResult {
  final String id;
  final NetworkImage image;

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
      if (rouletteImages2.length < 50) {
        print('less than 25, rolling again');
        rollFive();
      }
    });

    _gridScrollController.addListener(() {
      if (_gridScrollController.position.pixels ==
          _gridScrollController.position.maxScrollExtent) {
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
                itemCount: this.rouletteImages2.length,
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
                    child: FutureBuilder<ImageResult>(
                      future: rouletteImages2[index],
                      builder: (cx, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            child: GestureDetector(
                              onTap: () {
                                print('tappity: ${snapshot.data.id}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (cx) =>
                                        ImageViewer(imageId: snapshot.data.id),
                                  ),
                                );
                              },
                              child: Image(
                                image: snapshot.data.image,
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
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

  List<Future<ImageResult>> rouletteImages2 = [];
  //List<Future<Image>> rouletteImages = [];

  // TODO:  rename
  Future rollFive() async {
    for (var i = 0; i < 100; i++) {
      getImage2();
    }
  }

//  Future<Widget> getImage() async {
//    final Completer<Widget> completer = Completer();
//
//    var randomId = randomAlphaNumeric(5);
//    var url = 'https://i.imgur.com/${randomId}s.jpg';
//    var image = new NetworkImage(url);
//    var config = await image.obtainKey(new ImageConfiguration());
//    var load = image.load(config);
//
//    var listener = new ImageStreamListener((ImageInfo info, isSync) async {
//      print(info.image.width);
//      print(info.image.height);
//
//      if ((info.image.width == 198 && info.image.height == 160) ||
//          (info.image.width == 161 && info.image.height == 81)) {
//        //do nothing, except fix this code
//        print('bad image');
//        //completer.complete(Container(child: Text('AZAZA')));
//        //rouletteImages.add(completer.future);
//      } else {
//        print('ok image');
//        completer.complete(
//          Container(
//              child: Image(
//            image: image,
//            height: 90,
//            width: 90,
//            fit: BoxFit.cover,
//          )),
//        );
//        setState(() {
//          rouletteImages.add(completer.future);
//        });
//      }
//    });
//
//    load.addListener(listener);
//    return completer.future;
//  }

  Future<ImageResult> getImage2() async {
    final Completer<ImageResult> completer = Completer();

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
        completer.complete(ImageResult(id: randomId, image: image));
        setState(() {
          rouletteImages2.add(completer.future);
        });
      }
    });

    load.addListener(listener);
    return completer.future;
  }
}

class ImageViewer extends StatelessWidget {
  final String imageId;

  ImageViewer({Key key, @required this.imageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('https://i.imgur.com/$imageId/.png');
    return SafeArea(
      child: Dismissible(
        background: Container(color: Colors.red),
        key: Key(imageId),
        confirmDismiss: (DismissDirection direction) {
          //not left on last image
          //not right on first image
          return Future.value(true);
        },
        onDismissed: (DismissDirection direction) {
          print(direction.toString());
        },
        child: Container(
          child:
              Center(child: Image.network('https://i.imgur.com/$imageId.png')),
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
