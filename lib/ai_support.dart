import 'dart:convert';
//import 'package:cash_overflow/widgets/Sidebar.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_8/sidebar_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// 1. MODELS & DTOS
// =============================================================================

enum MessageType { text, whatIfTable, recommendationDetails }

class ChatMessage {
  final String sender;
  final String? text;
  final MessageType type;
  final ReplaySimulationResultDto? simulationData;

  ChatMessage({
    required this.sender,
    this.text,
    this.type = MessageType.text,
    this.simulationData,
  });
}

class ChatMessageDto {
  final String companyId;
  final String message;
  final String asOf;
  final String scenario;
  final double cashOnHand;
  final int runwayDays;
  final double arOutstanding;
  final double arOverdue;

  ChatMessageDto({
    this.companyId = "DEMO",
    required this.message,
    String? asOf,
    this.scenario = "public_sector_freeze",
    this.cashOnHand = 0.0,
    this.runwayDays = -1,
    this.arOutstanding = 0.0,
    this.arOverdue = 0.0,
  }) : asOf = asOf ?? "2026-09-15";

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
  final String reply;
  final String timestamp;

  ChatResponseDto({required this.reply, required this.timestamp});

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) {
    final String extractedReply =
        json['reply'] ??
        json['message'] ??
        json['text'] ??
        json['response'] ??
        json['data'] ??
        json['answer'] ??
        '';

    return ChatResponseDto(
      reply: extractedReply.trim().isNotEmpty
          ? extractedReply
          : "Received empty response from server.",
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class SimulationRequestDto {
  final String companyId;
  final String asOf;
  final int horizon;
  final String action;
  final double amount;
  final int days;
  final List<String> invoiceUuids;
  final bool stressBuffer;
  final String scenario;

  SimulationRequestDto({
    this.companyId = "company_123",
    String? asOf,
    this.horizon = 90,
    required this.action,
    this.amount = 0.0,
    this.days = 0,
    this.invoiceUuids = const [],
    this.stressBuffer = true,
    this.scenario = "default",
  }) : asOf = asOf ?? "2026-09-15";

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
  final String? companyId;
  final String? startDate;
  final String? endDate;
  final double? startingBalance;
  final double? endingBalance;
  final double? totalHistoricalInflow;
  final double? totalHistoricalOutflow;
  final double? lowestCashPoint;
  final List<DailyTimelineDto>? dailyTimeline;

  ReplaySimulationResultDto({
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

  factory ReplaySimulationResultDto.fromJson(Map<String, dynamic> json) {
    return ReplaySimulationResultDto(
      companyId: json['companyId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startingBalance: (json['startingBalance'] as num?)?.toDouble(),
      endingBalance: (json['endingBalance'] as num?)?.toDouble(),
      totalHistoricalInflow: (json['totalHistoricalInflow'] as num?)
          ?.toDouble(),
      totalHistoricalOutflow: (json['totalHistoricalOutflow'] as num?)
          ?.toDouble(),
      lowestCashPoint: (json['lowestCashPoint'] as num?)?.toDouble(),
      dailyTimeline: json['dailyTimeline'] != null
          ? (json['dailyTimeline'] as List)
                .map((i) => DailyTimelineDto.fromJson(i))
                .toList()
          : null,
    );
  }
}

class DailyTimelineDto {
  final String? date;
  final double? openingBalance;
  final double? totalInflow;
  final double? totalOutflow;
  final double? closingBalance;

  DailyTimelineDto({
    this.date,
    this.openingBalance,
    this.totalInflow,
    this.totalOutflow,
    this.closingBalance,
  });

  factory DailyTimelineDto.fromJson(Map<String, dynamic> json) {
    return DailyTimelineDto(
      date: json['date'],
      openingBalance: (json['openingBalance'] as num?)?.toDouble(),
      totalInflow: (json['totalInflow'] as num?)?.toDouble(),
      totalOutflow: (json['totalOutflow'] as num?)?.toDouble(),
      closingBalance: (json['closingBalance'] as num?)?.toDouble(),
    );
  }
}

// =============================================================================
// 2. API SERVICE LAYER
// =============================================================================

class ApiService {
  static const String baseUrl = "https://cashoverflow-api.runasp.net/v1";

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<ChatResponseDto?> sendChatMessage(ChatMessageDto dto) async {
    final url = Uri.parse('$baseUrl/Chat/message');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(dto.toJson()),
      );

      debugPrint(
        "Server Raw Response [${response.statusCode}]: ${response.body}",
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ChatResponseDto.fromJson(decoded);
        } else if (decoded is String) {
          return ChatResponseDto(
            reply: decoded,
            timestamp: DateTime.now().toIso8601String(),
          );
        }
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final errorMessage =
          data['reply'] ??
          data['detail'] ??
          data['title'] ??
          data['message'] ??
          'Error ${response.statusCode}';
      return ChatResponseDto(
        reply: "[Server Error ${response.statusCode}]: $errorMessage",
        timestamp: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      return ChatResponseDto(
        reply: "[Connection Exception]: $e",
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  static Future<ReplaySimulationResultDto?> runSimulation(
    SimulationRequestDto dto,
  ) async {
    final url = Uri.parse('$baseUrl/simulate');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        return ReplaySimulationResultDto.fromJson(jsonDecode(response.body));
      } else {
        debugPrint('Error status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error running simulation: $e');
    }
    return null;
  }
}

// =============================================================================
// 3. UI SCREEN & WIDGETS
// =============================================================================

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'ai',
      text:
          "Ive got your current cash-flow data ready. Ask me anything — no need to start from a suggestion.",
    ),
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: text));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    if (text.toLowerCase().contains("simulate") ||
        text.toLowerCase().contains("what if")) {
      final simResult = await ApiService.runSimulation(
        SimulationRequestDto(action: "DELAY_PAYMENT", amount: 15000, days: 14),
      );

      setState(() {
        _isLoading = false;
        if (simResult != null) {
          _messages.add(
            ChatMessage(
              sender: 'ai',
              text: 'Here is the simulation result for your request:',
              type: MessageType.whatIfTable,
              simulationData: simResult,
            ),
          );
        } else {
          _messages.add(
            ChatMessage(
              sender: 'ai',
              text: 'Failed to retrieve simulation data from the server.',
            ),
          );
        }
      });
    } else {
      final chatResult = await ApiService.sendChatMessage(
        ChatMessageDto(message: text),
      );

      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage(
            sender: 'ai',
            text: chatResult?.reply ?? "No response received from the server.",
          ),
        );
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Ask AI",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ask anything about your cash flow, simulate what-if scenarios, view forecasts, or weigh a decision.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageItem(message);
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              const SizedBox(height: 12),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isAi = message.sender == 'ai';
    final hasText = message.text != null && message.text!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: isAi
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isAi ? Colors.white : const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isAi
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasText)
                    Text(
                      message.text!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isAi ? const Color(0xFF1E293B) : Colors.white,
                        height: 1.4,
                      ),
                    )
                  else if (isAi && message.type == MessageType.text)
                    const Text(
                      "No response content received.",
                      style: TextStyle(fontSize: 14, color: Colors.redAccent),
                    ),
                  if (message.type == MessageType.whatIfTable &&
                      message.simulationData != null) ...[
                    const SizedBox(height: 12),
                    _buildSimulationTable(message.simulationData!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationTable(ReplaySimulationResultDto data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Simulation Overview",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Starting: \$${data.startingBalance ?? 0}"),
              Text("Ending: \$${data.endingBalance ?? 0}"),
              Text(
                "Lowest: \$${data.lowestCashPoint ?? 0}",
                style: const TextStyle(color: Color(0xFFD97706)),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 20),
          if (data.dailyTimeline != null && data.dailyTimeline!.isNotEmpty) ...[
            const Text(
              "Timeline:",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 32,
                columns: const [
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Inflow")),
                  DataColumn(label: Text("Outflow")),
                  DataColumn(label: Text("Closing")),
                ],
                rows: data.dailyTimeline!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(Text(e.date ?? "")),
                          DataCell(
                            Text(
                              "\$${e.totalInflow ?? 0}",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                          DataCell(
                            Text(
                              "\$${e.totalOutflow ?? 0}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          DataCell(Text("\$${e.closingBalance ?? 0}")),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ask me anything about your cash flow...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Color(0xFF1E293B)),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          CircleAvatar(
            backgroundColor: const Color(0xFF1D4ED8),
            radius: 18,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 18,
              ),
              onPressed: _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
