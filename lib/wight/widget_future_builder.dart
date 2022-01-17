import 'package:flutter/material.dart';

typedef ValueWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T value,
);

class CustomFutureBuilder<T> extends StatefulWidget {
  final ValueWidgetBuilder<T> builder;
  final Function futureFunc;
  final Map<String, dynamic> params;
  final Widget loadingWidget;

  CustomFutureBuilder({
    Key? key,
    required this.builder,
    required this.futureFunc,
    required this.loadingWidget,
    required this.params,
  }) : super(key: key);

  @override
  _CustomFutureBuilderState<T> createState() => _CustomFutureBuilderState<T>(
        builder: this.builder,
        futureFunc: this.futureFunc,
        loadingWidget: this.loadingWidget,
        params: this.params,
      );
}

class _CustomFutureBuilderState<T> extends State<CustomFutureBuilder> {
  final ValueWidgetBuilder<T> builder;
  final Function futureFunc;
  final Map<String, dynamic> params;
  final Widget loadingWidget;
  late Future<T> _future;
  String oldParams = '';
  _CustomFutureBuilderState({
    required this.builder,
    required this.futureFunc,
    required this.loadingWidget,
    required this.params,
  });

  @override
  void initState() {
    super.initState();
    _future = widget.futureFunc(context, widget.params);
    WidgetsBinding.instance?.addPostFrameCallback((call) {
      _request();
    });
  }

  void _request() {
    setState(() {
      if (widget.params == null)
        _future = widget.futureFunc(context, {});
      else {
        _future = widget.futureFunc(context, widget.params);
        oldParams = widget.params.values.join();
      }
    });
  }

  @override
  void didUpdateWidget(CustomFutureBuilder<T> oldWidget) {
    // 如果方法不一样了，那么则重新请求

    // if (oldWidget.futureFunc != widget.futureFunc) {
    //   print('func not');
    //   WidgetsBinding.instance?.addPostFrameCallback((call) {
    //     _request();
    //   });
    // }

    // 如果方法还一样，但是参数不一样了，则重新请求
    if (oldWidget.params != null && widget.params != null) {
      if (oldParams != widget.params.values.join()) {
        print('params not');
        oldParams = widget.params.values.join();
        WidgetsBinding.instance?.addPostFrameCallback((call) {
          _request();
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _future == null
        ? widget.loadingWidget
        : FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return widget.loadingWidget;
                case ConnectionState.done:
                  if (snapshot.hasData && snapshot.data != null) {
                    return widget.builder(context, snapshot.data);
                  } else if (snapshot.hasError) {
                    return widget.loadingWidget;
                  }
              }
              return Container();
            },
          );
  }
}
