import 'dart:convert';
import 'dart:typed_data';

class FileCustom{
  Uint8List? fileBytes;
  String fileName;
  FileCustom(this.fileBytes,this.fileName);
}