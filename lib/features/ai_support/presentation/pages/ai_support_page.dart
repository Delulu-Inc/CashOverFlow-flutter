import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/chat_models.dart';
import '../../data/repositories/ai_support_repository.dart';

/// "Ask AI" chat: free questions and what-if simulations.
class AiSupportPage extends StatefulWidget {
  const AiSupportPage({super.key});

  @override
  State<AiSupportPage> createState() => _AiSupportPageState();
}

class _AiSupportPageState extends State<AiSupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<ChatMessage> _messages = [
    const ChatMessage(
      sender: 'ai',
      text:
          "I've got your current cash-flow data ready. Ask me anything — no need to start from a suggestion.",
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  static bool _isSimulationRequest(String text) {
    final lower = text.toLowerCase();
    return lower.contains('simulate') || lower.contains('what if');
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final repository = context.read<AiSupportRepository>();

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: text));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    final ChatMessage reply;
    if (_isSimulationRequest(text)) {
      final simResult = await repository.runSimulation(
        SimulationRequestDto(action: 'DELAY_PAYMENT', amount: 15000, days: 14),
      );
      reply = simResult != null
          ? ChatMessage(
              sender: 'ai',
              text: 'Here is the simulation result for your request:',
              type: MessageType.whatIfTable,
              simulationData: simResult,
            )
          : const ChatMessage(
              sender: 'ai',
              text: 'Failed to retrieve simulation data from the server.',
            );
    } else {
      final chatResult = await repository.sendChatMessage(
        ChatMessageDto(message: text),
      );
      reply = ChatMessage(sender: 'ai', text: chatResult.reply);
    }

    // The user may have switched page while the AI was answering.
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _messages.add(reply);
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask AI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ask anything about your cash flow, simulate what-if scenarios, view forecasts, or weigh a decision.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                  itemBuilder: (context, index) =>
                      _buildMessageItem(_messages[index]),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
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
    final isAi = message.isAi;
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
                color: isAi ? Colors.white : AppColors.primary,
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
                    SelectableText(
                      message.text!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isAi ? AppColors.textPrimary : Colors.white,
                        height: 1.4,
                      ),
                    )
                  else if (isAi && message.type == MessageType.text)
                    const Text(
                      'No response content received.',
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
        color: AppColors.appBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulation Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 4,
              children: [
                Text('Starting: ${Formatters.currency(data.startingBalance)}'),
                Text('Ending: ${Formatters.currency(data.endingBalance)}'),
                Text(
                  'Lowest: ${Formatters.currency(data.lowestCashPoint)}',
                  style: const TextStyle(color: Color(0xFFD97706)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 20),
          if (data.dailyTimeline != null && data.dailyTimeline!.isNotEmpty) ...[
            const Text(
              'Timeline:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 32,
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Inflow')),
                  DataColumn(label: Text('Outflow')),
                  DataColumn(label: Text('Closing')),
                ],
                rows: [
                  for (final e in data.dailyTimeline!)
                    DataRow(
                      cells: [
                        DataCell(Text(e.date ?? '')),
                        DataCell(
                          Text(
                            Formatters.currency(e.totalInflow),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        DataCell(
                          Text(
                            Formatters.currency(e.totalOutflow),
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        DataCell(Text(Formatters.currency(e.closingBalance))),
                      ],
                    ),
                ],
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
              textInputAction: TextInputAction.send,
              decoration: const InputDecoration(
                hintText: 'Ask me anything about your cash flow...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: IconButton(
              tooltip: 'Send',
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
