import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/trip.dart';

  void showTripMap(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            children: [
              AppBar(
                title: Text('Trip Map - ${trip.id}'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(
                      25.2048,
                      55.2708,
                    ), // Dubai depot
                    initialZoom: 11.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.deliverydispatcher.app',
                    ),
                    MarkerLayer(
                      markers: [
                        // Depot marker
                        Marker(
                          point: const LatLng(25.2048, 55.2708),
                          width: 32,
                          height: 32,
                          child: const Icon(
                            Icons.home,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        // Stop markers
                        ...trip.stops.asMap().entries.map((entry) {
                          final index = entry.key;
                          final stop = entry.value;
                          Color color = Colors.red;
                          switch (stop.status) {
                            case DeliveryStatus.completed:
                              color = Colors.green;
                              break;
                            case DeliveryStatus.inTransit:
                              color = Colors.orange;
                              break;
                            case DeliveryStatus.failed:
                              color = Colors.red;
                              break;
                            case DeliveryStatus.pending:
                              color = Colors.grey;
                              break;
                          }

                          return Marker(
                            point: LatLng(
                              stop.location.latitude,
                              stop.location.longitude,
                            ),
                            width: 28,
                            height: 28,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
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
