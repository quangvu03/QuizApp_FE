import 'dart:math';

String generateSixDigitCode() {
  Random random = Random();

  int code = 100000 + random.nextInt(900000);

  return code.toString();
}

void main() {
  String code = generateSixDigitCode();
  print("Generated 6-digit code: $code");
}

