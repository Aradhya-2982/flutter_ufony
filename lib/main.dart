import 'package:flutter/material.dart';
import 'package:my_first_app/views/fee_screen.dart';
import 'package:provider/provider.dart';

import 'viewmodels/fee_view_model.dart';
import 'viewmodels/due_fee_view_model.dart';
import 'viewmodels/paid_fee_view_model.dart';

// 1. localization of hard coded string
// 2. in fee view , use term parameter to show on ui card view
// 3. add long press , so when user presses long on card (not button or radio button) pop up appears showing info about fee (i.e. feetype paramter)
// 4. converge all the viewmodels into single one
// 5. add pdf loading and opening on "receiptUrl" parameter in model class , onclick to forward icon
// ( if there is no pdf app, open the url in any browser)
// 6. "lateFeeCharges": 660.00,use fee subdetails to show breakdown of paid fee in a bottom sheet pressed on forward icon
// show payment id and feeid in details block


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DueFeeViewModel()),
        ChangeNotifierProvider(create: (_) => PaidFeeViewModel()),
        ChangeNotifierProvider(
          create: (context) => FeeViewModel(
            dueFeeVM: context.read<DueFeeViewModel>(),
            paidFeeVM: context.read<PaidFeeViewModel>(),
          )..loadData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FeeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
