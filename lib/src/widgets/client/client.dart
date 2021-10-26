import 'package:http_client/http_client.dart' as http;

import 'package:reader_mode/src/widgets/client/client_stub.dart'
    if (dart.library.io) 'package:reader_mode/src/widgets/client/client_native.dart'
    if (dart.library.html) 'package:reader_mode/src/widgets/client/client_web.dart';

/// Returns an implementation of [http.Client] which is Platform-specific
http.Client createHttpClient({String? userAgent}) =>
    createPlatformSpecific(userAgent: userAgent);
