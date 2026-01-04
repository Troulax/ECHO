class Shelter {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;

  const Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory Shelter.fromJson(Map<String, dynamic> j) => Shelter(
        id: j["id"].toString(),
        name: j["name"].toString(),
        address: j["address"].toString(),
        lat: double.parse(j["lat"].toString()),
        lng: double.parse(j["lng"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "lat": lat,
        "lng": lng,
      };
}

class ShelterWithDistance {
  final Shelter shelter;
  final double km;

  const ShelterWithDistance(this.shelter, this.km);
}
