import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:passtrackdash/colors.dart';
import 'package:provider/provider.dart';
import 'package:passtrackdash/components/summary_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerateReportPage extends StatefulWidget {
  const GenerateReportPage({super.key});

  @override
  State<GenerateReportPage> createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  String? selectedBusName;
  DateTime selectedDate = DateTime.now();
  String? selectedDestination;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SummaryProvider>(context, listen: false).fetchData();
    });
  }

  Future<void> generateReport(SummaryProvider summaryProvider) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Sales Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              pw.Text('Bus: ${selectedBusName ?? "All"}'),
              pw.Text('Destination: ${selectedDestination ?? "All"}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Route'),
                      pw.Text('Sales'),
                    ],
                  ),
                  ...summaryProvider.salesByRoute.entries.map((entry) {
                    final route = entry.key.split(' > ');
                    if ((selectedBusName == null || route[0] == selectedBusName) &&
                        (selectedDestination == null || route[1] == selectedDestination)) {
                      return pw.TableRow(
                        children: [
                          pw.Text(entry.key),
                          pw.Text('RWF ${NumberFormat('#,##0').format(entry.value)}'),
                        ],
                      );
                    } else {
                      return pw.TableRow(children: [pw.SizedBox(), pw.SizedBox()]);
                    }
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total Sales: RWF ${NumberFormat('#,##0').format(summaryProvider.totalSales)}'),
              pw.Text('Tickets Sold Today: ${summaryProvider.ticketsSoldToday}'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'sales_report.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SummaryProvider>(
      builder: (context, summaryProvider, child) {
        List<String> busNames = summaryProvider.salesByRoute.keys
            .map((route) => route.split(' > ')[0])
            .toSet()
            .toList();
        List<String> destinations = summaryProvider.salesByRoute.keys
            .map((route) => route.split(' > ')[1])
            .toSet()
            .toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: mcgpalette0[50],
            title: const Text("Generate Report"),
          ),
          body: summaryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedBusName,
                        hint: const Text("Select Departure"),
                        items: busNames.map((busName) => DropdownMenuItem(
                          value: busName,
                          child: Text(busName),
                        )).toList(),
                        onChanged: (value) => setState(() => selectedBusName = value),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Text(DateFormat('yMd').format(selectedDate)),
                          IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2023, 1, 1),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() => selectedDate = pickedDate);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        value: selectedDestination,
                        hint: const Text("Select Destination"),
                        items: destinations.map((destination) => DropdownMenuItem(
                          value: destination,
                          child: Text(destination),
                        )).toList(),
                        onChanged: (value) => setState(() => selectedDestination = value),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40), 
                          backgroundColor: mcgpalette0[50],
                        ),
                        onPressed: () => generateReport(summaryProvider),
                        child: const Text("Generate Report", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}