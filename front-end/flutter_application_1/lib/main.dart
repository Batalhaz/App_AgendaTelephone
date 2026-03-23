import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/contacts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
void main()async{ 
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isWindows || Platform.isLinux || Platform.isMacOS){
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Supabase.initialize(
    url: 'https://xhdmuqxpiiryazmlhxpw.supabase.co',
    anonKey: 'sb_publishable_zXKnCWjVHMv_-k9ZznGslg_X5UcMb5Z',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts',
      initialRoute: '/',
      routes: {
        '/': (context) => const ContactsHome(),
        '/contacts/': (context) => const ContactsHome(),
      },
    );
  }
}
