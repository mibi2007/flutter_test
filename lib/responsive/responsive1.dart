import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: SampleApp()));

class SampleApp extends StatelessWidget {
  const SampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);

    return Scaffold(
        body: Stack(children: [
      const LayoutBuilderIndicator(color: Colors.purple),
      const DeviceScreenIndicator(),
      Opacity(opacity: 0.25, child: HorizontalSizeIndicator(mediaQueryData: data)),
      Opacity(opacity: 0.25, child: VerticalSizeIndicator(mediaQueryData: data))
    ]));
  }
}

class LayoutBuilderIndicator extends StatelessWidget {
  final Color color;
  const LayoutBuilderIndicator({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 100,
        right: 170,
        top: 100,
        bottom: 200,
        child: Container(
            decoration: BoxDecoration(border: Border.all(color: color, width: 10)),
            child: LayoutBuilder(builder: (context, constraints) {
              var maxWidth = constraints.maxWidth;
              var maxHeight = constraints.maxHeight;

              return Stack(children: [
                const ChildLayoutBuilderIndicator(color: Colors.orange),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('LayoutBuilder', style: TextStyle(color: color, fontSize: 20)),
                    )),
                VerticalSizeConstraintsIndicator(maxWidth: maxWidth, maxHeight: maxHeight, color: color),
                HorizontalSizeConstraintsIndicator(maxWidth: maxWidth, maxHeight: maxHeight, color: color)
              ]);
            })));
  }
}

class ChildLayoutBuilderIndicator extends StatelessWidget {
  final Color color;
  const ChildLayoutBuilderIndicator({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 130,
        right: 130,
        top: 50,
        bottom: 50,
        child: Container(
            decoration: BoxDecoration(border: Border.all(color: color, width: 10)),
            child: LayoutBuilder(builder: (context, constraints) {
              var childMaxWidth = constraints.maxHeight;
              var childMaxHeight = constraints.maxWidth;

              return Stack(children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Child LayoutBuilder', style: TextStyle(color: color, fontSize: 20)),
                    )),
                VerticalSizeConstraintsIndicator(maxWidth: childMaxWidth, maxHeight: childMaxHeight, color: color),
                HorizontalSizeConstraintsIndicator(maxWidth: childMaxWidth, maxHeight: childMaxHeight, color: color)
              ]);
            })));
  }
}

class DeviceScreenIndicator extends StatelessWidget {
  const DeviceScreenIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceType deviceBreakpoint = Utils.getDeviceType(context);
    DeviceDescription deviceDesc = Utils.deviceTypes[deviceBreakpoint] as DeviceDescription;

    IconData icon = deviceDesc.icon;
    String label = deviceDesc.label;

    return Align(
        alignment: Alignment.topLeft,
        child: Container(
            margin: const EdgeInsets.all(25),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.blueAccent, size: 30),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(color: Colors.blueAccent, fontSize: 15))
            ])));
  }
}

class HorizontalSizeConstraintsIndicator extends StatelessWidget {
  final Color color;
  final double maxWidth;
  final double maxHeight;

  const HorizontalSizeConstraintsIndicator(
      {Key? key, required this.color, required this.maxWidth, required this.maxHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: maxHeight / 2, left: -6, child: Icon(Icons.west, color: color, size: 80)),
      Positioned(top: maxHeight / 2, right: -6, child: Icon(Icons.east, color: color, size: 80)),
      Positioned(
          top: (maxHeight / 2) + 36,
          left: 0,
          right: 0,
          child: Container(height: 8, color: color, margin: const EdgeInsets.only(left: 12, right: 12))),
      Align(
          alignment: Alignment.centerLeft,
          child: Container(
              margin: const EdgeInsets.only(left: 50, bottom: 30),
              child: Text('${maxWidth.toInt()}', style: TextStyle(fontSize: 30, color: color))))
    ]);
  }
}

class VerticalSizeConstraintsIndicator extends StatelessWidget {
  final Color color;
  final double maxWidth;
  final double maxHeight;

