import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';

class Auth {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

//register

  registerUser(fname, lname, email, password, file, type) async {
    final _storage = FirebaseStorage.instance;
    Reference storageRef = _storage.ref().child('images').child('${Random().nextInt(100)}pictures');
    var upload = storageRef.putData(file!);
    var snapshot = await upload;
    var url = await snapshot.ref.getDownloadURL();
    try {
      UserCredential user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (user.user != null) {
        if (user.additionalUserInfo!.isNewUser) {
         firestore.collection('users').doc(user.user!.uid).set({
            'displayname': fname + ' ' + lname,
            'email': user.user!.email,
            'photoUrl': url,
            'following': [],
            'followers': [],
            'uid': user.user!.uid,
            'type': type,
          });
        }
        return {'message': 'Sign Up Successful'};
      }
    } on FirebaseException catch (e) {
      print(e.message);
      return {'message': e.message};
    }
  }

//sign in with email and password
  signIn(email, password) async {
    try {
      UserCredential user = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (user.user != null) {
        return {'message': 'success'};
      }
    } on FirebaseException catch (e) {
      print(e.message);
      return {'message': e.message};
    }
  }

//reset

  reset(email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.toString().trim());
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

//sign in with google

  googleSignIn() async {
    if (kIsWeb) {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      try {
        googleAuthProvider
            .addScope("https://www.googleapis.com/auth/contacts.readonly");

        final UserCredential userData =
            await auth.signInWithPopup(googleAuthProvider);

        if (userData.user != null) {
          if (userData.additionalUserInfo!.profile != null) {
            //add

            //set
            if(userData.additionalUserInfo!.isNewUser){
              firestore.collection('users').doc(userData.user!.uid).set({
                'displayname': auth.currentUser!.displayName,
                'email': userData.user!.email,
                'photoUrl': userData.additionalUserInfo!.profile!['picture'],
                'following': [],
                'followers': [],
                'uid': userData.user!.uid,
                'type': 'user',
              });
            }
            // firestore.collection('users').doc(auth.currentUser!.uid).set({
            //   'displayName': auth.currentUser!.displayName,
            //   'email': auth.currentUser!.email,
            //   'photoUrl': auth.currentUser!.photoURL ?? '',
            //   'phoneNumber': auth.currentUser!.phoneNumber ?? '',
            //   'following': [],
            //   'followers': [],
            //   'uid': userData.user!.uid,
            // });
          }
          return {'message': 'success'};
        }
      } on FirebaseException catch (e) {
        print(e.message);
        return {'message': e.message};
      }
    } else {
      GoogleSignInAccount? googleSignIn = await GoogleSignIn().signIn();

      var googleUserAuth = await googleSignIn!.authentication;
      if (googleUserAuth.accessToken != null &&
          googleUserAuth.idToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleUserAuth.accessToken,
          idToken: googleUserAuth.idToken,
        );
        final UserCredential authResult =
            await auth.signInWithCredential(credential);
        if (authResult.user != null) {
          if (authResult.additionalUserInfo!.isNewUser) {
            //add

            //set
            firestore.collection('users').doc(auth.currentUser!.uid).set({
              'email': auth.currentUser!.email,
              'displayName': auth.currentUser!.displayName,
              'photoUrl': auth.currentUser!.photoURL ?? '',
              'phoneNumber': auth.currentUser!.phoneNumber ?? '',
              'following': [],
              'followers': [],
              'uid': authResult.user!.uid,
            });
          }
        }
      }
    }
  }

//sign out

  logout() async {
    await auth.signOut();
  }
}
