// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:litcon/Auth/auth_methods.dart';
import 'package:litcon/Model/model.dart';
import 'package:litcon/UI/views/tabs/categories.dart';
import 'package:litcon/UI/views/tabs/dashboard.dart';
import 'package:litcon/UI/views/tabs/favourites.dart';
import 'package:litcon/UI/views/tabs/profile.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  final dynamic uid;
  const HomePage({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  dynamic data;
  User? user;
  PageController pageController = PageController();
  final TextEditingController searchController = TextEditingController();
  int initialIndex = 0;
  logout() async {
    // Navigator.popUntil(context,  ModalRoute.withName('/signup'));
    Auth().logout();
  }

  List<Widget> pages = [];

  readData() {
    _firestore.collection('users').get().then((value) {
      value.docs.forEach((element) {
        if (element.reference.id == widget.uid) {
          setState(() {
            data = element.data();
            user = User.fromMap(data);
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readData();
    // print(categories);
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      const DashBoard(),
      const Categs(),
      const Favorites(),
      Profile(uid: widget.uid),
    ];

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.grey[200],
          iconTheme: IconThemeData(color: Colors.amber[600]),
          actions: [
            IconButton(
                onPressed: () {
                  logout();
                },
                icon: const Icon(Icons.logout))
          ]),
      drawer: user == null
          ? const SizedBox.shrink()
          : Drawer(
              child: ListView(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user!.photoUrl),
                        radius: 50,
                      ),
                      Text(
                        user!.displayname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                user!.type == 'user'
                    ? const SizedBox.shrink()
                    : ListTile(
                        title: const Text('My Posts'),
                        onTap: () {
                          Navigator.pop(context);

                          Navigator.pushNamed(context, '/myposts',
                              arguments: user!);
                        },
                      ),
                ListTile(
                  title: const Text('Logout'),
                  onTap: () {
                    logout();
                  },
                ),
              ],
            )),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            initialIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const [
          Icons.dashboard,
          Icons.category,
          Icons.favorite,
          Icons.person,
        ],
        onTap: (index) {
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
        activeIndex: initialIndex,
        activeColor: Colors.amber[600],
        inactiveColor: Colors.grey[600],
        gapWidth: 20,
      ),
    );
  }
}
