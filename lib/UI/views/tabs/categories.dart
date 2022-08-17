import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litcon/Model/model.dart';
import 'package:litcon/UI/Dashboard/images.dart';

class Categs extends StatefulWidget {
  const Categs({Key? key}) : super(key: key);

  @override
  State<Categs> createState() => _CategsState();
}

class _CategsState extends State<Categs> {
  List<Categories> categories = getCategories();
  final TextEditingController searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Post> search = [];
  bool isSearching = false;
  getSearch() {
    _firestore.collection('posts').get().then((value) {
      for (var element in value.docs) {
        if (element.data()['text'].toString().toLowerCase().contains(searchController.text.toLowerCase())
        ) {
          setState(() {
            search.add(Post.fromMap(element.data()));
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() async{
      if (searchController.text.isNotEmpty) {
        search.clear();
        setState(() {
          categories.clear();
          isSearching = true;
        });
         await getSearch();
        print(search);
      } else if (searchController.text.isEmpty) {
        setState(() {
          isSearching = false;
          categories = getCategories();
          search.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              constraints: BoxConstraints(
                maxHeight: 50,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              // border: OutlineInputBorder(),
              hintText: 'Search',
              suffixIcon: const Icon(Icons.search),
            ),
            // onChanged: (value) {
            //   if (value.isNotEmpty) {
            //     setState(() {
            //       categories.clear();
            //       isSearching = true;
            //     });
            //   } else {
            //     setState(() {
            //       categories = getCategories();
            //       isSearching = false;
            //       search.clear();
            //     });
            //   }
            // },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: !isSearching
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                print(categories[index].text);
                                Navigator.pushNamed(context, '/tags',
                                    arguments: categories[index].text);
                              },
                              child: Stack(children: [
                                Image.network(
                                  categories[index].image,
                                  height: 308,
                                  width: 250,
                                  fit: BoxFit.fitHeight,
                                  color:
                                      const Color.fromARGB(255, 100, 100, 100)
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
                          ),
                        );
                      },
                    )
                  : search.isNotEmpty? ListView.builder(itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(search[index].text),
                          subtitle: Text(search[index].content, maxLines: 2, overflow: TextOverflow.ellipsis,),
                          onTap: () {
                            Navigator.pushNamed(context, '/view',
                                arguments: search[index].postId);
                          },
                        ),
                      );
                    },
                itemCount: search.length,) : const Center(child: const Text('No item found'))
            ) ,
          ),
        ],
      ),
    );
  }
}
