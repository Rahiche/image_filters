// ignore_for_file: unused_element

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_shaders/flutter_shaders.dart';

class IosNameDropDemo extends StatefulWidget {
  const IosNameDropDemo({super.key});

  @override
  State<IosNameDropDemo> createState() => _IosNameDropDemoState();
}

class _IosNameDropDemoState extends State<IosNameDropDemo> {
  @override
  Widget build(BuildContext context) {
    return const DeviceAnimationDemo();
  }
}

class DeviceAnimationDemo extends StatefulWidget {
  const DeviceAnimationDemo({super.key});

  @override
  _DeviceAnimationDemoState createState() => _DeviceAnimationDemoState();
}

class _DeviceAnimationDemoState extends State<DeviceAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _isIPhone = true;
  final bool _isReverse = false;
  bool isNameDropAnimating = false;
  Duration nameDropDuration = const Duration(seconds: 4);
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _animation.addListener(() {
      if (mounted) {
        setState(() {
          if (_animation.value == 1.0 && !isNameDropAnimating) {
            isNameDropAnimating = true;
            Future.delayed(nameDropDuration, () {
              if (mounted) {
                setState(() {
                  isNameDropAnimating = false;
                  _controller.reverse();
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    if (_controller.status == AnimationStatus.completed) {
      Future.delayed(const Duration(seconds: 2), () {
        _isReverse ? _controller.reverse() : _controller.reset();
      });
    } else {
      _controller.forward();
    }
  }

  void _resetAnimation() {
    _controller.reset();
    setState(() {
      isNameDropAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 600,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(
                          -MediaQuery.of(context).size.width *
                              0.2 *
                              (1 - _animation.value),
                          0),
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DeviceFrame(
                            device: Devices.ios.iPhone13,
                            screen: buildNameDropIOS17(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(
                          MediaQuery.of(context).size.width *
                              0.2 *
                              (1 - _animation.value),
                          0),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DeviceFrame(
                            device: Devices.ios.iPhone13,
                            screen: buildNameDropIOS17(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleAnimation,
                  child: const Text('Toggle Animation'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetAnimation,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNameDropIOS17() {
    return MinuteChangeShaderEffect(
      duration: nameDropDuration,
      isAnimating: _isIPhone ? isNameDropAnimating : false,
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF4F4F4F),
        ),
        child: const TicketFoldDemo(),
      ),
    );
  }
}

class MinuteChangeShaderEffect extends StatefulWidget {
  const MinuteChangeShaderEffect({
    super.key,
    required this.child,
    required this.isAnimating,
    required this.duration,
  });

  final Widget child;
  final bool isAnimating;
  final Duration duration;

  @override
  State<MinuteChangeShaderEffect> createState() =>
      _MinuteChangeShaderEffectState();
}

class _MinuteChangeShaderEffectState extends State<MinuteChangeShaderEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween(begin: 0.0, end: 2.0).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _updateAnimationState();
  }

  @override
  void didUpdateWidget(MinuteChangeShaderEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAnimating != widget.isAnimating) {
      _updateAnimationState();
    }
  }

  void _updateAnimationState() async {
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.reset();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _controller.forward();
      }
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      (context, shader, child) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader.setFloat(0, size.width);
            shader.setFloat(1, size.height);
            shader.setFloat(2, _animation.value);
            shader.setImageSampler(0, image);
            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..shader = shader,
            );
          },
          child: widget.child,
        );
      },
      assetKey: 'shaders/name_drop.frag',
    );
  }
}

class TicketFoldDemo extends StatefulWidget {
  const TicketFoldDemo({super.key});

  @override
  _TicketFoldDemoState createState() => _TicketFoldDemoState();
}

class _TicketFoldDemoState extends State<TicketFoldDemo> {
  final List<BoardingPassData> _boardingPasses = DemoData().boardingPasses;

  final Color _backgroundColor = const Color(0xFFf0f0f0);

  final ScrollController _scrollController = ScrollController();

  final List<int> _openTickets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Flex(direction: Axis.vertical, children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: _boardingPasses.length,
            itemBuilder: (BuildContext context, int index) {
              return Ticket(
                boardingPass: _boardingPasses.elementAt(index),
                onClick: () => _handleClickedTicket(index),
              );
            },
          ),
        ),
      ]),
    );
  }

  bool _handleClickedTicket(int clickedTicket) {
    // Scroll to ticket position
    // Add or remove the item of the list of open tickets
    _openTickets.contains(clickedTicket)
        ? _openTickets.remove(clickedTicket)
        : _openTickets.add(clickedTicket);

    // Calculate heights of the open and closed elements before the clicked item
    double openTicketsOffset =
        Ticket.nominalOpenHeight * _getOpenTicketsBefore(clickedTicket);
    double closedTicketsOffset = Ticket.nominalClosedHeight *
        (clickedTicket - _getOpenTicketsBefore(clickedTicket));

    double offset = openTicketsOffset +
        closedTicketsOffset -
        (Ticket.nominalClosedHeight * .5);

    // Scroll to the clicked element
    _scrollController.animateTo(max(0, offset),
        duration: const Duration(seconds: 1),
        curve: const Interval(.25, 1, curve: Curves.easeOutQuad));
    // Return true to stop the notification propagation
    return true;
  }

  _getOpenTicketsBefore(int ticketIndex) {
    // Search all indexes that are smaller to the current index in the list of indexes of open tickets
    return _openTickets.where((int index) => index < ticketIndex).length;
  }

  PreferredSizeWidget _buildAppBar() {
    Color appBarIconsColor = const Color(0xFF212121);
    return AppBar(
      leading: Icon(Icons.arrow_back, color: appBarIconsColor),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: Icon(Icons.more_horiz, color: appBarIconsColor, size: 28),
        )
      ],
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          'Boarding Passes'.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            letterSpacing: 0.5,
            color: appBarIconsColor,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class BoardingPassData {
  String passengerName;
  _Airport origin;
  _Airport destination;
  _Duration duration;
  TimeOfDay boardingTime;
  DateTime departs;
  DateTime arrives;
  String gate;
  int zone;
  String seat;
  String flightClass;
  String flightNumber;

  BoardingPassData({
    required this.passengerName,
    required this.origin,
    required this.destination,
    required this.duration,
    required this.boardingTime,
    required this.departs,
    required this.arrives,
    required this.gate,
    required this.zone,
    required this.seat,
    required this.flightClass,
    required this.flightNumber,
  });
}

class _Airport {
  String code;
  String city;

  _Airport({required this.city, required this.code});
}

class _Duration {
  int hours;
  int minutes;

  _Duration({required this.hours, required this.minutes});

  @override
  String toString() {
    return '\t${hours}H ${minutes}M';
  }
}

class DemoData {
  final List<BoardingPassData> _boardingPasses = [
    BoardingPassData(
        passengerName: 'Ms. Jane Doe',
        origin: _Airport(code: 'YEG', city: 'Edmonton'),
        destination: _Airport(code: 'LAX', city: 'Los Angeles'),
        duration: _Duration(hours: 3, minutes: 30),
        boardingTime: const TimeOfDay(hour: 7, minute: 10),
        departs: DateTime(2019, 10, 17, 23, 45),
        arrives: DateTime(2019, 10, 18, 02, 15),
        gate: '50',
        zone: 3,
        seat: '12A',
        flightClass: 'Economy',
        flightNumber: 'AC237'),
    BoardingPassData(
        passengerName: 'Ms. Jane Doe',
        origin: _Airport(code: 'YYC', city: 'Calgary'),
        destination: _Airport(code: 'YOW', city: 'Ottawa'),
        duration: _Duration(hours: 3, minutes: 50),
        boardingTime: const TimeOfDay(hour: 12, minute: 15),
        departs: DateTime(2019, 10, 17, 23, 45),
        arrives: DateTime(2019, 10, 18, 02, 15),
        gate: '22',
        zone: 1,
        seat: '17C',
        flightClass: 'Economy',
        flightNumber: 'AC237'),
    BoardingPassData(
        passengerName: 'Ms. Jane Doe',
        origin: _Airport(code: 'YEG', city: 'Edmonton'),
        destination: _Airport(code: 'MEX', city: 'Mexico'),
        duration: _Duration(hours: 4, minutes: 15),
        boardingTime: const TimeOfDay(hour: 16, minute: 45),
        departs: DateTime(2019, 10, 17, 23, 45),
        arrives: DateTime(2019, 10, 18, 02, 15),
        gate: '30',
        zone: 2,
        seat: '22B',
        flightClass: 'Economy',
        flightNumber: 'AC237'),
    BoardingPassData(
        passengerName: 'Ms. Jane Doe',
        origin: _Airport(code: 'YYC', city: 'Calgary'),
        destination: _Airport(code: 'YOW', city: 'Ottawa'),
        duration: _Duration(hours: 3, minutes: 50),
        boardingTime: const TimeOfDay(hour: 12, minute: 15),
        departs: DateTime(2019, 10, 17, 23, 45),
        arrives: DateTime(2019, 10, 18, 02, 15),
        gate: '22',
        zone: 1,
        seat: '17C',
        flightClass: 'Economy',
        flightNumber: 'AC237'),
  ];

  get boardingPasses => _boardingPasses;

  getBoardingPass(int index) {
    return _boardingPasses.elementAt(index);
  }
}

class FlightBarcode extends StatelessWidget {
  const FlightBarcode({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0), color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: MaterialButton(
            child: Image.asset(
              'assets/images/barcode.png',
            ),
            onPressed: () {
              print('Button was pressed');
            }),
      ));
}

