/*
 * Copyright © 2020, Simform Solutions
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:showcaseview/get_position.dart';
import 'package:showcaseview/measure_size.dart';

class ToolTipWidget extends StatefulWidget {
  final GetPosition position;
  final Offset offset;
  final Size screenSize;
  final String title;
  final String description;
  final Animation<double> animationOffset;
  final TextStyle titleTextStyle;
  final TextStyle descTextStyle;
  final Widget container;
  final Color tooltipColor;
  final Color textColor;
  final bool showArrow;
  final double contentHeight;
  final double contentWidth;
  static bool isArrowUp;
  final VoidCallback onTooltipTap;
  final EdgeInsets contentPadding;

  ToolTipWidget(
      {this.position,
      this.offset,
      this.screenSize,
      this.title,
      this.description,
      this.animationOffset,
      this.titleTextStyle,
      this.descTextStyle,
      this.container,
      this.tooltipColor,
      this.textColor,
      this.showArrow,
      this.contentHeight,
      this.contentWidth,
      this.onTooltipTap,
      this.contentPadding});

  @override
  _ToolTipWidgetState createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget> {
  TextStyle _titleTextStyle;
  TextStyle _descriptionTextStyle;
  double _paddingTop;
  double _paddingBottom;
  Offset position;
  double _width;

  bool isCloseToTopOrBottom(Offset position) {
    double height = 120;
    height = widget.contentHeight ?? height;
    return (widget.screenSize.height - position.dy) <= height;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  double _getTooltipWidth() {
    final titleLength = widget.title != null
        ? (TextPainter(
                text: TextSpan(text: widget.title, style: _titleTextStyle),
                maxLines: 1,
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
                textDirection: TextDirection.ltr)
              ..layout())
            .size
            .width
        : 0;

    final descriptionLength = (TextPainter(
            text: TextSpan(
                text: widget.description, style: _descriptionTextStyle),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size
        .width;

    var maxTextWidth = max(titleLength, descriptionLength) +
        widget.contentPadding.left +
        widget.contentPadding.right;

    if (maxTextWidth > widget.screenSize.width - 20) {
      return widget.screenSize.width - 20;
    } else {
      return maxTextWidth;
    }
  }

  bool _isLeft() {
    double screenWidth = widget.screenSize.width / 3;
    return !(screenWidth <= widget.position.getCenter());
  }

  bool _isRight() {
    double screenWidth = widget.screenSize.width / 3;
    return ((screenWidth * 2) <= widget.position.getCenter());
  }

  double _getLeft() {
    if (_isLeft()) {
      double leftPadding = widget.position.getCenter() - (_width * 0.1);
      if (leftPadding + _width > widget.screenSize.width) {
        leftPadding = (widget.screenSize.width - 20) - _width;
      }
      if (leftPadding < 20) {
        leftPadding = 14;
      }
      return leftPadding;
    } else if (!(_isRight())) {
      return widget.position.getCenter() - (_width * 0.5);
    } else {
      return null;
    }
  }

  double _getRight() {
    if (_isRight()) {
      double rightPadding = widget.position.getCenter() + (_width / 2);
      if (rightPadding + _width > widget.screenSize.width) {
        rightPadding = 14;
      }
      return rightPadding;
    } else if (!(_isLeft())) {
      return widget.position.getCenter() - (_width * 0.5);
    } else {
      return null;
    }
  }

  double _getSpace() {
    double space = widget.position.getCenter() - (widget.contentWidth / 2);
    if (space + widget.contentWidth > widget.screenSize.width) {
      space = widget.screenSize.width - widget.contentWidth - 8;
    } else if (space < (widget.contentWidth / 2)) {
      space = 16;
    }
    return space;
  }

  @override
  void initState() {
    super.initState();
    position = widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = findPositionForContent(position);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    ToolTipWidget.isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = ToolTipWidget.isArrowUp
        ? widget.position.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position.getTop() + (contentOffsetMultiplier * 3);

    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

    _paddingTop = ToolTipWidget.isArrowUp ? 22 : 0;
    _paddingBottom = ToolTipWidget.isArrowUp ? 0 : 27;

    _titleTextStyle = widget.titleTextStyle ??
        Theme.of(context).textTheme.headline6.apply(color: widget.textColor);
    _descriptionTextStyle = widget.descTextStyle ??
        Theme.of(context).textTheme.subtitle2.apply(color: widget.textColor);

    if (!widget.showArrow) {
      _paddingTop = 10;
      _paddingBottom = 10;
    }

    _width = _getTooltipWidth();

    if (widget.container == null) {
      return Stack(
        children: <Widget>[
          widget.showArrow ? _getArrow(contentOffsetMultiplier) : Container(),
          Positioned(
            top: contentY,
            left: _getLeft(),
            right: _getRight(),
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: Offset(0.0, 0.100),
                ).animate(widget.animationOffset),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: _paddingTop, bottom: _paddingBottom),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: widget.onTooltipTap,
                        child: Container(
                          width: _width,
                          padding: widget.contentPadding,
                          color: widget.tooltipColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  crossAxisAlignment: widget.title != null
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.center,
                                  children: <Widget>[
                                    widget.title != null
                                        ? Text(
                                            widget.title,
                                            style: _titleTextStyle,
                                          )
                                        : Container(),
                                    Text(
                                      widget.description,
                                      style: _descriptionTextStyle,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - 10,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: !widget.showArrow && !ToolTipWidget.isArrowUp
                      ? Offset(0.0, 0.0)
                      : Offset(0.0, 0.100),
                ).animate(widget.animationOffset),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: widget.onTooltipTap,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: _paddingTop,
                      ),
                      color: Colors.transparent,
                      child: Center(
                        child: MeasureSize(
                            onSizeChange: (size) {
                              setState(() {
                                Offset tempPos = position;
                                tempPos = Offset(
                                    position.dx, position.dy + size.height);
                                position = tempPos;
                              });
                            },
                            child: widget.container),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _getArrow(contentOffsetMultiplier) {
    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);
    return Positioned(
      top: ToolTipWidget.isArrowUp
          ? widget.position.getBottom()
          : widget.position.getTop() - 1,
      left: widget.position.getCenter() - 24,
      child: FractionalTranslation(
        translation: Offset(0.0, contentFractionalOffset),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, contentFractionalOffset / 5),
            end: Offset(0.0, 0.150),
          ).animate(widget.animationOffset),
          child: Icon(
            ToolTipWidget.isArrowUp
                ? Icons.arrow_drop_up
                : Icons.arrow_drop_down,
            color: widget.tooltipColor,
            size: 50,
          ),
        ),
      ),
    );
  }
}
