import 'package:http_client/console.dart' as http;

/// Returns an implementation of [http.Client] which is Platform-specific
http.Client createPlatformSpecific({String? userAgent}) =>
    http.ConsoleClient(userAgent: userAgent);
