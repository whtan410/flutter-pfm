import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/budget_service.dart';

class BudgetSettings extends StatefulWidget {
  final String userId;
  final VoidCallback onBudgetUpdated; 

  const BudgetSettings({
    super.key,
    required this.userId,
    required this.onBudgetUpdated,  
  });

  @override
  State<BudgetSettings> createState() => _BudgetSettingsState();
}

class _BudgetSettingsState extends State<BudgetSettings> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  Future<void> _loadCurrentBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budget = await BudgetService(widget.userId).getCurrentMonthBudget();
        
    if (budget != null) {
      setState(() {
        _budgetController.text = budget.amount.toString();
      });
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_budgetController.text);
      await BudgetService(widget.userId).setBudget(amount);
      
      if (mounted) {
        widget.onBudgetUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save budget')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Set Current Month Budget',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveBudget,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_budgetController.text.isEmpty 
                        ? 'Set Budget' 
                        : 'Change Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}