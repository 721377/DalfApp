class Cart {
  final String id;
  final String codart;
  final String name;
  final String image;
  final double price;
  final double iva ;
  final String weight;
  final double weightPrezzo;
  int quantity; // Quantity field

  Cart({
    required this.id,
    required this.codart,
    required this.name,
    required this.image,
    required this.price,
    required this.iva,
    required this.weight,
    required this.weightPrezzo,
    this.quantity = 1, // Default quantity is 1
  });

  // Convert Cart object to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codart':codart,
      'name': name,
      'image': image,
      'price': price,
      'iva': iva,
      'weight': weight,
      'weightPrezzo' : weightPrezzo,
      'quantity': quantity,
    };
  }

  // Create a Cart object from JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      codart: json['codart'],
      name: json['name'],
      image: json['image'], // Added missing field
      price: (json['price'] as num).toDouble(), 
      iva: (json['iva'] as num).toDouble(),// Ensures price is double
      weight: json['weight'],
      weightPrezzo:json['weightPrezzo'],// Added missing field
      quantity: json['quantity'] ?? 1, // Default to 1 if missing
    );
  }
}
