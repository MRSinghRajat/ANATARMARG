import '../../chat/data/models/spiritual_service.dart';

extension SpiritualServiceTypeGuru on SpiritualServiceType {
  /// Key for [GuruPrompts.serviceSub]; Ask Anything uses `general` (no sub-prompt).
  String get guruPromptServiceKey =>
      this == SpiritualServiceType.askAnything ? 'general' : name;

  bool get guruUsesAskAnythingQuota =>
      this == SpiritualServiceType.askAnything;
}
