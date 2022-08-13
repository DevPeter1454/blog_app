import 'dart:typed_data';

import 'package:litcon/Model/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';


class PostMethods {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  createPost(
      {String content= '',
        String text = '',
      Uint8List? file,
      required String uid,
      required String displayname,
      required String profileImage,
      required String type,
      }) async {
    String postId = Uuid().v1();

    try {
      String? postUrl;
      if (file != null) {
        Reference imageRef =
            _storage.ref().child('post images').child('${Random().nextInt(100)}pic');
        UploadTask upload = imageRef.putData(file);
        TaskSnapshot snapshot = await upload;
        postUrl = await snapshot.ref.getDownloadURL();
      }

    Post post = Post(
      postId: postId,
      content: content,
      text: text,
      uid: uid,
      username: displayname,
      profileImg: profileImage,
      postUrl: postUrl!,
      likes: [],
      date: DateTime.now(),
      liked: false,
      type: ['all', type],
    );

    await _firestore.collection('posts').doc(postId).set(post.toMap());

    } catch (e) {
      print(e.toString());
    }
  }
  deleteBlog(id) async {
    try {
      await _firestore.collection('posts').doc(id).delete();
    } catch (e) {}
  }
    
}
