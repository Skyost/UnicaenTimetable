import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/widgets/cards/card.dart';

/// A dumb card. Don't use that.
class DumbCard extends MaterialCard {
  /// The card id.
  static const String id = 'dumb';

  /// Creates a new dumb card instance.
  DumbCard({
    super.key,
    String id = id,
    super.onRemove,
  }) : super(
    cardId: id,
  );

  @override
  Future<String> requestData(BuildContext context, WidgetRef ref) => Future<String>.value('An error occurred.\nPlease remove this card.');

  @override
  Color buildColor(BuildContext context, WidgetRef ref) => Colors.green[700]!;

  @override
  IconData buildIcon(BuildContext context, WidgetRef ref) => Icons.error_outline;

  @override
  void onTap(BuildContext context, WidgetRef ref) => onRemove == null ? null : onRemove!();
}