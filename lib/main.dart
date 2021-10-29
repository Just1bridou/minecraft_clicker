import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

//import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upgrade.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minecraft Clicker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Minecraft Clicker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  static BlockManager blockManager = BlockManager();
  static UpgradeManager upgradeManager = UpgradeManager();
  static VexManager vexManager = VexManager();

  static Random random = Random();
  static double x = random.nextInt(300).toDouble();
  static double y = random.nextInt(200).toDouble();

  static int xM = 1;
  static int yM = 1;

  static var transform = Matrix4.rotationY(math.pi);

  AudioPlayer audioPlayer = AudioPlayer();

  late AnimationController animControler;

  @override
  void initState() {
    super.initState();

    upgradeManager.init();
    blockManager.init();
    vexManager.init();

    for (var i = 0; i < vexManager.level; i++) {
      print("increment");
      _incrementVexLevel();
    }
    animControler = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 0,
      upperBound: 30,
    );

    animControler.addListener(() {
      setState(() {});
    });

    animControler.repeat(reverse: true);

    Timer.periodic(const Duration(milliseconds: 10), (Timer timer) {
      setState(() {
        x = x + xM;
        y = y + yM;

        if (y > 200 || y < 0) {
          yM = yM * -1;
        }

        if (x > MediaQuery.of(context).size.width || x < -100) {
          xM = xM * -1;
          transform = Matrix4.rotationY(xM > 0 ? math.pi : 0);
        }
      });
    });
  }

  void _incrementVexLevel() {
    setState(() {
      VexClick().init(() {
        blockManager.increment(value: vexManager.cps);
      });
    });
  }

  Container clickContainer = Container();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            blocksNumbers(blockManager.blocks),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: animControler.value + 50),
                              child: Center(
                                child: GestureDetector(
                                  onTapDown: (TapDownDetails details) {
                                    clickOnBlock(details);
                                  },
                                  child: Image.asset(
                                      blockManager.actualBlock.path,
                                      height: 200,
                                      width: 200),
                                ),
                              ),
                            ),
                            Positioned(
                              top: y,
                              left: x,
                              child: Transform(
                                transform: transform,
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTapDown: (TapDownDetails details) {
                                    clickOnBlock(details);
                                  },
                                  child: Image.asset(
                                    "assets/images/upgrades/Vexgif.gif",
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                              ),
                            ),
                            clickContainer
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(color: Color(0x66000000)),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: Column(children: [
                                  Image.asset(
                                      upgradeManager.actualElement.assetName),
                                  upgradeManager.maxLevel
                                      ? Text("Max level",
                                          style: GoogleFonts.patrickHand(
                                              textStyle: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w700)))
                                      : Column(
                                          children: [
                                            upgradeInformationText(
                                                text: "Cost " +
                                                    upgradeManager
                                                        .actualElement.price
                                                        .toString() +
                                                    " blocks"),
                                            upgradeInformationText(
                                                text: upgradeManager
                                                        .actualElement.click
                                                        .toString() +
                                                    " blocks per click"),
                                          ],
                                        ),
                                ]),
                              ),
                              upgradeShovel()
                            ],
                          ),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      child: Column(children: [
                                    Image.asset(
                                      "assets/images/upgrades/Vex.png",
                                      height: 200,
                                      width: 200,
                                    ),
                                    upgradeInformationText(
                                        text: "Vex level " +
                                            vexManager.level.toString()),
                                    upgradeInformationText(
                                        text: vexManager.level.toString() +
                                            " blocks / seconds")
                                  ])),
                                  upgradeVex()
                                ]),
                          ))
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  clickOnBlock(TapDownDetails details) {
    blockManager.increment();

    var posX = details.globalPosition.dx;
    var posY = details.globalPosition.dy - 240;

    clickContainer = Container(
        child: Positioned(
            top: posY,
            left: posX,
            child: GestureDetector(
              child: Text(
                "+" + blockManager.multiplier.toString(),
                style: GoogleFonts.patrickHand(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0)),
              ),
              onTapDown: (TapDownDetails details) {
                clickOnBlock(details);
              },
            )));

    Timer(const Duration(milliseconds: 300), () {
      clickContainer = Container();
    });
  }

  upgradeVex() {
    return GestureDetector(
      child: Container(
          width: MediaQuery.of(context).size.width / 2 - 20,
          decoration: BoxDecoration(
              color: blockManager.blocks >= vexManager.price
                  ? Colors.yellow
                  : Colors.grey),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "BUY (" + vexManager.price.toString() + ")",
                style: GoogleFonts.patrickHand(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0)),
              ),
            ),
          )),
      onTap: () {
        setState(() {
          if (blockManager.blocks >= vexManager.price) {
            blockManager.buy(vexManager.price);

            _incrementVexLevel();
            vexManager.upgrade();
          }
        });
      },
    );
  }

  upgradeShovel() {
    UpgradeElement nextElement = upgradeManager.actualElement;

    return GestureDetector(
      child: Container(
          width: MediaQuery.of(context).size.width / 2 - 20,
          decoration: BoxDecoration(
              color: !upgradeManager.maxLevel &&
                      blockManager.blocks >= upgradeManager.actualElement.price
                  ? Colors.yellow
                  : Colors.grey),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "BUY",
                style: GoogleFonts.patrickHand(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0)),
              ),
            ),
          )),
      onTap: () {
        playSound();
        setState(() {
          upgradeManager.canUpgrade(() {
            if (blockManager.blocks >= nextElement.price) {
              blockManager.multiplier = nextElement.click;

              blockManager.buy(nextElement.price);

              upgradeManager.checkMaxLevel();
            }
          });
        });
      },
    );
  }

  playSound() {
    HapticFeedback.heavyImpact();

    /*audioPlayer.stop();
    audioPlayer.setAsset("assets/sounds/upgrade.mp3").then((play) {
      audioPlayer.play();
      print("Playing now");
    });*/
  }

  blocksNumbers(int blocks) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$blocks ",
            style: GoogleFonts.patrickHand(
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0))),
        Text("blocks mined",
            style: GoogleFonts.patrickHand(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 30.0)))
      ],
    );
  }
}

class upgradeAvaibality extends StatelessWidget {
  const upgradeAvaibality({Key? key, required this.text, required this.color})
      : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          //color: Color(0x66000000),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,
            style: GoogleFonts.patrickHand(
                textStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0))),
      ),
    );
  }
}

class VexClick {
  init(Function callback) {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      callback();
    });
  }
}

class upgradeInformationText extends StatelessWidget {
  const upgradeInformationText({Key? key, required this.text})
      : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.patrickHand(
            textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0)));
  }
}
