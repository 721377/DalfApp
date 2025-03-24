import 'dart:convert';
import 'package:dalfapp/pages/Mainscreen.dart';
import 'package:dalfapp/settings/settings.dart';
import 'package:dalfapp/widgets/Categories.dart';
import 'package:flutter/material.dart';
import 'package:dalfapp/pages/ProductDetail.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'HomePage.dart';

class ProductsPage extends StatefulWidget {
  final String? category; // Selected category ID
  final String searchQuery; // Search query
  final int? selectedCategoryIndex; // Selected category index

  ProductsPage({
    this.category,
    this.searchQuery = "",
    this.selectedCategoryIndex,
  });

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _searchQuery = "";
  List<Map<String, dynamic>> products = [];
  List<Category> categories = [];
  int selectedCategoryIndex = 0; // Default to "All Categories"
  String? selectedCategory; // Track selected category (parent or child)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery;
    selectedCategory = widget.category; // Initialize with the passed category
    if (widget.selectedCategoryIndex != null) {
      selectedCategoryIndex = widget.selectedCategoryIndex!;
    }
    fetchData(); // Fetch products and categories
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await fetchProducts();
      await fetchCategories();
    } catch (error) {
      print('Error fetching data: $error');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data. Please check your internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.post(
        Uri.parse(Settings.getProduct),
        headers: {
          "Content-Type": "application/json",
          "X-API-TOKEN": Settings.apiToken,
        },
      );

      print('Products API Response: ${response.statusCode}');
      print('Products API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> fetchedProducts = [];

        for (var product in data) {
          fetchedProducts.add({
            "id": product["id"].toString(),
            "name": product["des"] ?? "No Name",
            "price": double.tryParse(product["prezzo"]?.toString() ?? "0.00")?.toStringAsFixed(2) ?? "0.00",
            "iva": double.tryParse(product["iva"]?.toString() ?? "0.00")?.toStringAsFixed(2) ?? "0.00",
            "desLong": product["des_long"]?.toString() ?? "",
            "image": product["images"] ?? "no_image.jpg",
            "category": product["catdescrizione"] ?? "Unknown",
          });
        }

        setState(() {
          products = fetchedProducts;
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load products. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse(Settings.categories),
        headers: {
          "Content-Type": "application/json",
          "X-API-TOKEN": Settings.apiToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((item) => Category.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load categories. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCategorySelected(int index, String? category) {
    setState(() {
      selectedCategoryIndex = index;
      selectedCategory = category;
    });
  }

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      // If no category is selected, show all products
      final matchesCategory = selectedCategory == null || product["category"].contains(selectedCategory);
      final matchesSearch = product["name"].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600; // Check if the app is running on web

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 28),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                    Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              (route) => false, // Clears the navigation stack
            );
// Simply pop the current route
                    },
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 248, 248, 248),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Color.fromARGB(255, 225, 225, 225)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.046),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: const Color.fromARGB(255, 158, 158, 158)),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onSubmitted: (searchQuery) {
                                setState(() {
                                  _searchQuery = searchQuery;
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Cerca Carne...",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories Section (Fixed at the top)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              color: Colors.white,
              child: _isLoading
                  ? _buildShimmerCategories()
                  : CategoryDisplay(
                      categories: categories,
                      onCategorySelected: (category) {
                        setState(() {
                          selectedCategory = category; // Update selected category
                        });
                      },
                    ),
            ),

            // Space between categories and products
            SizedBox(height: 10),

            // Products Section (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: _isLoading
                      ? _buildShimmerProducts(isWeb)
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWeb ? 4 : 2, // Adjust grid columns for web
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: isWeb ? 0.8 : 0.7, // Adjust aspect ratio for web
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                              child: productBox(product, isWeb),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCategories() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            6,
            (index) => Container(
              margin: EdgeInsets.only(left: 15),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProducts(bool isWeb) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling
      padding: EdgeInsets.symmetric(horizontal: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWeb ? 4 : 2, // Adjust grid columns for web
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: isWeb ? 0.8 : 0.7, // Adjust aspect ratio for web
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isWeb ? 180 : 140, // Adjust height for web
                  width: double.infinity,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 120,
                  color: Colors.white,
                ),
                SizedBox(height: 6),
                Container(
                  height: 14,
                  width: 80,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget productBox(Map<String, dynamic> product, bool isWeb) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10, // Increased blur radius
            spreadRadius: 2, // Added spread radius
            offset: Offset(0, 5), // Adjusted offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: product["image"],
              height: isWeb ? 180 : 140, // Adjust height for web
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: isWeb ? 180 : 140, // Adjust height for web
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),

          // Product Name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              product["name"],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

          // Price and Add Icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "€${product["price"]}/Kg",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}