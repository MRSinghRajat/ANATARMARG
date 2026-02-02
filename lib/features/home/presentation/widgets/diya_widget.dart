import 'package:flutter/material.dart';

class DiyaWidget extends StatefulWidget {
  final bool isLit;
  final VoidCallback onTap;

  const DiyaWidget({
    super.key,
    required this.isLit,
    required this.onTap,
  });

  @override
  State<DiyaWidget> createState() => _DiyaWidgetState();
}

class _DiyaWidgetState extends State<DiyaWidget> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLit ? null : widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Flame (Only visible if lit)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: widget.isLit ? 1.0 : 0.0,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: 20,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                      topRight: Radius.circular(0), // Flame tip shape
                    ),
                    boxShadow: widget.isLit
                        ? [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.6),
                              blurRadius: _glowAnimation.value * 5, // Pulsing radius
                              spreadRadius: _glowAnimation.value,
                            ),
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                );
              },
            ),
          ),
          
          // The Clay Lamp Base
          Container(
            width: 50,
            height: 25,
            decoration: BoxDecoration(
              color: const Color(0xFF5D4037), // Clay Brown
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF8D6E63), // Lighter top
                  const Color(0xFF4E342E), // Darker bottom
                ],
              ),
              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.2),
                   blurRadius: 4,
                   offset: const Offset(0, 2),
                 )
              ]
            ),
          ),
        ],
      ),
    );
  }
}
