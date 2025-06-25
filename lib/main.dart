  import 'dart:convert';
  import 'dart:io';

  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:flutter/services.dart' show rootBundle;
  import 'package:path_provider/path_provider.dart';

  void main() {
    runApp(MaterialApp(
      home: FeeScreen(),
      debugShowCheckedModeBanner: false,
    ));
  }

  class FeeScreen extends StatefulWidget {
    const FeeScreen({super.key});

    @override
    State<FeeScreen> createState() => _FeeScreenState();
  }

  class _FeeScreenState extends State<FeeScreen> {
    List<dynamic> allData = [];
    List<String> academicYears = [];
    String? selectedYear;
    List<dynamic> feesDue = [];
    List<dynamic> feesPaid = [];

    Set<int> selectedIndexes = {};

    final Color lavender = const Color(0xFFDBE2FF);
    final Color purple = const Color(0xFF45198E);

    @override
    void initState() {
      super.initState();
      loadFeeData();
    }


    Future<void> loadFeeData() async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/data.json');
        final String jsonString = await rootBundle.loadString('assets/dataFile.json');
        await file.writeAsString(jsonString);

        final content = await file.readAsString();
        final decoded = json.decode(content);

        setState(() {
          allData = decoded;
          academicYears = decoded
              .map<String>((e) => e['academicYear']['label'] as String)
              .toSet()
              .toList();
          selectedYear = academicYears.first;

        });
        filterByAcademicYear(selectedYear!);
      } catch (e) {
        // print("Error loading data: $e");
      }
    }

    void filterByAcademicYear(String year) {
      final yearData =
      allData.where((e) => e['academicYear']['label'] == year).toList();
      if (yearData.isEmpty) return;

      final payments = yearData.first['payments'] as List<dynamic>;



      final due = payments.where((p) => p['paidStatus'] == 'unPaid').map((p){
        return {
          "title": p["feeType"],
          "amount": p["amount"],
          "dueDate": formatDate(p["nextPaymentDate"])
        };
      }).toList();

      final paid = payments.where((p) => p['paidStatus'] == 'Paid').map((p) {
        return {
          "title": p["feeType"],
          "amount": p["amount"],
          "paidDate": formatDate(p["paidOnDate"])
        };
      }).toList();

      setState(() {
        feesDue = due;
        feesPaid = paid;
        selectedIndexes.clear();
      });
    }
    String formatDate(String isoDate) {
      try {
        DateTime parsedDate = DateTime.parse(isoDate);
        return DateFormat("d MMMM yyyy").format(parsedDate);
      } catch (e) {
        return "Invalid date";
      }
    }

    Future<void> updateFile() async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/data.json');
        await file.writeAsString(json.encode(allData));
      } catch (e) {
        // print("File save error: $e");
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: lavender,
          elevation: 0,
          toolbarHeight: 70,
          centerTitle: false,
          leading: const Icon(Icons.arrow_back, color: Colors.black),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fees', style: TextStyle(color: Colors.black)),
              Text('Avni A D', style: const TextStyle(color: Colors.black, fontSize: 16))
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.calendar_today, color: Colors.black),
              color: Color(0xFF000000), // Background of the popup menu
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (String year) {
                setState(() {
                  selectedYear = year;
                });
                filterByAcademicYear(year);
              },
              itemBuilder: (context) => academicYears
                  .map((year) => PopupMenuItem(
                value: year,
                child: SizedBox(
                  width: 80,
                  height: 50,
                  child: Center(
                    child: Text(year,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFFFFFFFF), // Purple
                      )),
                  ),
                ),
              ))
                  .toList(),
            ),
            const Icon(Icons.more_vert, color: Colors.black),
            const SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Due", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...feesDue.asMap().entries.map((entry) {
              int index = entry.key;
              var fee = entry.value;

              DateTime now = DateTime.now();
              DateTime date = DateTime.tryParse(fee["dueDate"]) ?? now;
              Color dueColor = date.isBefore(now) ? Colors.red : Colors.black;

              return Card(
                color: lavender,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Radio<int>(
                    value: index,
                    groupValue: selectedIndexes.contains(index) ? index : null,
                    toggleable: true,
                    onChanged: (_) {
                      setState(() {
                        selectedIndexes.contains(index)
                            ? selectedIndexes.remove(index)
                            : selectedIndexes.add(index);
                      });
                    },
                  ),
                  title: Text('₹ ${fee["amount"]}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fee["title"], style: const TextStyle(fontSize: 16)),
                      Text('Due on ${fee["dueDate"]}',
                          style: TextStyle(color: dueColor, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        final paidItem = {
                          "title": fee["title"],
                          "amount": fee["amount"],
                          "paidDate": formatDate(DateTime.now().toIso8601String())
                        };

                        for (var student in allData) {
                          if (student['academicYear']['label'] == selectedYear) {
                            for (var payment in student['payments']) {
                              if (payment['feeType'] == fee['title'] &&
                                  payment['amount'] == fee['amount'] &&
                                  payment['paidStatus'] == 'unPaid') {
                                payment['paidStatus'] = 'Paid';
                                payment['paidOnDate'] =
                                    DateTime.now().toIso8601String();
                                break;
                              }
                            }
                          }
                        }

                        feesPaid.add(paidItem);
                        feesDue.removeAt(index);
                        selectedIndexes = selectedIndexes
                            .where((i) => i != index)
                            .map((i) => i > index ? i - 1 : i)
                            .toSet();
                      });
                      updateFile();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder()),

                    child: const Text("Pay Now"),

                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text("Paid", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...feesPaid.map((fee) => Card(
              color: lavender,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('₹ ${fee["amount"]}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fee["title"], style: const TextStyle(fontSize: 16)),
                    Text('Paid on ${fee["paidDate"]}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            )),
          ]),
        ),
          bottomNavigationBar: selectedIndexes.isNotEmpty
              ?  Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            decoration: BoxDecoration(
              color: lavender,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: Offset(0, -2), // Shadow appears above the bar
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${selectedIndexes.length} Selected\n${selectedIndexes.map((i) => feesDue[i]['title']).join(', ')}",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text("Pay ₹ ${selectedIndexes.map((i) => feesDue[i]['amount'] as int).reduce((a, b) => a + b)}"),
                )
              ],
            ),
          ) : SizedBox.shrink()
      );
    }
  }
