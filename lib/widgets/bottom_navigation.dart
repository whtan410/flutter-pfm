import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../screens/home_screen.dart';
import '../screens/monthly_screen.dart';
import '../screens/yearly_screen.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return NavigationBar(
          selectedIndex: navigationProvider.currentIndex,
          onDestinationSelected: (int index) {
            navigationProvider.setIndex(index);
            
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MonthlyScreen()),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const YearlyScreen()),
                );
                break;
            }
          },
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.dashboard),
              icon: Icon(Icons.dashboard_outlined),
              label: 'Summary',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.calendar_month),
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Monthly',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bar_chart),
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Yearly',
            ),
          ],
        );
      },
    );
  }
}