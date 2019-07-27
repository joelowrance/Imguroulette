import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imgur_random/models/image_result.dart';
import 'package:random_string/random_string.dart';
import 'models/stats_tracker.dart';

class ImageService {
  //Singleton
  ImageService._privateConstructor();
  static final ImageService _instance = ImageService._privateConstructor();
  static ImageService get instance {
    return _instance;
  }

  List<Future<ImageResult>> rouletteImages = [];

  int imageCount() {
    return rouletteImages.length;
  }

  Future<ImageResult> getImage(int index) {
    return rouletteImages[index];
  }

  Future<ImageResult> getNextImage(int index) async {
    return rouletteImages[index];
  }

  String thumbnailUrl(String id) {
    return 'https://i.imgur.com/${id}s.jpg';
  }

  String mainUrl(String id) {
    return 'https://i.imgur.com/$id.png';
  }

  Future initialRoll() async {
    this.loadThumbnails(count: 100).then((value) async {
      if (rouletteImages.length < 50) {
        await loadThumbnails();
      }
    });
  }

  //TODO:  this is a dirty hack
  Function setState = () {};

  int loadingCount = 0;
  Future loadThumbnails({int count = 50}) async {
    if (loadingCount > 3) {
      return;
    }

    for (var i = 0; i < 100; i++) {
      _getImage();
    }
  }

  Future<ImageResult> _getImage() async {
    final Completer<ImageResult> completer = Completer();

    var length = (int.parse(randomNumeric(1)) > 2) ? 5 : 7;

    loadingCount++;
    var randomId = randomAlphaNumeric(length);
    var url = 'https://i.imgur.com/${randomId}s.jpg';
    var image = new NetworkImage(url);
    var config = await image.obtainKey(new ImageConfiguration());
    var load = image.load(config);

    var listener = new ImageStreamListener((ImageInfo info, isSync) async {
      loadingCount--;
      debugPrint('loadingCount $loadingCount');

      if ((info.image.width == 198 && info.image.height == 160) ||
          (info.image.width == 161 && info.image.height == 81)) {
        //do nothing, except fix this code
        debugPrint('bad image $randomId');
        StatsTracker.instance.addStat(length, false);
        //completer.complete(Container(child: Text('AZAZA')));
        //rouletteImages.add(completer.future);
      } else {
        debugPrint('ok image');
        completer.complete(ImageResult(id: randomId, image: image));
        StatsTracker.instance.addStat(length, true);

        setState(() {
          rouletteImages.add(completer.future);
        });
      }
    });

    load.addListener(listener);
    return completer.future;
  }

  Future<void> reset() async {
    setState(rouletteImages.clear());

    initialRoll();
  }
}
