import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:passtrackdash/components/summary_provider.dart';
import 'package:provider/provider.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String breakdownBy = 'Date';
  double totalSales = 0;
  int ticketsSoldToday = 0;
  Map<String, double> salesByRoute = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SummaryProvider>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SummaryProvider>(
        builder: (context, summaryProvider, child) {
          return summaryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: summaryProvider.fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewCard(summaryProvider),
                        const SizedBox(height: 20),
                        _buildSalesBreakdownSection(summaryProvider),
                        const SizedBox(height: 20),
                        _buildPieCharts(summaryProvider),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildOverviewCard(SummaryProvider summaryProvider) {
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
                _buildMetricItem('Total Sales',
                    'RWF${NumberFormat('#,##0').format(summaryProvider.totalSales)}'),
                _buildMetricItem('Tickets Sold\nToday',
                    '${summaryProvider.ticketsSoldToday}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text("$value", style: const TextStyle(fontSize: 17)),
      ],
    );
  }

  Widget _buildSalesBreakdownSection(SummaryProvider summaryProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sales Breakdown', style: TextStyle(fontSize: 17)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: breakdownBy,
              items: ['Date', 'Route']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  breakdownBy = newValue!;
                });
              },
            ),
            const SizedBox(height: 10),
            if (breakdownBy == 'Route') _buildRouteBreakdown(summaryProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteBreakdown(SummaryProvider summaryProvider) {
    List<MapEntry<String, double>> sortedEntries =
        summaryProvider.salesByRoute.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key),
              Text('RWF${NumberFormat('#,##0').format(entry.value)}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieCharts(SummaryProvider summaryProvider) {
    return Column(
      children: [
        _buildPieChart('Sales by Route', summaryProvider),
      ],
    );
  }

  Widget _buildPieChart(String title, SummaryProvider summaryProvider) {
    List<MapEntry<String, double>> sortedEntries =
        summaryProvider.salesByRoute.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    List<PieChartSectionData> sections = sortedEntries.take(5).map((entry) {
      return PieChartSectionData(
        color: Colors
            .primaries[sortedEntries.indexOf(entry) % Colors.primaries.length],
        value: entry.value,
        title:
            '${(entry.value / summaryProvider.totalSales * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

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
                  sections: sections,
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: sortedEntries.take(5).map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: Colors.primaries[sortedEntries.indexOf(entry) %
                            Colors.primaries.length],
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key)),
                      Text('RWF${NumberFormat('#,##0').format(entry.value)}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
