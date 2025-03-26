import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dalfapp/settings/settings.dart';
import 'package:http/http.dart' as http;

class NexiPaymentService {
  static const String apiUrl = "https://int-ecommerce.nexi.it/ecomm/api/paga/autenticazione3DS"; // Nexi Test API URL
  
  static Future<String?> processPayment({
    required String cardNumber,
    required String expiryDate, // Format MMYY
    required String cvv,
    required double amount,
  }) async {
    // Nexi Credentials
    String key = Settings.secretKey;
    String currency = "EUR";
    String transactionId = "LIVEPS_${DateTime.now().millisecondsSinceEpoch}";

    // Prepare Request Data
    Map<String, String> requestBody = {
      "alias": Settings.alias,
      "importo": (amount * 100).toInt().toString(), // Convert to cents
      "divisa": currency,
      "numero": cardNumber,
      "scadenza": expiryDate, // MMYY format
      "cvv": cvv,
      "codTrans": transactionId,
    };

    // Generate MAC (Security Hash)
    String macString =
        "codTrans=$transactionId" +
        "divisa=$currency" +
        "importo=${requestBody['importo']}" +
        key;
    requestBody["mac"] = sha1.convert(utf8.encode(macString)).toString();

    // Send POST Request to Nexi
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    // Handle Response
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse["esito"] == "OK") {
        return "Payment successful!";
      } else {
        return "Payment failed: ${jsonResponse["errore"]}";
      }
    } else {
      return "Error processing payment.";
    }
  }
}