  const VerticalSizeConstraintsIndicator(
      {Key? key, required this.maxWidth, required this.maxHeight, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: -6, right: 24, child: Icon(Icons.north, color: color, size: 80)),
      Positioned(bottom: -6, right: 24, child: Icon(Icons.south, color: color, size: 80)),
      Align(
        alignment: Alignment.centerRight,
        child: Container(width: 8, color: color, margin: const EdgeInsets.only(top: 12, bottom: 12, right: 60)),
      ),
      Align(
          alignment: Alignment.topRight,
          child: Transform.rotate(
              angle: -1.55,
              child: Container(
                  margin: const EdgeInsets.only(bottom: 30, right: 100),
                  child: Text('${maxHeight.toInt()}', style: TextStyle(fontSize: 30, color: color)))))
    ]);
  }
}

class HorizontalSizeIndicator extends StatelessWidget {
  final MediaQueryData mediaQueryData;

  const HorizontalSizeIndicator({Key? key, required this.mediaQueryData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = mediaQueryData.size.height;
    var width = mediaQueryData.size.width;

    return Stack(children: [
      Positioned(top: height - 100, left: -6, child: const Icon(Icons.west, color: Colors.green, size: 80)),
      Positioned(top: height - 100, right: -6, child: const Icon(Icons.east, color: Colors.green, size: 80)),
      Positioned(
          top: (height - 100) + 36,
          left: 0,
          right: 0,
          child: Container(height: 8, color: Colors.green, margin: const EdgeInsets.only(left: 12, right: 12))),
      Align(
          alignment: Alignment.bottomLeft,
          child: Container(
              margin: const EdgeInsets.only(left: 50, bottom: 80),
              child: Text('$width', style: const TextStyle(fontSize: 60, color: Colors.green))))
    ]);
  }
}

class VerticalSizeIndicator extends StatelessWidget {
  final MediaQueryData mediaQueryData;

  const VerticalSizeIndicator({required this.mediaQueryData});

  @override
  Widget build(BuildContext context) {
    var height = mediaQueryData.size.height;

    return Stack(children: [
      const Positioned(top: -6, right: 24, child: Icon(Icons.north, color: Colors.red, size: 80)),
      const Positioned(bottom: -6, right: 24, child: Icon(Icons.south, color: Colors.red, size: 80)),
      Align(
        alignment: Alignment.centerRight,
        child: Container(width: 8, color: Colors.red, margin: const EdgeInsets.only(top: 12, bottom: 12, right: 60)),
      ),
      Align(
          alignment: Alignment.topRight,
          child: Transform.rotate(
              angle: -1.55,
              child: Container(
                  margin: const EdgeInsets.only(bottom: 30, right: 100),
                  child: Text('$height', style: const TextStyle(fontSize: 60, color: Colors.red)))))
    ]);
  }
}

enum DeviceType { mobile, tablet, laptop }

class DeviceDescription {
  final IconData icon;
  final String label;

  DeviceDescription({required this.icon, required this.label});
}

class Utils {
  static const int mobileMaxWidth = 480;
  static const int tabletMaxWidth = 768;
  static const int laptopMaxWidth = 1024;

  static Map<DeviceType, DeviceDescription> deviceTypes = {
    DeviceType.mobile: DeviceDescription(icon: Icons.phone_iphone, label: "Mobile"),
    DeviceType.tablet: DeviceDescription(icon: Icons.tablet_mac, label: "Tablet"),
    DeviceType.laptop: DeviceDescription(icon: Icons.laptop_mac, label: "Laptop")
  };

  static DeviceType getDeviceType(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    DeviceType bk = DeviceType.mobile;

    if (data.size.width > Utils.mobileMaxWidth && data.size.width <= Utils.tabletMaxWidth) {
      bk = DeviceType.tablet;
    } else if (data.size.width > Utils.tabletMaxWidth) {
      bk = DeviceType.laptop;
    }

    return bk;
  }
}
