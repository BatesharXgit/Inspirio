import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Components {
  static Widget buildPlaceholder() {
    return Center(
      child: Builder(builder: (context) {
        Color primaryColour = Theme.of(context).colorScheme.primary;
        return LoadingAnimationWidget.beat(
          size: 35,
          color: primaryColour,
          // leftDotColor: Theme.of(context).colorScheme.primary,
          // rightDotColor: Theme.of(context).colorScheme.secondary
        );
      }),
    );
  }

  static Widget buildErrorWidget() {
    return Container(
      color: const Color(0xFFFE5163),
      child: const Icon(Icons.error),
    );
  }

  static Widget buildCircularIndicator() {
    return Center(
      child: Builder(builder: (context) {
        Color primaryColour = Theme.of(context).colorScheme.primary;
        return LoadingAnimationWidget.fourRotatingDots(
          size: 35,
          color: primaryColour,
        );
      }),
    );
  }
  
}
