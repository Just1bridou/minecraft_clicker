import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

class UpgradeElement {
  int click;
  int price;
  String assetName;

  UpgradeElement(
      @required this.click, @required this.price, @required this.assetName);
}

class BlockTexture {
  int level;
  String path;

  BlockTexture(@required this.level, @required this.path);
}

String path = 'assets/images/blocks/';

class BlockManager {
  int totalBlocksMined = 0;

  int blocks = 0;
  int multiplier = 1;

  List<BlockTexture> listTextures = [
    BlockTexture(0, path + "dirtBlock.png"),
    BlockTexture(100, path + "grassBlock.png"),
    BlockTexture(200, path + "pathBlock.png"),
    BlockTexture(300, path + "coarseBlock.png"),
    BlockTexture(400, path + "myceliumBlock.png"),
    BlockTexture(500, path + "snowBlock.png"),
  ];

  late BlockTexture actualBlock = listTextures[0];

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    totalBlocksMined = (prefs.getInt('totalBlocksMined') ?? 0);
    blocks = (prefs.getInt('blocks') ?? 0);
    multiplier = (prefs.getInt('multiplier') ?? 1);

    int index = (prefs.getInt('actualBlockIndex') ?? 0);
    actualBlock = listTextures[index];
  }

  void increment({int? value}) {
    if (value != null) {
      blocks += value;
    } else {
      blocks += multiplier;
    }

    savePrefs();

    checkTotalBlocksMined(value ?? multiplier);
  }

  void buy(int value) {
    blocks -= value;

    savePrefs();
  }

  void savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalBlocksMined', totalBlocksMined);
    await prefs.setInt('multiplier', multiplier);
    await prefs.setInt('blocks', blocks);

    int index = listTextures.indexOf(actualBlock);
    await prefs.setInt('actualBlockIndex', index);
  }

  void checkTotalBlocksMined(int value) {
    totalBlocksMined += value;

    int index = listTextures.indexOf(actualBlock);
    int nextIndex = index + 1;

    if (nextIndex <= listTextures.length - 1) {
      BlockTexture nextBlock = listTextures.elementAt(nextIndex);

      if (totalBlocksMined >= nextBlock.level) {
        actualBlock = nextBlock;
      }
    }
  }
}

class UpgradeManager {
  List<UpgradeElement> list = [];
  UpgradeElement actualElement = UpgradeElement(
      2, 20, "assets/images/upgrades/Enchanted_Wooden_Shovel.gif");

  bool maxLevel = false;

  int actualUpgrade = 0;

  UpgradeManager();

  void add(UpgradeElement element) {
    list.add(element);
  }

  void setList(List<UpgradeElement> listElements) {
    list = listElements;
  }

  void init() async {
    final List<UpgradeElement> upgradesList = [
      UpgradeElement(
          2, 20, "assets/images/upgrades/Enchanted_Wooden_Shovel.gif"),
      UpgradeElement(
          4, 40, "assets/images/upgrades/Enchanted_Stone_Shovel.gif"),
      UpgradeElement(6, 80, "assets/images/upgrades/Enchanted_Iron_Shovel.gif"),
      UpgradeElement(
          8, 160, "assets/images/upgrades/Enchanted_Golden_Shovel.gif"),
      UpgradeElement(
          10, 320, "assets/images/upgrades/Enchanted_Diamond_Shovel.gif"),
      UpgradeElement(
          12, 640, "assets/images/upgrades/Enchanted_Netherite_Shovel.gif"),
    ];

    setList(upgradesList);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    actualUpgrade = (prefs.getInt('actualUpgrade') ?? 0);
    maxLevel = (prefs.getBool('maxLevel') ?? false);

    actualElement = list[actualUpgrade];
  }

  void canUpgrade(Function cb) async {
    if (!maxLevel) {
      if (actualUpgrade < list.length) {
        cb();
      }
    }
  }

  void checkMaxLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (actualUpgrade + 1 < list.length) {
      actualUpgrade++;

      await prefs.setInt('actualUpgrade', actualUpgrade);

      actualElement = list[actualUpgrade];
    } else {
      maxLevel = true;

      await prefs.setBool('maxLevel', maxLevel);
    }
  }
}

class VexManager {
  int price = 100;
  int cps = 0;
  int level = 0;

  double priceMultiplier = 1.1;
  double cpsMultiplier = 1.1;

  VexManager();

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    price = (prefs.getInt('price') ?? 100);
    cps = (prefs.getInt('cps') ?? 0);
    level = (prefs.getInt('level') ?? 0);
  }

  upgrade() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    level++;

    var newPrice = price * priceMultiplier;
    price = newPrice.round();

    if (cps == 0) {
      cps = 1;
    } else {
      var newCps = cps * cpsMultiplier;
      cps = newCps.round();
    }

    await prefs.setInt('level', level);
    await prefs.setInt('price', price);
    await prefs.setInt('cps', cps);
  }
}
