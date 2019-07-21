/*
TODO:
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
import 'package:photo_view/photo_view.dart';

class ImageService {
  List<Future<ImageResult>> _rouletteImages = [];

  int imageCount() {
    return _rouletteImages.length;
  }

  Future<ImageResult> getImage(int index) {
    return _rouletteImages[index];
  }

  Future<ImageResult> getNextImage(int index) async {
    //if (index >= _rouletteImages.length) {
    return _rouletteImages[index];
    //} else {
    //  await loadThumbnails();
    //  return _rouletteImages[index];
    // }
  }

  String thumbnailUrl(String id) {
    return 'https://i.imgur.com/${id}s.jpg';
  }

  String mainUrl(String id) {
    return 'https://i.imgur.com/$id.png';
  }

  Future initialRoll() async {
    this.loadThumbnails(count: 100).then((value) async {
      if (_rouletteImages.length < 50) {
        await loadThumbnails();
      }
    });
  }

  //TODO:  this is a dirty hack
  Function setState = () {};

  int loadingCount = 0;
  Future loadThumbnails({int count = 50}) async {
//    if (_rouletteImages.length > 250) {
//      for (var wtf = 0; wtf < 100; wtf++) {
//        print('wtf $wtf');
//        _rouletteImages.removeAt(wtf);
//      }
//    }

    print('loading....');
    if (loadingCount > 3) {
      print('already loading');
      return;
    }

    for (var i = 0; i < 100; i++) {
      _getImage();
    }
  }

  Future<ImageResult> _getImage() async {
    final Completer<ImageResult> completer = Completer();

    loadingCount++;
    var randomId = randomAlphaNumeric(5); //TODO:  let's also try some 7
    var url = 'https://i.imgur.com/${randomId}s.jpg';
    var image = new NetworkImage(url);
    var config = await image.obtainKey(new ImageConfiguration());
    var load = image.load(config);

    var listener = new ImageStreamListener((ImageInfo info, isSync) async {
      print(info.image.width);
      print(info.image.height);

      loadingCount--;
      print('loadingCount $loadingCount');

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
          _rouletteImages.add(completer.future);
        });
      }
    });

    load.addListener(listener);
    return completer.future;
  }
}

class ImageResult {
  final String id;
  final NetworkImage image;

  const ImageResult({this.id, this.image});
}

void main() => runApp(MyApp());

ImageService imageService = new ImageService();

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
  final String title = 'Seattle Splat!';
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
    imageService.setState = this.setState;
    imageService.initialRoll();
    setState(() {});

//    rollFive().then((x) {
//      if (rouletteImages2.length < 50) {
//        print('less than 25, rolling again');
//        rollFive();
//      }
//    });

    _gridScrollController.addListener(() {
      print(
          '${_gridScrollController.position.pixels} / ${_gridScrollController.position.maxScrollExtent}');
      if (_gridScrollController.position.pixels >=
          _gridScrollController.position.maxScrollExtent - 250) {
        print('rolling');
        imageService.loadThumbnails();
        setState(() {});
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
            Text(
              '${imageService.loadingCount.toString()} - ${imageService._rouletteImages.length}',
            ),
            Expanded(
              child: GridView.builder(
                itemCount: imageService.imageCount(),
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
                      future: imageService.getImage(index),
                      builder: (cx, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            child: GestureDetector(
                              onTap: () {
                                print('tappity: ${snapshot.data.id}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (cx) => ImageView(
                                      imageId: snapshot.data.id,
                                      index: index,
                                    ),
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

  //List<Future<ImageResult>> rouletteImages2 = [];
  //List<Future<Image>> rouletteImages = [];

  // TODO:  rename
//  Future rollFive() async {
//    for (var i = 0; i < 100; i++) {
//      getImage2();
//    }
//  }

//  Future<ImageResult> getImage2() async {
//    final Completer<ImageResult> completer = Completer();
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
//        completer.complete(ImageResult(id: randomId, image: image));
//        setState(() {
//          rouletteImages2.add(completer.future);
//        });
//      }
//    });
//
//    load.addListener(listener);
//    return completer.future;
//  }
}

class ImageView extends StatefulWidget {
  final String imageId;
  final int index;

  ImageView({this.imageId, this.index});

  @override
  _ImageViewState createState() => _ImageViewState(imageId, index);
}

class _ImageViewState extends State<ImageView> {
  String imageId;
  int index;
  String url = "";

  _ImageViewState(this.imageId, this.index) {
    url = imageService.mainUrl(imageId);
  }

  @override
  Widget build(BuildContext context) {
    print('https://i.imgur.com/$imageId/.png');
    //String url = imageService.mainUrl(imageId);
    return SafeArea(
      child: Dismissible(
        background: Container(color: Colors.black),
        key: Key(imageId),
        confirmDismiss: (DismissDirection direction) {
          //not left on last image
          //not right on first image

          Future<ImageResult> image;
          int nextIndex;
          if (direction == DismissDirection.startToEnd) {
            if (index == 0) {
              return Future.value(false);
            }
            nextIndex = index - 1;

            print('next index minus $nextIndex');
          }
          //forward
          if (direction == DismissDirection.endToStart) {
            nextIndex = index + 1;
            print('next index plus $nextIndex');
          }

          image = imageService.getNextImage(nextIndex);

          image.then((result) {
            setState(() {
              imageId = result.id;
              index = nextIndex;
              url = imageService.mainUrl(result.id);
            });
          });

          return Future.value(false);
        },
        onDismissed: (DismissDirection direction) {
          print('on dismissed $direction');
        },
        child: Container(
          child: Center(
              //child: Image.network(url),
              child: PhotoView(
            imageProvider: NetworkImage(url),
          )),
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
