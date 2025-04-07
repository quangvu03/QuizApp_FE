import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ToastHelper {

  static void showSuccess(String message, {Duration? duration}) {
    showToast(
      message,
      position: ToastPosition.bottom,
      backgroundColor: Colors.green,
      radius: 12,
      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void showError(String message, {Duration? duration}) {
    showToast(
      message,
      position: ToastPosition.top,
      backgroundColor: Colors.redAccent,
      radius: 12,
      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  static void showInfo(String message, {Duration? duration}) {
    showToast(
      message,
      position: ToastPosition.center,
      backgroundColor: Colors.blue,
      radius: 12,
      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
      duration: duration ?? const Duration(seconds: 2),
    );
  }
}