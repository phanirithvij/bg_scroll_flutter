import 'package:flutter/material.dart';
import 'notifyingPageView.dart';

void main() => runApp(MyApp());

/// Maps a value n from the range start1, stop1 to start2, stop2
mapValue(n, start1, stop1, start2, stop2) {
  return ((n - start1) / (stop1 - start1)) * (stop2 - start2) + start2;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parallax Scrolling',
      theme: ThemeData.dark(),
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
  int _screenCount = 1;
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

    _image = NetworkImage(
        "https://w.wallhaven.cc/full/r2/wallhaven-r276qj.png");

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
          // Scrollable Page View
          NotifyingPageView(
            scrollMode: Axis.horizontal,
            notifier: _notifier,
            numScreens: _screenCount,
          ),
          //  A Slider that updates the number of pages
          Positioned(
            // Position it at the bottom
            bottom: MediaQuery.of(context).size.height * 0.025,
            width: MediaQuery.of(context).size.width,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                child: Slider(
                  onChanged: (dbl) {
                    // Slider was updated => setstate
                    setState(() {
                      _sliderVal = dbl;
                      _screenCount = _sliderVal.floor();
                      print("$_screenCount");
                    });
                  },
                  max: 20,
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

/// A SlidingImage that needs to be a statefulWidget
/// because it needs an re build every time a page is scrolled
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
    // init values before the image gets loaded
    // Should be initialized as they must mot be null
    _aspectRatio = 16 / 9;
    _maxWidth = 360;

    // Get the image width and the image's aspect ratio
    getImageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _aligner = getAlignment();

    // To Display a fullscreen image
    return OverflowBox(
      // required alignment, maxWidth
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
      // single page
      _aligner = Alignment(0, 0);
    } else if (widget.screenCount == 2) {
      _aligner = Alignment(-0.5 + widget._notifier.value, 0);
    } else {
      double _offset;
      // full scroll
      // -1 to 1 is start to end
      _offset =
          mapValue(widget._notifier.value, 0, widget.screenCount - 1, -1, 1);
      // Equi scroll: scroll a fixed amount, will not reach the end
      //   _offset = -1 + (widget._notifier.value / (widget.screenCount / 2));
      _aligner = Alignment(_offset, 0);
    }
    return _aligner;
  }

  /// Gets the image width and the image's aspect ratio
  /// Then sets the state of this Widget
  void getImageInfo() async {
    widget._image.resolve(ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) {
              setState(() {
                // Set the aspect ratio
                _aspectRatio = info.image.width / info.image.height;
                _maxWidth = info.image.width.toDouble();
              });
            },
            // If 404 :(
            onError: (info, trace) {
              // Handle it
              setState(() {});
            },
          ),
        );
  }
}
