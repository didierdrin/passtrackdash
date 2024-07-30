import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 20),
            _buildSalesBreakdownSection(),
            const SizedBox(height: 20),
            _buildPieCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem('Total Sales', '\$10,000'),
                _buildMetricItem('Tickets Sold Today', '150'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 17)),
      ],
    );
  }

  Widget _buildSalesBreakdownSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sales Breakdown', style: TextStyle(fontSize: 17)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: 'Date',
              items: ['Date', 'Route', 'Ticket Type']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                // Handle dropdown change
              },
            ),
            // You can add a list or table here showing the breakdown
          ],
        ),
      ),
    );
  }

  Widget _buildPieCharts() {
    return Column(
      children: [
        _buildPieChart('Sales by Route'),
        const SizedBox(height: 20),
        _buildPieChart('Sales by Ticket Type'),
      ],
    );
  }

  Widget _buildPieChart(String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 40,
                      title: '40%',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 30,
                      title: '30%',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 30,
                      title: '30%',
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}