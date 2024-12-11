import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

import '../widgets/bottom_navigation.dart';
import '../widgets/monthly_pie_chart.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/top_appbar.dart';
import '../widgets/budget_settings.dart'; 

class MonthlyScreen extends StatefulWidget {  
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  Key _budgetProgressKey = UniqueKey();  

  void _refreshBudgetProgress() {
    setState(() {
      _budgetProgressKey = UniqueKey();  
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please login'));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Monthly View'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [              
              BudgetSettings(
                userId: user.uid,
                onBudgetUpdated: _refreshBudgetProgress,
              ),
              
              const SizedBox(height: 16),
              
              BudgetProgressBar(
                key: _budgetProgressKey,
                userId: user.uid,
              ),
              
              const SizedBox(height: 16),

              Text(
                'Expenses for ${DateFormat('MMM yyyy').format(DateTime.now())}',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 0),
              
              Center(
                child: MonthlyPieChart(userId: user.uid),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
