import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  String txtButton = "Submit";
  bool _isLoading = false;

  String get nom => "";
  set nom(String nom) {}

  Map<String, dynamic> carte = new Map();
  bool recupCarte = false;

  Future<void> recupCartes(String nom) async {
    this.nom = nom;
    String url = "https://api.magicthegathering.io/v1/cards/" + nom;
    // https://api.magicthegathering.io/v1/cards/130550
    var reponse = await http.get(Uri.parse(url));
    if (reponse.statusCode == 200) {
      carte = convert.jsonDecode(reponse.body);
      recupCarte = true;
    }
  }

  startLoading() async {
    setState(() {
      _isLoading = true;
    });
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      await recupCartes(nom);
      if (recupCarte) {
        Navigator.popAndPushNamed(context, '/affiche', arguments: carte);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur dans recupération des informations."),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool isNumeric(String s) {
    bool isnum = false;
    try {
      double.parse(s);
      isnum = true;
    } catch (e) {}
    return isnum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Id  de la carte", hintText: "Saisir l'id de la carte"),
                validator: (value) {
                  if (value == null || value.isEmpty || !isNumeric(value)) {
                    return 'Id non valide !';
                  } else {
                    nom = value;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : startLoading,
                  child: _isLoading ? CircularProgressIndicator() : Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
