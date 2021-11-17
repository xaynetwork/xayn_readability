import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http_client/http_client.dart';
import 'package:xayn_readability/src/widgets/client/client.dart';
import 'package:xayn_readability/src/widgets/jobs/make_readable.dart';
import 'package:xayn_readability/src/widgets/objects/process_html_result.dart';
import 'package:xayn_readability/xayn_readability.dart';

/// The signature of [HttpLoader.builder] functions.
typedef ChildBuilder = Widget Function(BuildContext, ProcessHtmlResult?);

/// The signature of [HttpLoader.errorBuilder] functions.
typedef ErrorBuilder = Widget Function(BuildContext, ProcessHtmlError?);

/// The signature of [HttpLoader.onProcessedHtml] functions.
typedef OnProcessedHtml = Future<ProcessHtmlResult> Function(ProcessHtmlResult);

/// The signature of [HttpLoader.onNavigation] functions.
typedef OnNavigation = void Function(Uri?, Uri);

/// The signature of [HttpLoader.onFetching] functions.
typedef OnFetching = void Function(bool);

const String _kMethod = 'GET';
const String _kUserAgent =
    'Mozilla/5.0 (Linux; Android 11; sdk_gphone_x86_arm Build/RPB2.200611.009; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.101 Mobile Safari/537.36';

/// A [Widget] which loads the provided [uri] and then transforms its html contents into reader mode html.
///
/// Use [builder] to create a child which consumes the result, in [ProcessHtmlResult] format.
/// In case of an error, pass an [errorBuilder] which will be rendered instead.
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
class HttpLoader extends StatefulWidget {
  /// Builds a child [Widget] from [BuildContext] and [ProcessHtmlResult]
  final ChildBuilder builder;

  /// Builds an error [Widget] from [BuildContext] and [ProcessHtmlError]
  final ErrorBuilder errorBuilder;

  /// A handler which is called when the html has been fully processed
  /// Optionally return a modified [ProcessHtmlResult] if custom post-processing is required, or return the
  /// same [ProcessHtmlResult] which was presented as an argument.
  final OnProcessedHtml? onProcessedHtml;

  /// A handler which is called whenever navigation from an old url, to a new url, will take place.
  final OnNavigation? onNavigation;

  /// A handler which indicates when data is being fetched, or not.
  final OnFetching? onFetching;

  /// The [Uri] which should be fetched
  final Uri uri;

  /// The http request method, defaults to GET
  final String method;

  /// The user agent that is passed with the reqsuest
  final String userAgent;

  /// A list of classes which should be preserved while parsing html
  final List<String> classesToPreserve;

  /// A flag to either enable or disable jsonLd parsing
  final bool disableJsonLd;

  /// The default text style which is used to display textual content
  final TextStyle? textStyle;

  /// Constructs a new [HttpLoader] [Widget]
  const HttpLoader({
    Key? key,
    required this.builder,
    required this.errorBuilder,
    required this.uri,
    this.textStyle,
    this.onProcessedHtml,
    this.onNavigation,
    this.onFetching,
    this.classesToPreserve = const [],
    this.disableJsonLd = true,
    String? method,
    String? userAgent,
  })  : method = method ?? _kMethod,
        userAgent = userAgent ?? _kUserAgent,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _HttpLoaderState();
}

class _HttpLoaderState extends State<HttpLoader> {
  late final Client client;
  late Widget child;
  final Map<Uri, _BuiltChildFromHtml> builtChildren =
      <Uri, _BuiltChildFromHtml>{};

  @override
  void didChangeDependencies() {
    client = createHttpClient(userAgent: widget.userAgent);
    child = widget.builder(context, null);

    _fetchResult();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(HttpLoader oldWidget) {
    if (widget.uri != oldWidget.uri || widget.method != oldWidget.method) {
      _fetchResult(oldWidget.uri);
    }

    if (widget.textStyle != oldWidget.textStyle) {
      final existingChild = builtChildren[widget.uri];

      child = widget.builder(context, existingChild?.processedHtmlResult);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    builtChildren.clear();
    client.close(force: true);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }

  Future<void> _fetchResult([Uri? previousUri]) async {
    try {
      final onFetching = widget.onFetching;
      final onNavigation = widget.onNavigation;

      if (onNavigation != null) {
        onNavigation(previousUri, widget.uri);
      }

      final existingChild = builtChildren[widget.uri];
      ProcessHtmlResult? readerModeContents;

      if (existingChild != null) {
        readerModeContents = existingChild.processedHtmlResult;
      } else {
        if (onFetching != null) {
          onFetching(true);
        }

        final html = await _loadUri().onError((e, s) {
          log('$e $s');

          return '';
        });

        if (html.isNotEmpty) {
          readerModeContents = await compute(
              makeReadable,
              MakeReadablePayload(
                contents: html,
                options: ParserOptions(
                  disableJsonLd: widget.disableJsonLd,
                  classesToPreserve: widget.classesToPreserve,
                  baseUri: widget.uri.scheme != 'data'
                      ? widget.uri.replace(
                          pathSegments: const [],
                          queryParameters: const <String, dynamic>{},
                          fragment: null)
                      : null,
                ),
              ));
        }
      }

      final onProcessedHtml = widget.onProcessedHtml;
      ProcessHtmlError? error;

      if (onProcessedHtml != null) {
        try {
          if (readerModeContents != null && existingChild == null) {
            readerModeContents = await onProcessedHtml(readerModeContents);
          }
        } catch (e) {
          error = ProcessHtmlError(e);
        }
      }

      setState(() {
        if (onFetching != null) {
          onFetching(false);
        }

        if (existingChild != null) {
          child = existingChild.child;
        } else {
          if (readerModeContents == null) {
            child = widget.errorBuilder(context, error);
          } else {
            child = widget.builder(context, readerModeContents);
            builtChildren[widget.uri] = _BuiltChildFromHtml(
                child: child, processedHtmlResult: readerModeContents);
          }
        }
      });
    } catch (e) {
      log('error: $e');
    }
  }

  Future<String> _loadUri() async {
    const decoder = Utf8Decoder();

    if (widget.uri.scheme == 'data') {
      return decoder.convert(UriData.fromUri(widget.uri).contentAsBytes());
    }

    final url = widget.uri.toString();
    final response = await client.send(Request(widget.method, url));

    if (response.body is String) {
      return response.body as String;
    }

    writeToBuffer(StringBuffer buffer, String part) => buffer..write(part);

    final buffer = await response.bodyAsStream!
        .transform(decoder)
        .fold(StringBuffer(), writeToBuffer);

    return buffer.toString();
  }
}

class _BuiltChildFromHtml {
  final Widget child;
  final ProcessHtmlResult processedHtmlResult;

  const _BuiltChildFromHtml({
    required this.child,
    required this.processedHtmlResult,
  });
}

/// An error which is created when the parser was unable to convert content into reader mode content
class ProcessHtmlError extends Error {
  /// The underlying error
  final Object error;

  /// Constructs a new [ProcessHtmlError]
  ProcessHtmlError(this.error);

  @override
  String toString() {
    const nameString = '(ProcessHtmlError)';
    final message = Error.safeToString(error);
    final messageString = ': $message';

    return '$nameString$messageString';
  }
}
