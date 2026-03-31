import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:app_scheduler/core/theme/text_config.dart';
import 'package:app_scheduler/presentation/widgets/rouded_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:r_icon_pro/r_icon_pro.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/schedule_entity.dart';
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
            primary: AppColor.primaryColor,
            surface: AppColor.bgLight,
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
            primary: AppColor.primaryColor,
            surface: AppColor.bgLight,
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

    if (mounted) Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColor.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    ///========================= Body ===========================
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        ///========================= back Button ===========================

        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8).copyWith(left: 10),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.primaryColor, size: 18),
          ),
        ),
        title: Text(
          isEdit ? 'Edit Schedule' : 'New Schedule',
          style: AppText().headerLine4,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Text(
              'Selected App',
              style: AppText().bodyMediumBold,
            ),
            const SizedBox(height: 8),

            ///========================== Selected App Info ======================

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColor.primaryColor.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:  Icon(RIcon.Widget_, color: AppColor.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appName.isEmpty ? 'Select an App' : _appName,
                          style: AppText().bodyLarge,
                        ),
                        Text(
                          _packageName.isEmpty ? 'No app selected' : _packageName,
                          style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Label',
              style: AppText().bodyMediumBold,
            ),
            const SizedBox(height: 8),


            ///========================== Label Input field ======================
            Container(
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.primaryColor.withOpacity(0.4)),
              ),
              child: TextField(
                controller: _labelController,
                style: AppText().bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g. Daily Standup',
                  hintStyle: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                  prefixIcon: Icon(RIcon.Notes_Minimalistic, color: AppColor.appWhite.withOpacity(0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Date & Time',
              style: AppText().bodyMediumBold,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColor.primaryColor.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(RIcon.Calendar, color:AppColor.appWhite.withOpacity(0.3), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedTime != null ? DateFormat('EEE, MMM d yyyy  •  hh:mm a').format(_pickedTime!) : 'Tap to select date & time',
                        style: AppText().bodyMedium.copyWith(color: _pickedTime != null ? AppColor.appWhite :  AppColor.appWhite.withOpacity(0.4)),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color:  AppColor.appWhite.withOpacity(0.4)),
                  ],
                ),
              ),
            ),


            ///======================== Time Conflict Warning ======================

            if (_hasConflict) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColor.appRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.appRed.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColor.appRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Conflict! Another schedule exists at this time.',
                        style: AppText().bodyMedium.copyWith(color: AppColor.appRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

          ],
        ),
      ),



      ///========================= Cancel or Save Schedule Button ===========================

      bottomNavigationBar: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RoundedActionButton(
                  onClick: () {
                    Navigator.pop(context);
                  },
                  label: 'Cancel',
                  backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  forGroundColor: AppColor.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _hasConflict ? null : _save,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: _hasConflict ? AppColor.primaryColor.withOpacity(0.1) : AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        isEdit ? 'Update Schedule'.toUpperCase() : 'Save Schedule'.toUpperCase(),
                        style: AppText().bodyLarge.copyWith(
                              color: _hasConflict ? AppColor.primaryBlack.withOpacity(0.3) : AppColor.primaryBlack,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

