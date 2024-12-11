import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/expenses_service.dart';

class MonthlyPieChart extends StatefulWidget {
  final String userId;

  const MonthlyPieChart({
    super.key,
    required this.userId,
  });

  @override
  State<MonthlyPieChart> createState() => _MonthlyPieChartState();
}

class _MonthlyPieChartState extends State<MonthlyPieChart> {
  int touchedIndex = -1;
  late final Future<Map<String, double>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = ExpensesService(widget.userId).getCurrentMonthExpenses();
  }

  final Map<String, Color> categoryColors = {
    'Housing & Utilities': Colors.blue,
    'Food & Groceries': Colors.green,
    'Transportation': Colors.orange,
    'Healthcare': Colors.red,
    'Entertainment & Shopping': Colors.purple,
  };

   @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final expenses = snapshot.data ?? {};
        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses this month'));
        }

        final total = expenses.values.reduce((a, b) => a + b);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: _generateSections(expenses, total),
                ),
              ),
            ),
            const SizedBox(height: 4), 

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _generateIndicators(expenses, total),
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, double> expenses, double total) {
    int index = 0;
    return expenses.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 70.0 : 60.0;
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      final section = PieChartSectionData(
        color: categoryColors[entry.key] ?? Colors.grey,
        value: entry.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );

      index++;
      return section;
    }).toList();
  }

  List<Widget> _generateIndicators(Map<String, double> expenses, double total) {
    return expenses.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Center(
          child: _Indicator(
          color: categoryColors[entry.key] ?? Colors.grey,
          text: '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
          isSquare: true,
          ),
        ),
      );
    }).toList();
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        )
      ],
    );
  }
}