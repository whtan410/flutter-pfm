import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/expenses_form.dart';
import '../widgets/expenses_list.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/top_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Expense Tracker'),
      body: SingleChildScrollView(  
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${user?.email}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              const ExpansionTile(
                title: Text('Add New Expense'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ExpensesForm(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Your Expenses',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              SizedBox(
                height: 400,  
                child: ExpensesList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}