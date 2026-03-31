import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../providers/history_provider.dart';
import '../providers/providers.dart';
import '../providers/schedule_provider.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final AppInfo? selectedApp;
  final ScheduleEntity? existing;
  const ScheduleFormScreen({super.key, this.selectedApp, this.existing});

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _labelController = TextEditingController();
  DateTime? _pickedTime;
  bool _hasConflict = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _labelController.text = widget.existing!.label ?? '';
      _pickedTime = widget.existing!.scheduledTime;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String get _appName => widget.selectedApp?.appName ?? widget.existing?.appName ?? '';

  String get _packageName => widget.selectedApp?.packageName ?? widget.existing?.packageName ?? '';

  void _checkConflict(DateTime dt) {
    final check = ref.read(checkConflictProvider);
    setState(() => _hasConflict = check.call(dt, excludeId: widget.existing?.id));
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedTime ?? now.add(const Duration(minutes: 5)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickedTime ?? now),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _pickedTime = picked);
    _checkConflict(picked);
  }

  Future<void> _save() async {
    if (_pickedTime == null) {
      _showSnack('Please pick a date & time');
      return;
    }
    if (_pickedTime!.isBefore(DateTime.now())) {
      _showSnack('Time must be in the future');
      return;
    }

    final id = widget.existing?.id ?? const Uuid().v4();
    final entity = ScheduleEntity(
      id: id,
      appName: _appName,
      packageName: _packageName,
      label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
      scheduledTime: _pickedTime!,
    );

    await ref.read(scheduleListProvider.notifier).save(entity);
    // ← History যোগ করা নেই এখানে

    if (mounted) Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
        title: Text(
          isEdit ? 'Edit Schedule' : 'New Schedule',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.apps_rounded, color: Color(0xFF6C63FF), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appName.isEmpty ? 'Select an App' : _appName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _packageName.isEmpty ? 'No app selected' : _packageName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Label field
            _SectionLabel(label: 'Label (Optional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
              ),
              child: TextField(
                controller: _labelController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Daily Standup',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: Icon(Icons.label_outline_rounded, color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time
            _SectionLabel(label: 'Date & Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _pickedTime != null ? const Color(0xFF6C63FF).withOpacity(0.5) : const Color(0xFF6C63FF).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF6C63FF), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedTime != null ? DateFormat('EEE, MMM d yyyy  •  hh:mm a').format(_pickedTime!) : 'Tap to select date & time',
                        style: TextStyle(
                          fontSize: 14,
                          color: _pickedTime != null ? Colors.white : Colors.white.withOpacity(0.35),
                          fontWeight: _pickedTime != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
                  ],
                ),
              ),
            ),

            // Conflict warning
            if (_hasConflict) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Conflict! Another schedule exists at this time.',
                        style: const TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Center(
                        child: Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _hasConflict ? null : _save,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: _hasConflict
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
                              ),
                        color: _hasConflict ? Colors.white.withOpacity(0.05) : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _hasConflict
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                      ),
                      child: Center(
                        child: Text(
                          isEdit ? 'Update Schedule' : 'Save Schedule',
                          style: TextStyle(
                            color: _hasConflict ? Colors.white.withOpacity(0.3) : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.5),
        letterSpacing: 0.5,
      ),
    );
  }
}
