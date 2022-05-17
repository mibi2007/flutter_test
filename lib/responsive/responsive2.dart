import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FlutterAirApp());
}

class FlutterAirApp extends StatelessWidget {
  const FlutterAirApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.redHatDisplayTextTheme(Theme.of(context).textTheme)),
        home: const FlutterAirWelcome());
  }
}

class FlutterAirWelcome extends StatelessWidget {
  const FlutterAirWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterAirFlightInfoStyles flightInfoStyles =
        Utils.flightInfoStyles[Utils.getDeviceType(context)] as FlutterAirFlightInfoStyles;

    return Scaffold(
        backgroundColor: Colors.white,
        drawer: const Drawer(child: FlutterAirSideMenu()),
        appBar: const FlutterAirAppBar(),
        body: Row(children: [
          const FlutterAirSideBar(),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
                controller: ScrollController(),
                child: Container(
                  height: constraints.maxHeight,
                  constraints: BoxConstraints(
                      minHeight: constraints.minHeight < flightInfoStyles.minHeight
                          ? flightInfoStyles.minHeight
                          : constraints.minHeight),
                  child: const Padding(padding: EdgeInsets.all(50), child: FlutterAirFlightInfo()),
                ));
          }))
        ]));
  }
}

class FlutterAirSideMenu extends StatelessWidget {
  const FlutterAirSideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceType deviceBreakpoint = Utils.getDeviceType(context);
    FlutterAirSideMenuStyles menuStyles = Utils.sideMenuStyles[deviceBreakpoint] as FlutterAirSideMenuStyles;

    List<Widget> mainMenuItems =
        deviceBreakpoint == DeviceType.mobile ? getMenuItems(Utils.sideBarItems, menuStyles) : [];

    List<Widget> defaultMenuItems = getMenuItems(Utils.sideMenuItems, menuStyles);
    mainMenuItems.addAll(defaultMenuItems);

    return Container(
        color: menuStyles.backgroundColor,
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: mainMenuItems,
              ),
            ),
            Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: menuStyles.iconBgColor, borderRadius: BorderRadius.circular(35)),
                child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 40)),
          ],
        ));
  }

  List<Widget> getMenuItems(List<FlutterAirSideBarItem> items, FlutterAirSideMenuStyles styles) {
    return List.generate(items.length, (index) {
      var menuItem = items[index];

      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Icon(menuItem.icon, color: styles.labelColor, size: styles.iconSize),
            const SizedBox(width: 20),
            Text(menuItem.label, style: TextStyle(color: styles.labelColor, fontSize: styles.labelSize))
          ],
        ),
      );
    });
  }
}

class FlutterAirSideBar extends StatelessWidget {
  const FlutterAirSideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceType deviceType = Utils.getDeviceType(context);

    FlutterAirSideBarItemStyles sideBarItemStyles = Utils.sideBarItemStyles[deviceType] as FlutterAirSideBarItemStyles;

    return Visibility(
        visible: MediaQuery.of(context).size.width > Utils.mobileMaxWidth,
        child: Material(
            color: Utils.secondaryThemeColor,
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  const SizedBox(height: 20),
                  Expanded(child: LayoutBuilder(builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: ScrollController(),
                      child: Container(
                        height: constraints.maxHeight,
                        constraints: BoxConstraints(
                            minHeight: constraints.minHeight < sideBarItemStyles.minHeight
                                ? sideBarItemStyles.minHeight
                                : constraints.minHeight),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(Utils.sideBarItems.length, (index) {
                              return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                IconButton(
                                    color: Utils.secondaryThemeColor,
                                    splashColor: Utils.mainThemeColor.withOpacity(0.2),
                                    highlightColor: Utils.mainThemeColor.withOpacity(0.2),
                                    onPressed: () {},
                                    icon: Icon(Utils.sideBarItems[index].icon, // populate the icon
                                        color: Colors.white,
                                        size: sideBarItemStyles.iconSize // use the configured style
                                        )),
                                Visibility(
                                    visible: MediaQuery.of(context).size.width > Utils.tabletMaxWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 10, right: 20, bottom: 10),
                                      child: Text(Utils.sideBarItems[index].label,
                                          style: TextStyle(color: Colors.white, fontSize: sideBarItemStyles.labelSize)),
                                    ))
                              ]);
                            })),
                      ),
                    );
                  })),
                  const Spacer()
                ]))));
  }
}

