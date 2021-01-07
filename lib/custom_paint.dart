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

import 'package:flutter/material.dart';

class ShapePainter extends CustomPainter {
  Rect rect;
  final ShapeBorder shapeBorder;
  final Color color;
  final double opacity;

  ShapePainter({
    @required this.rect,
    this.color,
    this.shapeBorder,
    this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color.withOpacity(opacity);

    RRect outer =
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(0));

    Radius radius;
    if (shapeBorder is CircleBorder) {
      radius = Radius.circular(
          (rect.width <= rect.height ? rect.width : rect.height) / 2);
    } else {
      final border = shapeBorder as RoundedRectangleBorder;

      // Assumes same radius in all 4 corners
      radius = border != null
          ? border.borderRadius.resolve(TextDirection.ltr).topLeft
          : Radius.circular(3);
    }

    RRect inner = RRect.fromRectAndRadius(rect, radius);
    canvas.drawDRRect(outer, inner, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
