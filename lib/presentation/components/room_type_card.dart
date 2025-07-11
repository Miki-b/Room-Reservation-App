import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/room_type_model.dart';

class RoomTypeCard extends StatelessWidget {
  final RoomType room;
  final VoidCallback? onTap;
  final void Function(RoomType)? onAdd;
  const RoomTypeCard({Key? key, required this.room, this.onTap, this.onAdd})
      : super(key: key);

  // Example amenity icon mapping (customize as needed)
  IconData? _amenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case '24-hour reception':
        return Icons.access_time;
      case 'swimming pool':
        return Icons.pool;
      case 'breakfast offered':
        return Icons.free_breakfast;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (room.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: room.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              if (room.image.isNotEmpty) SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(room.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 8),
                    Text('Price: ETB ${room.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: room.amenityIds
                          .map((a) => Icon(_amenityIcon(a),
                              size: 20,
                              color: Theme.of(context).colorScheme.secondary))
                          .toList(),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add,
                    size: 24, color: Theme.of(context).colorScheme.secondary),
                onPressed: onAdd != null ? () => onAdd!(room) : null,
                tooltip: 'Add to booking',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
