import 'package:flutter/material.dart';
import 'package:open_container/src/hideable.dart';

/// The [OpenContainer] widget's fade transition type.
///
/// This determines the type of fade transition that the incoming and outgoing
/// contents will use.
enum ContainerTransitionType {
  /// Fades the incoming element in over the outgoing element.
  fade,

  /// First fades the outgoing element out, and starts fading the incoming
  /// element in once the outgoing element has completely faded out.
  fadeThrough,
}

/// A container that grows to fill the screen to reveal new route.
///
/// While the container is closed, it shows the [Widget] returned by
/// [builder]. When the navigation to [OpenContainerRoute] occurs it grows to
/// fill the entire size of the surrounding [Navigator] while fading out the
/// widget returned by [builder] and fading in the [OpenContainerRoute]. When
/// the route is closed the animation is reversed: The container shrinks back
/// to its original size while the [OpenContainerRoute] is faded out and the
/// widget returned by [builder] is faded back in.
///
/// By default, the container is in the closed state. During the transition from
/// closed to open and vice versa the [OpenContainerRoute] and [builder] exist
/// in the tree at the same time. Therefore, the widgets returned by these
/// builders cannot include the same global key.
///
/// See also:
///
///  * [Transitions with animated containers](https://material.io/design/motion/choreography.html#transformation)
///    in the Material spec.
class OpenContainer extends StatefulWidget {
  /// Creates an [OpenContainer].
  ///
  /// All arguments except for [key] must not be null. The arguments
  /// [tag] and [builder] are required.
  const OpenContainer({
    Key? key,
    required this.tag,
    this.color = Colors.white,
    this.middleColor,
    this.elevation = 1.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    required this.builder,
    this.clipBehavior = Clip.antiAlias,
  }) : super(key: key);

  /// The identifier for this particular OpenContainer. If the tag of this
  /// widget matches the tag of a [OpenContainerRoute] that we're navigating to
  /// or from, then an animation will be triggered.
  final Object tag;

  /// Background color of the container while it is closed.
  ///
  /// When the container is opened, it will first transition from this color
  /// to [middleColor] and then transition from there to [openColor] in one
  /// smooth animation. When the container is closed, it will transition back to
  /// this color from [openColor] via [middleColor].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color color;

  /// The color to use for the background color during the transition
  /// with [ContainerTransitionType.fadeThrough].
  ///
  /// Defaults to [Theme]'s [ThemeData.canvasColor].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color? middleColor;

  /// Elevation of the container while it is closed.
  ///
  /// When the route is opened, it will transition from this [elevation] to
  /// [OpenContainerRoute.elevation]. When the container is closed, it will
  /// transition back from [OpenContainerRoute.elevation] to this [elevation].
  ///
  /// Defaults to 1.0.
  ///
  /// See also:
  ///
  ///  * [Material.elevation], which is used to implement this property.
  final double elevation;

  /// Shape of the container while it is closed.
  ///
  /// When the route is opened it will transition from this [shape] to
  /// [OpenContainerRoute.shape]. When the container is closed, it will
  /// transition back to this [shape].
  ///
  /// Defaults to a [RoundedRectangleBorder] with a [Radius.circular] of 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder shape;

  /// Called to obtain the child for the container in the closed state.
  ///
  /// The [Widget] returned by this builder is faded out when the route
  /// opens and at the same time the widget returned by
  /// [OpenContainerRoute.builder] is faded in while the route grows to fill
  /// the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to open the
  /// container.
  final WidgetBuilder builder;

  /// The [builder] will be clipped (or not) according to this option.
  ///
  /// Defaults to [Clip.antiAlias], and must not be null.
  ///
  /// See also:
  ///
  ///  * [Material.clipBehavior], which is used to implement this property.
  final Clip clipBehavior;

  @override
  State<OpenContainer> createState() => OpenContainerState();
}

class OpenContainerState extends State<OpenContainer> {
  /// Key used in [OpenContainerRoute] to hide the widget returned by
  /// [OpenContainerRoute.builder] in the source route while the container is
  /// opening/open. A copy of that widget is included in the
  /// [OpenContainerRoute] where it fades out. To avoid issues with double
  /// shadows and transparency, we hide it in the source route.
  final GlobalKey<HideableState> hideableKey = GlobalKey<HideableState>();

  /// Key used to steal the state of the widget returned by
  /// [OpenContainerRoute.builder] from the source route and attach it to the
  /// same widget included in the [OpenContainerRoute] where it fades out.
  final GlobalKey builderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Hideable(
      key: hideableKey,
      child: Material(
        clipBehavior: widget.clipBehavior,
        color: widget.color,
        elevation: widget.elevation,
        shape: widget.shape,
        child: Builder(
          key: builderKey,
          builder: widget.builder,
        ),
      ),
    );
  }
}
