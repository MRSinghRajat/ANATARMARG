import 'package:flutter/material.dart';
import 'rive_room_background.dart';
import 'animated_guide.dart';

/// Shared room + character section for Aangan and Ashram.
/// Ensures identical room display size on both screens.
class RoomWithCharacter extends StatelessWidget {
  /// Height of the room area (same for both Aangan and Ashram)
  static double roomHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.5;

  final double characterSize;
  final bool isOnYatraPage;
  final EdgeInsets? characterPadding;

  const RoomWithCharacter({
    super.key,
    this.characterSize = 660,
    this.isOnYatraPage = false,
    this.characterPadding,
  });

  @override
  Widget build(BuildContext context) {
    final height = roomHeight(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RiveRoomBackground(fit: BoxFit.contain),
          Center(
            child: Padding(
              padding: characterPadding ?? const EdgeInsets.only(top: 50),
              child: AnimatedGuide(
                width: characterSize,
                height: characterSize,
                isOnYatraPage: isOnYatraPage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
