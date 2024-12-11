import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../services/expenses_service.dart';
import '../models/expenses_model.dart';

class ExpensesForm extends StatefulWidget {
  const ExpensesForm({super.key});

  @override
  State<ExpensesForm> createState() => _ExpensesFormState();
}

class _ExpensesFormState extends State<ExpensesForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController(); 
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Housing & Utilities';

  final List<String> _categories = [
    'Housing & Utilities',
    'Food & Groceries',
    'Transportation',
    'Healthcare',
    'Entertainment & Shopping',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();  
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      try {
        final expense = ExpensesModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          category: _selectedCategory,
          date: _selectedDate,
        );

        await ExpensesService(user.uid).createExpense(expense);

        _nameController.clear();
        _amountController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedCategory = _categories[0];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding expense: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Card(
        elevation: 4,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Expense',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Expense Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Expense Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expense name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      try {
                        double.parse(value);
                        return null;
                      } catch (e) {
                        return 'Please enter a valid number';
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _submitExpense,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}