class ApiConfig {
  static const bool _isProd = bool.fromEnvironment('dart.vm.product');
  static const String _defaultBaseUrl = 'https://api.jomngaji.com';
  static const String _defaultBaseUrls = _isProd
      ? 'https://api.jomngaji.com'
      : 'http://10.0.2.2:4000,http://192.168.1.141:4000,http://10.179.249.20:4000';

  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _rawBaseUrls = String.fromEnvironment(
    'API_BASE_URLS',
    defaultValue: _defaultBaseUrls,
  );

  static List<String> get baseUrls {
    final candidates = <String>[
      if (_rawBaseUrl.trim().isNotEmpty) _rawBaseUrl.trim(),
      if (_rawBaseUrl.trim().isEmpty)
        ..._rawBaseUrls.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
    ];
    if (candidates.isEmpty) {
      candidates.add(_defaultBaseUrl);
    }

    for (final url in candidates) {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        throw StateError('API_BASE_URL tidak valid: $url');
      }
      final allowHttpInDev = !_isProd;
      if (uri.scheme != 'https' && !allowHttpInDev) {
        throw StateError('API_BASE_URL wajib https untuk production/non-local: $url');
      }
    }
    return candidates
        .map((e) => e.endsWith('/') ? e.substring(0, e.length - 1) : e)
        .toList();
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
