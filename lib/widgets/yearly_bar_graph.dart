import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/expenses_service.dart';
import 'year_selector.dart';

class YearlyBarGraph extends StatefulWidget {  
  final String userId;

  const YearlyBarGraph({
    super.key,
    required this.userId,
  });

  @override
  State<YearlyBarGraph> createState() => _YearlyBarGraphState();
}

class _YearlyBarGraphState extends State<YearlyBarGraph> {
  int selectedYear = DateTime.now().year;  

  final Map<String, Color> categoryColors = {
    'Housing & Utilities': Colors.blue,
    'Food & Groceries': Colors.green,
    'Transportation': Colors.orange,
    'Healthcare': Colors.red,
    'Entertainment & Shopping': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, double>>>(
      future: ExpensesService(widget.userId).getYearlyExpensesByCategory(
        selectedYear: selectedYear,
      ),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yearly Expenses by Category',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  YearSelector(
                    selectedYear: selectedYear,
                    onYearChanged: (year) {
                      setState(() {
                        selectedYear = year;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                Center(child: Text('Error: ${snapshot.error}'))
              else if (snapshot.data?.isEmpty ?? true)
                const Center(
                  child: Text(
                    'No expenses found for selected year.\nTry selecting a different year.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxTotal(snapshot.data!) * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '\$${rod.toY.toStringAsFixed(2)}',
                                  const TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: _leftTitles,
                                reservedSize: 60,
                              ),
                              axisNameWidget: const Text(
                                'Amount',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: _bottomTitles,
                                reservedSize: 40,
                              ),
                              axisNameWidget: const Text(
                                'Month',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _createBarGroups(snapshot.data!),
                          groupsSpace: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, Map<String, double>> monthlyExpenses) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return List.generate(12, (index) {
      final month = months[index];
      final monthData = monthlyExpenses[month] ?? {};
      
      double stackedPosition = 0;
      final List<BarChartRodStackItem> stackItems = [];
      
      categoryColors.forEach((category, color) {
        final value = monthData[category] ?? 0;
        if (value > 0) {
          stackItems.add(
            BarChartRodStackItem(
              stackedPosition,
              stackedPosition + value,
              color,
            ),
          );
          stackedPosition += value;
        }
      });

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stackedPosition,
            width: 8,
            borderRadius: BorderRadius.circular(4),
            rodStackItems: stackItems,
          ),
        ],
      );
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(months[value.toInt()], style: style),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        '\$${value.toInt()}',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  double _getMaxTotal(Map<String, Map<String, double>> monthlyExpenses) {
    double maxTotal = 0;
    monthlyExpenses.forEach((month, categories) {
      final total = categories.values.fold(0.0, (sum, value) => sum + value);
      if (total > maxTotal) maxTotal = total;
    });
    return maxTotal;
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryColors.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}