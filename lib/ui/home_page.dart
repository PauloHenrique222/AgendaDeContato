import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:agenda_contato/helpers/contato_helper.dart';
import 'package:agenda_contato/ui/contato_page.dart';
import 'package:flutter/material.dart';

enum OrderOptions{orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContatoHelper contatoHelper = ContatoHelper();

  List<Contato> listContato = List();

  @override
  void initState() {
    super.initState();
    _getAllContato();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contato"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de A-Z"),
                  value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showContatoPage,
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: listContato.length,
        itemBuilder: (context, index) {
          return _contatoCard(context, index);
        },
      ),
    );
  }

  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: listContato[index].imagem != null
                            ? FileImage(File(listContato[index].imagem))
                            : AssetImage("images/contatoIcon.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listContato[index].nome ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      listContato[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      listContato[index].telefone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context,int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: (){},
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlatButton(
                      child: Text("Ligar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0)
                      ),
                      onPressed: (){
                        launch("tel:${listContato[index].telefone}");
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("Editar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0)
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContatoPage(contato: listContato[index]);
                      },
                    ),
                    FlatButton(
                      child: Text("Excluir",
                          style: TextStyle(color: Colors.red, fontSize: 20.0)
                      ),
                      onPressed: (){
                        contatoHelper.deleteContato(listContato[index].id);
                        setState(() {
                          listContato.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void _showContatoPage({Contato contato}) async{
    final recContato = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContatoPage(contato: contato,))
    );
    if(recContato != null){
      if(contato != null){
        await contatoHelper.updateContato(recContato);
      }else{
        await contatoHelper.saveContato(recContato);
      }
      _getAllContato();
    }
  }

  _getAllContato(){
    this.contatoHelper.getAllContato().then((list) {
      setState(() {
        this.listContato = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        listContato.sort((a, b){
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        listContato.sort((a, b){
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
