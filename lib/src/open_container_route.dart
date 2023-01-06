import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:open_container/src/open_container.dart';

/// A route revealed by growing [OpenContainer].
///
/// When the navigation to this route occurs, the [OpenContainer] with the same
/// [tag] grows to fill the entire size of the surrounding [Navigator] while
/// fading out the widget returned by [OpenContainer.builder] and fading in
/// this widget returned by [builder].
class OpenContainerRoute<T> extends PageRoute<T> {
  OpenContainerRoute({
    required this.tag,
    this.color = Colors.white,
    this.elevation = 4.0,
    this.shape = const RoundedRectangleBorder(),
    this.fallbackTransitionBuilder,
    required this.builder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionType = ContainerTransitionType.fade,
    RouteSettings? settings,
  }) : super(settings: settings);

  /// See [OpenContainerState.tag].
  final Object tag;

  /// Background color of the route while it is open.
  ///
  /// When the container is closed, it will first transition from
  /// [OpenContainer.color] to [OpenContainer.middleColor] and then transition
  /// from there to this [color] in one smooth animation. When the container is
  /// closed, it will transition back to [color] from this color via
  /// [OpenContainer.middleColor].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color color;

  /// Elevation of the route while it is open.
  ///
  /// When the route is opened, it will transition to this elevation from
  /// [OpenContainer.elevation]. When the route is closed, it will
  /// transition back from this elevation to [OpenContainer.elevation].
  ///
  /// Defaults to 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.elevation], which is used to implement this property.
  final double elevation;

  /// Shape of the route while it is open.
  ///
  /// When the route is opened it will transition from [OpenContainer.shape] to
  /// this [shape]. When the route is closed, it will transition from this
  /// [shape] back to [OpenContainer.shape].
  ///
  /// Defaults to a rectangular.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder shape;

  /// Fallback transition used when [OpenContainer] with the same [tag] is not
  /// found.
  final RouteTransitionsBuilder? fallbackTransitionBuilder;

  /// Builder for the new route.
  final WidgetBuilder builder;

  /// The time it will take to animate the container from its closed to
  /// the route open state and vice versa.
  ///
  /// Defaults to 300ms.
  @override
  final Duration transitionDuration;

  /// The type of fade transition that the container will use for its
  /// incoming and outgoing widgets.
  ///
  /// Defaults to [ContainerTransitionType.fade].
  final ContainerTransitionType transitionType;

