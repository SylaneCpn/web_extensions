import 'dart:io';

String extractFileNameFromPath(File file) => file.uri.pathSegments.last;
String getDirectoryName(Directory dir) {
  final segments = dir.uri.pathSegments;
  return segments[segments.length - 2];
}
