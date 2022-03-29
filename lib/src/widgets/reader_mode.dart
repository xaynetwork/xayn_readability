import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:xayn_readability/src/controllers/reader_mode_controller.dart';
import 'package:xayn_readability/src/widgets/http_loader.dart';
import 'package:xayn_readability/src/widgets/objects/process_html_result.dart';

/// The signature of [ReaderMode.loadingBuilder] functions.
typedef LoadingBuilder = Widget Function();

/// The signature of [ReaderMode.onImageTap] functions.
typedef OnImageTap = void Function(ImageMetadata?);

/// The signature of [ReaderMode.factoryBuilder] functions.
typedef FactoryBuilder = WidgetFactory Function()?;

/// The signature of [ReaderMode.onScroll] functions.
typedef ScrollHandler = void Function(double position);

/// The default error text that will be displayed, should [ReaderMode] fail
/// to display the contents.
const String kReaderModeStandardExceptionMessage =
    'An error occurred\n\nUnable to load ';

/// A [Widget] which uses flutter_html to display html contents as native Flutter [Widget]s.
///
/// Use [controller] to load resources and to control the history of pages
///
/// Use [errorBuilder] to display a [Widget] when an error occurs,
/// use [loadingBuilder] to display a [Widget] while this widget is loading
///
/// Three different hooks are available:
/// - [onProcessedHtml] fires whenever parsing completed
/// - [onNavigation] fires whenever the [uri] is updated
/// - [onFetching] fires with either true or false, when a http request is either started or ended
///
/// The http-request will use the [method] provided and is http-GET by default,
/// Use [userAgent] to pass a specific value with that same request.
///
/// [classesToPreserve] and [disableJsonLd] are both reader mode options.
class ReaderMode extends StatefulWidget {
  /// Triggers whenever the user taps an image
  final OnImageTap? onImageTap;

  /// Triggers when the original html is processed into reader mode html
  final OnProcessedHtml? onProcessedHtml;

  /// Triggers when a navigation from [Uri] a to b takes place
  final OnNavigation? onNavigation;

  /// Triggers when the http request is loading, or not
  final OnFetching? onFetching;

  /// A builder which is invoked whenever the html could not be parsed
  final ErrorBuilder? errorBuilder;

  /// A builder which is invoked while operations are in progress
  final LoadingBuilder? loadingBuilder;

  /// A controller, used to load urls and to control history
  final ReaderModeController controller;

  /// The http-request method, defaults to http-GET
  final String? method;

  /// The user agent which is passed with the http-request
  final String? userAgent;

  /// The text style of the rendered html textual contents
  final TextStyle? textStyle;

  /// To implement custom widgets for displaying specific html tags,
  /// pass a factory builder, see [flutter_widget_from_html_core](https://pub.dev/packages/flutter_widget_from_html_core)
  /// for more information
  final FactoryBuilder? factoryBuilder;

  /// A list of css classes which should not be stripped
  final List<String> classesToPreserve;

  /// Set to true if you wish to skip jsonLd parsing
  final bool disableJsonLd;

  /// Triggers whenever content is scrolled
  final ScrollHandler? onScroll;

  /// Custom styles for rendering html
  final CustomStylesBuilder? customStylesBuilder;

  /// Custom widgets for rendering html
  final CustomWidgetBuilder? customWidgetBuilder;

  /// Optional padding, used by the internal renderer
  final EdgeInsets? rendererPadding;

  /// Optionally pass in a ScrollController
  final ScrollController? scrollController;

