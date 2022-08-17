import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String displayname;
  final String email;
  final String photoUrl;
  final String uid;
  final String type;
  final List<String> following;
  final List<String> followers;

  User({
    required this.displayname,
    required this.email,
    required this.photoUrl,
    required this.uid,
    required this.type,
    required this.following,
    required this.followers,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'displayname': displayname});
    result.addAll({'email': email});
    result.addAll({'photoUrl': photoUrl});
    result.addAll({'uid': uid});
    result.addAll({'type': type});
    result.addAll({'following': following});
    result.addAll({'followers': followers});
  
    return result;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      displayname: map['displayname'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      following: List<String>.from(map['following']),
      followers: List<String>.from(map['followers']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}

class Post {
  final String text;
  final String content;
  final String uid;
  final String postId;
  final String username;
  final DateTime date;
  final String postUrl;
  final String profileImg;
  final List likes;
  final List type;
  final dynamic ref;
  final bool liked;

  Post({
    required this.text,
    required this.content,
    required this.uid,
    required this.postId,
    required this.username,
    required this.date,
    required this.postUrl,
    required this.profileImg,
    required this.likes,
    required this.type,
    this.ref,
    this.liked = false,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'text': text});
    result.addAll({'content': content});
    result.addAll({'uid': uid});
    result.addAll({'postId': postId});
    result.addAll({'username': username});
    result.addAll({'date': date.millisecondsSinceEpoch});
    result.addAll({'postUrl': postUrl});
    result.addAll({'profileImg': profileImg});
    result.addAll({'likes': likes});
    result.addAll({'type': type});
    result.addAll({'ref': ref});
    result.addAll({'liked': liked});
  
    return result;
  }

  factory Post.fromSnap(DocumentSnapshot snapshot, Map<String, dynamic> map) {
    DocumentReference ref = snapshot.reference;
    return Post(
      text: map['text'] ?? '',
      content: map['content'] ?? '',
      uid: map['uid'] ?? '',
      postId: map['postId'] ?? '',
      username: map['username'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      postUrl: map['postUrl'] ?? '',
      profileImg: map['profileImg'] ?? '',
      likes: List.from(map['likes']),
      type: List.from(map['type']),
      ref: ref,
      liked: map['likes'].contains(map['uid']),
    );
  }
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      text: map['text'] ?? '',
      content: map['content'] ?? '',
      uid: map['uid'] ?? '',
      postId: map['postId'] ?? '',
      username: map['username'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      postUrl: map['postUrl'] ?? '',
      profileImg: map['profileImg'] ?? '',
      likes: List.from(map['likes']),
      type: List.from(map['type']),
      ref: map['ref'],
      liked: map['liked'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  // factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
