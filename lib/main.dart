  import 'dart:convert';
  import 'dart:io';

  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:flutter/services.dart' show rootBundle;
  import 'package:path_provider/path_provider.dart'; // Import the path_provider package for file operations like getting the application's documents directory.

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
    // selectedIndexes is a set of integers representing the indices of the selected items in feesDue.

    final Color lavender = const Color(0xFFDBE2FF);
    final Color purple = const Color(0xFF45198E);

    @override
    void initState() {
      super.initState();
      loadFeeData();        // Load fee data when the widget is initialized from the local json file.
    }

    // The loadFeeData() function is used to load fee data from a local JSON file from "assets/dataFile.json".
    Future<void> loadFeeData() async {
      try {
        final dir = await getApplicationDocumentsDirectory();   // Get the application's documents directory.
        final file = File('${dir.path}/data.json');   // Create a file 'data.json' in the documents directory.
        final String jsonString = await rootBundle.loadString('assets/dataFile.json');   // Load the JSON data from the "assets/dataFile.json" file.
        await file.writeAsString(jsonString);    // Write the JSON data to the file.

        final content = await file.readAsString();
        final decoded = json.decode(content); // Decode the JSON data to proper Dart model.

        setState(() {
          allData = decoded;
          academicYears = decoded
              .map<String>((e) => e['academicYear']['label'] as String)
              .toSet()
              .toList(); // Extract academic years from the data and store them in a list of strings.
          selectedYear = academicYears.first; // Set the first academic year as the default selected year.

        });
        filterByAcademicYear(selectedYear!);
      } catch (e) {
        // print("File read error: $e");
      }
    }

    // The filterByAcademicYear(String year) function is used to filter fee data based on the selected academic year.
    void filterByAcademicYear(String year) {
      final yearData =
      allData.where((e) => e['academicYear']['label'] == year).toList();
      if (yearData.isEmpty) return;

      final payments = yearData.first['payments'] as List<dynamic>; // Extract the payments list from the first element of the yearData list and cast it to a List<dynamic>.


      // Sort the payments list based on the 'paidStatus' field.
      final due = payments.where((p) => p['paidStatus'] == 'unPaid').map((p) {
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

      // Update the state with the filtered data.
      setState(() {
        feesDue = due;
        feesPaid = paid;
        selectedIndexes.clear();
      });
    }

    // The formatDate(String isoDate) function is used to format a date string in ISO 8601 format to a more readable format.
    String formatDate(String isoDate) {
      try {
        DateTime parsedDate = DateTime.parse(isoDate);
        return DateFormat("d MMM yyyy").format(parsedDate);
      } catch (e) {
        return "Invalid date";
      }
    }
    // The updateFile() function is used to update the file with the current state of allData when changes are made to it.
    Future<void> updateFile() async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/data.json');
        await file.writeAsString(json.encode(allData));
      } catch (e) {
        // print("File save error: $e");
      }
    }
    // The selected(int index) function is used to toggle the selection of an item in the feesDue list.


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
            // Dropdown button for selecting academic year with a custom popup menu.
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
                filterByAcademicYear(year); // Filter the fee data based on the selected academic year.
              },
              itemBuilder: (context) => academicYears // Create a popup menu item for each academic year.
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
                        color: Color(0xFFFFFFFF),
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
            const Text("Due", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            ...feesDue.asMap().entries.map((entry) { // Iterate through the feesDue list and create a card for each item and asMap() is used to get the index of the entry.
              int index = entry.key;// 'index' is the index of the current entry in the list.
              var fee = entry.value; // 'fee' is the value of the current entry in the list.

              // Calculate the due color based on the due date.
              DateTime now = DateTime.now();
              DateTime date = DateFormat("d MMM yyyy").parse(fee["dueDate"]);
              Color dueColor = date.isBefore(now) ? Color(0xFFBD1C0D) : Colors.black;


              return InkWell( // InkWell is used to handle tap events on the card.
                onTap: () {
                  setState(() {
                    selectedIndexes.contains(index)
                        ? selectedIndexes.remove(index)
                        : selectedIndexes.add(index);
                  });
                },
                child: Card(
                  color: lavender,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Radio<int>(
                      value: index,
                      groupValue: selectedIndexes.contains(index) ? index : null,
                      toggleable: true, // Allow the radio button to be toggled- select & deselect.
                      onChanged: (_) { // Handle the radio button tap event.
                        setState(() {
                          selectedIndexes.contains(index)
                              ? selectedIndexes.remove(index)
                              : selectedIndexes.add(index); // Toggle the selection of the item.
                        });
                      },
                    ),
                    title: Text('₹ ${fee["amount"]}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fee["title"], style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w300)),
                        Text('Due on ${fee["dueDate"]}',
                            style: TextStyle(color: dueColor, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Create a new item to be added to the feesPaid list and update the state.
                          final paidItem = {
                            "title": fee["title"],
                            "amount": fee["amount"],
                            "paidDate": formatDate(DateTime.now().toIso8601String())
                          };
                
                          // Find the corresponding student in the allData list and update their payment status.
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
                          // Remove the item from the feesDue list and add it to the feesPaid list.
                          selectedIndexes = selectedIndexes
                              .where((i) => i != index)
                              .map((i) => i > index ? i - 1 : i)
                              .toSet();
                        });
                        // Update the file with the changes.
                        updateFile();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder()),
                
                      child: const Text("Pay Now"),
                
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text("Paid", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                    Text(fee["title"], style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w300)),
                    Text('Paid on ${fee["paidDate"]}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            )),
          ]),
        ),

          // Bottom bar with pay button if item(s) is selected(s) in the feesDue list.
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
                  offset: Offset(0, -2), // Shadow appears above the bar. -2 is the vertical offset.
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
                  child: Text("Pay ₹ ${selectedIndexes.map((i) => feesDue[i]['amount'] as int).reduce((a, b) => a + b)}"), // .reduce((a, b) => a + b) is used to sum the amounts of selected items by mapping the amounts to integers and summing them. 'a' is the accumulator and 'b' is the current value.
                )
              ],
            ),
          ) : SizedBox.shrink()
      );
    }
  }
