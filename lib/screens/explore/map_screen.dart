import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';

class MapScreen extends StatefulWidget {
  final String tourTitle;
  final List<Map<String, dynamic>> places;

  const MapScreen({super.key, required this.tourTitle, required this.places});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  int _selectedIndex = 0;

  LatLng _getLatLng(Map<String, dynamic> place) {
    final lat = place['latitude'] ?? 30.0444;
    final lng = place['longitude'] ?? 31.2357;
    return LatLng(
      double.tryParse(lat.toString()) ?? 30.0444,
      double.tryParse(lng.toString()) ?? 31.2357,
    );
  }

  void _selectPlace(int index) {
    setState(() => _selectedIndex = index);
    _mapController.move(_getLatLng(widget.places[index]), 13);
  }

  @override
  Widget build(BuildContext context) {
    // لو مفيش places هنعمل demo places في القاهرة
    final places = widget.places.isNotEmpty
        ? widget.places
        : [
            {
              'name': 'The Great Pyramids',
              'desc': 'Giza Plateau',
              'latitude': 29.9792,
              'longitude': 31.1342,
            },
            {
              'name': 'Egyptian Museum',
              'desc': 'Tahrir Square',
              'latitude': 30.0478,
              'longitude': 31.2336,
            },
            {
              'name': 'Khan El Khalili',
              'desc': 'Islamic Cairo',
              'latitude': 30.0478,
              'longitude': 31.2619,
            },
          ];

    final points = places.map((p) => _getLatLng(p)).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tour Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.tourTitle,
              style: const TextStyle(color: AppColors.gold, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Map Section ──────────────────────────────
          Container(
            height: 480,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: points.isNotEmpty
                      ? points[_selectedIndex]
                      : const LatLng(30.0444, 31.2357),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.amin_gide',
                  ),
                  // خط يربط الأماكن
                  if (points.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: AppColors.gold.withOpacity(0.5),
                          strokeWidth: 2.5,
                        ),
                      ],
                    ),
                  // Markers
                  MarkerLayer(
                    markers: List.generate(places.length, (i) {
                      final isSelected = _selectedIndex == i;
                      return Marker(
                        point: _getLatLng(places[i]),
                        width: isSelected ? 48 : 36,
                        height: isSelected ? 48 : 36,
                        child: GestureDetector(
                          onTap: () => _selectPlace(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.location_on,
                              color: isSelected
                                  ? AppColors.gold
                                  : Colors.white54,
                              size: isSelected ? 48 : 36,
                              shadows: [
                                Shadow(
                                  color: AppColors.gold.withOpacity(
                                    isSelected ? 0.6 : 0.2,
                                  ),
                                  blurRadius: isSelected ? 12 : 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Places Count ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.gold, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${places.length} Places Included',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Places List ──────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: places.length,
              itemBuilder: (context, i) {
                final place = places[i];
                final isSelected = _selectedIndex == i;
                return GestureDetector(
                  onTap: () => _selectPlace(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withOpacity(0.1)
                          : const Color(0xFF1E1A16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold.withOpacity(0.5)
                            : Colors.white10,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // رقم المكان
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.gold.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // اسم ووصف المكان
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place['name']?.toString() ?? '',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.gold
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if ((place['desc'] ?? place['description'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  (place['desc'] ?? place['description'] ?? '')
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // أيقونة
                        Icon(
                          isSelected
                              ? Icons.location_on
                              : Icons.location_on_outlined,
                          color: isSelected ? AppColors.gold : Colors.white24,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    
  }
  
  
}
