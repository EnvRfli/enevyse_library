import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import 'logic/main_layout_logic.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart';
import '../history/history_screen.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainLayoutLogic(),
      child: const _MainLayoutView(),
    );
  }
}

class _MainLayoutView extends StatelessWidget {
  const _MainLayoutView();

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<MainLayoutLogic>(context);

    // List of screens for each tab
    final screens = [
      const HomeScreen(),
      const ExploreScreen(),
      const HistoryScreen(),
      const Scaffold(body: Center(child: Text('Profile'))), // Placeholder
    ];

    return Scaffold(
      body: IndexedStack(
        index: logic.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: logic.currentIndex,
        onTap: logic.setIndex,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: 'explore'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time_outlined),
            activeIcon: const Icon(Icons.access_time_filled),
            label: 'history'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }
}
