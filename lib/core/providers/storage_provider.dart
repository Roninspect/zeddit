import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/type_defs.dart';

import 'firebase_providers.dart';

final storageRepositoryProvider =
    Provider((ref) => StorageRepository(storage: ref.watch(storageProvider)));

class StorageRepository {
  final FirebaseStorage _storage;
  StorageRepository({required FirebaseStorage storage}) : _storage = storage;

  FutureEither<String> storeFile(
      {required String path, required String id, required File file}) async {
    try {
      Reference ref = _storage.ref().child(path).child(id);

      UploadTask uploadFile = ref.putFile(file);

      final snapshot = await uploadFile;

      String getDownloadUrl = await snapshot.ref.getDownloadURL();

      return right(getDownloadUrl);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
