import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/cash_forecast.dart';
import '../models/kpi_data.dart';
import '../models/recommendation.dart';
import '../models/risk_signal.dart';

/// Cash-flow analytics shown on the dashboard.
class DashboardRepository {
  DashboardRepository({required this._api});

  final ApiClient _api;

  /// `GET /kpis`
  Future<KpiData> fetchKpis(int horizonDays) async {
    final response = await _api.get(
      '/kpis',
      query: {'companyId': AppConfig.demoCompanyId, 'horizonDays': horizonDays},
    );
    final json = response.json;

    if (response.statusCode == 200 && json != null) {
      return KpiData.fromJson(json);
    }
    if (response.statusCode == 401) {
      throw const ApiException(
        'Unauthorized: Invalid or expired token',
        statusCode: 401,
      );
    }
    throw ApiException(
      'Failed to load KPIs: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  /// `GET /forecast`
  Future<CashForecastData> fetchForecast(int horizonDays) async {
    final response = await _api.get(
      '/forecast',
      query: {'companyId': AppConfig.demoCompanyId, 'horizonDays': horizonDays},
    );
    final json = response.json;

    if (response.statusCode == 200 && json != null) {
      return CashForecastData.fromJson(json);
    }
    throw ApiException(
      'Failed to load forecast data (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  /// `GET /risks` – falls back to sample signals when unavailable.
  Future<List<RiskSignal>> fetchRiskSignals({
    required String asOf,
    required int horizonDays,
  }) async {
    try {
      final response = await _api.get(
        '/risks',
        query: {'as_of': asOf, 'horizon': horizonDays, 'stress_buffer': false},
      );
      final signals = response.json?['signals'];
      if (response.statusCode == 200 && signals is List && signals.isNotEmpty) {
        return signals
            .whereType<Map<String, dynamic>>()
            .map(RiskSignal.fromJson)
            .toList();
      }
    } catch (error) {
      AppLogger.error('Risks fetch error', error);
    }
    return RiskSignal.fallback(horizonDays);
  }

  /// `GET /explanation` – falls back to sample recommendations when
  /// unavailable.
  Future<List<RecommendationItem>> fetchRecommendations({
    required String asOf,
    required int horizonDays,
  }) async {
    try {
      final response = await _api.get(
        '/explanation',
        query: {
          'as_of': asOf,
          'horizon': horizonDays,
          'language': 'en',
          'stress_buffer': false,
        },
      );

      if (response.statusCode == 200) {
        final decoded = response.data;
        Object? items;

        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map<String, dynamic>) {
          items =
              decoded['recommendations'] ??
              decoded['actions'] ??
              decoded['items'] ??
              decoded['explanations'];

          if (items is! List &&
              (decoded['narrative'] != null || decoded['summary'] != null)) {
            return [
              RecommendationItem(
                tag: '# Liquidity Overview',
                title:
                    decoded['summary']?.toString() ??
                    decoded['narrative']?.toString() ??
                    'Review operating cash balance for the upcoming period.',
                points: [
                  'Horizon: $horizonDays days',
                  'Buffer: Target maintained',
                  'Confidence: High',
                ],
              ),
            ];
          }
        }

        if (items is List && items.isNotEmpty) {
          return items
              .whereType<Map<String, dynamic>>()
              .map(RecommendationItem.fromJson)
              .toList();
        }
      }
    } catch (error) {
      AppLogger.error('Recommendations fetch error', error);
    }
    return RecommendationItem.fallback(horizonDays);
  }
}