class FlutterAirFlightInfo extends StatelessWidget {
  const FlutterAirFlightInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterAirFlightInfoStyles flightInfoStyles =
        Utils.flightInfoStyles[Utils.getDeviceType(context)] as FlutterAirFlightInfoStyles;

    Column flightInfoColumn = Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Origin', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.labelSize)),
          Text('BOS', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.primaryValueSize))
        ]),
        Expanded(
          child: SizedBox(
            height: 120,
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Container(
                        margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
                        height: flightInfoStyles.flightLineSize,
                        color: Utils.lightPurpleColor.withOpacity(0.3))),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: flightInfoStyles.flightLineEndRadiusSize,
                      height: flightInfoStyles.flightLineEndRadiusSize,
                      margin: const EdgeInsets.only(top: 20, left: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(flightInfoStyles.flightLineEndRadiusSize),
                          color: Colors.white,
                          border: Border.all(
                              color: Utils.lightPurpleColor.withOpacity(0.3), width: flightInfoStyles.flightLineSize)),
                    )),
                Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: flightInfoStyles.flightLineEndRadiusSize,
                      height: flightInfoStyles.flightLineEndRadiusSize,
                      margin: const EdgeInsets.only(top: 20, right: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(flightInfoStyles.flightLineEndRadiusSize),
                          color: Colors.white,
                          border: Border.all(
                              color: Utils.lightPurpleColor.withOpacity(0.3), width: flightInfoStyles.flightLineSize)),
                    )),
                Align(
                  alignment: Alignment.center,
                  child: Transform.rotate(
                      origin: Offset.zero,
                      angle: 1.575,
                      child: Container(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 20, left: 25, top: 20),
                          child:
                              Icon(Icons.flight, color: Utils.mainThemeColor, size: flightInfoStyles.flightIconSize))),
                ),
              ],
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Destination', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.labelSize)),
          Text('STI', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.primaryValueSize))
        ]),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gate', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.labelSize)),
          Row(
            mainAxisSize: MainAxisSize.min,
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Icon(Icons.door_sliding, color: Utils.secondaryThemeColor, size: flightInfoStyles.secondaryIconSize),
              const SizedBox(width: 10),
              Text('G23',
                  style: TextStyle(color: Utils.secondaryThemeColor, fontSize: flightInfoStyles.secondaryValueSize))
            ],
          )
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Baggage Claim', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.labelSize)),
          Row(
            mainAxisSize: MainAxisSize.min,
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Icon(Icons.work, color: Utils.secondaryThemeColor, size: flightInfoStyles.secondaryIconSize),
              const SizedBox(width: 10),
              Text('B5',
                  style: TextStyle(color: Utils.secondaryThemeColor, fontSize: flightInfoStyles.secondaryValueSize))
            ],
          )
        ])
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Departure Time', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.labelSize)),
          Text('5:24 AM', style: TextStyle(color: Utils.darkThemeColor, fontSize: flightInfoStyles.tertiaryValueSize))
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Arrival Time', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.labelSize)),
          Text('7:30 AM', style: TextStyle(color: Utils.darkThemeColor, fontSize: flightInfoStyles.tertiaryValueSize))
        ])
      ])
    ]);

    List<Widget> flightInfoWidgets = [
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Flight', style: TextStyle(color: Utils.normalLabelColor, fontSize: flightInfoStyles.labelSize)),
        const Text('785', style: TextStyle(color: Utils.darkThemeColor, fontSize: 30))
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Container(
            padding: EdgeInsets.only(
                top: flightInfoStyles.seatBadgePaddingSize / 2,
                bottom: flightInfoStyles.seatBadgePaddingSize / 2,
                left: flightInfoStyles.seatBadgePaddingSize,
                right: flightInfoStyles.seatBadgePaddingSize),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Utils.lightPurpleColor),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Icon(Icons.airline_seat_recline_normal, color: Colors.white, size: flightInfoStyles.seatBadgeIconSize),
              Text('23A', style: TextStyle(color: Colors.white, fontSize: flightInfoStyles.seatBadgetLabelSize))
            ]))
      ])
    ];

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < Utils.twoColumnLayoutWidth) {
        return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: flightInfoWidgets),
          ...flightInfoColumn.children
        ]);
      }

      return Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(flex: 2, child: flightInfoColumn),
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: flightInfoWidgets))
      ]);
    });
  }
}

class FlutterAirAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FlutterAirAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    FlutterAirAppBarStyles appBarStyles = Utils.appBarStyles[Utils.getDeviceType(context)] as FlutterAirAppBarStyles;

    return AppBar(
      backgroundColor: appBarStyles.backgroundColor,
      elevation: 0,
      title: const FlutterAirAppHeaderTitle(),
      leading: Builder(builder: (context) {
        return Material(
            color: appBarStyles.leadingIconBackgroundColor,
            child: InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Icon(Icons.menu, color: appBarStyles.leadingIconForegroundColor))));
      }),
    );
  }
}

class FlutterAirAppHeaderTitle extends StatelessWidget {
  const FlutterAirAppHeaderTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterAirAppBarStyles appBarStyles = Utils.appBarStyles[Utils.getDeviceType(context)] as FlutterAirAppBarStyles;

    return Row(children: [
      Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: Utils.secondaryThemeColor, borderRadius: BorderRadius.circular(20)),
          child: Icon(Icons.flight_takeoff, color: appBarStyles.titleIconColor, size: 20)),
      const SizedBox(width: 10),
      Text('Welcome', style: TextStyle(fontSize: 18, color: appBarStyles.titleColor))
    ]);
  }
}

// Utility Classes

enum DeviceType { mobile, tablet, laptop }

class Utils {
  static const int mobileMaxWidth = 480;
  static const int tabletMaxWidth = 768;
  static const int laptopMaxWidth = 1024;

  static const int twoColumnLayoutWidth = 600;

  static const Color mainThemeColor = Color(0xFF5C1896);
  static const Color secondaryThemeColor = Color(0xFFA677FF);
  static const Color darkThemeColor = Color(0xFF44146E);
  static const Color normalLabelColor = Color(0xFF6C6C6C);
  static const Color lightPurpleColor = Color(0xFFC5ABF6);

  static Map<DeviceType, FlutterAirAppBarStyles> appBarStyles = {
    DeviceType.mobile: FlutterAirAppBarStyles(
        leadingIconBackgroundColor: Colors.transparent,
        leadingIconForegroundColor: Utils.mainThemeColor,
        backgroundColor: Colors.transparent,
        titleColor: Utils.mainThemeColor,
        titleIconColor: Colors.white),
    DeviceType.tablet: FlutterAirAppBarStyles(
      leadingIconBackgroundColor: Utils.darkThemeColor,
      leadingIconForegroundColor: Colors.white,
      backgroundColor: Utils.mainThemeColor,
      titleColor: Colors.white,
      titleIconColor: Utils.mainThemeColor,
    ),
    DeviceType.laptop: FlutterAirAppBarStyles(
      leadingIconBackgroundColor: Utils.darkThemeColor,
      leadingIconForegroundColor: Colors.white,
      backgroundColor: Utils.mainThemeColor,
      titleColor: Colors.white,
      titleIconColor: Utils.mainThemeColor,
    )
  };

  static Map<DeviceType, FlutterAirFlightInfoStyles> flightInfoStyles = {
    DeviceType.mobile: FlutterAirFlightInfoStyles(
      labelSize: 15,
      primaryValueSize: 60,
      secondaryValueSize: 40,
      tertiaryValueSize: 30,
      flightIconSize: 50,
      seatBadgePaddingSize: 15,
      seatBadgeIconSize: 25,
      seatBadgetLabelSize: 25,
      flightLineSize: 3,
      flightLineEndRadiusSize: 10,
      secondaryIconSize: 30,
      minHeight: 500,
    ),
    DeviceType.tablet: FlutterAirFlightInfoStyles(
        labelSize: 20,
        primaryValueSize: 60,
        secondaryValueSize: 50,
        tertiaryValueSize: 30,
        flightIconSize: 60,
        seatBadgePaddingSize: 20,
        seatBadgeIconSize: 30,
        seatBadgetLabelSize: 30,
        flightLineSize: 4,
        flightLineEndRadiusSize: 15,
        secondaryIconSize: 30,
        minHeight: 500),
    DeviceType.laptop: FlutterAirFlightInfoStyles(
        labelSize: 20,
        primaryValueSize: 70,
        secondaryValueSize: 60,
        tertiaryValueSize: 40,
        flightIconSize: 60,
        seatBadgePaddingSize: 30,
        seatBadgeIconSize: 35,
        seatBadgetLabelSize: 35,
        flightLineSize: 4,
        flightLineEndRadiusSize: 15,
        secondaryIconSize: 30,
        minHeight: 500)
  };

