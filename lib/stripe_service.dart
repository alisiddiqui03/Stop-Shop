// class StripeService{
//   String secretKey = "";
//   String publishKey = "";
//
//
//   static Future<dynamic> createCheckoutSession( List<dynamic> productItems,
//       totalAmount,) async{
//     final url = Uri.parse("https://api.stripe/v1/checkout/sessions");
//     String lineItems = "";
//     int index = 0;
//
//     productItems.forEach((val){
//       var productPrice = (val["productPrice"] *100).round().toString();
//       lineItems +=
//
//     });
//
//   }
//
// }