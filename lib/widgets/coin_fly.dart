import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// One flying banknote: spawns at the screen edge and lands on the balance.
class CashFlight {
  CashFlight({
    required this.id,
    required this.start,
    required this.end,
    required this.delay,
    required this.size,
  });

  final int id;
  final Offset start;
  final Offset end;
  final Duration delay;
  final double size;
}

/// Owns the list of active flights. Call [burst] to spray banknotes from the
/// left/right screen edges towards the balance chip ("money flowing from the
/// side of the screen into the balance").
class CashFlyController extends ChangeNotifier {
  final List<CashFlight> _flights = <CashFlight>[];
  int _nextId = 0;
  bool _disposed = false;

  List<CashFlight> get flights => List.unmodifiable(_flights);

  void burst({
    required Offset end,
    required double screenWidth,
    required double screenHeight,
    int count = 10,
  }) {
    if (_disposed) return;
    final random = math.Random();
    for (var i = 0; i < count; i++) {
      final fromLeft = (i + random.nextInt(3)) % 2 == 0;
      final startY = screenHeight * (0.32 + random.nextDouble() * 0.48);
      _flights.add(CashFlight(
        id: _nextId++,
        start: Offset(fromLeft ? -60 : screenWidth + 60, startY),
        end: end,
        delay: Duration(milliseconds: i * 65),
        size: 24 + random.nextDouble() * 14,
      ));
    }
    notifyListeners();
  }

  void remove(int id) {
    if (_disposed) return;
    _flights.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _flights.clear();
    super.dispose();
  }
}

/// Full-screen overlay rendering every active flight. Place it at the top of
/// the reels Stack — it ignores pointers.
class CashFlyLayer extends StatelessWidget {
  const CashFlyLayer({super.key, required this.controller});

  final CashFlyController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Stack(
            children: [
              for (final flight in controller.flights)
                _FlyingCash(
                  key: ValueKey<int>(flight.id),
                  flight: flight,
                  onDone: () => controller.remove(flight.id),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FlyingCash extends StatefulWidget {
  const _FlyingCash({super.key, required this.flight, required this.onDone});

  final CashFlight flight;
  final VoidCallback onDone;

  @override
  State<_FlyingCash> createState() => _FlyingCashState();
}

class _FlyingCashState extends State<_FlyingCash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInQuad);
    Future.delayed(widget.flight.delay, () {
      if (!mounted) return;
      setState(() => _launched = true);
      _controller.forward().whenComplete(() {
        if (mounted) widget.onDone();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_launched) return const SizedBox.shrink();
    final f = widget.flight;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value;
        final x = lerpDouble(f.start.dx, f.end.dx, t)!;
        final y = lerpDouble(f.start.dy, f.end.dy, t)! -
            math.sin(math.pi * t) * 52; // arc
        final scale = lerpDouble(1.0, 0.4, t)!;
        final opacity = t >= 0.82 ? (1.0 - (t - 0.82) / 0.18) : 1.0;
        return Positioned(
          left: x - f.size * 0.75,
          top: y - f.size * 0.45,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: math.sin(t * math.pi * 2) * 0.35,
                child: _Banknote(width: f.size * 1.5, height: f.size * 0.9),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Banknote extends StatelessWidget {
  const _Banknote({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF41D7A7), Color(0xFF149E76)],
        ),
        border: Border.all(color: const Color(0xFF7CF2C6), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF149E76).withOpacity(0.45),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '\$',
        style: TextStyle(
          color: const Color(0xFF063B2B),
          fontSize: height * 0.55,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
