import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:netease_app/wight/playlistStack.dart';

class BackgroundFlexibleSpaceBar extends StatefulWidget {
  const BackgroundFlexibleSpaceBar({
    Key? key,
    required this.background,
    this.title,
    this.centerTitle,
    this.titlePadding,
    this.collapseMode = CollapseMode.parallax,
    required this.backimage,
    this.imageUrl = 'images/default/playlistdefault.png',
    this.appbarTitle = '歌单',
    this.playlistdetail,
    this.collection = '收藏',
    this.chat = '评论',
    this.share = '分享',
    this.playCount = 0,
    this.avatorUrl = '',
  }) : super(key: key);
  final Widget? title;
  final Widget background;
  final bool? centerTitle;
  final CollapseMode collapseMode;
  final EdgeInsetsGeometry? titlePadding;

  final String imageUrl;
  final String appbarTitle;
  final playlistdetail;
  final String collection;
  final String chat;
  final String share;
  final int playCount;
  final String avatorUrl;
  final backimage;
  static Widget createSettings({
    double? toolbarOpacity,
    double? minExtent,
    double? maxExtent,
    required double currentExtent,
    required Widget child,
  }) {
    return FlexibleSpaceBarSettings(
      toolbarOpacity: toolbarOpacity ?? 1.0,
      minExtent: minExtent ?? currentExtent,
      maxExtent: maxExtent ?? currentExtent,
      currentExtent: currentExtent,
      child: child,
    );
  }

  @override
  _BackgroundFlexibleSpaceBarState createState() =>
      _BackgroundFlexibleSpaceBarState();
}

class _BackgroundFlexibleSpaceBarState
    extends State<BackgroundFlexibleSpaceBar> {
  bool _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) return widget.centerTitle!;
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) return Alignment.bottomCenter;
    final TextDirection textDirection = Directionality.of(context);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final double deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final FlexibleSpaceBarSettings settings = context
          .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

      final List<Widget> children = <Widget>[];

      final double deltaExtent = settings.maxExtent - settings.minExtent;

      // 0.0 -> Expanded
      // 1.0 -> Collapsed to toolbar
      final double t =
          (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
              .clamp(0.0, 1.0);
      final double fadeStart =
          math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
      const double fadeEnd = 1.0;

      final double opacity = settings.maxExtent == settings.minExtent
          ? 1.0
          : 1.0 - Interval(fadeStart, fadeEnd).transform(t);

      double height = settings.maxExtent;

      if (constraints.maxHeight > height) {
        height = constraints.maxHeight;
      }

      // background image
      children.add(Positioned(
        top: _getCollapsePadding(t, settings),
        left: 0.0,
        right: 0.0,
        height: height,
        child: PlayListStack(
          showopacity: opacity,
          backimage: widget.backimage,
          imageUrl: widget.imageUrl,
          appbarTitle: widget.appbarTitle,
          playlistdetail: widget.playlistdetail,
          chat: widget.chat,
          collection: widget.collection,
          playCount: widget.playCount,
          share: widget.share,
          avatorUrl: widget.avatorUrl,
        ),
      ));

      if (widget.title != null) {
        final ThemeData theme = Theme.of(context);

        Widget title;
        switch (theme.platform) {
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            title = widget.title!;
            break;
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            title = Semantics(
              namesRoute: true,
              child: widget.title,
            );
            break;
        }

        final bool effectiveCenterTitle =
            _getEffectiveCenterTitle(Theme.of(context));
        final EdgeInsetsGeometry padding = widget.titlePadding ??
            EdgeInsetsDirectional.only(
              start: effectiveCenterTitle ? 0.0 : 72.0,
              bottom: 16.0,
            );
        final double scaleValue =
            Tween<double>(begin: 1.5, end: 1.0).transform(t);
        final Matrix4 scaleTransform = Matrix4.identity()
          ..scale(scaleValue, scaleValue, 1.0);
        final Alignment titleAlignment =
            _getTitleAlignment(effectiveCenterTitle);
        children.add(Container(
          padding: padding,
          child: Transform(
            alignment: titleAlignment,
            transform: scaleTransform,
            child: Align(
              alignment: titleAlignment,
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.headline6!,
                child: title,
              ),
            ),
          ),
        ));
      }

      return ClipRect(child: Stack(children: children));
    });
  }
}
