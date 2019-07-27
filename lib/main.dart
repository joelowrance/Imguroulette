import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imgur_random/components/image_view.dart';
import 'package:imgur_random/components/sidebar.dart';
import 'package:imgur_random/models/image_result.dart';
import 'package:imgur_random/image_service.dart';
import 'package:imgur_random/models/stats_tracker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      title: 'ImgurRoulette',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title = 'Imgur Roulette';
  @override
  _MyHomePage createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  ScrollController _gridScrollController = new ScrollController();
  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ImageService.instance.setState = this.setState;
    ImageService.instance.initialRoll();
    setState(() {});

    _gridScrollController.addListener(() {
      if (_gridScrollController.position.pixels >=
          _gridScrollController.position.maxScrollExtent - 250) {
        ImageService.instance.loadThumbnails();
        setState(() {});
      }
    });
  }

  Future<void> _refreshStockPrices() async {
    setState(() {
      ImageService.instance.rouletteImages.clear();
    });

    ImageService.instance.initialRoll();
  }

  @override
  Widget build(BuildContext context) {
    StatsTracker.instance.calculate();
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            child: Container(
              child: Text(widget.title),
              width: double.infinity,
            ),
            onDoubleTap: () => _gridScrollController.animateTo(0,
                duration: Duration(milliseconds: 750), curve: Curves.easeIn),
          ),
        ),
        drawer: new SideBar(),
        body: Column(
          children: [
//            Text(
//              '${ImageService.instance.loadingCount.toString()} - ${ImageService.instance.rouletteImages.length}',
//            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshStockPrices,
                child: GridView.builder(
                  itemCount: ImageService.instance.imageCount(),
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
                        future: ImageService.instance.getImage(index),
                        builder: (cx, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              child: GestureDetector(
                                onTap: () {
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
                            return CupertinoActivityIndicator(animating: true);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
