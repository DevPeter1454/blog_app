import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:litcon/Model/model.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> posts = [];
  getUser() {
    _firestore.collection('posts').get().then((value) {
      for (var element in value.docs) {
        if (element.data()['likes'].contains(_auth.currentUser!.uid)) {
          posts.add(Post.fromMap(element.data()));
        }
      }
      setState(() {});
      print(posts);
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        // physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Card(
              child: ListTile(
            title: Text(posts[index].text),
            subtitle: Text(posts[index].content,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Image.network(
                posts[index].postUrl,
                color:
                    const Color.fromARGB(255, 100, 100, 100).withOpacity(0.2),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red), 
              onPressed: () {
                _firestore.collection('posts').doc(posts[index].postId).update({
                  'likes': FieldValue.arrayRemove([_auth.currentUser!.uid])
                });
                posts.clear();
                getUser();
                // setState(() {
                  
                // });

              }),
          ));
        },
        itemCount: posts.length,
      ),
    ));
  }
}
