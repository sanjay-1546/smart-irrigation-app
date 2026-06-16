class Farm {
  final String id;
  final String name;
  final String location;
  final double sizeAcres;
  final String ownerName;

  const Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.sizeAcres,
    required this.ownerName,
  });

  Farm copyWith({String? name, String? location, double? sizeAcres, String? ownerName}) {
    return Farm(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      sizeAcres: sizeAcres ?? this.sizeAcres,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}
