import 'package:http_client/browser.dart' as http;

/// Returns an implementation of [http.Client] which is Platform-specific
http.Client createPlatformSpecific({String? userAgent}) => http.BrowserClient();
