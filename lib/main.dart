import 'package:flutter/material.dart';
import 'notifyingPageView.dart';

void main() => runApp(MyApp());

mapValue(n, start1, stop1, start2, stop2) {
  return ((n - start1) / (stop1 - start1)) * (stop2 - start2) + start2;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parallax Scrolling',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<double> _notifier;
  int _screenCount;
  double _sliderVal = 1;
  ImageProvider _image;

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _notifier = ValueNotifier<double>(0);
    _screenCount = 1;

    _image = NetworkImage(
        "https://res.cloudinary.com/rootworld/image/upload/v1573488108/bBwallhaven-13x79v.jpg");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: _notifier,
            builder: (context, _) {
              return Container(
                child: SlidingImage(
                  notifier: _notifier,
                  screenCount: _screenCount,
                  image: _image,
                ),
              );
            },
          ),
          NotifyingPageView(
            scrollMode: Axis.horizontal,
            notifier: _notifier,
            numScreens: _screenCount,
          ),
          Positioned(
            // top: 0,
            bottom: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: null,
                child: Slider(
                  onChanged: (dbl) {
                    setState(() {
                      _sliderVal = dbl;
                      _screenCount = _sliderVal.floor();
                      print("$_screenCount");
                    });
                  },
                  max: 20.toDouble(),
                  min: 1,
                  divisions: 20 - 1,
                  value: _sliderVal,
                  label: _sliderVal.toInt().toString(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SlidingImage extends StatefulWidget {
  const SlidingImage({
    Key key,
    @required ValueNotifier<double> notifier,
    @required ImageProvider image,
    @required this.screenCount,
  })  : _image = image,
        _notifier = notifier,
        super(key: key);

  final int screenCount;
  final ImageProvider _image;
  final ValueNotifier<double> _notifier;

  @override
  _SlidingImageState createState() => _SlidingImageState();
}

class _SlidingImageState extends State<SlidingImage> {
  double _aspectRatio;
  double _maxWidth;

  @override
  initState() {
    _aspectRatio = 16 / 9;
    _maxWidth = 360;

    getImageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _aligner = getAlignment();
    return OverflowBox(
      // -1 to 1 is start to end
      alignment: _aligner,
      maxWidth: _maxWidth,
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: widget._image,
            ),
          ),
        ),
      ),
    );
  }

  AlignmentGeometry getAlignment() {
    AlignmentGeometry _aligner;

    if (widget.screenCount == 1) {
      _aligner = Alignment(0, 0);
    } else if (widget.screenCount == 2) {
      _aligner = Alignment(-0.5 + widget._notifier.value, 0);
    } else {
      double _offset;
      // full scroll
      _offset =
          mapValue(widget._notifier.value, 0, widget.screenCount - 1, -1, 1);
      // Equi scroll
      //   _offset = -1 + (widget._notifier.value / (widget.screenCount / 2));
      _aligner = Alignment(_offset, 0);
    }
    return _aligner;
  }

  void getImageInfo() {
    widget._image
        .resolve(ImageConfiguration(platform: TargetPlatform.android))
        .addListener(ImageStreamListener((info, _) {
      setState(() {
        _aspectRatio = info.image.width / info.image.height;
        _maxWidth = info.image.width.toDouble();
      });
    }));
  }
}
