import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerSlider extends StatefulWidget {
  final List<String> bannerImages;

  BannerSlider({required this.bannerImages});

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel Slider
        Container(
          margin: EdgeInsets.symmetric(horizontal: 0), // Reduced padding
          height: 220, // Slightly increased height for better visibility
          child: CarouselSlider.builder(
            itemCount: widget.bannerImages.length,
            itemBuilder: (context, index, realIndex) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4), // Small gap for better preview
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    widget.bannerImages[index],
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.92, // Wider images
                    height: 220,
                  ),
                ),
              );
            },
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 6),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              enlargeCenterPage: true,
              viewportFraction: 0.92, // Slightly larger image with small previews
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),

        // Dot Indicator
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.bannerImages.length,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentIndex == index ? 14 : 8, // Larger active dot
              decoration: BoxDecoration(
                color: _currentIndex == index ? Color(0xFFE3051B) : const Color.fromARGB(255, 206, 206, 206),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
