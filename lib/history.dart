import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:newwapp/customappbar.dart';
import 'package:newwapp/listEleeve.dart';

class News {
  final int id;
  final String title;
  final String description;
  final String content;
  final DateTime date;
  bool isSelected;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.date,
    this.isSelected = false,
  });
}

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<News> filteredNewsList = [];

  @override
  void initState() {
    super.initState();
    fetchHomeworkData();
  }

  Future<void> fetchHomeworkData() async {
  var uri = Uri.parse('http://apiserv.ise-college-lycee.com:8415/GetDetailsHomeworks/4011');
  try {
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;

      // Create a set to keep track of IDs of existing homeworks
      Set<int> existingHomeworkIds = filteredNewsList.map((news) => news.id).toSet();

      // Use a set to track IDs of new homeworks to avoid duplicates
      Set<int> newHomeworkIds = {};

      List<News> newHomeworks = [];
      
      for (var jsonItem in data) {
        int id = jsonItem['id'];
        if (!existingHomeworkIds.contains(id) && !newHomeworkIds.contains(id)) {
          newHomeworks.add(News(
            id: id,
            title: jsonItem['titre'] ?? '',
            description: jsonItem['description'] ?? '',
            content: jsonItem['content'] ?? '',
            date: DateTime.parse(jsonItem['datelimite'] ?? DateTime.now().toIso8601String()),
          ));
          newHomeworkIds.add(id); // Track the ID of the newly added homework
        }
      }

      setState(() {
        filteredNewsList.addAll(newHomeworks);
      });
    } else {
      throw Exception('Échec du chargement des devoirs');
    }
  } catch (e) {
    print('Error fetching homework: $e');
    Fluttertoast.showToast(
      msg: "Une erreur est survenue. Veuillez réessayer",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}



  Future<void> deleteHomework(int id, int index) async {
    var uri = Uri.parse('http://apiserv.ise-college-lycee.com:8415/deleteHomework/$id');

    try {
      var response = await http.delete(uri);
      if (response.statusCode == 200) {
        setState(() {
          filteredNewsList.removeAt(index);
        });
        Fluttertoast.showToast(
          msg: "Elément supprimé avec succès.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Échec de la suppression de l'élément. Veuillez réessayer.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print('Error deleting item: $e');
      Fluttertoast.showToast(
        msg: "Une erreur est survenue. Veuillez réessayer.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      image: AssetImage('assets/avaters/history.png'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historique',
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
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Sélectionnez un devoir pour voir ses détails ',
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
              itemCount: filteredNewsList.length,
              itemBuilder: (context, index) {
                return Center(
                  child: GestureDetector(
                    onTap: () {
                    showClassesModal(context, filteredNewsList[index].id);
                    },
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
                        leading: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                        title: Text(
                          filteredNewsList[index].title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          filteredNewsList[index].description,
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Color.fromARGB(255, 197, 78, 78)),
                          onPressed: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirmer la suppression'),
                                  content: Text('Êtes-vous sûr de vouloir supprimer ce devoir ?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Annuler'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Supprimer'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm) {
                              await deleteHomework(filteredNewsList[index].id, index);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showClassesModal(BuildContext context, int homeworkId) async {
  var uri = Uri.parse('http://apiserv.ise-college-lycee.com:8415/getclassebyhomework/$homeworkId');
  try {
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Choisir une classe',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 31, 12, 70),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 8,
                      radius: Radius.circular(5),
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          var classItem = data[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 40, left: 40),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Classe : ',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Color.fromARGB(255, 25, 21, 21),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: classItem['nomclassefr'],
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(255, 78, 50, 175),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  int idClasse = classItem['idclasse']; // Extract idclasse
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Screen3(homeworkId: homeworkId, classeId: idClasse),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      throw Exception('une erreur est survenue, veuillez réessayer');
    }
  } catch (e) {
    print('Error fetching classes: $e');
    Fluttertoast.showToast(
      msg: "Une erreur est survenue, veuillez réessayer.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}

