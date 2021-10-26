import 'package:http_client/http_client.dart' as http;

/// Returns an implementation of [http.Client] which is Platform-specific
http.Client createPlatformSpecific({String? userAgent}) =>
    throw UnsupportedError('Cannot create client');
