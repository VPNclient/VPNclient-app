import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/flags.dart';
import '../../vpn_state.dart';

/// Speed-test screen (per Figma Info-Not-Ready: Info-Default / Info-Test-*).
/// Reads the real selected server from [VpnState] (not the prototype's raw
/// SharedPreferences read). Reachable by tapping the Main screen's stat tiles.
class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

const List<int> _ticks = [5, 10, 50, 100, 250, 500, 750, 1000];

class _InfoPageState extends State<InfoPage> {
  bool _running = false;
  double _speed = 0;
  Timer? _ticker;
  final _rand = Random();

  void _toggleTest() {
    // TODO(sdd-vpnclient-vpnengine): this animates toward a random target
    // instead of measuring anything real. Add real download/upload/ping
    // methods to the chosen engine (timed HTTP GET/POST, ICMP/HTTP
    // round-trip), expose as a Stream, and feed emitted values into `_speed`
    // here instead of the Timer.periodic random walk below.
    if (_running) {
      setState(() {
        _running = false;
        _speed = 0;
      });
      _ticker?.cancel();
      return;
    }
    final target = 30 + _rand.nextInt(920);
    setState(() {
      _running = true;
      _speed = 0;
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 120), (t) {
      setState(() {
        _speed += (target - _speed) * 0.18 + _rand.nextDouble() * 4;
        if (_speed >= target - 1) {
          _speed = target.toDouble();
          _running = false;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnState>();
    final theme = Theme.of(context);
    final locationName = vpn.selectedServerName ?? 'Auto';
    final flagCode = vpn.selectedFlagCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Speed Test'),
        centerTitle: true,
        titleTextStyle: theme.textTheme.headlineSmall,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
          child: Column(
            children: [
              // Server-Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.divider,
                      blurRadius: 32,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(locationName, style: theme.textTheme.bodyLarge),
                        SvgPicture.asset(
                          AppFlags.forIsoCode(flagCode),
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // STUB: no real usage/session tracking exists yet — see
                    // flows/sdd-vpnclient-vpnengine (ConnectionStats).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Server',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted)),
                        Text('—', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Data used',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted)),
                        Text('—', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text('Speed test', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  const Icon(Icons.help_outline, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 286,
                height: 286,
                child: CustomPaint(
                  painter: _GaugePainter(
                    progress: (log(1 + _speed) / log(1 + 1000)).clamp(0, 1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _speed.round().toString(),
                          style: theme.textTheme.displayLarge
                              ?.copyWith(fontSize: 40),
                        ),
                        Text('Mb/s',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _toggleTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _running ? theme.colorScheme.surface : AppColors.brandBlue,
                    foregroundColor: _running ? AppColors.danger : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _running ? 'Stop test' : 'Start test',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  _GaugePainter({required this.progress});

  static const double _startDeg = 135;
  static const double _sweepDeg = 270;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - 14;
    final start = _startDeg * pi / 180;
    final sweep = _sweepDeg * pi / 180;

    final track = Paint()
      ..color = AppColors.disabled
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(14), start, sweep, false, track);

    final progressPaint = Paint()
      ..shader = AppColors.brandGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(14), start, sweep * progress, false, progressPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < _ticks.length; i++) {
      final angle = start + sweep * (i / (_ticks.length - 1));
      final pos = Offset(
        center.dx + (radius + 22) * cos(angle),
        center.dy + (radius + 22) * sin(angle),
      );
      textPainter.text = TextSpan(
        text: '${_ticks[i]}',
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
