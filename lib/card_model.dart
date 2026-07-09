class MJCardItem {
  final int cardNumber;
  final String cardName;
  final String cardType;
  
  // A map to store whether each specific variation is checked (e.g., {'Base': true, 'Red /87': false})
  Map<String, bool> variations;

  // A map to store the specific serial number entered for numbered parallels (e.g., {'Red /87': '42/87'})
  Map<String, String> serialNumbers;

  String notes;

  MJCardItem({
    required this.cardNumber,
    required this.cardName,
    required this.cardType,
    Map<String, bool>? variations,
    Map<String, String>? serialNumbers,
    this.notes = '',
  })  : variations = variations ?? {},
        serialNumbers = serialNumbers ?? {};

  // Helper getter to check if any variation of this card is collected
  bool get isCollected => variations.values.contains(true);

  // Convert to JSON/Map if you are saving to Firebase or local storage later
  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'cardName': cardName,
        'cardType': cardType,
        'variations': variations,
        'serialNumbers': serialNumbers,
        'notes': notes,
      };

  // Create from JSON/Map
  factory MJCardItem.fromJson(Map<String, dynamic> json) {
    return MJCardItem(
      cardNumber: json['cardNumber'] ?? 0,
      cardName: json['cardName'] ?? '',
      cardType: json['cardType'] ?? '',
      variations: Map<String, bool>.from(json['variations'] ?? {}),
      serialNumbers: Map<String, String>.from(json['serialNumbers'] ?? {}),
      notes: json['notes'] ?? '',
    );
  }
}