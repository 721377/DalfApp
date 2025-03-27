import 'dart:convert';
import 'package:dalfapp/pages/ProductAll.dart';
import 'package:dalfapp/providers/cart_provider.dart';
import 'package:dalfapp/widgets/Categories.dart';
import 'package:flutter/material.dart';
import 'package:dalfapp/widgets/HomeAppBar.dart';
import 'package:dalfapp/pages/ProductDetail.dart';
import 'package:dalfapp/widgets/BannerSlider.dart'; // Ensure this import is correct
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart';
import 'package:cached_network_image/cached_network_image.dart';// Import for SystemChrome

class HomePage extends StatefulWidget {
  final Function(String? category) onCategorySelected;

  HomePage({required this.onCategorySelected});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int selectedCategoryIndex = 0;

  List<String> bannerImages = [
    "images/Dalf_carne/banner1.jpg",
    "images/Dalf_carne/banner3.png"
  ];

  // Simulate loading state
  bool _isLoading = true;

  List<Map<String, dynamic>> products = [];
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    fetchData(); // Fetch data when the widget is first created

    // Set the system navigation bar color to black
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    super.dispose();
  }

  // Listen for app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Fetch data when the app resumes
      fetchData();
    }
  }

  // Fetch products and categories from the API
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true; // Show loading state
    });

    try {
      await fetchProducts();
      await fetchCategories();
    } catch (error) {
      print('Error fetching data: $error');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to load data. Please check your internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading state
      });
    }
  }

  // Fetch products from the API
  Future<void> fetchProducts() async {
    try {
      final response = await http.post(
        Uri.parse(Settings.getProduct),
        headers: {
          "Content-Type": "application/json",
          "X-API-TOKEN":
              Settings.apiToken, // Include the API token in the headers
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
            "codart":product['cod'].toString(),
            "name": product["des"] ?? "No Name",
            "price": double.tryParse(product["prezzo"]?.toString() ?? "0.00")
                    ?.toStringAsFixed(2) ??
                "0.00",
            "iva": double.tryParse(product["iva"]?.toString() ?? "0.00")
                    ?.toStringAsFixed(2) ??
                "0.00",
            "desLong": product["des_long"]?.toString() ?? "",
            "image": product["images"] ?? "no_image.jpg",
            "category": product["catdescrizione"] ?? "Unknown",
          });
        }
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.updateCartItems(fetchedProducts);
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

  // Fetch categories from the API
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
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load categories. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >
        600; // Check if the app is running on web

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 130), // Add 30px space below the HomeAppBar
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Search Bar (Redirect to ProductsPage with search query)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  onSubmitted: (searchQuery) {
                                    // Navigate to ProductsPage with search query
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductsPage(
                                          searchQuery: searchQuery,
                                          selectedCategoryIndex:
                                              selectedCategoryIndex, // Pass the selected category index
                                        ),
                                      ),
                                    );
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

                        // Categories Section
                        CategoryDisplay(
                          categories: categories,
                          onCategorySelected: (category) {
                            // Handle category selection
                            widget.onCategorySelected(category);
                            print("Selected Category: $category");
                          },
                        ),

                        SizedBox(height: 22),

                        // 📌 Banner Holder with White Background
                        BannerSlider(bannerImages: bannerImages),

                        SizedBox(height: 18),

                        // 🛒 Popular Products Section
                        _isLoading
                            ? _buildShimmerProductSection(
                                "Prodotti popolari", isWeb)
                            : productSection(
                                "Prodotti popolari", products, isWeb),

                        SizedBox(height: 24),

                        // 🥩 Lamb Products Section
                        _isLoading
                            ? _buildShimmerProductSection("Maiale", isWeb)
                            : productSection("Maiale", products, isWeb),

                        SizedBox(height: 104),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed HomeAppBar at the top with safe area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: 
               HomeAppBar(),
            
          ),
        ],
      ),
    );
  }

  // Widget for Product Section
  Widget productSection(
      String title, List<Map<String, dynamic>> productList, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF060505),
            ),
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Display only the first 4 products
              ...List.generate(
                productList.length > 4 ? 4 : productList.length,
                (index) => GestureDetector(
                  onTap: () {
                    // Navigate to the product detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          product:
                              productList[index], // Pass the selected product
                        ),
                      ),
                    );
                  },
                  child: productBox(productList[index], isWeb),
                ),
              ),
              // Add "Vedi Tutti" button if there are more than 4 products
              if (productList.length > 4)
                GestureDetector(
                  onTap: () {
                    // Navigate to the ProductsPage with the category or search query
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: 120,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(28, 0, 0, 0),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Vedi Tutti",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C304C),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Shimmer Effect for Product Section
  Widget _buildShimmerProductSection(String title, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 25,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              3,
              (index) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  width: isWeb ? 300 : 220, // Adjust width for web
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 190,
                        width: isWeb ? 280 : 210, // Adjust width for web
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget for Product Box
  // Widget for Product Box
  Widget productBox(Map<String, dynamic> product, bool isWeb) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 10, vertical: 15), // Added vertical margin
      padding: EdgeInsets.all(18), // Increased padding
      width: isWeb ? 300 : 220, // Adjust width for web
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(17, 0, 0, 0),
            blurRadius: 10, // Increased blur radius
            spreadRadius: 2, // Added spread radius
            offset: Offset(0, 5), // Adjusted offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🖼 Product Image with Shimmer Loading
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: product["image"],
              height: 190,
              width: isWeb ? 280 : 210, // Adjust width for web
              fit: BoxFit.contain,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 190,
                  width: isWeb ? 280 : 210, // Adjust width for web
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          SizedBox(height: 8),
          // 📌 Product Name
          Container(
            height: 40,
            child: Text(
              product["name"],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 10),

          // 💰 Price in Euro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "€${product["price"]}/Kg", // Price in Euro
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF060505)),
              ),
              Container(
                height: 35, // Increased size for add button
                width: 35, // Increased size for add button
                decoration: BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle),
                child: Center(
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
