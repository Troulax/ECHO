import 'package:url_launcher/url_launcher.dart';

class DirectionsService {
  Future<void> openDirections(double lat, double lng) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
