import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:agenda_contato/helpers/contato_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContatoPage extends StatefulWidget {

  final Contato contato;

  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {

  bool _userEdied = false;
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  Contato _editedContato;

  @override
  void initState() {
    super.initState();
    if(widget.contato == null){
        _editedContato = Contato();
    }else{
      _editedContato = Contato.fromMap(widget.contato.toMap());
      _nomeController.text = _editedContato.nome;
      _emailController.text = _editedContato.email;
      _telefoneController.text = _editedContato.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContato.nome ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pop(context, _editedContato);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _editedContato.imagem != null
                              ? FileImage(File(_editedContato.imagem))
                              : AssetImage("images/contatoIcon.png"))),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then((file){
                    if(file == null){
                      return;
                    }else{
                      setState(() {
                        _editedContato.imagem = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                    labelText: "Nome"
                ),
                onChanged:(text){
                  _userEdied = true;
                  setState(() {
                    _editedContato.nome = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: "Email"
                ),
                onChanged:(text){
                  _userEdied = true;
                  _editedContato.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _telefoneController,
                decoration: InputDecoration(
                    labelText: "Telefone"
                ),
                onChanged:(text){
                  _userEdied = true;
                  _editedContato.telefone = text;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool>_requestPop(){
    if(_userEdied){
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar Alterações"),
            content: Text("Se sair as alterações serão perdidas"),
            actions: [
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}
