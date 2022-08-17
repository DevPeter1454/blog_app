// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litcon/Model/model.dart';
import 'package:litcon/UI/widgets/loading.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  final dynamic uid;
  const Profile({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  dynamic data;
  User? user;
  bool isLoading = true;
  List<Post> posts = [];
  getUser() {
    _firestore.collection('users').get().then((value) {
      value.docs.forEach((element) {
        if (element.reference.id == widget.uid) {
          setState(() {
            data = element.data();
            user = User.fromMap(data);
            isLoading = false;
          });
        }
      });
    });
   
  }

  // getLikedPosts() async{
  //   await _firestore.collection('posts').get().then((value) {
  //     for (var element in value.docs) {
  //       if(user != null){
  //         if (element.data()['likes'].contains(user!.uid)) {
  //         print(element.data()['likes']);
  //       }
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    getUser();
    // getLikedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : Scaffold(
            body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user!.photoUrl),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                user!.displayname,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                user!.email,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                '${user!.followers.length.toString()} followers',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                '${user!.following.length.toString()} following',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ));
  }
}
