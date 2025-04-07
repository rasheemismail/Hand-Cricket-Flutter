import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class HandGestureWidget extends StatefulWidget {
  final int? number;
  final bool isUser;

  const HandGestureWidget({
    Key? key,
    required this.number,
    required this.isUser,
  }) : super(key: key);

  @override
  _HandGestureWidgetState createState() => _HandGestureWidgetState();
}

class _HandGestureWidgetState extends State<HandGestureWidget> {
  Artboard? _artboard;
  SMIInput<double>? _fingerInput;
  StateMachineController? _controller;

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  Future<void> _loadRive() async {
    final data = await rootBundle.load('assets/images/hand_cricket.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (_controller != null) {
      artboard.addController(_controller!);
      _fingerInput = _controller!.findInput<double>('Input');

      _fingerInput?.value = widget.number?.toDouble() ?? 0;
    }

    setState(() => _artboard = artboard);
  }

  @override
  void didUpdateWidget(covariant HandGestureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.number != oldWidget.number && _fingerInput != null) {
      _fingerInput!.value = widget.number?.toDouble() ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 300,
      alignment: Alignment.center,
      child: _artboard != null
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(widget.isUser ? -1.0 : 1.0, 1.0),
              child: Rive(
                artboard: _artboard!,
                fit: BoxFit.cover,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
