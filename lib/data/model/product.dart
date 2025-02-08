class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final int stock;

  Product(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.description,
      required this.price,
      required this.stock});

  factory Product.fromMap(Map<String, dynamic> map, String documentId) =>
      Product(
          id: documentId,
          name: map['name'],
          imageUrl: map['imageUrl'],
          description: map['description'],
          price: map['price'],
          stock: map['stock']);

  Map<String, dynamic> toMap() => {
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'price': price,
        'stock': stock,
      };
}
