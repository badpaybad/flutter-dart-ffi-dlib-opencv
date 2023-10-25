import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:path/path.dart' as path;

import 'dylibloader.dart' as DyLibLoader;

final dylib= DyLibLoader.dylib_dlib_opencv;