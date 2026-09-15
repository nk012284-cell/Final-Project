import 'package:flutter/material.dart';
import 'package:mobil_app_project/models/property_model.dart';

class PropertyImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final BorderRadius borderRadius;

  const PropertyImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      'assets/images/final.png',
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
    final image = imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback,
          )
        : Image.asset(
            imageUrl,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback,
          );

    return ClipRRect(borderRadius: borderRadius, child: image);
  }
}

class PropertyListCard extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;

  const PropertyListCard({
    super.key,
    required this.property,
    this.onFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = property.imageUrls.isEmpty
        ? 'assets/images/final.png'
        : property.imageUrls.first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: PropertyImage(imageUrl: image, height: 86),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${property.currency} ${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF138048),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${property.beds} Beds  |  ${property.baths} Baths',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                property.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: property.isFavorite ? Colors.red : Colors.grey,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertyGridCard extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;

  const PropertyGridCard({
    super.key,
    required this.property,
    this.onFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = property.imageUrls.isEmpty
        ? 'assets/images/final.png'
        : property.imageUrls.first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PropertyImage(imageUrl: image, height: 118),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onFavorite,
                      icon: Icon(
                        property.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: property.isFavorite ? Colors.red : Colors.grey,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${property.currency} ${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF138048),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
