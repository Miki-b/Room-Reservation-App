import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchHotelCard extends StatefulWidget {
  final String name;
  final String location;
  final int stars;
  final List<String> images;
  final VoidCallback? onTap;
  const SearchHotelCard({
    Key? key,
    required this.name,
    required this.location,
    required this.stars,
    required this.images,
    this.onTap,
  }) : super(key: key);

  @override
  State<SearchHotelCard> createState() => _SearchHotelCardState();
}

class _SearchHotelCardState extends State<SearchHotelCard> {
  bool _isPressed = false;

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(
        rating,
        (index) => Icon(Icons.star, color: Colors.amber, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainImage = widget.images.isNotEmpty ? widget.images[0] : '';
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 220,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: mainImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: mainImage,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          height: 220,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )
                    : Container(
                        color: Colors.grey[200],
                        height: 220,
                        width: double.infinity,
                        child: Icon(Icons.hotel, size: 40, color: Colors.grey),
                      ),
              ),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 64,
                right: 20,
                child: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 20,
                bottom: 44,
                right: 20,
                child: buildStars(widget.stars),
              ),
              Positioned(
                left: 20,
                bottom: 24,
                right: 20,
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
