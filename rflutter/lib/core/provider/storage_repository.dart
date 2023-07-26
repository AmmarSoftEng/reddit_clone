import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rflutter/core/constants/firebase_constants.dart';
import 'package:rflutter/core/faliure.dart';
import 'package:rflutter/core/typedef.dart';

final storageRepositoryprovidre = Provider(
    (ref) => StorageRepository(firebaseStorage: ref.read(storageProvider)));

class StorageRepository {
  final FirebaseStorage _storage;
  StorageRepository({required FirebaseStorage firebaseStorage})
      : _storage = firebaseStorage;

  FuterEither<String> storeFile(
      {required String path, required String id, required File file}) async {
    try {
      final snapshort =
          await _storage.ref().child(path).child(id).putFile(file);
      return right(await snapshort.ref.getDownloadURL());
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }
}
