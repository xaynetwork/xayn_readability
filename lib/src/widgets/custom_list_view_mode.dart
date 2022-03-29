import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

/// A render mode that builds HTML into a [ListView] widget.
class CustomListViewMode extends ListViewMode {
  /// [Scrollbar.thickness]
  final double? scrollbarThickness;

  /// [Scrollbar.radius]
  final Radius? scrollbarRadius;

  /// [Scrollbar.isAlwaysShown]
  final bool scrollbarIsAlwaysShown;

  /// Creates a custom list view render mode, which includes a [Scrollbar].
  const CustomListViewMode({
    bool addAutomaticKeepAlives = false,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = false,
    Clip clipBehavior = Clip.hardEdge,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    EdgeInsetsGeometry? padding,
    bool? primary,
    ScrollPhysics? physics,
    String? restorationId,
    bool shrinkWrap = false,
    this.scrollbarThickness,
    this.scrollbarRadius,
    this.scrollbarIsAlwaysShown = true,
  }) : super(
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          clipBehavior: clipBehavior,
          controller: controller,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          padding: padding,
          primary: primary,
          physics: physics,
          restorationId: restorationId,
          shrinkWrap: shrinkWrap,
        );

  @override
  Widget buildBodyWidget(
    WidgetFactory wf,
    BuildContext context,
    List<Widget> children,
  ) {
    return Scrollbar(
      thickness: scrollbarThickness,
      radius: scrollbarRadius,
      isAlwaysShown: scrollbarIsAlwaysShown,
      child: super.buildBodyWidget(wf, context, children),
    );
  }
}
