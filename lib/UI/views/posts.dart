import 'package:firebase_auth/firebase_auth.dart';
import 'package:litcon/Model/model.dart' as user;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:litcon/Model/model.dart';
// import 'package:litcon/Model/model.dart';

class View extends StatefulWidget {
  const View({Key? key}) : super(key: key);

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  // FirebaseFirestore _firestore = FirebaseFirestore.instance;
  dynamic post;
  dynamic postReceived;
  dynamic user;
  dynamic writer;
  ScrollController controller = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var height;
  var width;
  bool liked = false;
  likeBlog(String id, List like) async {
    if (postReceived.likes.contains(FirebaseAuth.instance.currentUser!.uid)) {
      await _firestore.collection('posts').doc(id).update({
        'likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
        // 'liked': false,
      });
    } else {
      await _firestore.collection('posts').doc(id).update({
        'likes':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
    }
  }

  followWriter() async {
    if (postReceived.uid != FirebaseAuth.instance.currentUser!.uid) {
      if (writer['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid)) {
        await _firestore.collection('users').doc(writer['uid']).update({
          'followers':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
        });
      }else {
        await _firestore.collection('users').doc(postReceived.uid).update({
          'followers':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
        });
      }

     
    }
  }
  followUser()async{
     if (user['following'].contains(writer['uid'])) {
        await _firestore.collection('users').doc(user['uid']).update({
          'following':
              FieldValue.arrayRemove([writer['uid']]),
        });
      }else{
        await _firestore.collection('users').doc(user['uid']).update({
          'following':
              FieldValue.arrayUnion([writer['uid']]),
        });
      }
  }

  readData() {
    _firestore.collection('users').get().then((value) {
      value.docs.forEach((element) {
        if (element.reference.id == FirebaseAuth.instance.currentUser!.uid) {
          setState(() {
            user = element.data();
          });
          print(user);
          // print(postReceived.uid);
        }
        if (element.reference.id == postReceived.uid) {
          setState(() {
            writer = element.data();
          });
          print(writer);
        }
      });
    });
  }

  getPost() async {
    await _firestore.collection('posts').get().then((value) {
      for (var element in value.docs) {
        if (element.reference.id == post) {
          setState(() {
            postReceived = Post.fromMap(element.data());
            liked = postReceived.likes
                .contains(FirebaseAuth.instance.currentUser!.uid);
            // liked = postReceived.liked;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      getPost();
      readData();
    });
  }

  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context)!.settings.arguments;
    // print("build ${post}");
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        // appBar: AppBar(),
        body: SafeArea(
      // minimum: const EdgeInsets.all(8.0),
      child: postReceived == null || user == null || writer == null
          ? Container(
              alignment: Alignment.center,
              child: const Center(
                child: SpinKitFadingCube(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            )
          : SingleChildScrollView(
              controller: controller,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 350,
                  child: Stack(children: [
                    Image.network(postReceived.postUrl,
                        // fit: BoxFit.fitWidth,
                        width: double.infinity,
                        height: 300),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios,
                              color: Colors.amber[800], size: 30)),
                    ),
                  ]),
                ),
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.5,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(postReceived.profileImg),
                        ),
                        title: Text(postReceived.username),
                        subtitle: Text(
                            '${DateFormat.yMMMd().format(postReceived.date)}'),
                      ),
                    ),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () async {
                              await likeBlog(
                                  postReceived.postId, postReceived.likes);
                              getPost();
                              setState(() {
                                // liked = !liked;
                              });
                            },
                            icon: postReceived.likes.contains(
                                    FirebaseAuth.instance.currentUser!.uid)
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(Icons.favorite_border,
                                    color: Colors.amber)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${postReceived.likes.length} likes'),
                      ),
                       postReceived.uid == FirebaseAuth.instance.currentUser!.uid ?
                          const SizedBox.shrink():
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () async {
                            await followWriter();
                            await followUser();
                            readData();
                            setState(() {});

                            // getPost();
                          },
                          child:
                           writer['followers'].contains(
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? const Text('Following')
                              : const Text('Follow'),
                        ),
                      ),
                    ])
                  ],
                )),
                Text(postReceived.text,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(postReceived.content,
                      style: const TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 100),
              ]),
            ),
    ));
  }
}
