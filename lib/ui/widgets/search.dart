import 'package:cyclista/main.dart';
import 'package:mapbox_api/mapbox_api.dart';

void searchMapbox() async {
  const kApiKey = MyApp.ACCESS_TOKEN;

  final mapbox = MapboxApi(
    accessToken: kApiKey,
  );

  final response = await mapbox.forwardGeocoding.request(
    searchText: 'st agustine academy',
    fuzzyMatch: true,
    language: 'en',
    country: ['ph'],
    limit: 10,
  );

  if (response.error != null) {
    if (response.error is GeocoderError) {
      print('GeocoderError: ${(response.error as GeocoderError).message}');
      return;
    }

    print('Network error');
    return;
  }

  if (response.features != null && response.features.isNotEmpty) {
    for (final feature in response.features) {
      print(feature.placeName);
    }
  }
}
