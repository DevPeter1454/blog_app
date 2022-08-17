import 'package:litcon/UI/Authenticate/signin.dart';
import 'package:litcon/UI/Authenticate/signup.dart';
import 'package:litcon/UI/views/tabs/dashboard.dart';
import 'package:litcon/UI/views/myposts.dart';
import 'package:litcon/UI/views/posts.dart';
import 'package:litcon/UI/views/tabs/home.dart';
import 'package:litcon/UI/views/tags.dart';
import 'package:litcon/UI/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading();
          } else if (snapshot.hasData) {
            dynamic name = snapshot.data;
            print(name);
            return HomePage(uid: name.uid);
          }
          return const SignUp();
        },
      ),

      routes: {
        '/signin': (context) => const SignIn(),
        '/view': (context) => const View(),
        '/myposts': (context) => const MyPosts(),
        '/tags': (context) => const Tags(),
      },
      // initialRoute: '/',
    );
  }
}
