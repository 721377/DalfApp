class Cart {
  final String id;
  final String name;
  final String image;
  final double price;
  final double iva ;
  final String weight;
  int quantity; // Quantity field

  Cart({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.iva,
    required this.weight,
    this.quantity = 1, // Default quantity is 1
  });

  // Convert Cart object to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'iva': iva,
      'weight': weight,
      'quantity': quantity,
    };
  }

  // Create a Cart object from JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      name: json['name'],
      image: json['image'], // Added missing field
      price: (json['price'] as num).toDouble(), 
      iva: (json['iva'] as num).toDouble(),// Ensures price is double
      weight: json['weight'], // Added missing field
      quantity: json['quantity'] ?? 1, // Default to 1 if missing
    );
  }
}
