import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// Filters applied to the demo requests table.
class DemoRequestFilters {
  const DemoRequestFilters({
    this.statuses = const {'Contacted', 'Pending', 'Closed'},
    this.from,
    this.to,
  });

  final Set<String> statuses;

  /// Inclusive date range on the submission date.
  final DateTime? from;
  final DateTime? to;
}

/// Status & date filters for the demo requests table.
class DemoRequestFilterDialog extends StatefulWidget {
  const DemoRequestFilterDialog({super.key, required this.initialFilters});

  final DemoRequestFilters initialFilters;

  @override
  State<DemoRequestFilterDialog> createState() =>
      _DemoRequestFilterDialogState();
}

class _DemoRequestFilterDialogState extends State<DemoRequestFilterDialog> {
  late bool isContacted;
  late bool isPending;
  late bool isClosed;
  DateTime? _from;
  DateTime? _to;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    isContacted = filters.statuses.contains('Contacted');
    isPending = filters.statuses.contains('Pending');
    isClosed = filters.statuses.contains('Closed');
    _from = filters.from;
    _to = filters.to;
    _startDateController = TextEditingController(text: _format(_from));
    _endDateController = TextEditingController(text: _format(_to));
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  static String _format(DateTime? date) =>
      date == null ? '' : Formatters.isoDate(date);

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _from : _to) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _from = picked;
        _startDateController.text = _format(picked);
        if (_to != null && _to!.isBefore(picked)) {
          _to = picked;
          _endDateController.text = _format(picked);
        }
      } else {
        _to = picked;
        _endDateController.text = _format(picked);
        if (_from != null && _from!.isAfter(picked)) {
          _from = picked;
          _startDateController.text = _format(picked);
        }
      }
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      DemoRequestFilters(
        statuses: {
          if (isContacted) 'Contacted',
          if (isPending) 'Pending',
          if (isClosed) 'Closed',
        },
        from: _from,
        to: _to,
      ),
    );
  }

  void _clearAll() {
    setState(() {
      isContacted = false;
      isPending = false;
      isClosed = false;
      _from = null;
      _to = null;
      _startDateController.clear();
      _endDateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          color: const Color(0xFFFAFAFA),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _clearAll,
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF808080),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    _checkboxOption(
                      'Contacted',
                      isContacted,
                      (v) => setState(() => isContacted = v!),
                    ),
                    _checkboxOption(
                      'Pending',
                      isPending,
                      (v) => setState(() => isPending = v!),
                    ),
                    _checkboxOption(
                      'Closed',
                      isClosed,
                      (v) => setState(() => isClosed = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: () => _pickDate(isStart: true),
                        decoration: _inputDecoration('start'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'to',
                        style: TextStyle(color: Color(0xFF666666)),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _pickDate(isStart: false),
                        decoration: _inputDecoration('end'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply filters',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkboxOption(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF808080), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