  static Map<DeviceType, FlutterAirSideMenuStyles> sideMenuStyles = {
    DeviceType.mobile: FlutterAirSideMenuStyles(
        backgroundColor: Utils.secondaryThemeColor,
        labelColor: Colors.white,
        iconSize: 20,
        labelSize: 20,
        iconBgColor: Utils.mainThemeColor),
    DeviceType.tablet: FlutterAirSideMenuStyles(
        backgroundColor: Colors.white,
        labelColor: Utils.darkThemeColor,
        iconSize: 30,
        labelSize: 20,
        iconBgColor: Utils.secondaryThemeColor),
    DeviceType.laptop: FlutterAirSideMenuStyles(
        backgroundColor: Colors.white,
        labelColor: Utils.darkThemeColor,
        iconSize: 30,
        labelSize: 20,
        iconBgColor: Utils.secondaryThemeColor)
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

  static List<FlutterAirSideBarItem> sideBarItems = [
    FlutterAirSideBarItem(icon: Icons.home, label: 'Home'),
    FlutterAirSideBarItem(icon: Icons.face, label: 'Passengers'),
    FlutterAirSideBarItem(icon: Icons.airplane_ticket, label: 'Flight Info'),
    FlutterAirSideBarItem(icon: Icons.airline_seat_recline_normal, label: 'Reserve Seat')
  ];

  static List<FlutterAirSideBarItem> sideMenuItems = [
    FlutterAirSideBarItem(icon: Icons.settings, label: 'Settings'),
    FlutterAirSideBarItem(icon: Icons.qr_code, label: 'Boarding Pass')
  ];

  static Map<DeviceType, FlutterAirSideBarItemStyles> sideBarItemStyles = {
    DeviceType.mobile: FlutterAirSideBarItemStyles(iconSize: 30, labelSize: 15, minHeight: 200),
    DeviceType.tablet: FlutterAirSideBarItemStyles(iconSize: 30, labelSize: 15, minHeight: 200),
    DeviceType.laptop: FlutterAirSideBarItemStyles(iconSize: 25, labelSize: 15, minHeight: 200)
  };
}

class FlutterAirAppBarStyles {
  final Color leadingIconBackgroundColor;
  final Color leadingIconForegroundColor;
  final Color backgroundColor;
  final Color titleColor;
  final Color titleIconColor;

  FlutterAirAppBarStyles(
      {required this.leadingIconBackgroundColor,
      required this.leadingIconForegroundColor,
      required this.backgroundColor,
      required this.titleColor,
      required this.titleIconColor});
}

class FlutterAirFlightInfoStyles {
  final double labelSize;
  final double primaryValueSize;
  final double secondaryValueSize;
  final double tertiaryValueSize;
  final double flightIconSize;
  final double seatBadgePaddingSize;
  final double seatBadgeIconSize;
  final double seatBadgetLabelSize;
  final double flightLineSize;
  final double flightLineEndRadiusSize;
  final double secondaryIconSize;
  final double minHeight;

  FlutterAirFlightInfoStyles(
      {required this.labelSize,
      required this.primaryValueSize,
      required this.secondaryValueSize,
      required this.tertiaryValueSize,
      required this.flightIconSize,
      required this.seatBadgeIconSize,
      required this.seatBadgePaddingSize,
      required this.seatBadgetLabelSize,
      required this.flightLineSize,
      required this.flightLineEndRadiusSize,
      required this.secondaryIconSize,
      required this.minHeight});
}

class FlutterAirSideBarItemStyles {
  final double iconSize;
  final double labelSize;
  final double minHeight;

  FlutterAirSideBarItemStyles({required this.iconSize, required this.labelSize, required this.minHeight});
}

class FlutterAirSideMenuStyles {
  final Color backgroundColor;
  final Color labelColor;
  final Color iconBgColor;
  final double iconSize;
  final double labelSize;

  FlutterAirSideMenuStyles(
      {required this.backgroundColor,
      required this.labelColor,
      required this.iconSize,
      required this.labelSize,
      required this.iconBgColor});
}

class FlutterAirSideBarItem {
  final IconData icon;
  final String label;

  FlutterAirSideBarItem({required this.icon, required this.label});
}
