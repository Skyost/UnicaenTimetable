import 'package:flutter/material.dart';

/// A settings object that can be rendered in the widget tree.
mixin RenderableSettingsObject {
  /// Renders this object.
  Widget render(BuildContext context);
}
