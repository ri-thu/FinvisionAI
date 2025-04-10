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
  String insights = "Loading insights...";
  List<Map<String, dynamic>> dailyExpenditure = [];
  Map<String, double> categoryExpenditure = {};
  String recommendations = "Fetching recommendations...";

  @override
  void initState() {
    super.initState();
    // Call fetchInsights when the page initializes
    fetchInsights();
  }

  Future<void> fetchInsights() async {
    const url = "http://10.0.2.2:8000/analyze-finances"; // Replace with actual IP
    try {
      print("Attempting to connect to: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "income": 7500.00,
          "expenses": {
            "Rent": 2000.00,
            "Utilities": 150.50,
            "Groceries": 700.00,
            "Transport": 250.00,
            "Insurance": 120.00,
            "Phone Bill": 80.00,
            "Subscriptions": 45.00
          },
          "savings_goals": {
            "Emergency Fund": 10000.00,
            "Vacation": 3000.00,
            "New Laptop": 1500.00
          },
          "discretionary_percentage": 0.15
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          insights = data['analysis'] ?? "No insights found."; // Note: changed from 'insights' to 'analysis'

          // These fields might not be in your API response based on your FastAPI code
          // You might need to adjust or remove these lines
          //dailyExpenditure = List<Map<String, dynamic>>.from(data['daily_expenditure'] ?? []);
          //categoryExpenditure = Map<String, double>.from(data['category_expenditure'] ?? {});
          //recommendations = data['recommendations'] ?? "No recommendations available.";
        });
      } else {
        setState(() {
          insights = "Error: ${response.statusCode} - ${response.body}";
          recommendations = "Failed to fetch recommendations.";
        });
      }
    } catch (e) {
      print("Exception details: ${e.toString()}");
      setState(() {
        insights = "Network Error: Failed to fetch insights. ${e.toString()}";
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
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: dailyExpenditure.map((data) {
                                  final day = DateTime.parse(data['date'] as String);
                                  final expenditure = data['amount'] as double;
                                  return FlSpot(day.day.toDouble(), expenditure);
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
                      SizedBox(
                        height: 300,
                        child: BarChart(
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
                                tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                                tooltipMargin: 10,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final category = categoryExpenditure.keys.elementAt(group.x);
                                  final amount = categoryExpenditure.values.elementAt(group.x);
                                  return BarTooltipItem(
                                    "$category\n\$${amount.toStringAsFixed(2)}",
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
            // Refresh Insights Button
            ElevatedButton(
              onPressed: fetchInsights,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00359E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text("Refresh Insights"),
            ),
          ],
        ),
      ),
    );
  }
}
