import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/data/models/demo_request.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../widgets/cancel_subscription_dialog.dart';
import '../widgets/demo_request_filter_dialog.dart';

/// Admin dashboard: companies asking for a demo.
class DemoRequestsPage extends StatefulWidget {
  const DemoRequestsPage({super.key});

  @override
  State<DemoRequestsPage> createState() => _DemoRequestsPageState();
}

class _DemoRequestsPageState extends State<DemoRequestsPage> {
  static const TextStyle _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1E3A8A),
  );
  static const TextStyle _cellStyle = TextStyle(
    fontSize: 13,
    color: Color(0xFF333333),
  );

  final TextEditingController _searchController = TextEditingController();

  DemoRequestFilters _filters = const DemoRequestFilters();

  List<DemoRequest> _allRequests = [];
  List<DemoRequest> _filteredRequests = [];

  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _loadingApproveIds = {};

  OnboardingRepository get _repository => context.read<OnboardingRepository>();

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repository.fetchDemoRequests();
      if (!mounted) return;
      _allRequests = data;
      setState(() => _isLoading = false);
      _applyFilters();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    }
  }

  /// Search + status + date range.
  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    final from = _filters.from;
    final to = _filters.to;

    setState(() {
      _filteredRequests = _allRequests.where((item) {
        final matchesQuery =
            item.companyName.toLowerCase().contains(query) ||
            item.contactEmail.toLowerCase().contains(query);

        final matchesStatus =
            _filters.statuses.isEmpty ||
            _filters.statuses.contains(item.status);

        final submitted = item.submittedAt;
        final matchesDate =
            (from == null && to == null) ||
            (submitted != null &&
                (from == null || !submitted.isBefore(from)) &&
                (to == null || !submitted.isAfter(to)));

        return matchesQuery && matchesStatus && matchesDate;
      }).toList();
    });
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<DemoRequestFilters>(
      context: context,
      builder: (context) => DemoRequestFilterDialog(initialFilters: _filters),
    );

    if (result != null && mounted) {
      _filters = result;
      _applyFilters();
    }
  }

  void _showCancelDialog(DemoRequest request) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => CancelSubscriptionDialog(
        onConfirm: () {
          request.status = 'Closed';
          _applyFilters();
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  Future<void> _approveAndSendEmail(DemoRequest request) async {
    setState(() => _loadingApproveIds.add(request.id));

    final success = await _repository.approveDemoRequest(request.id);

    if (!mounted) return;
    setState(() => _loadingApproveIds.remove(request.id));

    if (success) {
      request.status = 'Contacted';
      _applyFilters();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to ${request.contactEmail}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 32.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Demo Requests Management',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review and manage demo requests from companies, and send invitations to get started.',
                style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 24),

              _buildToolbar(),
              const SizedBox(height: 20),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchRequests,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    final search = Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _applyFilters(),
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );

    final filterButton = OutlinedButton.icon(
      onPressed: _showFilterDialog,
      icon: const Icon(Icons.tune, size: 16, color: Color(0xFF1D4ED8)),
      label: const Text(
        'Apply filters',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1D4ED8),
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: const BorderSide(color: Color(0xFF1D4ED8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              filterButton,
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 320, child: search),
            filterButton,
          ],
        );
      },
    );
  }

  Widget _buildTable() {
    final table = DataTable(
      headingRowColor: WidgetStateProperty.all(const Color(0xFFEEF2FF)),
      headingRowHeight: 48,
      horizontalMargin: 24,
      columnSpacing: 20,
      columns: const [
        DataColumn(label: Text('Company Name', style: _headerStyle)),
        DataColumn(label: Text('Contact Email', style: _headerStyle)),
        DataColumn(label: Text('Phone Number', style: _headerStyle)),
        DataColumn(label: Text('Submission Date', style: _headerStyle)),
        DataColumn(label: Text('Status', style: _headerStyle)),
        DataColumn(label: Text('Action', style: _headerStyle)),
      ],
      rows: [
        for (final request in _filteredRequests)
          DataRow(
            cells: [
              DataCell(Text(request.companyName, style: _cellStyle)),
              DataCell(Text(request.contactEmail, style: _cellStyle)),
              DataCell(Text(request.phoneNumber, style: _cellStyle)),
              DataCell(Text(request.submissionDate, style: _cellStyle)),
              DataCell(_buildStatusBadge(request.status)),
              DataCell(_buildActionButton(request)),
            ],
          ),
      ],
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fills the card on desktop, scrolls sideways on small screens.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: table,
                ),
              ),
              if (_filteredRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No demo requests match your search or filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color = switch (status) {
      'Pending' => const Color(0xFFD97706),
      'Contacted' => const Color(0xFF16A34A),
      _ => const Color(0xFF64748B),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(DemoRequest request) {
    final isApproving = _loadingApproveIds.contains(request.id);

    if (request.status == 'Pending') {
      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: isApproving ? null : () => _approveAndSendEmail(request),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: isApproving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Approve & Send Email',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    }

    if (request.status == 'Contacted') {
      return SizedBox(
        height: 32,
        child: OutlinedButton(
          onPressed: () => _showCancelDialog(request),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFDC2626)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text(
            'Cancel Subscription',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC2626),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
