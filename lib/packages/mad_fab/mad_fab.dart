library mad_fab;

import 'package:flutter/material.dart';

/// Floating Action Button
/// [BackgroundOverlay]
/// [MadFabItem]
/// [MadFabChild]
/// [AnimatedFab]
/// [MadFab]

class MadFab extends StatefulWidget {
  final List<MadFabItem>? children;
  final bool scrollVisible;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Alignment? alignment;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;

  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingTop;

  final Color? overlayColor;
  final double? overlayOpacity;
  final AnimatedIconData? animatedIcon;
  final IconThemeData? animatedIconTheme;
  final Widget? child;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final VoidCallback onPressed;
  final bool? overlayVisible;
  final int? speed;
  final String? title;
  final String? subtitle;
  final Color? titleColor;
  final Color? subtitleColor;

  const MadFab({
    Key? key,
    this.children = const [],
    this.scrollVisible = true,
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.foregroundColor,
    this.titleColor,
    this.subtitleColor,
    this.elevation = 7.0,
    this.overlayOpacity = 0.8,
    this.overlayColor = Colors.white,
    this.animatedIcon,
    this.animatedIconTheme,
    this.child,
    this.marginBottom = 0.0,
    this.marginLeft = 16.0,
    this.marginRight = 0.0,
    required this.onPressed,
    this.onClose,
    this.onOpen,
    this.overlayVisible = false,
    this.shape = const CircleBorder(),
    this.alignment = Alignment.centerRight,
    this.paddingRight = 0.0,
    this.paddingLeft = 0.0,
    this.paddingTop = 0.0,
    this.speed = 150,
  }) : super(key: key);

  @override
  State<MadFab> createState() => _MadFabState();
}

class _MadFabState extends State<MadFab> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _calculateMainControllerDuration(),
      vsync: this,
    );
    
  }

  Duration _calculateMainControllerDuration() => Duration(
      milliseconds: widget.speed! +
          widget.children!.length * (widget.speed! / 5).round());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _perfromAnimtion() {
    if (!mounted) return;
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(MadFab oldWidget) {
    if (oldWidget.children!.length != widget.children!.length) {
      _controller.duration = _calculateMainControllerDuration();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _toggleChildren() {
    var newValue = !_open;
    setState(() {
      _open = newValue;
    });

    if (newValue && widget.onOpen != null) widget.onOpen!();
    _perfromAnimtion();
    if (!newValue && widget.onClose != null) widget.onClose!();
  }

  List<Widget>? _getChildrenList() {
    final singleChildrenTween = 1.0 / widget.children!.length;
    return widget.children!
        .map((MadFabItem item) {
          int index = widget.children!.indexOf(item);
          var childAnimation = Tween(begin: 0.0, end: 62.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                0,
                singleChildrenTween * (index + 1),
              ),
            ),
          );
          return AnimatedMadFabChild(
            animation: childAnimation,
            index: index,
            visible: _open,
            backgroundcColor: item.backgroundColor,
            elevation: item.elevation!,
            title: item.title,
            subtitle: item.subtitle,
            titleColor: item.titleColor,
            subtitleColor: item.subtitleColor,
            child: item.child!,
            onTap: item.onTap!,
            toggleChildren: () {
              if (!widget.overlayVisible!) _toggleChildren();
            },
          );
        })
        .toList()
        .reversed
        .toList();
  }

  Widget _renderOverlay() {
    return Positioned(
        right: -16,
        bottom: -16,
        top: _open ? 0.0 : null,
        left: _open ? 0.0 : null,
        child: GestureDetector(
          onTap: _toggleChildren,
          child: BackgroundOverlay(
            animation: _controller,
            color: widget.overlayColor!,
            opacity: widget.overlayOpacity!,
          ),
        ));
  }

  Widget _renderButton() {
    var child = widget.animatedIcon != null
        ? AnimatedIcon(
            icon: widget.animatedIcon!,
            progress: _controller,
            color: widget.animatedIconTheme?.color,
            size: widget.animatedIconTheme?.size,
          )
        : widget.child;

    var fabChildren = _getChildrenList();
    var animatedFab = AnimatedMadFab(
      visible: widget.scrollVisible,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      elevation: widget.elevation,
      onLongPress: _toggleChildren,
      onTap:
          (_open || widget.onPressed == null) ? _toggleChildren : widget.onPressed,
      child: child,
      shape: widget.shape,
    );
    return Positioned(
      left: widget.marginLeft! + 16,
      bottom: widget.marginBottom,
      right: widget.marginRight,
      child: Container(
        alignment: Alignment.bottomCenter,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const SizedBox(
              height: kToolbarHeight + 40,
            ),
            Visibility(
              visible: _open,
              child: Expanded(
                child: ListView(
                  children: List.from(fabChildren!),
                  reverse: true,
                ),
              ),
            ),
            Align(
              alignment: widget.alignment!,
              child: Container(
                padding: EdgeInsets.only(
                  left: widget.paddingLeft!,
                  right: widget.paddingRight!,
                  top: 8.0 + widget.paddingTop!,

                ),
                child: animatedFab,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      !widget.overlayVisible! ? _renderOverlay() : Container(),
      _renderButton(),
    ];
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      fit: StackFit.expand,
      children: children,
    );
  }
}

class AnimatedMadFab extends StatelessWidget {
  const AnimatedMadFab({
    Key? key,
    this.visible = true,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.heroTag,
    this.elevation = 6.0,
    this.shape = const CircleBorder(),
    this.curve = Curves.linear,
    this.child,
  }) : super(key: key);

  final bool visible;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final String? heroTag;
  final double? elevation;
  final ShapeBorder? shape;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    var margin = visible ? 0.0 : 28.0;
    return Container(
      constraints: const BoxConstraints(
        minHeight: 0.0,
        minWidth: 0.0,
      ),
      width: 56.0,
      height: 56.0,
      child: AnimatedContainer(
        curve: curve!,
        margin: EdgeInsets.all(margin),
        duration: const Duration(milliseconds: 150),
        width: visible ? 56.0 : 0.0,
        height: visible ? 56.0 : 0.0,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: FloatingActionButton(
            child: visible ? child : null,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            onPressed: onTap,
            tooltip: tooltip,
            heroTag: heroTag,
            elevation: elevation,
            highlightElevation: elevation,
            shape: shape,
          ),
        ),
      ),
    );
  }
}

