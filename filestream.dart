import 'dart:io';

class FileStream {
  FileStream(this.filepath);
  final String filepath;
  List<String> get fileAsList => File(filepath).readAsLinesSync();
  int line = 0;
  String getLine() {
    line++;
    return fileAsList[line - 1];
  }
}
