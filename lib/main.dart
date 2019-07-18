import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';

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
  ScrollController _scrollController = new ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    rollFive().then((x) {
      if (rouletteImages.length < 25) {
        print('less than 25, rolling again');
        rollFive();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('rolling');
        rollFive();
      }
    });

    //fetchFive();
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
              child: ListView.builder(
                controller: _scrollController,
                itemCount: this.rouletteImages.length,
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
                        }),
                  );
                },
              ),
            ),
//            FutureBuilder<Widget>(
//              future: getImage(),
//              builder: (cx, snapshot) {
//                if (snapshot.hasData) {
//                  print('has data');
//                  return snapshot.data;
//                } else {
//                  print('no data');
//                  return Text('loading...');
//                }
//              },
//            ),
//            Expanded(
//              child: ListView.builder(
//                controller: _scrollController,
//                itemCount: dogImages.length,
//                itemBuilder: (BuildContext context, int index) {
//                  return Container(
//                    constraints: BoxConstraints.tightFor(height: 200),
//                    child: Image.network(
//                      dogImages[index],
//                      fit: BoxFit.fitWidth,
//                    ),
//                  );
//                },
//              ),
//            ),
          ],
        ),
      ),
    );
  }

  List<Future<Widget>> rouletteImages = List<Future<Widget>>();

  Future rollFive() async {
    //var i = 0;
//    while (rouletteImages.length < 25) {
//      await getImage();
//    }
    for (var i = 0; i < 25; i++) {
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
            fit: BoxFit.scaleDown,
          )),
        );
        setState(() {
          rouletteImages.add(completer.future);
        });
      }

//      if (info.image.width != 20 && info.image.height != 160) {
//        completer.complete(Container(child: Image(image: image)));
//
//        setState(() {
//          rouletteImages.add(completer.future);
//        });
//      } else {
//        completer.complete(Container(child: Text('AZAZA')));
//      }
    });

    load.addListener(listener);
    return completer.future;
  }

//  fetch() async {
//    final response = await http.get('https://dog.ceo/api/breeds/image/random');
//    if (response.statusCode == 200) {
//      await getImage();
//      var url = json.decode(response.body)['message'];
//      print(url);
//      setState(() {
//        dogImages.add(url);
//      });
//    } else {
//      throw Exception("ohno");
//    }
//  }

//  fetchFive() {
//    for (var x = 0; x < 10; x++) {
//      fetch();
//      print('fetched $x');
//    }
//  }
}

/// This Widget is the main application widget.
//class MyApp extends StatelessWidget {
//  static const String _title = 'Flutter Code Sample';
//
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: _title,
//      home: MyStatelessWidget(),
//    );
//  }
//}
//
//final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//final SnackBar snackBar = const SnackBar(content: Text('Showing Snackbar'));
//
//void openPage(BuildContext context) {
//  Navigator.push(context, MaterialPageRoute(
//    builder: (BuildContext context) {
//      return Scaffold(
//        appBar: AppBar(
//          title: const Text('Next page'),
//        ),
//        body: const Center(
//          child: Text(
//            'This is the next page',
//            style: TextStyle(fontSize: 24),
//          ),
//        ),
//      );
//    },
//  ));
//}
//
///// This is the stateless widget that the main application instantiates.
//class MyStatelessWidget extends StatelessWidget {
//  MyStatelessWidget({Key key}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: scaffoldKey,
//      appBar: AppBar(
//        title: const Text('AppBar Demo'),
//        actions: <Widget>[
//          IconButton(
//            icon: const Icon(Icons.add_alert),
//            tooltip: 'Show Snackbar',
//            onPressed: () {
//              scaffoldKey.currentState.showSnackBar(snackBar);
//            },
//          ),
//          IconButton(
//            icon: const Icon(Icons.navigate_next),
//            tooltip: 'Next page',
//            onPressed: () {
//              openPage(context);
//            },
//          ),
//        ],
//      ),
//      body: const Center(
//        child: Text(
//          'This is the home page',
//          style: TextStyle(fontSize: 24),
//        ),
//      ),
//    );
//  }
//}
