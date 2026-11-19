import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/chat_models.dart';

/// AI assistant: free text chat and what-if simulations.
class AiSupportRepository {
  AiSupportRepository({required this._api});

  final ApiClient _api;

  /// `POST /Chat/message` – never throws; failures are returned as a reply
  /// so they can be displayed inside the conversation.
  Future<ChatResponseDto> sendChatMessage(ChatMessageDto dto) async {
    try {
      final response = await _api.post(
        '/Chat/message',
        body: dto.toJson(),
        timeout: AppConfig.aiRequestTimeout,
      );
      final decoded = response.data;

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return ChatResponseDto.fromJson(decoded);
        }
        final text = decoded is String ? decoded : response.body;
        if (text.trim().isNotEmpty) {
          return ChatResponseDto(reply: text, timestamp: _now);
        }
      }

      final message =
          ApiException.messageFrom(decoded) ?? 'Error ${response.statusCode}';
      return ChatResponseDto(
        reply: '[Server Error ${response.statusCode}]: $message',
        timestamp: _now,
      );
    } on ApiException catch (error) {
      return ChatResponseDto(
        reply: '[Connection Exception]: ${error.message}',
        timestamp: _now,
      );
    }
  }

  /// `POST /simulate` – returns `null` when the simulation is unavailable.
  Future<ReplaySimulationResultDto?> runSimulation(
    SimulationRequestDto dto,
  ) async {
    try {
      final response = await _api.post(
        '/simulate',
        body: dto.toJson(),
        timeout: AppConfig.aiRequestTimeout,
      );
      final json = response.json;
      if (response.statusCode == 200 && json != null) {
        return ReplaySimulationResultDto.fromJson(json);
      }
    } on ApiException {
      // Reported to the user as "Failed to retrieve simulation data".
    }
    return null;
  }

  static String get _now => DateTime.now().toIso8601String();
}