class FlightDetails extends StatelessWidget {
  final BoardingPassData boardingPass;
  final TextStyle titleTextStyle = const TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 11,
    height: 1,
    letterSpacing: .2,
    fontWeight: FontWeight.w600,
    color: Color(0xffafafaf),
  );
  final TextStyle contentTextStyle = const TextStyle(
    fontFamily: 'Oswald',
    fontSize: 16,
    height: 1.8,
    letterSpacing: .3,
    color: Color(0xff083e64),
  );

  const FlightDetails(this.boardingPass, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Gate'.toUpperCase(), style: titleTextStyle),
                      Text(boardingPass.gate, style: contentTextStyle),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Zone'.toUpperCase(), style: titleTextStyle),
                      Text(boardingPass.zone.toString(),
                          style: contentTextStyle),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Seat'.toUpperCase(), style: titleTextStyle),
                      Text(boardingPass.seat, style: contentTextStyle),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Class'.toUpperCase(), style: titleTextStyle),
                      Text(boardingPass.flightClass, style: contentTextStyle),
                    ]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Flight'.toUpperCase(), style: titleTextStyle),
                      Text(boardingPass.flightNumber, style: contentTextStyle),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Departs'.toUpperCase(), style: titleTextStyle),
                      // Text(DateFormat('MMM d, H:mm').format(boardingPass.departs).toUpperCase(), style: contentTextStyle),
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Arrives'.toUpperCase(), style: titleTextStyle),
                      // Text(DateFormat('MMM d, H:mm').format(boardingPass.arrives).toUpperCase(), style: contentTextStyle)
                    ]),
              ],
            ),
          ],
        ),
      );
}

