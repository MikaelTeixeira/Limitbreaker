import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.index, required this.child});
  final int index;
  final Widget child;
  static const paths = [
    '/home',
    '/ranking',
    '/friends',
    '/achievements',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => context.go(paths[value]),
      backgroundColor: AppColors.carbon,
      indicatorColor: AppColors.bone,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.leaderboard_outlined),
          selectedIcon: Icon(Icons.leaderboard),
          label: 'Ranking',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group),
          label: 'Amigos',
        ),
        NavigationDestination(
          icon: Icon(Icons.military_tech_outlined),
          selectedIcon: Icon(Icons.military_tech),
          label: 'Conquistas',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    ),
  );
}
