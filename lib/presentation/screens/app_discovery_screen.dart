import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:app_scheduler/core/theme/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:r_icon_pro/r_icon_pro.dart';
import '../../domain/entities/app_info.dart';
import '../providers/app_list_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_back_button.dart';
import 'schedule_form_screen.dart';

class AppDiscoveryScreen extends ConsumerStatefulWidget {
  final bool isSelecting;

  const AppDiscoveryScreen({super.key, this.isSelecting = false});

  @override
  ConsumerState<AppDiscoveryScreen> createState() => _AppDiscoveryScreenState();
}

class _AppDiscoveryScreenState extends ConsumerState<AppDiscoveryScreen> {
  String _query = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAppTap(AppInfo app) {
    if (widget.isSelecting) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScheduleFormScreen(selectedApp: app),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScheduleFormScreen(selectedApp: app),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(appListProvider);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///================================= Header =============================
                  Row(
                    children: [
                      if (widget.isSelecting) CustomBackButton(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isSelecting ? 'Select App' : 'Installed Apps',
                              style: AppText().headerLine1,
                            ),
                            Text(
                              widget.isSelecting ? 'Choose app to schedule' : 'Tap any app to schedule it',
                              style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withAlpha(100)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ///================================= Search Field =============================
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColor.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: AppColor.appWhite),
                      decoration: InputDecoration(
                        hintText: 'Search apps...',
                        hintStyle: AppText().bodyMediumBold.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                        prefixIcon: Icon(
                          RIcon.Rounded_Magnifer,
                          color: AppColor.appWhite.withOpacity(0.4),
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: AppColor.appWhite.withOpacity(0.4)),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (v) => setState(() => _query = v.toLowerCase()),
                    ),
                  ),
                ],
              ),
            ),

            ///================================= App List =============================

            Expanded(
              child: appsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: TextStyle(color: AppColor.appRed)),
                ),
                data: (apps) {
                  final filtered =
                      apps.where((a) => a.appName.toLowerCase().contains(_query) || a.packageName.toLowerCase().contains(_query)).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No apps found',
                        style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.6)),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => AppCard(
                      app: filtered[i],
                      onTap: () => _onAppTap(filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
