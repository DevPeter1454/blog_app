import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litcon/Model/model.dart';

class Tags extends StatefulWidget {
  const Tags({Key? key}) : super(key: key);

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> posts = [];
  dynamic tag;
  // bool? liked;
  getTagPosts() {
    _firestore.collection('posts').get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['type'].contains(tag)) {
          setState(() {
            posts.add(Post.fromMap(element.data()));
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getTagPosts();
  }

  @override
  Widget build(BuildContext context) {
    tag = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(tag.toString().toUpperCase()),
      ),
        body: posts.isEmpty
            ? Center(
              child: Text(
                  'No posts under ${tag.toString().toUpperCase()} yet...Watch out', style: GoogleFonts.acme(
                  fontSize: 20,
                  ),),
            )
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: ((context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(posts[index].text),
                      subtitle: Text(posts[index].content,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      leading: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                          child: Image.network(
                            posts[index].postUrl,
                            fit: BoxFit.cover,
                          )),
                      
                      onTap: () {
                        Navigator.pushNamed(context, '/view', arguments: posts[index].postId);
                      },
                    ),
                  );
                }),
              ));
  }
}
