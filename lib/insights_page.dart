// insights_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});
  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String insights = "Press the button to get insights.";
  List<Map<String, double>> dailyExpenditure = [];
  Map<String, double> categoryExpenditure = {};
  String recommendations = "Fetching recommendations...";

  Future<void> fetchInsights() async {
    const url = "http://192.168.1.41:8000/generate_insights/"; // Replace with actual IP
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"expense_data": "Your expense details here"}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          insights = data['insights'] ?? "No insights found.";
          dailyExpenditure = List<Map<String, double>>.from(data['daily_expenditure'] ?? []);
          categoryExpenditure = Map<String, double>.from(data['category_expenditure'] ?? {});
          recommendations = data['recommendations'] ?? "No recommendations available.";
        });
      } else {
        setState(() {
          insights = "Error: ${response.statusCode} - ${response.body}";
          recommendations = "Failed to fetch recommendations.";
        });
      }
    } catch (e) {
      setState(() {
        insights = "Network Error: Failed to fetch insights.";
        recommendations = "Failed to fetch recommendations.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        backgroundColor: const Color(0xFF00359E),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Insights Text
            Text(
              insights,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Waveform Chart for Daily Expenditure
            if (dailyExpenditure.isNotEmpty)
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daily Expenditure",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: dailyExpenditure.map((data) {
                                final day = DateTime.parse(data['date'] as String);
                                final expenditure = data['amount'];
                                return FlSpot(day.day.toDouble(), expenditure!);
                              }).toList(),
                              isCurved: true,
                              color: const Color(0xFF9C0A7C),
                              barWidth: 4,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF9C0A7C).withOpacity(0.3),
                                    const Color(0xFF9C0A7C).withOpacity(0),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ],
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = DateTime.now().subtract(Duration(days: dailyExpenditure.length - value.toInt()));
                                  return Text(
                                    "${date.day}/${date.month}",
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bar Chart for Category Expenditure
            if (categoryExpenditure.isNotEmpty)
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Category Expenditure",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BarChart(
                        BarChartData(
                          barGroups: categoryExpenditure.entries.map((entry) {
                            return BarChartGroupData(
                              x: categoryExpenditure.keys.toList().indexOf(entry.key),
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  color: const Color(0xFF9C0A7C),
                                  width: 22,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final category = categoryExpenditure.keys.elementAt(value.toInt());
                                  return RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      category,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              //tooltipBackgroundColor: const Color(0xFF9C0A7C),
                              tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                              tooltipMargin: 10,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final category = categoryExpenditure.keys.elementAt(group.x);
                                final amount = categoryExpenditure.values.elementAt(group.x);
                                return BarTooltipItem(
                                  [
                                    TextSpan(
                                      text: "$category\n\$${amount.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] as String,
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Recommendations Box
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recommendations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      recommendations,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // Get Insights Button
            ElevatedButton(
              onPressed: fetchInsights,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00359E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text("Get Insights"),
            ),
          ],
        ),
      ),
    );
  }
}