import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'executor.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {"/": (context) => Executor()},
    debugShowCheckedModeBanner: false,
  ));
}