class MadFabItem {
  final Widget? child;
  final VoidCallback? onTap;
  final double? elevation;
  final String? title;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;

  MadFabItem(
      {Key? key,
      this.child,
      this.onTap,
      this.elevation,
      this.title,
      this.subtitle,
      this.backgroundColor,
      this.titleColor,
      this.subtitleColor});
}

class AnimatedMadFabChild extends AnimatedWidget {
  final int? index;
  final double elevation;
  final Widget child;
  final bool visible;
  final VoidCallback onTap;
  final VoidCallback toggleChildren;

  final String? title;
  final String? subtitle;
  final Color? backgroundcColor;
  final Color? titleColor;
  final Color? subtitleColor;

  const AnimatedMadFabChild({
    Key? key,
    required Animation<double> animation,
    this.index,
    this.backgroundcColor,
    this.elevation = 6.0,
    required this.child,
    this.title,
    this.subtitle,
    this.visible = false,
    required this.onTap,
    required this.toggleChildren,
    this.titleColor,
    this.subtitleColor,
  }) : super(
          key: key,
          listenable: animation,
        );

  void _performAction() {
    if (onTap != null) onTap();
    toggleChildren();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    final Widget buttonChild = animation.value > 50.0
        ? Container(
            width: animation.value,
            height: animation.value,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: child == null ? child : Container(),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: (titleColor == null)
                                ? Colors.black
                                : titleColor,
                            fontSize: 16.0),
                      ),
                      const SizedBox(
                        height: 13.0,
                      ),
                      Text(
                        subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (subtitleColor == null)
                              ? Colors.black
                              : subtitleColor,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          )
        : const SizedBox(
            width: 0.0,
            height: 0.0,
          );

    return Container(
      width: MediaQuery.of(context).size.width - 30,
      height: 80.0,
      padding: EdgeInsets.only(bottom: 72 - animation.value),
      child: GestureDetector(
        onTap: _performAction,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: backgroundcColor,
          child: buttonChild,
        ),
      ),
    );
  }
}

class BackgroundOverlay extends AnimatedWidget {
  final Color color;
  final double opacity;

  const BackgroundOverlay({
    Key? key,
    required Animation<double> animation,
    this.color = Colors.white,
    this.opacity = 0.8,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return Container(
      color: color.withOpacity(animation.value * opacity),
    );
  }
}
