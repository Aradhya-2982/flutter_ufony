import 'package:flutter/material.dart';
import 'package:my_first_app/views/fee_screen.dart';
import 'package:provider/provider.dart';

import 'viewmodels/fee_view_model.dart';
import 'viewmodels/due_fee_view_model.dart';
import 'viewmodels/paid_fee_view_model.dart';


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
