import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../uihelper/currency_symb.dart';
import '../uihelper/constants.dart';
import '../viewmodels/due_fee_view_model.dart';
import '../viewmodels/fee_view_model.dart';


class FeeScreen extends StatelessWidget {
  const FeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feeViewModel = Provider.of<FeeViewModel>(context);
    final dueVM = feeViewModel.dueFeeVM;
    final paidVM = feeViewModel.paidFeeVM;

    return Consumer<DueFeeViewModel>(
      builder: (context, value, child){
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Constants.cardColor,
            elevation: 0,
            toolbarHeight: 70,
            centerTitle: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Constants.appbarIconColor),
              onPressed: () {
                Navigator.pop(context);
                },
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fees', style: TextStyle(color: Colors.black)),
                Text('Avni A D', style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.calendar_today, color: Constants.appbarIconColor),
                color: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (year) => feeViewModel.filterByYear(year),
                itemBuilder: (context) => feeViewModel.academicYears
                    .map((year) => PopupMenuItem(
                  value: year,
                  child: SizedBox(
                    width: 80,
                    height: 50,
                    child: Center(
                      child: Constants.calenderIconList(text: year),
                    ),
                  ),
                )).toList(),
              ),
              Icon(Icons.more_vert, color: Constants.appbarIconColor),
              SizedBox(width: Constants.boxGap),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Constants.smallNormalFont(text: 'Due'),
              SizedBox(height: Constants.boxGap),
              ...dueVM.duePayments.asMap().entries.map((entry) {
                final index = entry.key;
                final fee = entry.value;
                final date = DateTime.parse(fee.nextPaymentDate!);
                final isOverdue = date.isBefore(DateTime.now());

                return InkWell(
                  onTap: () => dueVM.toggleSelection(index),
                  child: Card(
                    color: Constants.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Radio<int>(
                        value: index,
                        groupValue: dueVM.selectedIndexes.contains(index) ? index : null,
                        toggleable: true,
                        onChanged: (_) => dueVM.toggleSelection(index),
                      ),
                      title: Constants.largeBoldFont(text: CurrencyFormatter.currencySymbol(fee.amount , context)),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Constants.smallThinFont(text: fee.feeType),
                          Text(
                            'Due on ${feeViewModel.formatDate(fee.nextPaymentDate!)}',
                            style: TextStyle(
                              color: isOverdue ? Colors.red : Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => dueVM.markAsPaid(index, (paid) => paidVM.addPayment(paid),feeViewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.buttonColor,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text("Pay Now"),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Constants.smallNormalFont(text: 'Paid'),
              const SizedBox(height: 10),
              ...paidVM.paidPayments.map((fee) => Card(
                color: Constants.cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Constants.largeBoldFont(text: CurrencyFormatter.currencySymbol(fee.amount , context)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Constants.smallThinFont(text: fee.feeType),
                      Text(
                        'Paid on ${feeViewModel.formatDate(fee.paidOnDate ?? '')}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              )),
            ]),
          ),
          bottomNavigationBar: dueVM.selectedIndexes.isNotEmpty
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFDBE2FF),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${dueVM.selectedIndexes.length} Selected\n${dueVM.selectedIndexes.map((i) => dueVM.duePayments[i].feeType).join(', ')}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF45198E),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text("Pay ${CurrencyFormatter.currencySymbol(dueVM.totalSelectedAmount, context)}"),
                )
              ],
            ),
          )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
