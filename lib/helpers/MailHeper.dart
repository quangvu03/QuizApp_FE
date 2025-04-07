import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailOTPHelper {
  final String _smtpServer;
  final int _smtpPort;
  final String _username;
  final String _password;
  final bool _ssl;
  final String _senderName;

  EmailOTPHelper({
    required String smtpServer,
    required int smtpPort,
    required String username,
    required String password,
    bool ssl = true,
    required String senderName,
  })  : _smtpServer = smtpServer,
        _smtpPort = smtpPort,
        _username = username,
        _password = password,
        _ssl = ssl,
        _senderName = senderName;

  // Factory constructor cho Gmail
  factory EmailOTPHelper.gmail({
    required String username,
    required String password,
    required String senderName,
  }) {
    return EmailOTPHelper(
      smtpServer: 'smtp.gmail.com',
      smtpPort: 465,
      username: username,
      password: password,
      ssl: true,
      senderName: senderName,
    );
  }

  // Gửi email OTP với template đẹp
  Future<bool> sendOTPEmail({
    required String recipientEmail,
    required String recipientName,
    required String otpCode,
    required int otpExpiryMinutes,
  }) async {
    final smtpServer = SmtpServer(
      _smtpServer,
      username: _username,
      password: _password,
      port: _smtpPort,
      ssl: _ssl,
    );

    final htmlContent = _buildOTPEmailHTML(
      recipientName: recipientName,
      otpCode: otpCode,
      otpExpiryMinutes: otpExpiryMinutes,
    );

    final message = Message()
      ..from = Address(_username, _senderName)
      ..recipients.add(recipientEmail)
      ..subject = 'Mã OTP của bạn - $_senderName'
      ..html = htmlContent;

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Lỗi gửi email OTP: $e');
      return false;
    }
  }

  String _buildOTPEmailHTML({
    required String recipientName,
    required String otpCode,
    required int otpExpiryMinutes,
  }) {
    return '''
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mã OTP của bạn</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            text-align: center;
            padding: 20px 0;
            border-bottom: 1px solid #eee;
        }
        .logo {
            max-width: 150px;
        }
        .content {
            padding: 20px 0;
        }
        .otp-container {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            text-align: center;
            margin: 20px 0;
        }
        .otp-code {
            font-size: 28px;
            letter-spacing: 5px;
            color: #2c3e50;
            font-weight: bold;
            padding: 10px;
            background: #fff;
            border-radius: 5px;
            display: inline-block;
            margin: 10px 0;
        }
        .footer {
            text-align: center;
            padding: 20px 0;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #777;
        }
        .button {
            display: inline-block;
            padding: 10px 20px;
            background: #3498db;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>Xin chào, $recipientName!</h2>
    </div>
    
    <div class="content">
        <p>Bạn đang yêu cầu mã OTP để xác thực tài khoản. Dưới đây là mã OTP của bạn:</p>
        
        <div class="otp-container">
            <p>Mã OTP của bạn là:</p>
            <div class="otp-code">$otpCode</div>
            <p>Mã này có hiệu lực trong $otpExpiryMinutes phút.</p>
        </div>
        
        <p>Vui lòng không chia sẻ mã này với bất kỳ ai. Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.</p>
        
        <p>Trân trọng,</p>
        <p>Đội ngũ $_senderName</p>
    </div>
    
    <div class="footer">
        <p>© ${DateTime.now().year} $_senderName. Tất cả quyền được bảo lưu.</p>
    </div>
</body>
</html>
    ''';
  }
}