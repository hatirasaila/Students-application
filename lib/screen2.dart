 import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newwapp/customappbar.dart';
import 'package:newwapp/hh.dart'; // Update with the correct import for your Actualite page
import 'package:fluttertoast/fluttertoast.dart'; // Add this dependency
import 'package:http/http.dart' as http;

class NextPage extends StatefulWidget {
  final List<News> selectedNews;
final List<int> selectedIds;
  NextPage({Key? key, required this.selectedNews, required this.selectedIds}) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> selectedFiles = [];
  List<String> fileNames = [];
  String _selectedSubject = 'Option 1';
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool compteRenduObligatoire = false;

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
                  height: 70,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/avaters/hh.png'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Devoirs',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                child: Text(
                  'Classes sélectionnées pour faire les devoirs à la maison:',
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 33, 22, 73),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.selectedNews.map((news) {
                    return Container(
                      width: 70,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(255, 29, 49, 121),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 203, 203, 203).withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          news.classe,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veuillez remplir ce formulaire',
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromARGB(255, 33, 22, 73),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.info_outline),
                        labelText: 'Titre *',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 33, 22, 73),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 8, 20, 61)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.description_rounded),
                        labelText: 'Description *',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 33, 22, 73),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 8, 20, 61)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _dateController,
                      maxLength: 10, // Adjusted to fit YYYY-MM-DD format
                      decoration: const InputDecoration(
                        helperText: 'Au format AAAA-MM-JJ.',
                        icon: Icon(Icons.date_range_rounded),
                        labelText: 'Date *',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 33, 22, 73)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 8, 20, 61)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une date';
                        }
                        // Check if the entered date matches the YYYY-MM-DD format
                        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                          return 'Veuillez entrer une date au format AAAA-MM-JJD';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: compteRenduObligatoire,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                compteRenduObligatoire = value;
                              });
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Compte rendu obligatoire',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        takeImageOrPdf(context);
                      },
                      child: Text(' + ajouter des pièces jointes'),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: fileNames.map((fileName) {
                        return Chip(
                          label: Text(fileName),
                          onDeleted: () {
                            setState(() {
                              int index = fileNames.indexOf(fileName);
                              fileNames.removeAt(index);
                              selectedFiles.removeAt(index);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 100,
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                widget.selectedNews.isNotEmpty &&
                                _selectedSubject.isNotEmpty) {
                              submitForm();
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text("Please fill out all fields or select a Class."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          label: Text('Confirmer'),
                          icon: Icon(Icons.check),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void takeImageOrPdf(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Prendre une photo avec la caméra'),
                onTap: () {
                  pickImageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Choisissez depuis la galerie'),
                onTap: () {
                  pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Sélectionnez un fichier PDF'),
                onTap: () {
                  pickPdfFiles();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedFiles.add(File(pickedFile.path));
        fileNames.add(pickedFile.name);
      });
    }
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedFiles.add(File(pickedFile.path));
        fileNames.add(pickedFile.name);
      });
    }
  }
Future<void> pickPdfFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result != null && result.files.single.path != null) {
    print('Picked file path: ${result.files.single.path!}');
    setState(() {
      selectedFiles.add(File(result.files.single.path!));
      fileNames.add(result.files.single.name);
    });
  } else {
    print('Sélection de fichier annulée ou échouée.');
  }
}

Future<void> submitForm() async {
  if (!_formKey.currentState!.validate()) {
    Fluttertoast.showToast(
      msg: "Veuillez remplir tous les champs correctement.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    return;
  }

  var uri = Uri.parse('http://apiserv.ise-college-lycee.com:8415/addHomeworks/4011'); // Adjust this URL to your server endpoint
  var request = http.MultipartRequest('POST', uri);

  // Add form fields
  request.fields['titre'] = _titleController.text;
  request.fields['description'] = _descriptionController.text;
  request.fields['datelimite'] = _dateController.text;
  request.fields['compteRendu'] = compteRenduObligatoire.toString();
  request.fields['selectedSubject'] = _selectedSubject;

  // Add class IDs as multiple fields
  for (int i = 0; i < widget.selectedIds.length; i++) {
    request.fields['class_ids[$i]'] = widget.selectedIds[i].toString();
  }

  // Add files
  for (int i = 0; i < selectedFiles.length; i++) {
    var file = selectedFiles[i];
    var fileName = fileNames[i];
    print('Adding file: ${file.path} with filename: $fileName'); // Debugging statement

    try {
      var multipartFile = await http.MultipartFile.fromPath('pdf[]', file.path, filename: fileName);
      request.files.add(multipartFile);
    } catch (e) {
      print('Error adding file: $e'); // Debugging statement
      Fluttertoast.showToast(
        msg: "Erreur lors de l'ajout des fichiers. Veuillez réessayer.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
  }

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      print("Response status: ${response.statusCode}");

      // Assuming your server returns the file paths in response
      var responseData = await http.Response.fromStream(response);
      var filePathsFromResponse = json.decode(responseData.body);

      Fluttertoast.showToast(
        msg: "Formulaire soumis avec succès !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print(widget.selectedIds);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Actualite()),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Échec de la soumission du formulaire",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    print("Request failed with error: $e");
    Fluttertoast.showToast(
      msg: "Une erreur est survenue. Veuillez réessayer.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}




}