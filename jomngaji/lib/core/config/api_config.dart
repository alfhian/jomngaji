class ApiConfig {
  static const bool _isProd = bool.fromEnvironment('dart.vm.product');
  static const bool _allowHttpInProd = bool.fromEnvironment(
    'ALLOW_HTTP_IN_PROD',
    defaultValue: false,
  );
  static const String _defaultBaseUrl = 'https://api.jomngaji.com';
  static const String _defaultBaseUrls = _isProd
      ? 'https://api.jomngaji.com'
      : 'http://10.0.2.2:4000';

  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _rawBaseUrls = String.fromEnvironment(
    'API_BASE_URLS',
    defaultValue: _defaultBaseUrls,
  );

  static List<String> get baseUrls {
    final rawCandidates = <String>[
      if (_rawBaseUrl.trim().isNotEmpty) _rawBaseUrl.trim(),
      if (_rawBaseUrl.trim().isEmpty)
        ..._rawBaseUrls.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
    ];
    if (rawCandidates.isEmpty) {
      rawCandidates.add(_defaultBaseUrl);
    }

    final normalized = <String>[];
    for (final url in rawCandidates) {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        continue;
      }
      final allowHttpInDev = !_isProd;
      final allowHttpViaFlag = _isProd && _allowHttpInProd;
      if (uri.scheme != 'https' && !allowHttpInDev && !allowHttpViaFlag) {
        continue;
      }
      normalized.add(url.endsWith('/') ? url.substring(0, url.length - 1) : url);
    }

    if (normalized.isEmpty) {
      return [_defaultBaseUrl];
    }

    return normalized;
  }

  static String get baseUrl {
    return baseUrls.first;
  }

  static String endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalizedPath';
  }

  static List<String> endpointCandidates(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return baseUrls.map((base) => '$base$normalizedPath').toList();
  }
}
