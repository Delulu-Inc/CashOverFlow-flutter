enum MessageType { text, whatIfTable, recommendationDetails }

/// A bubble displayed in the AI chat.
class ChatMessage {
  const ChatMessage({
    required this.sender,
    this.text,
    this.type = MessageType.text,
    this.simulationData,
  });

  /// `ai` or `user`.
  final String sender;
  final String? text;
  final MessageType type;
  final ReplaySimulationResultDto? simulationData;

  bool get isAi => sender == 'ai';
}

/// Body of `POST /Chat/message`.
class ChatMessageDto {
  ChatMessageDto({
    this.companyId = 'DEMO',
    required this.message,
    String? asOf,
    this.scenario = 'public_sector_freeze',
    this.cashOnHand = 0.0,
    this.runwayDays = -1,
    this.arOutstanding = 0.0,
    this.arOverdue = 0.0,
  }) : asOf = asOf ?? '2026-09-15';

  final String companyId;
  final String message;
  final String asOf;
  final String scenario;
  final double cashOnHand;
  final int runwayDays;
  final double arOutstanding;
  final double arOverdue;

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'CompanyId': companyId,
      'message': message,
      'asOf': asOf,
      'AsOf': asOf,
      'company_id': companyId,
      'as_of': asOf,
      'scenario': scenario,
      'cash_on_hand': cashOnHand,
      'runway_days': runwayDays,
      'ar_outstanding': arOutstanding,
      'ar_overdue': arOverdue,
    };
  }
}

class ChatResponseDto {
  const ChatResponseDto({required this.reply, required this.timestamp});

  final String reply;
  final String timestamp;

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) {
    final dynamic rawReply =
        json['reply'] ??
        json['message'] ??
        json['text'] ??
        json['response'] ??
        json['data'] ??
        json['answer'];

    final extractedReply = rawReply?.toString() ?? '';

    return ChatResponseDto(
      reply: extractedReply.trim().isNotEmpty
          ? extractedReply
          : 'Received empty response from server.',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }
}

/// Body of `POST /simulate`.
class SimulationRequestDto {
  SimulationRequestDto({
    this.companyId = 'company_123',
    String? asOf,
    this.horizon = 90,
    required this.action,
    this.amount = 0.0,
    this.days = 0,
    this.invoiceUuids = const [],
    this.stressBuffer = true,
    this.scenario = 'default',
  }) : asOf = asOf ?? '2026-09-15';

  final String companyId;
  final String asOf;
  final int horizon;
  final String action;
  final double amount;
  final int days;
  final List<String> invoiceUuids;
  final bool stressBuffer;
  final String scenario;

  Map<String, dynamic> toJson() => {
    'company_id': companyId,
    'as_of': asOf,
    'horizon': horizon,
    'action': action,
    'amount': amount,
    'days': days,
    'invoice_uuids': invoiceUuids,
    'stress_buffer': stressBuffer,
    'scenario': scenario,
  };
}

class ReplaySimulationResultDto {
  const ReplaySimulationResultDto({
    this.companyId,
    this.startDate,
    this.endDate,
    this.startingBalance,
    this.endingBalance,
    this.totalHistoricalInflow,
    this.totalHistoricalOutflow,
    this.lowestCashPoint,
    this.dailyTimeline,
  });

  final String? companyId;
  final String? startDate;
  final String? endDate;
  final double? startingBalance;
  final double? endingBalance;
  final double? totalHistoricalInflow;
  final double? totalHistoricalOutflow;
  final double? lowestCashPoint;
  final List<DailyTimelineDto>? dailyTimeline;

  factory ReplaySimulationResultDto.fromJson(Map<String, dynamic> json) {
    double? read(String key) => (json[key] as num?)?.toDouble();

    return ReplaySimulationResultDto(
      companyId: json['companyId']?.toString(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      startingBalance: read('startingBalance'),
      endingBalance: read('endingBalance'),
      totalHistoricalInflow: read('totalHistoricalInflow'),
      totalHistoricalOutflow: read('totalHistoricalOutflow'),
      lowestCashPoint: read('lowestCashPoint'),
      dailyTimeline: json['dailyTimeline'] is List
          ? (json['dailyTimeline'] as List)
                .whereType<Map<String, dynamic>>()
                .map(DailyTimelineDto.fromJson)
                .toList()
          : null,
    );
  }
}

class DailyTimelineDto {
  const DailyTimelineDto({
    this.date,
    this.openingBalance,
    this.totalInflow,
    this.totalOutflow,
    this.closingBalance,
  });

  final String? date;
  final double? openingBalance;
  final double? totalInflow;
  final double? totalOutflow;
  final double? closingBalance;

  factory DailyTimelineDto.fromJson(Map<String, dynamic> json) {
    double? read(String key) => (json[key] as num?)?.toDouble();

    return DailyTimelineDto(
      date: json['date']?.toString(),
      openingBalance: read('openingBalance'),
      totalInflow: read('totalInflow'),
      totalOutflow: read('totalOutflow'),
      closingBalance: read('closingBalance'),
    );
  }
}
