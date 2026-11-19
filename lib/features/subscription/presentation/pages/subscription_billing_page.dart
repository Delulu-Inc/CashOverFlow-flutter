import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/subscription_models.dart';
import '../../data/repositories/subscription_repository.dart';

/// Owner-only page: plan, payment method and billing history.
class SubscriptionBillingPage extends StatefulWidget {
  const SubscriptionBillingPage({super.key});

  @override
  State<SubscriptionBillingPage> createState() =>
      _SubscriptionBillingPageState();
}

class _SubscriptionBillingPageState extends State<SubscriptionBillingPage> {
  late Future<SubscriptionDetails> _subscriptionFuture;
  late Future<List<BillingHistoryItem>> _billingHistoryFuture;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _cvcController = TextEditingController();

  SubscriptionRepository get _repository =>
      context.read<SubscriptionRepository>();

  @override
  void initState() {
    super.initState();
    _subscriptionFuture = _repository.fetchSubscriptionDetails();
    _billingHistoryFuture = _repository.fetchBillingHistory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _subscriptionFuture = _repository.fetchSubscriptionDetails();
      _billingHistoryFuture = _repository.fetchBillingHistory();
    });
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF808080), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB3B3B3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subscription & Billing',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF050505),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your subscription, payment method, and billing history.',
                style: TextStyle(fontSize: 12, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 20),

              // Subscription plan
              FutureBuilder<SubscriptionDetails>(
                future: _subscriptionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: SizedBox(
                        height: 154,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading subscription: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  final data = snapshot.data;
                  if (data == null) return const SizedBox.shrink();
                  return _buildSubscriptionPlanCard(data);
                },
              ),

              const SizedBox(height: 16),

              // Payment method
              FutureBuilder<SubscriptionDetails>(
                future: _subscriptionFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return _buildPaymentMethodCard(snapshot.data!);
                },
              ),

              const SizedBox(height: 16),

              // Billing history
              FutureBuilder<List<BillingHistoryItem>>(
                future: _billingHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading billing history: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  return _buildBillingHistoryCard(snapshot.data ?? const []);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlanCard(SubscriptionDetails details) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    DateTime? renewDate;
    final parsed = DateTime.tryParse(details.startDate ?? '');
    if (parsed != null) {
      renewDate = DateTime(parsed.year + 1, parsed.month, parsed.day);
    }

    final planInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cash Overflow',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${details.subscriptionPlan ?? 'Pro'} Plan",
          style: const TextStyle(color: Color(0xFF4D4D4D), fontSize: 12),
        ),
        const SizedBox(height: 12),
        const Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(
              '\$${AppConfig.planPricePerYear}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            Text(
              ' /year',
              style: TextStyle(color: Color(0xFF808080), fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Renews on ${renewDate != null ? dateFormat.format(renewDate) : 'N/A'}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      ],
    );

    const features = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FeatureItem(text: 'Cash-flow forecasting'),
        _FeatureItem(text: 'Risk detection with explanations'),
        _FeatureItem(text: 'AI-powered recommendations'),
        _FeatureItem(text: 'What-if simulations'),
        _FeatureItem(text: 'Role-based permissions'),
      ],
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF9F9F9),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  planInfo,
                  const Divider(color: Color(0xFFB3B3B3), height: 32),
                  features,
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 2, child: planInfo),
                  const VerticalDivider(
                    color: Color(0xFFB3B3B3),
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                  ),
                  const SizedBox(width: 24),
                  const Expanded(flex: 3, child: features),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(SubscriptionDetails details) {
    final cardInfo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details.cardBrand ?? 'Visa',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF000000),
              ),
            ),
            Text(
              '•••• •••• •••• ${details.last4 ?? "----"}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF000000)),
            ),
          ],
        ),
      ],
    );

    final updateButton = OutlinedButton.icon(
      onPressed: () => _showUpdatePaymentModal(context, details.last4 ?? ''),
      icon: const Icon(Icons.credit_card, size: 15, color: Color(0xFF15389B)),
      label: const Text(
        'Update payment method',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF15389B),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: const BorderSide(color: Color(0xFF15389B)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: const Color(0xFFF9F9F9),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Your current payment method is used for subscription renewals.',
              style: TextStyle(color: Color(0xFF666666), fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB9C8F3), width: 0.5),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 400) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cardInfo,
                        const SizedBox(height: 12),
                        updateButton,
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [cardInfo, updateButton],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingHistoryCard(List<BillingHistoryItem> history) {
    final dateFormat = DateFormat('MMM d, yyyy');
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF102A74),
    );
    const cellStyle = TextStyle(color: Color(0xFF1A1A1A));

    Widget cell(String text, {TextStyle style = cellStyle}) => Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: style),
    );

    final table = Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB3B3B3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(2.5),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.0),
            4: FlexColumnWidth(1.2),
            5: FlexColumnWidth(1.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFDDE4F9)),
              children: [
                for (final title in const [
                  'Transaction ID',
                  'Email',
                  'Plan',
                  'Amount',
                  'Status',
                  'Date',
                ])
                  cell(title, style: headerStyle),
              ],
            ),
            for (final item in history)
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  border: Border(bottom: BorderSide(color: Color(0xFFB3B3B3))),
                ),
                children: [
                  cell(item.transactionId),
                  cell(item.email),
                  cell(item.plan),
                  cell('\$${item.amount.toInt()}'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 10,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  cell(
                    DateTime.tryParse(item.date) != null
                        ? dateFormat.format(DateTime.parse(item.date))
                        : item.date,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.appBackground,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Billing History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'View your previous transactions and payment details.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No billing history available',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
              )
            else
              // The table keeps its desktop proportions and scrolls
              // horizontally on narrow screens.
              LayoutBuilder(
                builder: (context, constraints) {
                  const double minTableWidth = 760;
                  if (constraints.maxWidth >= minTableWidth) return table;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: minTableWidth, child: table),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSuccessModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFCFCFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: 500,
            padding: EdgeInsets.all(context.isMobile ? 8 : 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment method updated',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF050505),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your new card will be used for your next renewal.',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2252C7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color(0xFFFCFCFC),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitPaymentMethod(
    BuildContext outerContext,
    BuildContext dialogContext,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(dialogContext).pop();

    showDialog<void>(
      context: outerContext,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _repository.updatePaymentMethod(
      cardNumber: _cardController.text.trim(),
    );

    if (!outerContext.mounted) return;
    Navigator.of(outerContext, rootNavigator: true).pop();

    if (success) {
      _showSuccessModal(outerContext);
      _reload();
    } else {
      ScaffoldMessenger.of(outerContext).showSnackBar(
        const SnackBar(
          content: Text('Failed to update payment method.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showUpdatePaymentModal(BuildContext outerContext, String currentLast4) {
    _nameController.clear();
    _cardController.clear();
    _cvcController.clear();

    showDialog<void>(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFCFCFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update payment method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF050505),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Currently on file: Card •••• $currentLast4',
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cardholder Name',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4D4D4D)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      autofillHints: const [AutofillHints.creditCardName],
                      decoration: _inputDecoration('Enter cardholder name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter cardholder name'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Card Number',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4D4D4D)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cardController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      autofillHints: const [AutofillHints.creditCardNumber],
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        'Enter 16-digit card number',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter card number';
                        }
                        final clean = value.replaceAll(RegExp(r'\s+'), '');
                        return (clean.length < 12 || clean.length > 16)
                            ? 'Card number must be 12-16 digits'
                            : null;
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'CVC',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4D4D4D)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      autofillHints: const [
                        AutofillHints.creditCardSecurityCode,
                      ],
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration('123'),
                      validator: (value) =>
                          (value == null ||
                              !RegExp(r'^\d{3,4}$').hasMatch(value.trim()))
                          ? 'Enter 3 or 4 digits'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  _submitPaymentMethod(outerContext, dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A46C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF050505)),
            ),
          ),
        ],
      ),
    );
  }
}
