import 'package:flutter/material.dart';

class YearSelector extends StatelessWidget {
  final int selectedYear;
  final Function(int) onYearChanged;

  const YearSelector({
    super.key,
    required this.selectedYear,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: selectedYear,
      items: List.generate(7, (index) {
        final year = 2022 + index;
        return DropdownMenuItem(
          value: year,
          child: Text('$year'),
        );
      }),
      onChanged: (int? value) {
        if (value != null) {
          onYearChanged(value);
        }
      },
    );
  }
}