enum SummaryTheme { dark, light }

class FlightSummary extends StatelessWidget {
  final BoardingPassData boardingPass;
  final SummaryTheme theme;
  final bool isOpen;

  const FlightSummary(
      {super.key,
      required this.boardingPass,
      this.theme = SummaryTheme.light,
      this.isOpen = false});

  Color get mainTextColor =>
      (theme == SummaryTheme.dark) ? Colors.white : const Color(0xFF083e64);
  Color get secondaryTextColor => (theme == SummaryTheme.dark)
      ? const Color(0xff61849c)
      : const Color(0xFF838383);
  Color get separatorColor => (theme == SummaryTheme.dark)
      ? const Color(0xffeaeaea)
      : const Color(0xff396583);

  TextStyle get bodyTextStyle => TextStyle(
        color: mainTextColor,
        fontSize: 13,
        fontFamily: 'Oswald',
      );

  bool get isLight => theme == SummaryTheme.light;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getBackgroundDecoration(),
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildLogoHeader(),
            _buildSeparationLine(),
            _buildTicketHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: _buildTicketOrigin()),
                  Align(
                      alignment: Alignment.center,
                      child: _buildTicketDuration()),
                  Align(
                      alignment: Alignment.centerRight,
                      child: _buildTicketDestination())
                ],
              ),
            ),
            _buildBottomIcon()
          ],
        ),
      ),
    );
  }

  _getBackgroundDecoration() {
    return isLight
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Colors.white,
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            image: const DecorationImage(
                image: AssetImage('assets/images/bg_blue.png'),
                fit: BoxFit.cover),
          );
  }

  _buildLogoHeader() {
    if (isLight) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Image.asset('assets/images/flutter-logo.png', width: 8),
          ),
          Text('Fluttair'.toUpperCase(),
              style: TextStyle(
                color: mainTextColor,
                fontFamily: 'OpenSans',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ))
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Image.asset('assets/images/logo_white.png', height: 12),
      );
    }
  }

  Widget _buildSeparationLine() {
    return Container(
      width: double.infinity,
      height: 1,
      color: separatorColor,
    );
  }

  Widget _buildTicketHeader(context) {
    var headerStyle = const TextStyle(
        fontFamily: 'OpenSans',
        fontWeight: FontWeight.bold,
        fontSize: 11,
        color: Color(0xFFe46565));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(boardingPass.passengerName.toUpperCase(), style: headerStyle),
        Text('BOARDING ${boardingPass.boardingTime.format(context)}',
            style: headerStyle),
      ],
    );
  }

  Widget _buildTicketOrigin() {
    return Column(
      children: <Widget>[
        Text(
          boardingPass.origin.code.toUpperCase(),
          style: bodyTextStyle.copyWith(fontSize: 42),
        ),
        Text(boardingPass.origin.city,
            style: bodyTextStyle.copyWith(color: secondaryTextColor)),
      ],
    );
  }

  Widget _buildTicketDuration() {
    String routeType = isLight ? 'blue' : 'white';
    final planeImage = Image.asset('assets/images/airplane_$routeType.png',
        height: 20, fit: BoxFit.contain);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(
          width: 120,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.asset('assets/images/planeroute_$routeType.png',
                  fit: BoxFit.cover),
              isLight
                  ? planeImage
                  : _AnimatedSlideToRight(isOpen: isOpen, child: planeImage)
            ],
          ),
        ),
        Text(boardingPass.duration.toString(),
            textAlign: TextAlign.center, style: bodyTextStyle),
      ],
    );
  }

  Widget _buildTicketDestination() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          boardingPass.destination.code.toUpperCase(),
          style: bodyTextStyle.copyWith(fontSize: 42),
        ),
        Text(
          boardingPass.destination.city,
          style: bodyTextStyle.copyWith(color: secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildBottomIcon() {
    IconData icon =
        isLight ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up;
    return Icon(
      icon,
      color: mainTextColor,
      size: 18,
    );
  }
}

class _AnimatedSlideToRight extends StatefulWidget {
  final Widget child;
  final bool isOpen;

  const _AnimatedSlideToRight(
      {super.key, required this.child, required this.isOpen});

  @override
  _AnimatedSlideToRightState createState() => _AnimatedSlideToRightState();
}

class _AnimatedSlideToRightState extends State<_AnimatedSlideToRight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1700));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOpen) _controller.forward(from: 0);
    return SlideTransition(
      position:
          Tween(begin: const Offset(-2, 0), end: const Offset(1, 0)).animate(
        CurvedAnimation(curve: Curves.easeOutQuad, parent: _controller),
      ),
      child: widget.child,
    );
  }
}

