import 'dart:io';

class TokenStorage {
  final String filePath = "${Directory.systemTemp.path}/token.txt";

  Future<String?> readToken() async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  Future<void> writeToken(String token) async {
    final file = File(filePath);
    await file.writeAsString(token);
  }

  Future<void> deleteToken() async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
