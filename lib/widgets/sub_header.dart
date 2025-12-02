
import 'package:flutter/material.dart';
import '../constants/style_constants.dart';

class SubHeader extends StatelessWidget {
  final String subtitle;

  const SubHeader({
    super.key,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
      ],
    );
  }
}

