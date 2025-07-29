import 'package:flutter/material.dart';

Widget getMapPageWidget() => Scaffold(
  appBar: AppBar(title: const Text('보물 지도')),
  body: const Center(child: Text('이 지도 기능은 모바일(Android/iOS)에서만 지원됩니다.')),
);
