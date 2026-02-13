/// Enum representing the spiritual services available in the AI chatbot.
/// Order matters - "Ask Anything" is first, then others
enum SpiritualServiceType {
  askAnything,      // General spiritual Q&A - on top
  numerology,
  kundli,
  palmistry,
  mantra,
  upcomingEvents,   // Upcoming spiritual events
}

/// Extension to provide metadata for each spiritual service.
extension SpiritualServiceMetadata on SpiritualServiceType {
  String get id => name;

  String get title {
    switch (this) {
      case SpiritualServiceType.askAnything:
        return 'Ask Anything';
      case SpiritualServiceType.numerology:
        return 'Numerology';
      case SpiritualServiceType.kundli:
        return 'Kundli Reading';
      case SpiritualServiceType.palmistry:
        return 'Palmistry';
      case SpiritualServiceType.mantra:
        return 'Mantra Guidance';
      case SpiritualServiceType.upcomingEvents:
        return 'Upcoming Events';
    }
  }

  String get emoji {
    switch (this) {
      case SpiritualServiceType.askAnything:
        return '💬';
      case SpiritualServiceType.numerology:
        return '🔢';
      case SpiritualServiceType.kundli:
        return '⭐';
      case SpiritualServiceType.palmistry:
        return '🖐️';
      case SpiritualServiceType.mantra:
        return '🕉️';
      case SpiritualServiceType.upcomingEvents:
        return '📅';
    }
  }

  String get shortDescription {
    switch (this) {
      case SpiritualServiceType.askAnything:
        return 'Ask any spiritual question freely';
      case SpiritualServiceType.numerology:
        return 'Discover your life path through sacred numbers';
      case SpiritualServiceType.kundli:
        return 'Vedic birth chart analysis & predictions';
      case SpiritualServiceType.palmistry:
        return 'Read the lines of destiny on your palms';
      case SpiritualServiceType.mantra:
        return 'Personalized mantras for spiritual growth';
      case SpiritualServiceType.upcomingEvents:
        return 'Auspicious dates & spiritual occasions';
    }
  }

  bool get isPopular {
    return this == SpiritualServiceType.askAnything ||
        this == SpiritualServiceType.numerology ||
        this == SpiritualServiceType.palmistry;
  }

  /// Required fields for data collection form
  List<ServiceFormField> get requiredFields {
    switch (this) {
      case SpiritualServiceType.askAnything:
        return [
          ServiceFormField.question,
        ];
      case SpiritualServiceType.numerology:
        return [
          ServiceFormField.fullName,
          ServiceFormField.dateOfBirth,
        ];
      case SpiritualServiceType.kundli:
        return [
          ServiceFormField.fullName,
          ServiceFormField.dateOfBirth,
          ServiceFormField.birthTime,
          ServiceFormField.birthPlace,
        ];
      case SpiritualServiceType.palmistry:
        return [
          ServiceFormField.palmImage,
          ServiceFormField.dominantHand,
        ];
      case SpiritualServiceType.mantra:
        return [
          ServiceFormField.fullName,
          ServiceFormField.dateOfBirth,
          ServiceFormField.spiritualGoals,
        ];
      case SpiritualServiceType.upcomingEvents:
        return [
          ServiceFormField.eventInterest,
        ];
    }
  }
}

/// Form fields used across different services
enum ServiceFormField {
  fullName,
  dateOfBirth,
  birthTime,
  birthPlace,
  dominantHand,
  palmImage,
  question,
  spiritualGoals,
  eventInterest,
}

extension ServiceFormFieldMetadata on ServiceFormField {
  String get label {
    switch (this) {
      case ServiceFormField.fullName:
        return 'Full Name';
      case ServiceFormField.dateOfBirth:
        return 'Date of Birth';
      case ServiceFormField.birthTime:
        return 'Birth Time (HH:MM)';
      case ServiceFormField.birthPlace:
        return 'Birth Place';
      case ServiceFormField.dominantHand:
        return 'Dominant Hand';
      case ServiceFormField.palmImage:
        return 'Palm Image';
      case ServiceFormField.question:
        return 'Your Question';
      case ServiceFormField.spiritualGoals:
        return 'Spiritual Goals';
      case ServiceFormField.eventInterest:
        return 'What events interest you?';
    }
  }

  String get hint {
    switch (this) {
      case ServiceFormField.fullName:
        return 'Enter your full name as per birth certificate';
      case ServiceFormField.dateOfBirth:
        return 'DD/MM/YYYY';
      case ServiceFormField.birthTime:
        return '24-hour format (e.g., 14:30)';
      case ServiceFormField.birthPlace:
        return 'City, State, Country';
      case ServiceFormField.dominantHand:
        return 'Left or Right';
      case ServiceFormField.palmImage:
        return 'Take a clear photo of your palm';
      case ServiceFormField.question:
        return 'What guidance are you seeking?';
      case ServiceFormField.spiritualGoals:
        return 'Peace, prosperity, health, etc.';
      case ServiceFormField.eventInterest:
        return 'Festivals, Puja dates, Fasting days, etc.';
    }
  }

  bool get isMultiline {
    return this == ServiceFormField.question ||
        this == ServiceFormField.spiritualGoals ||
        this == ServiceFormField.eventInterest;
  }

  bool get isDateField {
    return this == ServiceFormField.dateOfBirth;
  }

  bool get isTimeField {
    return this == ServiceFormField.birthTime;
  }

  bool get isImageField {
    return this == ServiceFormField.palmImage;
  }
}
