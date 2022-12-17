import 'dart:io';

class YamlToJson {
  final String pathEntrada;
  final String pathSaida;

  YamlToJson(this.pathEntrada, this.pathSaida);

  //variáveis compartilhadas entre as funções
  List<String> linhasArquivo = [];
  List<String> novasLinhas = [];
  bool flagbloco = false;
  bool flagbarra = false;
  int index = 0;
  int quantidadeTabs = 0;

  //remove comentários e espaços (a direita) da linha
  String cleanLine(String linha) {
    linha = linha.replaceAll(RegExp('#(.*)?\$'), '').trimRight();

    return linha;
  }

  //conta espaços/tabs das linhas, pra saber o nível do bloco
  int countSpaces(String line) {
    return '\t'.allMatches(line).isNotEmpty
        ? '\t'.allMatches(line).length
        : '  '.allMatches(line).length;
  }

  //processa a string e descobre quais caracteres devem ser concatenados
  String splitValue(String linha) {
    //caso seja valor de array
    if (!linha.contains(':'))
      return '"' + linha.replaceAll('- ', '').replaceAll(' ', '') + '",';

    //key e value da linha
    List<String> arrayLinha = linha.replaceAll(' ', '').split(':');

    //caso tenha mais que um ':' na linha, essa gambi ajusta
    if (arrayLinha.length > 2) {
      arrayLinha[0] = linha.split(':')[0].replaceAll(' ', '');
      arrayLinha[1] = linha.split(RegExp('^([^:]*):'))[1].replaceAll(' ', '');
    }

    //verificando se é elemento pai, se é filho simples ou array, e caso filho sem value atribui null
    String char = '{';
    if ((index + 1) == linhasArquivo.length ||
        countSpaces(linhasArquivo[index + 1]) == 0 ||
        countSpaces(linhasArquivo[index + 1]) ==
            countSpaces(linhasArquivo[index])) {
      char = 'null,';
    } else if ((index + 1) < linhasArquivo.length &&
        linhasArquivo[index + 1].contains('- ')) {
      char = '[';
    }

    //descobre o tipo de dado e coloca ""
    Object jsonObject = {
      '"${arrayLinha[0]}"': int.tryParse(arrayLinha[1]) != null
          ? arrayLinha[1]
          : '"${arrayLinha[1].replaceAll('"', '')}"'
    };

    //verifica se é nodo pai ou filho e retorna
    return arrayLinha[1].isEmpty
        ? '"${arrayLinha[0]}": ' + char
        : '${jsonObject.toString().replaceAll('{', '').replaceAll('}', '')},';
  }

  // se detectado que é o fim do bloco, fecha as chaves/conchetes
  void fechaBloco(String virgula) {
    for (var i = quantidadeTabs; i > 0; i--) {
      if (i == 1) {
        novasLinhas.add('${'\t' * i}}${virgula}\n');
        flagbloco = false;
      } else if (i == quantidadeTabs) {
        novasLinhas.add('${'\t' * i}${flagbarra ? ']' : '}'}\n');
        flagbarra = false;
      } else {
        novasLinhas.add('${'\t' * i}}\n');
      }
    }
  }

  void removeVirgulaLastLine() {
    novasLinhas[novasLinhas.length - 1] =
        novasLinhas[novasLinhas.length - 1].replaceAll(',', '');
  }

  //faz toda a logica que converte
  Future<void> convert() async {
    List<String> linhasArq = await File(this.pathEntrada).readAsLines();

    for (String line in linhasArq) {
      if (line.isNotEmpty && line.length > 2) {
        linhasArquivo.add(cleanLine(line));
      }
    }

    //loop nas linhas do arquivo
    for (index = 0; index < linhasArquivo.length; index++) {
      String linha = linhasArquivo[index];
      String novalinha = splitValue(linha);

      //se tem mais que um espaço a esquerda é nodo filho
      if (countSpaces(linha) > 0) {
        flagbloco = true;
      }

      //se possui "[" é pai de array
      if (novalinha.contains('[') && novalinha.contains(':')) {
        flagbarra = true;
        flagbloco = true;
      }

      //conta tabs pra identar o json
      quantidadeTabs = countSpaces(linha);
      String tabs = '\t' * (quantidadeTabs + 1);

      //adiciona nova linha no jsonajustada
      novasLinhas.add('$tabs$novalinha\n');

      //se for o final do código e nada ta aberto, só termina o processamento
      if ((index + 1) == linhasArquivo.length && !flagbarra && !flagbloco)
        break;

      // se for o final do código e tem algo aberto, fecha
      else if ((index + 1) == linhasArquivo.length &&
          (flagbarra || flagbloco)) {
        novasLinhas[novasLinhas.length - 1] =
            novasLinhas[novasLinhas.length - 1].replaceAll(',', '');

        fechaBloco('');
        break;
      }

      //testa os tipos possíveis de fechamento de bloco
      if (flagbloco &&
          (countSpaces(linhasArquivo[index + 1]) == 0 &&
              linhasArquivo[index + 1].length > 2)) {
        removeVirgulaLastLine();

        fechaBloco(',');
      }

      if (flagbloco &&
          (countSpaces(linhasArquivo[index + 1]) ==
              countSpaces(linhasArquivo[index]) - 1) &&
          linhasArquivo[index + 1].length > 2) {
        removeVirgulaLastLine();

        novasLinhas.add(
            '${'\t' * (countSpaces(linhasArquivo[index + 1]) + 1)}${flagbarra ? ']' : '}'},\n');
        flagbloco = false;
        flagbarra = false;
      }
    }

    var filename = this.pathSaida;
    await File(filename).writeAsString('{\n${novasLinhas.join()}}');
  }
}

void main() {
  YamlToJson test = YamlToJson('pubspec_masterclass.yaml', 'saida.json');
  test.convert();
}
