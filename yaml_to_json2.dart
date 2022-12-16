import 'dart:io';

/*
  Função utilizada pra remover caracteres não desejados da linha
*/
cleanLine(String linha) {
  //remove comentários da llinha
  linha = linha.replaceAll(RegExp('#(.*)?\$'), '');

  return linha;
}

splitValue(String linha, List<String> linhas, int index) {
  List<String> arrayLinha = linha.replaceAll(' ', '').split(':');

  print([index, linhas.length, arrayLinha[0]]);
  String char = '{';
  if ((index + 1) == linhas.length || countSpaces(linhas[index + 1]) == 0) {
    char = 'null';
  } else if ((index + 1) < linhas.length && linhas[index + 1].contains('- ')) {
    char = '[';
  }

  Object jsonObject = {
    '"${arrayLinha[0]}"': int.tryParse(arrayLinha[1]) != null
        ? arrayLinha[1]
        : '"${arrayLinha[1].replaceAll('"', '')}"'
  };

  return arrayLinha[1].isEmpty
      ? '"${arrayLinha[0]}": ' + char
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

    String novalinha = splitValue(linha, linhasArquivo, index);

    if (novalinha.contains('{')) {
      flagbloco = true;
    }

    int quantidadeTabs = countSpaces(linha);
    String tabs = '\t' * (quantidadeTabs + 1);
    novasLinhas.add('$tabs$novalinha\n');

    if ((index + 1) == linhasArquivo.length) break;

    if (flagbloco && countSpaces(linhasArquivo[index + 1]) == 0) {
      novasLinhas[novasLinhas.length - 1] =
          novasLinhas[novasLinhas.length - 1].replaceAll(',', '');

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

  const filename = 'saida.json';
  await File(filename).writeAsString('{\n${novasLinhas.join()}}');
}
