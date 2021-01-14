import 'package:flutter/material.dart';

typedef ActionSheetCallback = Function(int index);

class ActionSheetWidget extends StatelessWidget {
  ActionSheetWidget({
    this.actionList,
    this.highlightIndex,
    this.onSelectAction,
  });

  final List<String> actionList;
  final int highlightIndex;
  final ActionSheetCallback onSelectAction;

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    List<Widget> list = [];
    int index = 0;
    for (final String title in actionList) {
      list.add(ActionSheetItemWidget(
        title: title,
        isHighlight: index == highlightIndex,
        isShowBottomLine: index < actionList.length - 1,
        onTap: () {
          if (onSelectAction != null) {
            onSelectAction(index);
          }
        },
      ));
      index += 1;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...list,
          Container(
            height: 6.0,
            color: Colors.grey,
          ),
          ActionSheetItemWidget(
            title: '取消',
            isShowBottomLine: false,
          ),
          SizedBox(
            height: bottomPadding,
          ),
        ],
      ),
    );
  }
}

class ActionSheetItemWidget extends StatelessWidget {
  ActionSheetItemWidget({
    this.title,
    this.isHighlight = false,
    this.isShowBottomLine = true,
    this.onTap,
  });

  final String title;
  final bool isHighlight;
  final bool isShowBottomLine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50.0,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                color: isHighlight ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ),
        if (isShowBottomLine)
          Container(
            height: 0.5,
            color: Colors.grey,
          ),
      ],
    );
  }
}
