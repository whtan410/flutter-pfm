import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/top_appbar.dart';
import '../widgets/yearly_bar_graph.dart';
class YearlyScreen extends StatelessWidget {
  const YearlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please login'));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Yearly View'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              YearlyBarGraph(userId: user.uid),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}