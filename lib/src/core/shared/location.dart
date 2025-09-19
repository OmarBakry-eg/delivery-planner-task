class Location {
  final double latitude;
  final double longitude;

  const Location(this.latitude, this.longitude);

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    (json['lat'] as num).toDouble(),
    (json['lon'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'lat': latitude, 'lon': longitude};

  @override
  String toString() => 'Location($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
