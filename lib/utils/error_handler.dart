import 'package:flutter/material.dart';

class EdgeXErrorHandler {
  static String getErrorMessage(dynamic error) {
    String msg = error.toString();
    
    if (msg.contains('409')) {
      if (msg.contains('deviceprofile')) {
        return 'Conflict (409): Cannot delete profile. It is likely still in use by one or more devices.';
      }
      if (msg.contains('interval')) {
        return 'Conflict (409): Cannot delete interval. It is likely still referenced by an interval action.';
      }
      return 'Conflict (409): This resource is currently in use by another entity.';
    }
    
    if (msg.contains('404')) {
      return 'Not Found (404): The requested resource or service could not be found. Check if the EdgeX service is running.';
    }
    
    if (msg.contains('Connection refused') || msg.contains('errno = 111')) {
      return 'Connection Error: Could not connect to EdgeX. Ensure services are running on localhost.';
    }

    // Strip "Exception: " prefix if present
    return msg.replaceFirst('Exception: ', '');
  }

  static void showSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
