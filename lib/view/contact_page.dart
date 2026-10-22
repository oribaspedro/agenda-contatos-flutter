import 'dart:io';

import 'package:agendacontatos/database/helper/contact_helper.dart';
import 'package:agendacontatos/database/model/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agendacontatos/services/cep_service.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? _editContact;
  bool _userEdited = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imgController = TextEditingController();
  final ContactHelper _helper = ContactHelper();
  final ImagePicker _picker = ImagePicker();
  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    if(widget.contact == null) {
      _editContact = Contact(name: "", email: "", phone: "", img: null);
    } else {
      _editContact = widget.contact;
      _nameController.text = _editContact?.name ?? "";
      _emailController.text = _editContact?.email ?? "";
      _phoneController.text = _editContact?.phone ?? "";
      _imgController.text = _editContact?.img ?? "";
      _cepController.text = _editContact?.cep ?? "";
      _streetController.text = _editContact?.street ?? "";
      _numberController.text = _editContact?.number ?? "";
      _complementController.text = _editContact?.complement ?? "";
      _neighborhoodController.text = _editContact?.neighborhood ?? "";
      _cityController.text = _editContact?.city ?? "";
      _stateController.text = _editContact?.state ?? "";
    }
  }

  bool _emailValidator() {
    final email = _emailController.text;
    final RegExp emailRegex = RegExp(
      r'^((?!\.)[\w\-_.]*[^.])(@\w+)(\.\w+)+$',
      multiLine: true,
    );
    if(!emailRegex.hasMatch(email)) {
      return false;
    }
    return true;
  }

  Future<void> _searchCep() async {
    final digits = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return;
    try {
      final a = await buscarCep(digits);
      if (!mounted) return;
      if (a == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CEP não encontrado")));
        return;
      }
      setState(() {
        _streetController.text = a['logradouro'] ?? "";
        _neighborhoodController.text = a['bairro'] ?? "";
        _cityController.text = a['localidade'] ?? "";
        _stateController.text = a['uf'] ?? "";
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao consultar o CEP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(_editContact?.name ?? "Novo contato"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {_saveContact();},
        child: const Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => _selectImage(),
              child: Container(
                width: 140.0, height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _editContact?.img != null && _editContact!.img!.isNotEmpty
                    ? FileImage(File(_editContact!.img!)) : AssetImage("assets/imgs/contact.png") as ImageProvider,
                    fit: BoxFit.cover,
                  )
                ),
              ),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nome"),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editContact?.name = text;
                });
              },
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editContact?.email = text;
                });
              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Telefone"),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editContact?.phone = text;
                });
              },
              keyboardType: TextInputType.phone,
              inputFormatters: [phoneMask],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cepController,
              decoration: const InputDecoration(labelText: "CEP"),
              keyboardType: TextInputType.number,
              inputFormatters: [cepMask],
              onChanged: (t) {
                if (t.replaceAll(RegExp(r'\D'), '').length == 8) _searchCep();
              },
            ),
            TextField(controller: _streetController, decoration: const InputDecoration(labelText: "Logradouro")),
            TextField(controller: _numberController, decoration: const InputDecoration(labelText: "Número")),
            TextField(controller: _complementController, decoration: const InputDecoration(labelText: "Complemento")),
            TextField(controller: _neighborhoodController, decoration: const InputDecoration(labelText: "Bairro")),
            TextField(controller: _cityController, decoration: const InputDecoration(labelText: "Cidade")),
            TextField(controller: _stateController, decoration: const InputDecoration(labelText: "UF")),
          ],
        )
      ),
    );
  }

  Future<void> _selectImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foto do contato'),
        content: const Text('Escolha a origem da imagem:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, ImageSource.camera);
            },
            child: const Text('Câmera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery);
            },
            child: const Text('Galeria'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() {
        _editContact?.img = image.path;
      });
    }
  }

  void _saveContact() async {
    if(_editContact?.name != null && _editContact!.name!.isNotEmpty && _emailValidator()) {
      _editContact!
      ..cep = _cepController.text
      ..street = _streetController.text
      ..number = _numberController.text
      ..complement = _complementController.text
      ..neighborhood = _neighborhoodController.text
      ..city = _cityController.text
      ..state = _stateController.text;
      if(_editContact?.id != null) {
        await _helper.updateContact(_editContact!);
      } else {
        await _helper.saveContact(_editContact!);
      }
      Navigator.pop(context, _editContact);
    } else if(_editContact?.name == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nome é obrigatório!")),
      );
    } else if(!_emailValidator()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Digite um email válido!")),
      );
    }
  }
}