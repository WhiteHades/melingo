import 'package:flutter/material.dart';

enum AppWindowSize {
  compact,
  medium,
  expanded,
}

AppWindowSize resolveWindowSize(Size size) {
  if (size.width >= 1024) {
    return AppWindowSize.expanded;
  }
  if (size.width >= 700) {
    return AppWindowSize.medium;
  }
  return AppWindowSize.compact;
}
