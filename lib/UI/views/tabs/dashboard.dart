// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:typed_data';
import 'package:litcon/Model/model.dart';
import 'package:litcon/UI/Dashboard/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litcon/Auth/auth_methods.dart';

class DashBoard extends StatefulWidget {
  // final dynamic uid;
  const DashBoard({
    Key? key,
    // required this.uid,
  }) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final _firestore = FirebaseFirestore.instance;
  dynamic data;
  num? width;
  User? user;
  List<Categories> categories = getCategories();
  // var num = Random().nextInt(100);
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  ScrollController controller = ScrollController();
  ScrollController viewcontroller = ScrollController();
  Uint8List? image;
  logout() async {
    // Navigator.popUntil(context,  ModalRoute.withName('/signup'));
    Auth().logout();
  }

  @override
  void initState() {
    super.initState();
    // readData();
    // print(categories);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  controller: viewcontroller,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      onTap: () {
                        print(categories[index].text);
                        Navigator.pushNamed(context, '/tags',
                            arguments: categories[index].text);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(children: [
                          Image.network(
                            categories[index].image,
                            height: 308,
                            width: 250,
                            fit: BoxFit.fitHeight,
                            color: const Color.fromARGB(255, 100, 100, 100)
                                .withOpacity(0.2),
                            colorBlendMode: BlendMode.modulate,
                          ),
                          Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              top: 20,
                              child: Center(
                                  child: Text(
                                categories[index].text.toUpperCase(),
                                style: GoogleFonts.acme(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              )))
                        ]),
                      ),
                    );
                  }))),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Latest',
                  style: GoogleFonts.acme(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ))),
          Expanded(
            child: StreamBuilder(
                stream: _firestore.collection('posts').snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: SpinKitFadingCube(
                      color: Colors.blue,
                      size: 50.0,
                    ));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error'));
                  } else if (snapshot.hasData) {
                    if (width! < 600) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: controller,
                              itemCount: snapshot.data.docs.length < 5
                                  ? snapshot.data.docs.length
                                  : 5,
                              itemBuilder: ((context, index) {
                                var posts = snapshot.data.docs[index].data();
                                return Card(
                                  child: ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      child: Image.network(
                                        posts['postUrl'],
                                        color: const Color.fromARGB(
                                                255, 100, 100, 100)
                                            .withOpacity(0.2),
                                        colorBlendMode: BlendMode.modulate,
                                      ),
                                    ),
                                    title: Text(
                                      snapshot.data.docs[index]
                                          .data()['text']
                                          .toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.acme(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w100,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    subtitle: Text(
                                      snapshot.data.docs[index]
                                          .data()['content'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.acme(
                                        fontSize: 12,
                                        // fontWeight: FontWeight.w100,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    onTap: () {
                                      Post post = Post.fromMap(
                                          snapshot.data.docs[index].data());
                                      Navigator.pushNamed(context, '/view',
                                          arguments: post.postId);
                                      // print(post.liked);
                                    },
                                  ),
                                );
                              })));
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                            controller: controller,
                            itemCount: snapshot.data.docs.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: width! < 600
                                  ? 1
                                  : width! > 600 && width! < 700
                                      ? 2
                                      : width! > 700 && width! < 850
                                          ? 3
                                          : 4,
                            ),
                            itemBuilder: (context, index) {
                              var posts = snapshot.data.docs[index].data();

                              return GestureDetector(
                                onTap: () {
                                  Post post = Post.fromMap(
                                      snapshot.data.docs[index].data());
                                  Navigator.pushNamed(context, '/view',
                                      arguments: post.postId);
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child:
                                              Image.network(posts['postUrl']),
                                        ),
                                        Text(
                                          snapshot.data.docs[index]
                                              .data()['text'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          snapshot.data.docs[index]
                                              .data()['content'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      );
                    }
                  }
                  return const Text('No Data');
                }),
          ),
        ],
      ),
      // bottomNavigationBar: AnimatedBottomNavigationBar(
      //   icons: const [
      //     Icons.home,
      //     Icons.search,
      //     Icons.favorite,
      //     Icons.person,
      //   ]),
    );
  }
}
