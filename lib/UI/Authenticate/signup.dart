// ignore_for_file: use_build_context_synchronously

import 'package:litcon/Auth/auth_methods.dart';
import 'package:litcon/UI/widgets/loading.dart';
import 'package:litcon/UI/widgets/widgets.dart';
import 'package:flutter/material.dart';
// import 'package:auth_buttons/auth_buttons.dart';
import 'package:file_picker/file_picker.dart';
// import 'dart:io';
import 'dart:typed_data';

enum AuthMode {
  user,
  admin,
}

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController email = TextEditingController();
  final TextEditingController fname = TextEditingController();
  final TextEditingController lname = TextEditingController();
  final TextEditingController password = TextEditingController();
  AuthMode _auth = AuthMode.user;
  String type = 'user';
  Uint8List? image;
  dynamic result;
  bool loading = false;

  signUp() async {
    if (result == null) {
      setState(() {
        loading = true;
      });
    }
    result = await Auth().registerUser(fname.text.trim(), lname.text.trim(),
        email.text.trim(), password.text.trim(), image, type) as Map;

    if (result != null) {
      setState(() {
        loading = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${result['message']}'.toString()),
    ));

    // print('$result result');
  }

  googleSignIn() async {
    if (result == null) {
      setState(() {
        loading = true;
      });
    }
    result = await Auth().googleSignIn();

    if (result != null) {
      setState(() {
        loading = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${result['message']}'.toString()),
    ));

    // print('$result result');
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // allowedExtensions: ['jpg', 'png'],
    );
    // var file = result.files.first.bytes;
    setState(() {
      image = result!.files.first.bytes;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.grey[200],
            body: SingleChildScrollView(
              child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10,),
                              const Text('Welcome'),
                              const SizedBox(height: 10,),
                              ListTile(
                                leading: Radio(
                                  value: AuthMode.user,
                                  groupValue: _auth,
                                  onChanged: (AuthMode? value) {
                                    setState(() {
                                      _auth = value!;
                                      type = 'user';
                                      print(type);

                                    });
                                  },
                                ),
                                title: const Text('Sign Up as User'),
                              ),
                            
                          if(_auth==AuthMode.user)
                          authenticatee(context),
              ListTile(
                    leading: Radio(
                      value: AuthMode.admin,
                      groupValue: _auth,
                      onChanged: (AuthMode? value) {
                        setState(() {
                          _auth = value!;
                          type = 'admin';
                          print(type);
                        });
                      },
                    ),
                    title: const Text('Sign Up as Admin'),
                  ),
              if(_auth==AuthMode.admin)
               authenticatee(context),
              ])
            )));
  }

  Center authenticatee(BuildContext context) {
    return Center(
                            child: Card(
                                child: Container(
                          width: 400,
                          height: 650,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('Register'),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: fname,
                                  decoration: textField.copyWith(labelText: 'First Name'),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: lname,
                                  decoration: textField.copyWith(labelText: 'Last Name'),
                                ),
                                const SizedBox(height: 10),
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
                                Container(
                                  width: 350,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                  child: image == null
                                      ? IconButton(
                                          onPressed: () {
                                            pickFile();
                                          },
                                        
            icon: const Icon(Icons.add_a_photo),
                            )
                          : Image.memory(
                              image!,
                            ),
                    ),
                    OutlinedButton(
                      child: const Text('Sign Up'),
                      onPressed: () {
                        if (fname.text.trim().isNotEmpty &&
                            lname.text.trim().isNotEmpty &&
                            email.text.trim().isNotEmpty &&
                            password.text.trim().isNotEmpty &&
                            image != null) {
                          signUp();
                          lname.clear();
                          fname.clear();
                          email.clear();
                          password.clear();
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.5),
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content:
                                  const Text('Please fill all the fields'),
                              actions: <Widget>[
                                OutlinedButton(
                                  child: const Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('OR'),
                    const SizedBox(height: 10),
                    _auth == AuthMode.user?
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
                            ])) : const SizedBox.shrink(),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Colors.black, indent: 20),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signin');
                          },
                          child: const Text('Sign In',
                              style: TextStyle(
                                color: Colors.blue,
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )));
  }
}
