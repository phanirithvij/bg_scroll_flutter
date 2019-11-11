import 'package:flutter/material.dart';

class NotifyingPageView extends StatefulWidget {
    final ValueNotifier<double> notifier;
    final int numScreens;
    final Axis scrollMode;

    const NotifyingPageView({
        Key key,
        @required this.notifier,
        @required this.numScreens,
        this.scrollMode = Axis.horizontal,
    }) : super(key: key);

    @override
    _NotifyingPageViewState createState() => _NotifyingPageViewState(numScreens);
}

class _NotifyingPageViewState extends State<NotifyingPageView> {
    PageController _pageController;
    int _numScreens;

    _NotifyingPageViewState(this._numScreens);

    @override
    void didUpdateWidget(NotifyingPageView oldWidget) {
        super.didUpdateWidget(oldWidget);
        // print("Before pageview ${widget.numScreens}");
        // print("DiD i leave the stove on? ${oldWidget.numScreens}");
        if (widget.numScreens != oldWidget.numScreens){
            setState(() {
                _numScreens = widget.numScreens;
            });
        }
    }

    void _onScroll() {
        if (_pageController.page.toInt() == _pageController.page) {
            print("${_pageController.page} current page");
        }
        widget.notifier?.value = _pageController.page /* - _previousPage */;
    }

    @override
    void initState() {
        _pageController = PageController(
            initialPage: 0,
            viewportFraction: 0.9,
        )..addListener(_onScroll);

        super.initState();
    }

    List<Widget> get _pages {
        return List.generate(
            _numScreens,
            (index) {
                return Container(
                    height: 10,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Text(
                        "Card number ${index+1}",
                        style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                        ),
                    ),
                );
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            child: PageView(
                scrollDirection: widget.scrollMode,
                children: _pages,
                controller: _pageController,
            )
        );
    }
}
