import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ToastHelper {
  // static void showSuccesss(String message, {Duration? duration}) {
  //   showToastWidget(
  //     Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       margin: const EdgeInsets.symmetric(horizontal: 24),
  //       decoration: BoxDecoration(
  //         color: Colors.green,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Icon(Icons.check_circle, color: Colors.white),
  //           const SizedBox(width: 8),
  //           Text(
  //             message,
  //             style: const TextStyle(color: Colors.white, fontSize: 16),
  //           ),
  //         ],
  //       ),
  //     ),
  //     position: ToastPosition.bottom,
  //     duration: duration ?? const Duration(seconds: 2),
  //   );
  // }

  // Hiển thị toast thành công
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

  // Hiển thị toast lỗi
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

  // Hiển thị toast thông tin (thêm nếu cần)
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