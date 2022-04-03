library mad_picker;

import 'package:flutter/material.dart';

final Map<int, double> _correctSizes = {};

double _correctButtonSize(int itemSize, double screenWidth) {
  double inittSize = 52;
  double maxWidth = screenWidth - inittSize;
  bool isSizeGood = false;
  double finalSize = 48;

  do {
    finalSize -= 2;
    double eachSize = finalSize * 1.2;
    double buttonArea = itemSize * eachSize;
    isSizeGood = maxWidth > buttonArea;
  } while (!isSizeGood);
  _correctSizes[itemSize] = finalSize;
  return finalSize;
}

class MadPickerItem extends StatelessWidget {
  
  const MadPickerItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
