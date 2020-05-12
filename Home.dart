import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List lista=[];
  Map<String, dynamic> ultimoremovido = Map();
  TextEditingController _controllertarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    var arquivo = File('${diretorio.path}/dados.json');
  }

  _salvarTarefa(){
    String textoDigitado = _controllertarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa['titulo']=textoDigitado;
    tarefa['realizada']=false;
    setState(() {
      lista.add(tarefa);
    });
    _salvarArquivo();
    _controllertarefa.text='';
  }

  _salvarArquivo() async {

    var arquivo= await _getFile();

    String dados = json.encode(lista);
    arquivo.writeAsString(dados);

  }

  _lerArquivo() async {
    try{
      final arquivo = await _getFile();
      return arquivo.readAsString();
    }catch(e){
      return null;
    }
  }
  @override
  void initState() {
    super.initState();
    _lerArquivo().then(
        (dados){
          setState(() {
            lista= json.decode(dados);
          });
        }
    );
  }

  Widget criarItemLista(context, index){

    final item = lista[index]['titulo'];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){
          ultimoremovido=lista[index];
          lista.removeAt(index);
          _salvarArquivo();
          final snackbar = SnackBar(
              content: Text('tarefa removida'),
              action: SnackBarAction(
                  label: 'Desfazer',
                  onPressed: (){
                    setState(() {
                      lista.insert(index, ultimoremovido);
                    });
                      _salvarArquivo();
                  }
              ),
          );
          Scaffold.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
            title: Text(lista[index]['titulo']),
            value: lista[index]['realizada'],
            onChanged: (valorAlterado){
              setState(() {
                lista[index]['realizada']=valorAlterado;
              });
              _salvarArquivo();
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    print('items:' + DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Lista de tarefas'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: criarItemLista
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          child: Icon(Icons.add),
          onPressed: (){
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: Text('adicionar tarefa'),
                    content: TextField(
                      controller: _controllertarefa,
                      decoration: InputDecoration(
                        labelText: 'Digite sua tarefa',
                      ),
                      onChanged: (text){

                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: ()=> Navigator.pop(context),
                          child: Text('Cancelar')
                      ),
                      FlatButton(
                          onPressed: (){
                            _salvarTarefa();
                            Navigator.pop(context);
                          },
                          child: Text('Salvar')
                      )
                    ],
                  );
                }
            );
          }
      ),
    );
  }

}

