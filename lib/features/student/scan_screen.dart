import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/visit_provider.dart';
import '../../services/scan_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  _ScanResultData? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isValidLibraryQr(String scanned) {
    final parts = scanned.split(':');
    if (parts.length != 2 || parts[0] != 'SMART_LIB') return false;

    final scannedWindow = int.tryParse(parts[1]);
    if (scannedWindow == null) return false;

    final currentWindow = DateTime.now().millisecondsSinceEpoch ~/ 5000;
    return (currentWindow - scannedWindow).abs() <= 2; // ±3s grace
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    if (!isValidLibraryQr(raw)) {
      await _controller.stop(); // ✅ add this
      setState(() {
        _result = _ScanResultData(
          success: false,
          isEntry: false,
          title: 'Invalid QR Code',
          subtitle: 'QR has expired or is not a library code.',
          color: AppColors.danger,
          icon: Icons.qr_code_2,
        );
      });
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    setState(() => _isProcessing = true);
    await _controller.stop();

    final user = context.read<AuthProvider>().currentUser!;
    final visitProvider = context.read<VisitProvider>();
    final scanResult = await visitProvider.processScan(
      'LIBRARY_ENTRY',
      user.id,
    );

    _ScanResultData resultData;
    switch (scanResult) {
      case ScanResult.entry:
        resultData = _ScanResultData(
          success: true,
          isEntry: true,
          title: '✅ Entry Recorded!',
          subtitle: 'Welcome to the library, ${user.name.split(' ').first}!',
          color: AppColors.secondary,
          icon: Icons.login_rounded,
        );
        break;
      case ScanResult.exit:
        resultData = _ScanResultData(
          success: true,
          isEntry: false,
          title: '👋 Exit Recorded!',
          subtitle: 'See you next time, ${user.name.split(' ').first}!',
          color: AppColors.primary,
          icon: Icons.logout_rounded,
        );
        break;
      case ScanResult.blocked:
        resultData = _ScanResultData(
          success: false,
          isEntry: false,
          title: 'Access Denied',
          subtitle: 'Your account is blocked. Contact admin.',
          color: AppColors.danger,
          icon: Icons.block,
        );
        break;
      case ScanResult.invalid:
      default:
        resultData = _ScanResultData(
          success: false,
          isEntry: false,
          title: 'Invalid QR Code',
          subtitle: 'Please scan the official library QR code.',
          color: AppColors.danger,
          icon: Icons.qr_code_2,
        );
    }

    setState(() {
      _result = resultData;
      _isProcessing = false;
    });

    // Auto pop after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final isInside = context.watch<VisitProvider>().isStudentInside(user.id);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(AppStrings.scanQR),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Dim overlay + scan frame
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isInside
                        ? AppColors.secondary.withOpacity(0.9)
                        : AppColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isInside ? Icons.sensors : Icons.sensors_off,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isInside
                            ? 'Currently Inside — Scan to Exit'
                            : 'Currently Outside — Scan to Enter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Spacer to push below the scan box
                const SizedBox(height: 280),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Point at the library QR code',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Result overlay
          if (_result != null) _ResultOverlay(data: _result!),

          // Loading
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Result overlay ───────────────────────────────────────────────────────────

class _ScanResultData {
  final bool success;
  final bool isEntry;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  _ScanResultData({
    required this.success,
    required this.isEntry,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

class _ResultOverlay extends StatelessWidget {
  final _ScanResultData data;
  const _ResultOverlay({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: data.color.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.color, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: data.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                data.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Custom scan frame painter ────────────────────────────────────────────────

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const boxSize = 240.0;
    const cornerLen = 32.0;
    const strokeW = 4.0;
    final cx = size.width / 2;
    final cy = size.height / 2 - 30;

    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: boxSize,
      height: boxSize,
    );
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Dim
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    // Corners
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final l = rect.left, t = rect.top, r = rect.right, b = rect.bottom;
    // TL
    canvas.drawLine(Offset(l, t + cornerLen), Offset(l, t), p);
    canvas.drawLine(Offset(l, t), Offset(l + cornerLen, t), p);
    // TR
    canvas.drawLine(Offset(r - cornerLen, t), Offset(r, t), p);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLen), p);
    // BL
    canvas.drawLine(Offset(l, b - cornerLen), Offset(l, b), p);
    canvas.drawLine(Offset(l, b), Offset(l + cornerLen, b), p);
    // BR
    canvas.drawLine(Offset(r - cornerLen, b), Offset(r, b), p);
    canvas.drawLine(Offset(r, b), Offset(r, b - cornerLen), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
