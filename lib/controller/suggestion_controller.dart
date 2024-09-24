import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuggestionsController extends GetxController {
  var suggestions = <String>[].obs;
  var isLoading = false.obs;

  Timer? _debounce; // Declare a Timer to use for debouncing

  // Method to fetch suggestions based on each word in the complaint with loading indicator
  Future<void> fetchSuggestions(String complaint) async {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel(); // Cancel the previous timer if still running
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (complaint.isEmpty) {
        clearSuggestions(); // Clear suggestions if complaint is empty
        return;
      }

      final List<String> words =
          complaint.split(' '); // Split complaint into words
      final List<String> allSuggestions = []; // Store all suggestions

      isLoading.value = true; // Show CircularProgressIndicator

      try {
        for (String word in words) {
          if (word.isNotEmpty) {
            final url = Uri.parse(
                'http://test.ankusamlogistics.com/doc_reception_api/doctor/get_suggestions.php');

            final response = await http.post(url, body: {'complaint': word});

            if (response.statusCode == 200) {
              final jsonResponse = json.decode(response.body);
              if (jsonResponse['status'] == true) {
                // Add suggestions from the current word to the overall list
                allSuggestions
                    .addAll(List<String>.from(jsonResponse['suggestions']));
              } else {
                Get.snackbar('Error', jsonResponse['message']);
              }
            } else {
              Get.snackbar('Error', 'Failed to load suggestions');
            }
          }
        }

        // Remove duplicate suggestions if any
        suggestions.value = allSuggestions.toSet().toList();
      } catch (e) {
        Get.snackbar('Error', 'An error occurred: $e');
      } finally {
        isLoading.value =
            false; // Hide CircularProgressIndicator after data is fetched
      }
    });
  }

  // Clear suggestions
  void clearSuggestions() {
    suggestions.clear();
  }
}
