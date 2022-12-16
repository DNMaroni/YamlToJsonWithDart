import 'dart:io';

/*
  Função utilizada pra remover caracteres não desejados da linha
*/
cleanLine(String linha) {
  //remove comentários da llinha
  linha = linha.replaceAll(RegExp('#(.*)?\$'), '');

  //remove traços, de arrays no yaml
  linha = linha.replaceAll('-', '');

  return linha;
}

/*
  Conta quantos espaços/tabs tem na linha pra saber como está na árvore
*/
countSpaces(String line) {
  return '\t'.allMatches(line).isNotEmpty
      ? '\t'.allMatches(line).length
      : '  '.allMatches(line).length;
}

splitValue(String linha) {
  List<String> arrayLinha = linha.replaceAll(' ', '').split(':');

  Object jsonObject = {
    '"${arrayLinha[0]}"': int.tryParse(arrayLinha[1]) != null
        ? arrayLinha[1]
        : '"${arrayLinha[1]}"'
  };

  return arrayLinha[1].isEmpty ? arrayLinha[0] : jsonObject;
}

void main() async {
  List<String> linhasArquivo =
      await File('${Directory.current.path}/pubspec_masterclass.yaml')
          .readAsLines();

  Map<String, dynamic> json = {};

  for (int index = 0; index < linhasArquivo.length; index++) {
    //ignora enters
    if (linhasArquivo[index].isEmpty) continue;

    String linha = cleanLine(linhasArquivo[index]);

    var object = splitValue(linha);

    if (object is String) {
      Map<int, List<Object>> teste = {
        1: [object]
      };
      //json.addAll({object: {}});

      while (countSpaces(linhasArquivo[++index]) > 0) {
        if (splitValue(linhasArquivo[index]) is Object) {
          Object objeto = linhasArquivo[index];
        }
      }
    } else {
      json.addAll(object);
    }
  }

  print(json);
}
