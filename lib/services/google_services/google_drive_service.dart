import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import "package:googleapis_auth/auth_io.dart";

class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];

  drive.DriveApi? _driveApi;
  AuthClient? _authClient;

  bool get isInitialized => _driveApi != null && _authClient != null;

  Future<void> init() async {
    final credentials = await _loadServiceAccountCredentials();
    _authClient = await clientViaServiceAccount(credentials, _scopes);
    _driveApi = drive.DriveApi(_authClient!);
  }

  Future<ServiceAccountCredentials> _loadServiceAccountCredentials() async {
    final jsonString =
        await rootBundle.loadString('assets/jsons/service_account.json');
    final jsonData = jsonDecode(jsonString);
    return ServiceAccountCredentials.fromJson(jsonData);
  }

  Future<String?> uploadFile(File file) async {
    if (!isInitialized) {
      throw StateError(
          'GoogleDriveService must be initialized before use. Call init() first.');
    }

    var driveFile = drive.File();
    driveFile.name = file.path.split('/').last;

    driveFile.parents = ["1NjNqT_VjucN5S79ITbvDdw_wbfzilC6s"];

    final fileStream = file.openRead();
    final media = drive.Media(fileStream, file.lengthSync());

    try {
      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      return uploadedFile.id;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _authClient?.close();
    _authClient = null;
    _driveApi = null;
  }
}
