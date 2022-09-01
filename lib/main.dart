// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options_dev.dart';
import 'firebase_options_prod.dart';

/// 環境（フレーバー）
enum Flavor {
  /// 開発環境
  dev,

  /// 本番環境
  prod,
  ;

  /// 文字列から Flavor を返す
  /// 見つからない場合は dev になる
  static Flavor valueOf(String? name) =>
      Flavor.values.firstWhereOrNull((flavor) => flavor.name == name) ??
      Flavor.dev;

  FirebaseOptions get firebaseOptions {
    switch (flavor) {
      case Flavor.dev:
        return DefaultFirebaseOptionsDev.currentPlatform;
      case Flavor.prod:
        return DefaultFirebaseOptionsProd.currentPlatform;
    }
  }
}

/// 現在のフレーバー
final flavor = Flavor.valueOf(const String.fromEnvironment('FLAVOR'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('flavor = ${flavor.name}');

  // Firebaseの初期化
  await Firebase.initializeApp(
    options: flavor.firebaseOptions,
  );

  // await FirebaseAuth.instance.signOut();

  // 匿名ユーザーを取得する
  final firebaseUser = await FirebaseAuth.instance.userChanges().first;
  print('uid = ${firebaseUser?.uid}');
  if (firebaseUser == null) {
    // 未サインインなので匿名ユーザーでサインインする
    // サインイン済みなら何もしないので無条件に呼び出してOK
    final credential = await FirebaseAuth.instance.signInAnonymously();
    final uid = credential.user!.uid;
    print('Signed in: uid = $uid');

    // userドキュメントを作成する
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(<String, dynamic>{
      'counter': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('Created user document');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get _userRef =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  Future<void> _incrementCounter() async {
    await _userRef.update(<String, dynamic>{
      'counter': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('Updated user document');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      _changesUserDocumentSnapshot() => _userRef.snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _changesUserDocumentSnapshot(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                print(
                  'Change user doc: '
                  'connectionState = ${snapshot.connectionState} '
                  'data = $data',
                );
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (data == null) {
                  return const CircularProgressIndicator();
                }

                final count = data['counter'] as int;
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
