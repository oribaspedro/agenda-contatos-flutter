import 'dart:io';

import 'package:agendacontatos/database/helper/contact_helper.dart';
import 'package:agendacontatos/database/model/contact_model.dart';
import 'package:agendacontatos/view/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAZ, orderZA }

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });           
    /*
    Contact c = Contact(
      name: "Joao da Silva",
      email: "jsilva@gmail.com",
      phone: "4299999999",
      img: null,
    );
    helper.saveContact(c);*/
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda de contatos"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton <OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderAZ,
                child: Text("Ordenar de A-Z"),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderZA,
                child: Text("Ordenar de Z-A"),
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ? FileImage(File(contacts[index].img!)) : AssetImage("assets/imgs/contact.png") as ImageProvider,
                  )
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        contacts[index].name ?? "",
                        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        contacts[index].phone ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      if (contacts[index].fullAddress.isNotEmpty)
                        Text(
                          contacts[index].fullAddress,
                          style: TextStyle(fontSize: 14.0, color: Colors.black54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  void _showContactPage({Contact? contact}) async {
    final updatedContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact,),
      )
    );
    if(updatedContact != null) {
      setState(() {
        helper.getAllContacts().then((list) {
          setState(() {
            contacts = list;
          });
        });
      });
    }
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    child: const Text(
                      "Ligar",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20.0,
                      ),
                    ),
                    onPressed: () {
                      launch("tel:${contacts[index].phone}");
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "Editar",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: contacts[index]);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "Excluir",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    ),
                    onPressed: () {
                      if(contacts[index].id != null) {
                        helper.deleteContact(contacts[index].id!);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Erro: ID do contato não encontrado."
                            ),
                          )
                        );
                      }
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

  void _orderList(OrderOptions result) {
    switch(result) {
      case OrderOptions.orderAZ:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}