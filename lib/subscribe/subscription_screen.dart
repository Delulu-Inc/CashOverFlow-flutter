import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_models.dart';
import 'subscription_service.dart';

class SubscriptionBillingScreen extends StatefulWidget {
  const SubscriptionBillingScreen({super.key});

  @override
  State<SubscriptionBillingScreen> createState() =>
      _SubscriptionBillingScreenState();
}

class _SubscriptionBillingScreenState extends State<SubscriptionBillingScreen> {
  final SubscriptionService _apiService = SubscriptionService();

  Future<SubscriptionDetails>? _subscriptionFuture;
  Future<List<BillingHistoryItem>>? _billingHistoryFuture;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkRoleAndLoadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _checkRoleAndLoadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString('user_role');

    // If role is known and is not Owner, redirect to dashboard immediately
    if (role != null && role.trim().toLowerCase() != 'owner') {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
      return;
    }

    _loadData();
  }

  void _loadData() {
    setState(() {
      _subscriptionFuture = _apiService.getSubscriptionDetails();
      _billingHistoryFuture = _apiService.getBillingHistory();
    });
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF808080), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
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
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
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

              // Subscription Plan
              if (_subscriptionFuture != null)
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

              // Payment Method
              if (_subscriptionFuture != null)
                FutureBuilder<SubscriptionDetails>(
                  future: _subscriptionFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return _buildPaymentMethodCard(snapshot.data!);
                  },
                ),

              const SizedBox(height: 16),

              // Billing History
              if (_billingHistoryFuture != null)
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
                    final history = snapshot.data ?? [];
                    return _buildBillingHistoryCard(history);
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
    if (details.startDate != null && details.startDate!.isNotEmpty) {
      final parsed = DateTime.tryParse(details.startDate!);
      if (parsed != null) {
        renewDate = DateTime(parsed.year + 1, parsed.month, parsed.day);
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF9F9F9),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
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
                      style: const TextStyle(
                        color: Color(0xFF4D4D4D),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: const [
                        Text(
                          "\$499",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Text(
                          ' /year',
                          style: TextStyle(
                            color: Color(0xFF808080),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Renews on ${renewDate != null ? dateFormat.format(renewDate) : 'N/A'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                color: Color(0xFFB3B3B3),
                thickness: 1,
                indent: 8,
                endIndent: 8,
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _FeatureItem(text: 'Cash-flow forecasting'),
                    _FeatureItem(text: 'Risk detection with explanations'),
                    _FeatureItem(text: 'AI-powered recommendations'),
                    _FeatureItem(text: 'What-if simulations'),
                    _FeatureItem(text: 'Role-based permissions'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(SubscriptionDetails details) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB9C8F3), width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showUpdatePaymentModal(context, details.last4 ?? ''),
                    icon: const Icon(
                      Icons.credit_card,
                      size: 15,
                      color: Color(0xFF15389B),
                    ),
                    label: const Text(
                      'Update payment method',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15389B),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      side: const BorderSide(color: Color(0xFF15389B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingHistoryCard(List<BillingHistoryItem> history) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF8FAFC),
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
              Container(
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
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFDDE4F9)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Transaction ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102A74),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102A74),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Plan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102A74),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102A74),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102A74),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102A74),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...history.map((item) {
                        DateTime? parsedDate;
                        if (item.date.isNotEmpty) {
                          parsedDate = DateTime.tryParse(item.date);
                        }

                        return TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF6F6F6),
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFB3B3B3)),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                item.transactionId,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                item.email,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                item.plan,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                '\$${item.amount.toInt()}',
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
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
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                parsedDate != null
                                    ? dateFormat.format(parsedDate)
                                    : item.date,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFCFCFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: 500,
            padding: const EdgeInsets.all(32),
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

  void _showUpdatePaymentModal(BuildContext outerContext, String currentLast4) {
    _nameController.clear();
    _cardController.clear();
    _expiryController.clear();
    _cvcController.clear();

    showDialog(
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
                    decoration: _inputDecoration('Enter cardholder name'),
                    validator: (value) => value == null || value.trim().isEmpty
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
                    decoration: _inputDecoration(
                      'Enter 16-digit card number',
                    ).copyWith(counterText: ''),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CVC',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4D4D4D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _cvcController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: _inputDecoration(
                          '123',
                        ).copyWith(counterText: ''),
                        validator: (value) =>
                            (value == null ||
                                !RegExp(r'^\d{3,4}$').hasMatch(value.trim()))
                            ? 'Enter 3 or 4 digits'
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop();

                  showDialog(
                    context: outerContext,
                    barrierDismissible: false,
                    builder: (loadingContext) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  bool success = false;
                  try {
                    success = await _apiService.updatePaymentMethod(
                      cardholderName: _nameController.text.trim(),
                      cardNumber: _cardController.text.trim(),
                      expiry: _expiryController.text.trim(),
                      cvc: _cvcController.text.trim(),
                    );
                  } catch (e) {
                    debugPrint('Error: $e');
                  }

                  if (!outerContext.mounted) return;
                  Navigator.of(outerContext, rootNavigator: true).pop();

                  if (success) {
                    _showSuccessModal(outerContext);
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update payment method.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
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
  final String text;
  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1D4ED8), size: 16),
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