class FoldingTicket extends StatefulWidget {
  static const double padding = 16.0;
  final bool isOpen;
  final List<FoldEntry> entries;
  final VoidCallback? onClick;
  final Duration? duration;

  const FoldingTicket(
      {super.key,
      this.duration,
      required this.entries,
      this.isOpen = false,
      this.onClick});

  @override
  _FoldingTicketState createState() => _FoldingTicketState();
}

class _FoldingTicketState extends State<FoldingTicket>
    with SingleTickerProviderStateMixin {
  late List<FoldEntry> _entries = widget.entries;
  late final AnimationController _controller = AnimationController(vsync: this);
  double _ratio = 0.0;

  double get openHeight =>
      _entries.fold<double>(0.0, (val, o) => val + o.height) +
      FoldingTicket.padding * 2;

  double get closedHeight => _entries[0].height + FoldingTicket.padding * 2;

  bool get isOpen => widget.isOpen;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_tick);
    _updateFromWidget();
  }

  @override
  void didUpdateWidget(FoldingTicket oldWidget) {
    // Opens or closes the ticked if the status changed
    _updateFromWidget();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FoldingTicket.padding),
      height: closedHeight +
          (openHeight - closedHeight) * Curves.easeOut.transform(_ratio),
      child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                  spreadRadius: 1)
            ],
          ),
          child: _buildEntry(0)),
    );
  }

  Widget _buildEntry(int index) {
    FoldEntry entry = _entries[index];
    int count = _entries.length - 1;
    double ratio = max(0.0, min(1.0, _ratio * count + 1.0 - index * 1.0));

    Matrix4 mtx = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..setEntry(1, 2, 0.2)
      ..rotateX(pi * (ratio - 1.0));

    Widget card = SizedBox(
        height: entry.height, child: ratio < 0.5 ? entry.back : entry.front);

    return Transform(
        alignment: Alignment.topCenter,
        transform: mtx,
        child: GestureDetector(
          onTap: widget.onClick,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            // Note: Container supports a transform property, but not alignment for it.
            child: (index == count || ratio <= 0.5)
                ? card
                : // Don't build a stack if it isn't needed.
                Column(children: [
                    card,
                    _buildEntry(index + 1),
                  ]),
          ),
        ));
  }

  void _updateFromWidget() {
    _entries = widget.entries;
    _controller.duration =
        widget.duration ?? Duration(milliseconds: 400 * (_entries.length - 1));
    isOpen ? _controller.forward() : _controller.reverse();
  }

  void _tick() {
    setState(() {
      _ratio = Curves.easeInQuad.transform(_controller.value);
    });
  }
}

