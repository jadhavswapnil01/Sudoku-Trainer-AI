import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class Particle {
  final Animatable<Movie> tween;
  final double size;
  final Color color;
  final Duration duration;
  final Duration startTime;

  Particle(this.tween, this.size, this.color, this.duration, this.startTime);
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  final List<Particle> particles = [];
  final Random random = Random();
  final List<Color> particleColors = [
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.cyanAccent,
    Colors.deepPurpleAccent
  ];

  @override
  void initState() {
    super.initState();
    List.generate(80, (_) => particles.add(_randomParticle()));
  }

  Particle _randomParticle() {
    final startX = random.nextDouble();
    final startY = 1.0 + random.nextDouble() * 0.5;
    final endY = -0.2 - random.nextDouble() * 0.6;

    final duration = Duration(milliseconds: 3000 + random.nextInt(3000));

    final tween = MovieTween()
      ..tween('x', Tween(begin: startX, end: startX + (random.nextDouble() - 0.5) * 0.1), duration: duration)
      ..tween('y', Tween(begin: startY, end: endY), duration: duration)
      ..tween('opacity', Tween(begin: 0.0, end: 0.6), duration: const Duration(seconds: 1))
      ..tween('opacity', Tween(begin: 0.6, end: 0.0), duration: duration - const Duration(seconds: 1));

    return Particle(
      tween,
      1.5 + random.nextDouble() * 4,
      particleColors[random.nextInt(particleColors.length)],
      duration,
      Duration(milliseconds: random.nextInt(6000)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌈 Gradient background for richness
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243e)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        LoopAnimationBuilder(
          duration: const Duration(seconds: 4),
          tween: ConstantTween(0.0),
          builder: (context, value, child) {
            final time = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
            return CustomPaint(
              painter: ParticlePainter(particles, time),
              child: const SizedBox.expand(),
            );
          },
        ),
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Duration time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // ✨ soft glow

    for (final particle in particles) {
      final elapsed = (time - particle.startTime).inMilliseconds;
      final progress = elapsed % particle.duration.inMilliseconds;
      final movie = particle.tween.transform(progress / particle.duration.inMilliseconds);

      final x = movie.get<double>('x') * size.width;
      final y = movie.get<double>('y') * size.height;
      final opacity = movie.get<double>('opacity');

      if (opacity > 0.0) {
        paint.color = particle.color.withOpacity(opacity);
        canvas.drawCircle(Offset(x, y), particle.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
