import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PathManager {
  Future<PermissionStatus> _getStoragePermissionStatus() async {
    await Permission.storage.request();
    return await Permission.storage.status;
  }

  // TODO: need to return MAP <path, name>
  Future<List<String>> getSelectedFolderFilesPaths() async {
    PermissionStatus status;
    try {
      status = await _getStoragePermissionStatus();
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } catch (e) {
      print('ERROR - grant permission: $e');
      return [];
    }

    if (status.isDenied) {
      return [];
    }

    String? dirPath;

    try {
      dirPath = await FilePicker.platform.getDirectoryPath();
    } catch (e) {
      print('ERROR - get der path: $e');
      return [];
    }

    if (dirPath == null) {
      return [];
    }

    Directory dir = Directory(dirPath);
    List<FileSystemEntity> listDir = await dir.list().toList();
    List<String> paths = [];

    listDir.forEach((FileSystemEntity fse) {
      if (fse is File && fse.path.endsWith('.mp3')) {
        paths.add(fse.path);
      }
    });

    return paths;

    // try {
    //   var dirList = dir.list();
    //   await for (FileSystemEntity f in dirList) {
    //     if (f is File) {
    //       print('Found file ${f.path}');
    //     } else if (f is Directory) {
    //       print('Found dir ${f.path}');
    //     }
    //   }
    // } catch (e) {
    //   print(e.toString());
    // }
    //
    // Directory dir = Directory(dirPath);
    // return dir.list().toList();
  }

  // List<String> getSelectedFilesPath() {}
  //
  // String getSelectedFilePath() {}
}
