// ignore_for_file: use_build_context_synchronously

import 'package:litcon/Auth/auth_methods.dart';
import 'package:litcon/UI/widgets/loading.dart';
import 'package:litcon/UI/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  dynamic result;
  bool loading = false;
  login() async {
    if (result == null) {
      setState(() {
        loading = true;
      });
    }
    result =
        await Auth().signIn(email.text.trim(), password.text.trim()) as Map;
    if (result != null) {
      setState(() {
        loading = false;
        if (result['message'] == 'success') {
          Navigator.pop(context);
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${result['message']}'.toString()),
    ));
  }
  googleSignIn() async {
    if (result == null) {
      setState(() {
        loading = true;
      });
    }
    result = await Auth().googleSignIn() as Map;

    if (result != null) {
      setState(() {
        loading = false;
        if (result['message'] == 'success') {
          Navigator.pop(context);
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${result['message']}'.toString()),
    ));

    // print('$result result');
  }

  @override
  Widget build(BuildContext context) {
    return loading? const Loading(): Scaffold(
        body: SafeArea(
            child: Center(
                child: Card(
      child: Container(
          width: 400,
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Sign in'),
                const SizedBox(height: 15),
                TextField(
                  controller: email,
                  decoration: textField.copyWith(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: textField.copyWith(labelText: 'Password'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    if (email.text.trim().isNotEmpty &&
                        password.text.trim().isNotEmpty) {
                      login();
                      email.clear();
                      password.clear();
                    } else {
                      showDialog(
                          barrierDismissible: false,
                          barrierColor: Colors.black.withOpacity(0.5),
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content:
                                    const Text('Please fill all the fields'),
                                actions: <Widget>[
                                  OutlinedButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ));
                    }
                  },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 10),
                      const Text('OR'),
                      const SizedBox(height: 10),
                      OutlinedButton(
                          onPressed: () {
                            googleSignIn();
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 15,
                                  child: Image.network(
                                    'https://img.icons8.com/color/48/000000/google-logo.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('Sign in with Google'),
                              ])),
                      const SizedBox(height: 10),
              ],
            ),
          )),
    ))));
  }
}
