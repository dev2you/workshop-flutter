import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  TextEditingController nameController = TextEditingController(text: 'Paul');
  TextEditingController cepController = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String logradouro = '';
  String bairro;
  String localidade;
  String uf;

  @override
  Widget build(BuildContext context) {

    List<Widget> options = [
      _home(), _help(), _settings()
    ];

    return Scaffold(
      key: scaffoldKey,
      body: options.elementAt(index),
      appBar: AppBar(
        title: Text('Meu Primeiro App'),
        leading: Icon(Icons.add_alert),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){},
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (i){
            setState(() {
              index = i;
            });
          },
          items: [
            BottomNavigationBarItem(
                title: Text('Home'),
                icon: Icon(Icons.home)
            ),
            BottomNavigationBarItem(
                title: Text('Help'),
                icon: Icon(Icons.help)
            ),
            BottomNavigationBarItem(
                title: Text('Settings'),
                icon: Icon(Icons.settings)
            )
          ]
      ),
    );
  }

  Widget _home() {
    return Stack(
      children: <Widget>[
        Container(color: Colors.yellow,),
        Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('Sim; ${nameController.text}', style: Theme.of(context).textTheme.title,),
                  SizedBox(height: 10,),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      validator: (v) {
                        if(cepController.text.isEmpty) return 'Campo obrigatorio';
                      },
                      controller: cepController,
                      decoration: InputDecoration(
                          labelText: 'CEP',
                          hintText: 'Informe o CEP',
                          border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Text('Logradouro: ${logradouro ?? ''}'),
                      Text('Bairro: ${bairro ?? ''}'),
                      Text('Localidade: ${localidade ?? ''}'),
                      Text('UF: ${uf ?? ''}'),

                    ],
                  ),

                  SizedBox(height: 20,),
                  RaisedButton(
                    child: Text('Buscar'),
                    onPressed: (){
                      if(!formKey.currentState.validate()) return ;

                      http.get('https://viacep.com.br/ws/${cepController.text}/json/')
                          .then((data){
                        Map<String, dynamic> body = json.decode(data.body);

                        if(data.statusCode == 200 && body['erro'] == null) {

                          setState(() {
                            logradouro = body['logradouro'];
                            bairro = body['bairro'];
                            localidade = body['localidade'];
                            uf = body['uf'];
                          });

                        } else {
                          print(data.statusCode);
                          _showError();
                        }
                      }).catchError((e){
                        _showError();
                      });

                    },
                  ),

                ],
              ),
            )
        )
      ],
    );
  }


  Widget _help() {
    return Container(
      color: Colors.blue,
        child: Center(
          child: Text('Sim; ${nameController.text} - Eu posso te ajudar', style: Theme.of(context).textTheme.title,),
        )
    );
  }


  Widget _settings() {
    return Container(
      color: Colors.white70,
      child: TextField(
        controller: nameController,
      ),
    );
  }

  _showError() {

    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Ops, algo deu errado'),
        backgroundColor: Theme.of(context).errorColor,
      )
    );

  }

}