  static _FlippableTweenSequence<Color?> _getColorTween({
    required ContainerTransitionType transitionType,
    required Color closedColor,
    required Color openColor,
    required Color middleColor,
  }) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<Color?>(
          <TweenSequenceItem<Color?>>[
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(closedColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: closedColor, end: openColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(openColor),
              weight: 3 / 5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<Color?>(
          <TweenSequenceItem<Color?>>[
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: closedColor, end: middleColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: middleColor, end: openColor),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  static _FlippableTweenSequence<double> _getClosedOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(1.0),
              weight: 1,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 1.0, end: 0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  static _FlippableTweenSequence<double> _getOpenOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(1.0),
              weight: 3 / 5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  static final TweenSequence<Color?> _scrimFadeInTween = TweenSequence<Color?>(
    <TweenSequenceItem<Color?>>[
      TweenSequenceItem<Color?>(
        tween: ColorTween(begin: Colors.transparent, end: Colors.black54),
        weight: 1 / 5,
      ),
      TweenSequenceItem<Color>(
        tween: ConstantTween<Color>(Colors.black54),
        weight: 4 / 5,
      ),
    ],
  );
  static final Tween<Color?> _scrimFadeOutTween = ColorTween(
    begin: Colors.transparent,
    end: Colors.black54,
  );

  /// Key used for the widget returned by [builder] to keep
  /// its state when the shape of the widget tree is changed at the end of the
  /// animation to remove all the craft that was necessary to make the animation
  /// work.
  final GlobalKey _builderKey = GlobalKey();

  /// Defines the position and the size of the (opening) [OpenContainer] within
  /// the bounds of the enclosing [Navigator].
  final RectTween _rectTween = RectTween();

  late Tween<double> _elevationTween;
  late ShapeBorderTween _shapeTween;
  late _FlippableTweenSequence<double> _closedOpacityTween;
  late _FlippableTweenSequence<double> _openOpacityTween;
  late _FlippableTweenSequence<Color?> _colorTween;

  AnimationStatus? _lastAnimationStatus;
  AnimationStatus? _currentAnimationStatus;
  OpenContainerState? _openContainerState;

  /// Specifies if fallback transition should be used.
  ///
  /// By default fallback transition is used.
  /// If didPush is called, then the main transition is used.
  bool _useFallbackTransition = true;

  @override
  TickerFuture didPush() {
    void visitor(Element element) {
      final widget = element.widget;
      if (widget is OpenContainer && widget.tag == tag) {
        final openContainer = element as StatefulElement;
        _openContainerState = openContainer.state as OpenContainerState;
      } else {
        element.visitChildren(visitor);
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      navigator!.context.visitChildElements(visitor);

      assert(
        fallbackTransitionBuilder != null || _openContainerState != null,
        'No OpenContainer with tag $tag found and '
        'no fallback transition builder specified.',
      );

      if (_openContainerState == null) {
        // No OpenContainer with the given tag was found so we use the fallback
        // transition.
        _useFallbackTransition = true;
        return;
      }

      final middleColor = _openContainerState!.widget.middleColor ??
          Theme.of(_openContainerState!.context).canvasColor;

      _elevationTween = Tween<double>(
        begin: _openContainerState!.widget.elevation,
        end: elevation,
      );
      _shapeTween = ShapeBorderTween(
        begin: _openContainerState!.widget.shape,
        end: shape,
      );
      _colorTween = _getColorTween(
        transitionType: transitionType,
        closedColor: _openContainerState!.widget.color,
        openColor: color,
        middleColor: middleColor,
      );
      _closedOpacityTween = _getClosedOpacityTween(transitionType);
      _openOpacityTween = _getOpenOpacityTween(transitionType);

      _takeMeasurements();

      animation!.addStatusListener((AnimationStatus status) {
        _lastAnimationStatus = _currentAnimationStatus;
        _currentAnimationStatus = status;
        switch (status) {
          case AnimationStatus.dismissed:
            _toggleHideable(hide: false);
            break;
          case AnimationStatus.completed:
            _toggleHideable(hide: true);
            break;
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
            break;
        }
      });
    });

    // Post frame callback registered so fallback transition is not used.
    _useFallbackTransition = false;

    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    _takeMeasurements(
      delayForSourceRoute: true,
    );
    return super.didPop(result);
  }

  @override
  void dispose() {
    if (_openContainerState?.hideableKey.currentState?.isVisible == false) {
      // This route may be disposed without dismissing its animation if it is
      // removed by the navigator.
      SchedulerBinding.instance
          .addPostFrameCallback((Duration d) => _toggleHideable(hide: false));
    }
    super.dispose();
  }

  void _toggleHideable({required bool hide}) {
    if (_openContainerState?.hideableKey.currentState != null) {
      _openContainerState!.hideableKey.currentState!
        ..placeholderSize = null
        ..isVisible = !hide;
    }
  }

  void _takeMeasurements({
    bool delayForSourceRoute = false,
  }) {
    final RenderBox navigatorBox =
        navigator!.context.findRenderObject()! as RenderBox;
    final Size navSize = _getSize(navigatorBox);
    _rectTween.end = Offset.zero & navSize;

    void takeMeasurementsInSourceRoute([Duration? _]) {
      if (!navigatorBox.attached ||
          _openContainerState?.hideableKey.currentContext == null) {
        return;
      }
      _rectTween.begin =
          _getRect(_openContainerState!.hideableKey, navigatorBox);
      _openContainerState!.hideableKey.currentState!.placeholderSize =
          _rectTween.begin!.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance
          .addPostFrameCallback(takeMeasurementsInSourceRoute);
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render.hasSize);
    return render.size;
  }

  // Returns the bounds of the [RenderObject] identified by `key` in the
  // coordinate system of `ancestor`.
  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    assert(key.currentContext != null);
    assert(ancestor.hasSize);
    final RenderBox render =
        key.currentContext!.findRenderObject()! as RenderBox;
    assert(render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    bool wasInProgress = false;
    bool isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
        break;
      case null:
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
        break;
      case null:
        break;
    }
    return wasInProgress && isInProgress;
  }

  void closeContainer({T? returnValue}) {
    Navigator.of(subtreeContext!).pop(returnValue);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? _) {
          if (_useFallbackTransition && fallbackTransitionBuilder != null) {
            return fallbackTransitionBuilder!(
              context,
              animation,
              secondaryAnimation,
              Builder(
                key: _builderKey,
                builder: builder,
              ),
            );
          }

          if (animation.isCompleted || _openContainerState == null) {
            return SizedBox.expand(
              child: Visibility(
                visible: _openContainerState != null,
                child: Material(
                  color: color,
                  elevation: elevation,
                  shape: shape,
                  child: Builder(
                    key: _builderKey,
                    builder: builder,
                  ),
                ),
              ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve:
                _transitionWasInterrupted ? null : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<Color?>? colorTween;
          TweenSequence<double>? closedOpacityTween, openOpacityTween;
          Animatable<Color?>? scrimTween;
          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              colorTween = _colorTween;
              scrimTween = _scrimFadeInTween;
              break;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedOpacityTween = _closedOpacityTween;
                openOpacityTween = _openOpacityTween;
                colorTween = _colorTween;
                scrimTween = _scrimFadeInTween;
                break;
              }
              closedOpacityTween = _closedOpacityTween.flipped;
              openOpacityTween = _openOpacityTween.flipped;
              colorTween = _colorTween.flipped;
              scrimTween = _scrimFadeOutTween;
              break;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
              break;
          }
          assert(colorTween != null);
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);
          assert(scrimTween != null);

          final Rect rect = _rectTween.evaluate(curvedAnimation)!;
          return SizedBox.expand(
            child: Container(
              color: scrimTween!.evaluate(curvedAnimation),
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(rect.left, rect.top),
                  child: SizedBox(
                    width: rect.width,
                    height: rect.height,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      animationDuration: Duration.zero,
                      color: colorTween!.evaluate(animation),
                      shape: _shapeTween.evaluate(curvedAnimation),
                      elevation: _elevationTween.evaluate(curvedAnimation),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          // Closed child fading out.
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: _rectTween.begin!.width,
                              height: _rectTween.begin!.height,
                              child: (_openContainerState?.hideableKey
                                          .currentState?.isInTree ??
                                      false)
                                  ? null
                                  : Opacity(
                                      opacity: closedOpacityTween!
                                          .evaluate(animation),
                                      child: Builder(
                                        key: _openContainerState!.builderKey,
                                        builder:
                                            _openContainerState!.widget.builder,
                                      ),
                                    ),
                            ),
                          ),

                          // Open child fading in.
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: _rectTween.end!.width,
                              height: _rectTween.end!.height,
                              child: Opacity(
                                opacity: openOpacityTween!.evaluate(animation),
                                child: Builder(
                                  key: _builderKey,
                                  builder: builder,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;
}

class _FlippableTweenSequence<T> extends TweenSequence<T> {
  _FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  _FlippableTweenSequence<T>? _flipped;

  _FlippableTweenSequence<T>? get flipped {
    if (_flipped == null) {
      final List<TweenSequenceItem<T>> newItems = <TweenSequenceItem<T>>[];
      for (int i = 0; i < _items.length; i++) {
        newItems.add(TweenSequenceItem<T>(
          tween: _items[i].tween,
          weight: _items[_items.length - 1 - i].weight,
        ));
      }
      _flipped = _FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}
