/// Application-wide configuration values.
///
/// Everything that used to be hard-coded across pages (API host, timeouts,
/// demo dataset anchors) lives here so it can be changed in one place.
abstract final class AppConfig {
  static const String appName = 'Cash Overflow';

  /// Base URL of the Cash Overflow REST API.
  ///
  /// Can be overridden at build time:
  /// `flutter build web --dart-define=API_BASE_URL=https://example.com/v1`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://cashoverflow-api.runasp.net/v1',
  );

  /// Default timeout applied to every API request.
  static const Duration requestTimeout = Duration(seconds: 30);

  /// AI chat / simulation requests can take longer to generate.
  static const Duration aiRequestTimeout = Duration(seconds: 90);

  /// Sub-path used when the web build is served from GitHub Pages.
  static const String githubPagesBasePath = '/CashOverFlow-flutter';

  /// Company identifier of the demo dataset exposed by the API.
  static const String demoCompanyId = 'DEMO';

  /// The demo dataset served by the API is anchored on this date.
  static final DateTime demoAsOfDate = DateTime(2026, 9, 1);

  /// The single Cash Overflow plan, as shown on the pricing section.
  ///
  /// Every page (pricing, checkout, payment results, billing) reads the
  /// price from here, and it is the amount sent to the checkout API.
  static const String planName = 'Pro';
  static const int planPricePerYear = 499; // USD

  /// Browser tab title, e.g. `Log In · Cash Overflow`.
  static String pageTitle(String? title) =>
      title == null ? appName : '$title · $appName';
}
