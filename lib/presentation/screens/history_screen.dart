import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:app_scheduler/core/theme/text_config.dart';
import 'package:app_scheduler/presentation/widgets/rouded_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../widgets/clear_all_button.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);


    ///======================== Body ======================

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ///======================== Header ======================


            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: AppText().headerLine1,
                      ),
                      Text(
                        '${history.length} completed',
                        style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withAlpha(100)),
                      ),
                    ],
                  ),

                  ///========================= Clear All Button =======================
                  if (history.isNotEmpty)
                    ClearAllButton(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            // contentPadding: EdgeInsets.all(12),
                            backgroundColor: AppColor.bgLight,
                            actionsAlignment: MainAxisAlignment.start,
                            alignment: AlignmentDirectional.centerStart,
                            clipBehavior: Clip.hardEdge,

                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text('Clear History', style: AppText().headerLine2),
                            content: Text(
                              'Are you sure you want to clear all history?',
                              style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.5)),
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RoundedActionButton(
                                      onClick: () {
                                        Navigator.pop(context);
                                      },
                                      label: 'Cancel',
                                      textStyle: AppText().bodyLarge,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: RoundedActionButton(
                                      onClick: () {
                                        ref.read(historyProvider.notifier).clear();
                                        Navigator.pop(context);
                                      },
                                      backgroundColor: AppColor.appRed,
                                      label: 'Clear',
                                      textStyle: AppText().bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )
                ],
              ),
            ),


            ///===================== History Card ========================
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No History Yet',
                        style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.6)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.length,
                      itemBuilder: (_, i) {
                        final item = history[i];
                        return HistoryCard(item: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