class FoldEntry {
  final Widget? front;
  late Widget? back;
  final double height;

  FoldEntry({required this.front, required this.height, Widget? back}) {
    this.back = Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .001)
          ..rotateX(pi),
        child: back);
  }
}

class Ticket extends StatefulWidget {
  static const double nominalOpenHeight = 400;
  static const double nominalClosedHeight = 160;
  final BoardingPassData boardingPass;
  final VoidCallback? onClick;

  const Ticket({super.key, required this.boardingPass, required this.onClick});
  @override
  State<StatefulWidget> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  FlightSummary? topCard;
  late FlightSummary frontCard =
      FlightSummary(boardingPass: widget.boardingPass);
  late FlightDetails middleCard = FlightDetails(widget.boardingPass);
  FlightBarcode bottomCard = const FlightBarcode();
  bool _isOpen = false;

  Widget get backCard => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: const Color(0xffdce6ef),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FoldingTicket(
        entries: _getEntries(), isOpen: _isOpen, onClick: _handleOnTap);
  }

  List<FoldEntry> _getEntries() {
    return [
      FoldEntry(height: 160.0, front: topCard),
      FoldEntry(height: 160.0, front: middleCard, back: frontCard),
      FoldEntry(height: 80.0, front: bottomCard, back: backCard)
    ];
  }

  void _handleOnTap() {
    widget.onClick?.call();
    setState(() {
      _isOpen = !_isOpen;
      topCard = FlightSummary(
          boardingPass: widget.boardingPass,
          theme: SummaryTheme.dark,
          isOpen: _isOpen);
    });
  }
}