  /// Constructs a new [ReaderMode] [Widget]
  const ReaderMode({
    Key? key,
    required this.controller,
    this.errorBuilder,
    this.loadingBuilder,
    this.onImageTap,
    this.onProcessedHtml,
    this.onNavigation,
    this.onFetching,
    this.method,
    this.userAgent,
    this.textStyle,
    this.factoryBuilder,
    this.classesToPreserve = const [],
    this.disableJsonLd = true,
    this.onScroll,
    this.customStylesBuilder,
    this.customWidgetBuilder,
    this.rendererPadding,
    this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReaderModeState();
}

class _ReaderModeState extends State<ReaderMode> {
  late ReaderModeController _controller;
  late final ScrollController _scrollController;
  double _scrollOffsetToRestore = .0;
  bool _isCurrentlyFetching = false;

  @override
  void initState() {
    _controller = widget.controller;
    _scrollController =
        widget.scrollController ?? ScrollController(keepScrollOffset: false);

    _attachController(_controller);
    _scrollController.addListener(_observeScrolling);

    super.initState();
  }

  @override
  void dispose() {
    _detachController(_controller);
    _scrollController.removeListener(_observeScrolling);

    _scrollController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(ReaderMode oldWidget) {
    final currentController = widget.controller;

    if (currentController != oldWidget.controller) {
      _detachController(_controller);
      _attachController(currentController);

      _controller = currentController;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final uri = _controller.uri;

    if (uri == null) {
      return Container();
    }

    return HttpLoader(
      method: widget.method,
      userAgent: widget.userAgent,
      onProcessedHtml: _onProcessedHtml,
      onNavigation: _onNavigation,
      onFetching: _onFetching,
      builder: _builder(uri),
      errorBuilder: _errorBuilder(uri),
      uri: uri,
      disableJsonLd: widget.disableJsonLd,
    );
  }

  Widget Function(BuildContext, ProcessHtmlResult?) _builder(Uri uri) =>
      (BuildContext context, ProcessHtmlResult? result) {
        final html = result?.contents;
        final loadingBuilder = widget.loadingBuilder;

        if (html != null && html.isNotEmpty) {
          return _buildHtmlWidget(uri: uri, html: html);
        }

        if (loadingBuilder != null) {
          return loadingBuilder();
        }

        return Container();
      };

  Widget Function(BuildContext, ProcessHtmlError?) _errorBuilder(Uri uri) => (
        BuildContext context,
        ProcessHtmlError? error,
      ) {
        final errorBuilder = widget.errorBuilder;

        if (errorBuilder != null) {
          return errorBuilder(context, error);
        }

        return Text('$kReaderModeStandardExceptionMessage$uri');
      };

  Future<ProcessHtmlResult> _onProcessedHtml(ProcessHtmlResult result) async {
    final onProcessedHtml = widget.onProcessedHtml;
    var updatedResult = result;

    if (onProcessedHtml != null) {
      updatedResult = await onProcessedHtml(result);
    }

    return updatedResult;
  }

  void _onNavigation(Uri? previousUri, Uri currentUri) {
    final onNavigation = widget.onNavigation;

    if (previousUri != null && _scrollController.hasClients) {
      _controller.setScrollPositionForPreviousIndex(
          previousUri, _scrollController.offset);
    }

    _scrollOffsetToRestore = _controller.positionForUri(currentUri);

    if (onNavigation != null) {
      onNavigation(previousUri, currentUri);
    }
  }

  void _onFetching(bool isFetching) {
    final onFetching = widget.onFetching;

    _isCurrentlyFetching = isFetching;

    if (onFetching != null) {
      onFetching(isFetching);
    }

    if (!isFetching) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollOffsetToRestore);
        }
      });
    }
  }

  Widget _buildHtmlWidget({required String html, required Uri uri}) {
    return HtmlWidget(
      html,
      buildAsync: false,
      factoryBuilder: widget.factoryBuilder,
      renderMode: ListViewMode(
        controller: _scrollController,
        padding: widget.rendererPadding,
      ),
      textStyle: widget.textStyle,
      onTapImage: widget.onImageTap,
      onTapUrl: (url) {
        if (!_isCurrentlyFetching) {
          final linkUri = Uri.parse(url);

          if (linkUri.host.isEmpty) {
            _controller.loadUri(uri.replace(path: url));
          } else {
            _controller.loadUri(linkUri);
          }

          return true;
        }

        return false;
      },
      customStylesBuilder: widget.customStylesBuilder,
      customWidgetBuilder: widget.customWidgetBuilder,
    );
  }

  void _onController() {
    setState(() {});
  }

  void _detachController(ReaderModeController controller) {
    controller.removeListener(_onController);
  }

  void _attachController(ReaderModeController controller) {
    controller.addListener(_onController);
  }

  void _observeScrolling() {
    final value = _scrollController.position.pixels;
    _controller.updateScrollPositionForCurrentIndex(value);

    widget.onScroll?.call(value);
  }
}
