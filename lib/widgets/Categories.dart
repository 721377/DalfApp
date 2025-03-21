import 'package:flutter/material.dart';

class Category {
  final String id;
  final String description;
  final String parentId;
  final List<Category> children;
  final bool isNew; // Flag to indicate if the category is new

  Category({
    required this.id,
    required this.description,
    required this.parentId,
    required this.children,
    this.isNew = false, // Default to false
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      description: json['descrizione'] ?? '',
      parentId: json['id_parent'].toString(),
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => Category.fromJson(child))
              .toList() ??
          [],
      isNew: json['isNew'] ?? false, // Set isNew from JSON if available
    );
  }
}


class CategoryDisplay extends StatefulWidget {
  final List<Category> categories;
  final Function(String? category) onCategorySelected;

  const CategoryDisplay({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _CategoryDisplayState createState() => _CategoryDisplayState();
}

class _CategoryDisplayState extends State<CategoryDisplay> {
  int selectedParentIndex = -1; // Track selected parent category
  int selectedChildIndex = -1; // Track selected child category

  Map<String, String> categoryIcons = {
    "Bovino Adulto": "images/Dalf_carne/icone-dalf-02.png",
    "Suino": "images/Dalf_carne/icone-dalf-01.png",
    "Avicoli e Avicunicoli": "images/Dalf_carne/icone-dalf-03.png",
    // Add more icons as needed
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Ensure proper alignment
      children: [
        // Categories Section
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          height: 60,
          child: Text(
            "Categorie",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF060505),
            ),
          ),
        ),

        // Horizontal Parent Categories with Icons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.categories.length, (index) {
              final category = widget.categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedParentIndex = index; // Update selected parent category
                    selectedChildIndex = -1; // Reset child selection
                  });
                  widget.onCategorySelected(category.description); // Pass parent category
                },
                child: Container(
                  margin: EdgeInsets.only(left: 15, right: 5, bottom: 10), // Added bottom margin
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  decoration: BoxDecoration(
                    color: selectedParentIndex == index ? Color(0xFF1C304C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: selectedParentIndex == index ? Colors.white : const Color.fromARGB(19, 0, 0, 0),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (categoryIcons.containsKey(category.description))
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              selectedParentIndex == index ? Colors.white : Colors.black,
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              categoryIcons[category.description]!,
                              width: 25,
                              height: 25,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedParentIndex == index ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        // Display Children of Selected Parent Category
        if (selectedParentIndex != -1 && widget.categories[selectedParentIndex].children.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    widget.categories[selectedParentIndex].children.length,
                    (childIndex) {
                      final childCategory = widget.categories[selectedParentIndex].children[childIndex];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedChildIndex = childIndex; // Update selected child category
                          });
                          widget.onCategorySelected(childCategory.description); // Pass child category
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 13, bottom: 10),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedChildIndex == childIndex
                                ? Color.fromARGB(255, 236, 236, 236)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: selectedChildIndex == childIndex ? Colors.white : const Color.fromARGB(19, 0, 0, 0),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            childCategory.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
