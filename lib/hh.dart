import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:newwapp/customappbar.dart';
import 'package:newwapp/history.dart';
import 'package:newwapp/screen2.dart';

class News {
  final int id;
  final String classe;
  bool isSelected;

  News({required this.id, required this.classe, this.isSelected = false});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(id: json['idclasse'], classe: json['nomclassefr']);
  }
}

class Actualite extends StatefulWidget {
  @override
  _ActualiteState createState() => _ActualiteState();
}

class _ActualiteState extends State<Actualite> {
  List<News> newsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(Uri.parse('http://apiserv.ise-college-lycee.com:8415/GetClasseEnseignants/4011/5'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<News> fetchedNews = data.map((json) => News.fromJson(json)).toList();

        setState(() {
          newsList = fetchedNews;
          isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement des classes');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

    }
  }

  void toggleSelected(int index) {
    setState(() {
      newsList[index].isSelected = !newsList[index].isSelected;
    });
  }

  void navigateToNextPage() {
    List<News> selectedNews = newsList.where((news) => news.isSelected).toList();
    List<int> selectedIds = selectedNews.map((news) => news.id).toList();
  print('Selected IDs: $selectedIds');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextPage(selectedNews: selectedNews, selectedIds: selectedIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          width: double.infinity,
          child: CustomAppBar(),
        ),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            ),
            Container(
              width: 80,
              height: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/avaters/hi.png'),
                ),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Classe',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => History(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '   Sélectionnez une classe \npour télécharger les devoirs',
                    style: TextStyle(
                      fontFamily: 'Varela',
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: const Color.fromARGB(255, 152, 152, 152),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(5),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                newsList[index].classe,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            trailing: Checkbox(
                              value: newsList[index].isSelected,
                              onChanged: (value) {
                                toggleSelected(index);
                              },
                            ),
                            onTap: () {
                              toggleSelected(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToNextPage,
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
