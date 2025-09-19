import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/app.dart';
import 'package:test_hsa_group/init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyApp());
}