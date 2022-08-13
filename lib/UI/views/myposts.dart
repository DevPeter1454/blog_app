// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:litcon/Model/model.dart';
import 'package:litcon/Model/postmethods.dart';
import 'package:litcon/UI/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum PostsType {
  world,
  politics,
  business,
  technology,
  literature,
  sports,
  entertainment,
  science,
  health,
  lifestyle,
  other,
}

class MyPosts extends StatefulWidget {
  const MyPosts({
    Key? key,
  }) : super(key: key);

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> posts = [];
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  Uint8List? image;
  User? user;
  num? width;
  PostsType types = PostsType.world;
  String type = 'world';
  getMyPosts() {
    _firestore.collection('posts').get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['uid'] == user!.uid){
          setState(() {
            posts.add(Post.fromSnap(element, element.data()));
          });
          // print(type.toString());
        }
      });
    });
  }

  editPost(DocumentReference ref, String text, String text2) async {
    setState(() {
      title.text = text;
      content.text = text2;
    });
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: title,
                decoration: const InputDecoration(
                  hintText: 'Edit Title',
                ),
              ),
            ),
            Expanded(
              child: TextField(
                minLines: null,
                maxLines: null,
                expands: true,
                controller: content,
                decoration: const InputDecoration(
                  hintText: 'Edit Content',
                ),
              ),
            ),
            OutlinedButton(
                onPressed: () {
                  if (content.text.isNotEmpty && title.text.isNotEmpty) {
                    ref.update({
                      'text': title.text,
                      'content': content.text,
                    });
                    Navigator.pop(context);
                    posts.clear();
                    getMyPosts();
                    setState(() {});
                  }
                },
                child: const Text('Update')),
          ]);
        });
  }

  post() {
    if (title.text.isNotEmpty && content.text.isNotEmpty && image != null) {
      PostMethods().createPost(
        uid: user!.uid,
        displayname: user!.displayname,
        profileImage: user!.photoUrl,
        file: image,
        text: title.text,
        content: content.text,
        type: type.toString(),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill all the fields'),
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
  }

  @override
  void initState() {
    super.initState();
    getMyPosts();
  }

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)!.settings.arguments as User;
    width = MediaQuery.of(context).size.width;
    print('posts $posts');
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: posts.isEmpty
          ? const Center(child: Text('No Posts'))
          : GridView.builder(
              itemCount: posts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width! < 600
                      ? 1
                      : width! > 600 && width! < 700
                          ? 1
                          : width! > 700 && width! < 850
                              ? 3
                              : 4),
              itemBuilder: ((context, index) {
                return Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Container(
                              height: 350,
                              child: Image.network(posts[index].postUrl)),
                          Text(posts[index].text,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      await PostMethods()
                                          .deleteBlog(posts[index].postId);
                                      posts.clear();
                                      getMyPosts();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.delete)),
                                IconButton(
                                    onPressed: () async {
                                      await editPost(
                                          posts[index].ref,
                                          posts[index].text,
                                          posts[index].content);
                                    },
                                    icon: const Icon(Icons.edit)),
                              ])
                        ])));
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var data = await showDialog(
              context: context,
              builder: (context) =>
                  StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      title: const Center(child: Text('Add Post')),
                      content: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            TextField(
                              controller: title,
                              decoration:
                                  textField.copyWith(labelText: 'Title'),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                expands: true,
                                minLines: null,
                                maxLines: null,
                                controller: content,
                                decoration:
                                    textField.copyWith(labelText: 'Content'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              // width: MediaQuery.of(context).size.width * 0.5,
                              child: ListView(
                                shrinkWrap:true,
                                // scrollDirection: Axis.horizontal,
                                children: [
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.world,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'world';
                                        });
                                      },
                                    ),
                                    title: const Text('World'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.politics,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'politics';
                                        });
                                      },
                                    ),
                                    title: const Text('Politics'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.business,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'business';
                                        });
                                      },
                                    ),
                                    title: const Text('Business'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.technology,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'technology';
                                        });
                                      },
                                    ),
                                    title: const Text('Technology'),
                                  ),
                                   ListTile(
                                    leading: Radio(
                                      value: PostsType.literature,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'literature';
                                        });
                                      },
                                    ),
                                    title: const Text('Literature'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.sports,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'sports';
                                        });
                                      },
                                    ),
                                    title: const Text('Sports'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.entertainment,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'entertainment';
                                        });
                                      },
                                    ),
                                    title: const Text('Entertainment'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.science,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'science';
                                        });
                                      },
                                    ),
                                    title: const Text('Science'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.health,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'health';
                                        });
                                      },
                                    ),
                                    title: const Text('Health'),
                                  ),
                                  ListTile(
                                    leading: Radio(
                                      value: PostsType.lifestyle,
                                      groupValue: types,
                                      onChanged: (PostsType ? value) {
                                        setState(() {
                                          types = value!;
                                          type = 'lifestyle';
                                          print(type);
                                        });
                                      },
                                    ),
                                    title: const Text('Lifestyle'),
                                  ),
                                ],
                              ),
                            ),
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
                                        pickImage() async {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            type: FileType.image,
                                          );
                                          // var file = result.files.first.bytes;
                                          setState(() {
                                            image = result!.files.first.bytes;
                                          });
                                        }

                                        pickImage();
                                      },
                                      icon: const Icon(Icons.add_a_photo),
                                    )
                                  : Image.memory(image!),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel')),
                            const SizedBox(width: 10),
                            OutlinedButton(
                                onPressed: () {
                                  post();
                                  Navigator.pop(context);
                                  title.clear();
                                  content.clear();
                                  image = null;
                                  // getMyPosts();
                                  // setState(() {});
                                },
                                child: const Text('Ok')),
                          ],
                        ),
                      ],
                    );
                  }));
          if (data == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please wait'),
              ),
            );

            Future.delayed(const Duration(seconds: 4), () async{
              posts.clear();
             
              await getMyPosts();
              setState((){
              });
             
            });
          }
        },
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
