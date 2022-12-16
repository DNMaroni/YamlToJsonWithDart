import 'dart:io';

/*
  Função utilizada pra remover caracteres não desejados da linha
*/
cleanLine(String linha) {
  //remove comentários da llinha
  linha = linha.replaceAll(RegExp('#(.*)?\$'), '').trimRight();

  return linha;
}

splitValue(String linha, List<String> linhas, int index) {
  if (!linha.contains(':'))
    return '"' + linha.replaceAll('- ', '').replaceAll(' ', '') + '",';

  List<String> arrayLinha = linha.replaceAll(' ', '').split(':');

  if (arrayLinha.length > 2) {
    arrayLinha[0] = linha.split(':')[0].replaceAll(' ', '');
    arrayLinha[1] = linha.split(RegExp('^([^:]*):'))[1].replaceAll(' ', '');
  }

  String char = '{';
  if ((index + 1) == linhas.length ||
      countSpaces(linhas[index + 1]) == 0 ||
      countSpaces(linhas[index + 1]) == countSpaces(linhas[index])) {
    char = 'null,';
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
  List<String> linhasArq =
      await File('${Directory.current.path}/pubspec_masterclass.yaml')
          .readAsLines();

  List<String> linhasArquivo = [];
  for (String line in linhasArq) {
    if (line.isNotEmpty && line.length > 2) {
      linhasArquivo.add(cleanLine(line));
    }
  }

  print(linhasArquivo);
  List<String> novasLinhas = [];

  bool flagbloco = false;
  bool flagbarra = false;
  bool flagfinalcode = false;

  for (int index = 0; index < linhasArquivo.length; index++) {
    if (linhasArquivo[index].isEmpty) continue;

    String linha = linhasArquivo[index];

    String novalinha = splitValue(linha, linhasArquivo, index);

    if (countSpaces(linha) > 0) {
      flagbloco = true;
    }

    if (novalinha.contains('[') && novalinha.contains(':')) {
      flagbarra = true;
      flagbloco = true;
    }

    int quantidadeTabs = countSpaces(linha);
    String tabs = '\t' * (quantidadeTabs + 1);
    novasLinhas.add('$tabs$novalinha\n');

    if ((index + 1) == linhasArquivo.length && !flagbarra && !flagbloco)
      break;
    else if ((index + 1) == linhasArquivo.length && (flagbarra || flagbloco)) {
      novasLinhas[novasLinhas.length - 1] =
          novasLinhas[novasLinhas.length - 1].replaceAll(',', '');

      for (var i = quantidadeTabs; i > 0; i--) {
        if (i == 1) {
          novasLinhas.add('${'\t' * i}}\n');
          flagbloco = false;
        } else if (i == quantidadeTabs) {
          novasLinhas.add('${'\t' * i}${flagbarra ? ']' : '}'}\n');
          flagbarra = false;
        } else {
          novasLinhas.add('${'\t' * i}}\n');
        }
      }
      break;
    }

    /* if (linhasArquivo[index] == '  http: ^0.13.4') {
      print(flagbloco);
    } */
    if (flagbloco &&
        (countSpaces(linhasArquivo[index + 1]) == 0 &&
            linhasArquivo[index + 1].length > 2)) {
      novasLinhas[novasLinhas.length - 1] =
          novasLinhas[novasLinhas.length - 1].replaceAll(',', '');

      for (var i = quantidadeTabs; i > 0; i--) {
        if (i == 1) {
          novasLinhas.add('${'\t' * i}},\n');
          flagbloco = false;
        } else if (i == quantidadeTabs) {
          novasLinhas.add('${'\t' * i}${flagbarra ? ']' : '}'}\n');
          flagbarra = false;
        } else {
          novasLinhas.add('${'\t' * i}}\n');
        }
      }
    }

    if (flagbloco &&
        (countSpaces(linhasArquivo[index + 1]) ==
            countSpaces(linhasArquivo[index]) - 1) &&
        linhasArquivo[index + 1].length > 2) {
      novasLinhas[novasLinhas.length - 1] =
          novasLinhas[novasLinhas.length - 1].replaceAll(',', '');

      novasLinhas.add(
          '${'\t' * (countSpaces(linhasArquivo[index + 1]) + 1)}${flagbarra ? ']' : '}'},\n');
      flagbloco = false;
      flagbarra = false;
    }
  }

  const filename = 'saida.json';
  var json = novasLinhas.join();
  await File(filename).writeAsString('{\n${json}}');
}
