class ApiConfig {
  static const bool _isProd = bool.fromEnvironment('dart.vm.product');
  static const String _defaultBaseUrl = _isProd
      ? 'https://api.jomngaji.com'
      : 'http://10.0.2.2:4000';
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static String get baseUrl {
    final normalized = _rawBaseUrl.endsWith('/')
        ? _rawBaseUrl.substring(0, _rawBaseUrl.length - 1)
        : _rawBaseUrl;
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL tidak valid: $normalized');
    }

    final allowHttpInDev = !_isProd;

    if (uri.scheme != 'https' && !allowHttpInDev) {
      throw StateError(
        'API_BASE_URL wajib https untuk production/non-local: $normalized',
      );
    }
    return normalized;
  }

  static String endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalizedPath';
  }
}
