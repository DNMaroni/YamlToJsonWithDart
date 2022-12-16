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

splitValue(String linha) {
  List<String> arrayLinha = linha.replaceAll(' ', '').split(':');

  Object jsonObject = {
    '"${arrayLinha[0]}"': int.tryParse(arrayLinha[1]) != null
        ? arrayLinha[1]
        : '"${arrayLinha[1]}"'
  };

  return arrayLinha[1].isEmpty
      ? '"${arrayLinha[0]}: {"'
      : '${jsonObject.toString().replaceAll('{', '').replaceAll('}', '')},';
}

countSpaces(String line) {
  return '\t'.allMatches(line).isNotEmpty
      ? '\t'.allMatches(line).length
      : '  '.allMatches(line).length;
}

void main() async {
  List<String> linhasArquivo =
      await File('${Directory.current.path}/pubspec_masterclass.yaml')
          .readAsLines();

  List<String> novasLinhas = [];

  bool flagbloco = false;

  for (int index = 0; index < linhasArquivo.length; index++) {
    //ignora enters

    if (linhasArquivo[index].isEmpty) continue;

    String linha = cleanLine(linhasArquivo[index]);

    String novalinha = splitValue(linha);

    if (novalinha.contains('{')) {
      flagbloco = true;
    }

    int quantidadeTabs = countSpaces(linha);
    String tabs = '\t' * (quantidadeTabs + 1);
    novasLinhas.add('$tabs$novalinha\n');

    if (linhasArquivo.length > (index + 1)) {
      if (flagbloco && countSpaces(linhasArquivo[index + 1]) == 0) {
        for (var i = quantidadeTabs; i > 0; i--) {
          if (i == 1) {
            novasLinhas.add('${'\t' * i}},\n');
            flagbloco = false;
          } else {
            novasLinhas.add('${'\t' * i}}\n');
          }
        }
      }
    }
  }

  const filename = 'saida.txt';
  await File(filename).writeAsString('{\n${novasLinhas.join()}}');
}
