import 'package:flutter/material.dart';

class SearchFilterDrawer extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final List<String> amenities;
  final Set<String> selectedAmenities;
  final ValueChanged<String?> onCitySelected;
  final ValueChanged<String> onAmenityToggled;
  final VoidCallback onClear;
  const SearchFilterDrawer({
    Key? key,
    required this.cities,
    required this.selectedCity,
    required this.amenities,
    required this.selectedAmenities,
    required this.onCitySelected,
    required this.onAmenityToggled,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: onClear, child: Text('Clear')),
              ],
            ),
            SizedBox(height: 16),
            Text('City', style: Theme.of(context).textTheme.bodyLarge),
            DropdownButton<String>(
              value: selectedCity,
              hint: Text('Select City'),
              isExpanded: true,
              items: cities
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
              onChanged: onCitySelected,
            ),
            SizedBox(height: 16),
            Text('Amenities', style: Theme.of(context).textTheme.bodyLarge),
            Wrap(
              spacing: 8,
              children: amenities
                  .map((amenity) => FilterChip(
                        label: Text(amenity),
                        selected: selectedAmenities.contains(amenity),
                        onSelected: (_) => onAmenityToggled(amenity),
                      ))
                  .toList(),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
