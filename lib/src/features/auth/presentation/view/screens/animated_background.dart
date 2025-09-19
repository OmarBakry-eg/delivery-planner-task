part of 'login_screen.dart';
class _AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue.shade700,
      Colors.indigo.shade600,
      Colors.purple.shade600,
    ];
    return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 10),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, value * 0.5, 1],
                  colors: colors,
                ),
              ),
            );
          },
          onEnd: () {},
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .blurXY(begin: 0, end: 8, duration: 7.seconds);
  }
}
