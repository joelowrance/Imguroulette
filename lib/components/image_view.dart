import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imgur_random/image_service.dart';
import 'package:imgur_random/models/image_result.dart';
import 'package:photo_view/photo_view.dart';

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
  PageController controller = new PageController();

  _ImageViewState(this.imageId, this.index) {
    url = ImageService.instance.mainUrl(imageId);
    controller = new PageController(initialPage: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Image'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          )
        ],
        leading: Container(),
      ),
      body: Container(
        color: Colors.black,
        child: PageView.builder(
          controller: controller,
          itemCount: ImageService.instance.rouletteImages.length,
          itemBuilder: (context, index) {
            return FutureBuilder<ImageResult>(
              future: ImageService.instance.getNextImage(index),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    color: Colors.black,
                    child: GestureDetector(
                      onVerticalDragEnd: (e) {
                        if (e.velocity.pixelsPerSecond.dy < -500) {
                          Navigator.of(context).pop(null);
                        }
                      },
                      child: PhotoView(
                        imageProvider: NetworkImage(
                          ImageService.instance.mainUrl(snapshot.data.id),
                        ),
                      ),
                    ),
                  );
                } else {
                  return CupertinoActivityIndicator(
                      radius: 50, animating: true);
                }
              },
            );
          },
          onPageChanged: (index) {},
        ),
      ),
    );
  }
}
