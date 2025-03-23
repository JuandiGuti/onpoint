import 'package:flutter/material.dart';
import 'package:onpoint/pages/MakeReserveScreen.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class RoomButton extends StatelessWidget {
  final String roomId;
  final String roomName;

  const RoomButton({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              roomName,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MakeReserveScreen(
                    roomId: roomId,
                    roomName: roomName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
class InfoDialog extends StatelessWidget {
  final String message;

  const InfoDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Información"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
Widget infoFloatingButton(BuildContext context, String message) {
  return FloatingActionButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => InfoDialog(message: message),
      );
    },
    child: const Icon(Icons.info_outline),
    backgroundColor: Theme.of(context).colorScheme.primary,
  );
}