String idColumn = "idColumn";
String nameColumn = "nameColumn";
String emailColumn = "emailColumn";
String phoneColumn = "phoneColumn";
String imgColumn = "imgColumn";
String contactTable = "contactTable";
String cepColumn = "cepColumn";
String streetColumn = "streetColumn";
String numberColumn = "numberColumn";
String complementColumn = "complementColumn";
String neighborhoodColumn = "neighborhoodColumn";
String cityColumn = "cityColumn";
String stateColumn = "stateColumn";

class Contact {
  Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.img,
    this.cep,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
  });

  int? id;
  String name;
  String email;
  String phone;
  String? img;
  String? cep, street, number, complement, neighborhood, city, state;

  Contact.fromMap(Map<String, dynamic> map)
    : id = map[idColumn],
    name = map[nameColumn],
    email = map[emailColumn],
    phone = map[phoneColumn],
    img = map[imgColumn],
    cep = map[cepColumn],
    street = map[streetColumn],
    number = map[numberColumn],
    complement = map[complementColumn],
    neighborhood = map[neighborhoodColumn],
    city = map[cityColumn],
    state = map[stateColumn];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
      cepColumn: cep,
      streetColumn: street,
      numberColumn: number,
      complementColumn: complement,
      neighborhoodColumn: neighborhood,
      cityColumn: city,
      stateColumn: state,
    };
    if(id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  String get fullAddress {
    String clean(String? s) => (s ?? "").trim();
    final streetNumber = [clean(street), clean(number)]
        .where((s) => s.isNotEmpty).join(", ");
    final cityState = [clean(city), clean(state)]
        .where((s) => s.isNotEmpty).join("/");
    return [streetNumber, clean(complement), clean(neighborhood), cityState]
        .where((s) => s.isNotEmpty).join(" - ");
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name,)"
    "email: $email, phone: $phone, img: $img";
  }
}