import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/constant.dart';
import 'package:stripe_payment/views/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntentData;
 final String _stripeSecretKey = 'sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN';
 String? accountID;
  setAccountId(String code) async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString(keyValue, code);
  }

  Future<String> getAccountId() async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString(keyValue) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                // final paymentMethod = await Stripe.instance.createPaymentMethod(
                //     params: const PaymentMethodParams.card(
                //         paymentMethodData: PaymentMethodData()));
                await makePayment();
              },
              child: Container(
                height: 50,
                width: 200,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Pay',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                // final paymentMethod = await Stripe.instance.createPaymentMethod(
                //     params: const PaymentMethodParams.card(
                //         paymentMethodData: PaymentMethodData()));
                await subscriptions();
              },
              child: Container(
                height: 50,
                width: 200,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Subscription',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                await createExpressAccount();
              },
              child: Container(
                height: 50,
                width: 230,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Create Express Account',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                await getExpressAccount();
              },
              child: Container(
                height: 50,
                width: 230,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Get Express Account',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                await accountLinks();
              },
              child: Container(
                height: 50,
                width: 230,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Link Account',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                await transfer();
              },
              child: Container(
                height: 50,
                width: 230,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Transfer',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                await payout();
              },
              child: Container(
                height: 50,
                width: 230,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Payout',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData =
          await createPaymentIntent('20', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  setupIntentClientSecret: 'sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN',
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  //applePay: PaymentSheetApplePay.,
                  //googlePay: true,
                  //testEnv: true,
                  customFlow: true,
                  style: ThemeMode.dark,
                  // merchantCountryCode: 'US',
                  merchantDisplayName: 'Kashif'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              //       parameters: PresentPaymentSheetParameters(
              // clientSecret: paymentIntentData!['client_secret'],
              // confirmPayment: true,
              // )
              )
          .then((newValue) {
        print('payment intent${paymentIntentData!['id']}');
        print('payment intent${paymentIntentData!['client_secret']}');
        print('payment intent${paymentIntentData!['amount']}');
        print('payment intent$paymentIntentData');
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

//   Implementation of payment intent creation
// Just post the payment intents api. You need to include information about the amount to be paid in the body.

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount('20'),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

// Implementation of payment method creation
// Just post the payment method api. You need to include your credit card information in the body.

Future<Map<String, dynamic>> _createPaymentMethod(
      {required String number,
        required String expMonth,
        required String expYear,
        required String cvc}) async {
     String url = 'https://api.stripe.com/v1/payment_methods';
    var response = await http.post(
      Uri.parse(url),
      headers: {
            'Authorization': 'Bearer sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
      body: {
        'type': 'card',
        'card[number]': '$number',
        'card[exp_month]': '$expMonth',
        'card[exp_year]': '$expYear',
        'card[cvc]': '$cvc',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to create PaymentMethod.';
    }
  }

//   Implementation of payment method attach
// Just post the payment method attach api. You need to include the customer to be attached in the body.

  Future<Map<String, dynamic>> _attachPaymentMethod(String paymentMethodId, String customerId) async {
    final String url = 'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach';
    var response = await http.post(
      Uri.parse(url),
      headers: {
            'Authorization': 'Bearer sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
      body: {
        'customer': customerId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to attach PaymentMethod.';
    }
  }

//   Implementing the default payment method setting
// Just post the customers update api. You need to include payment method to be set as default in the body.

  Future<Map<String, dynamic>> _updateCustomer(
      String paymentMethodId, String customerId) async {
    final String url = 'https://api.stripe.com/v1/customers/$customerId';

    var response = await http.post(
      Uri.parse(url),
      headers: {
            'Authorization': 'Bearer sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
      body: {
        'invoice_settings[default_payment_method]': paymentMethodId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to update Customer.';
    }
  }

// Implementation of subscription registration
// Just post the subscriptions api. you need to include the customer id and the id of the pricing plan in the body. Pricing plans can be created in the stripe dashboard.
  
Future<Map<String, dynamic>> _createSubscriptions(String customerId) async {
     String url = 'https://api.stripe.com/v1/subscriptions';

    Map<String, dynamic> body = {
      'customer': customerId,
      'items[0][price]': '10',
    };

    var response =
        await http.post(Uri.parse(url), headers: {
            'Authorization': 'Bearer sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN',
            'Content-Type': 'application/x-www-form-urlencoded'
          }, body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
     // print(json.decode(response.body));
      throw 'Failed to register as a subscriber.';
    }
  }

//   Implementation of customer creation
// Just post the customers api. You can refer to the customers created here in the stripe dashboard.

  Future<Map<String, dynamic>> _createCustomer() async {
    String url = 'https://api.stripe.com/v1/customers';
    var response = await http.post(
      Uri.parse(url),
      headers: {
            'Authorization': 'Bearer sk_test_51MWauPBMN7f2KaatD7dcslVBw3YkT7Rme2n8tMcEyYVZ5XqDW3SP9D1Jwhp8HZDgfJMHcgW2DBNOCbrrOGHFrEao00nbRtoLQN',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
      body: {
        'description': 'Arslan'
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a customer.';
    }
  }

  Future<void> subscriptions() async {
    final _customer = await _createCustomer();
    final _paymentMethod = await _createPaymentMethod(number: '4242424242424242', expMonth: '03', expYear: '23', cvc: '123');
    await _attachPaymentMethod(_paymentMethod['id'], _customer['id']);
    await _updateCustomer(_paymentMethod['id'], _customer['id']);
    await _createSubscriptions(_customer['id']);
  }

  createExpressAccount() async{
    try{
    var body = {
        "type": 'express',
        "country": "US",
        "business_type": 'individual',
       // 'email': 'jenny.rosen@example.com',
       'capabilities[transfers][requested]': 'true',
  // 'capabilities': {
  //   'card_payments': {'requested': true},
  //   'transfers': {'requested': true},
  // },
       // "capabilities[transfers][requested]": 'true',

        // "capabilities[card_payments][requested]": 'false'
  };
 //var bodie = json.encode(body);
  var response = await http.post(Uri.parse('https://api.stripe.com/v1/accounts'),
  body: body,
  headers: {
    'Authorization': 'Bearer $_stripeSecretKey',
    'Content-Type': 'application/x-www-form-urlencoded'
  }
  );
  
  if (response.statusCode == 200) {
    Future.delayed(const Duration(seconds: 1),
    () {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Express account created successfully"),
              duration: Duration(seconds: 3),
            ));
    },
    );
    
  Map<String, dynamic> payoutResponse = json.decode(response.body);
  print('payout Response -> ${payoutResponse.toString()}');
  print('success Response -> ${response.body.toString()}');
  print('success ID Response -> ${payoutResponse['id'].toString()}');
  await setAccountId(payoutResponse['id'].toString());
  accountID = payoutResponse['id'].toString();
  // Handle successful payout
} else {
  print('unsuccess Response -> ${response.body.toString()}');
  // Handle unsuccessful payout
}
    }catch (e){
      print('error Response -> ${e.toString()}');
    }
}

getExpressAccount() async{
    try{
  String? accountID1 = await getAccountId();
  var response = await http.post(Uri.parse('https://api.stripe.com/v1/accounts/$accountID1'),
  headers: {
    'Authorization': 'Bearer $_stripeSecretKey',
    'Content-Type': 'application/x-www-form-urlencoded'
  }
  );
  if (response.statusCode == 200) {
    Future.delayed(
          const Duration(seconds: 1),
          () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Get the Express account created successfully"),
              duration: Duration(seconds: 3),
            ));
          },
        );
  Map<String, dynamic> payoutResponse = json.decode(response.body);
 // print('payout Response -> ${payoutResponse.toString()}');
  print('success Response -> ${response.body.toString()}');
  // Handle successful payout
} else {
  print('unsuccess Response -> ${response.body.toString()}');
  // Handle unsuccessful payout
}
    }catch (e){
      print('error Response -> ${e.toString()}');
    }
}

accountLinks() async{
    try{
      String? accountID2 = await getAccountId();
 var body = {
      "account": accountID2,
      "refresh_url": 'https://oraxtech.com/',
      "return_url": "https://api.stripe.com/",
      "type": 'account_onboarding',
    };
  var response = await http.post(Uri.parse('https://api.stripe.com/v1/account_links'),
  body: body,
  headers: {
    'Authorization': 'Bearer $_stripeSecretKey',
    'Content-Type': 'application/x-www-form-urlencoded'
  }
  );
  if (response.statusCode == 200) {
    Future.delayed(
          const Duration(seconds: 1),
          () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Express account created successfully"),
              duration: Duration(seconds: 3),
            ));
          },
        );
  Map<String, dynamic> payoutResponse = json.decode(response.body);
  Navigator.of(context).push(MaterialPageRoute(builder: (context){
    return DashBoardScreen(accountLink: payoutResponse['url'].toString());
  }));
 // print('payout Response -> ${payoutResponse.toString()}');
  print('success link Response -> ${response.body.toString()}');
  // Handle successful payout
} else {
  print('unsuccess link Response -> ${response.body.toString()}');
  // Handle unsuccessful payout
}
    }catch (e){
      print('error link Response -> ${e.toString()}');
    }
}

transfer()async{
  try{
  //  await capabilities();
  String? accountID3 = await getAccountId();
 var body = {
      "amount": '20',
      "currency": 'usd',
      "destination": accountID3,
    };
  var response = await http.post(Uri.parse('https://api.stripe.com/v1/transfers'),
  body: body,
  headers: {
    'Authorization': 'Bearer $_stripeSecretKey',
    'Content-Type': 'application/x-www-form-urlencoded',
  }
  );
  if (response.statusCode == 200) {
    Future.delayed(
          const Duration(seconds: 1),
          () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Transfer done successfully"),
              duration: Duration(seconds: 3),
            ));
          },
        );
  Map<String, dynamic> payoutResponse = json.decode(response.body);
 // print('payout Response -> ${payoutResponse.toString()}');
  print('success transfer Response -> ${response.body.toString()}');
  // Handle successful payout
} else {
  print('unsuccess transfer Response -> ${response.body.toString()}');
  // Handle unsuccessful payout
}
    }catch (e){
      print('error transfer Response -> ${e.toString()}');
    }
}

payout() async{
  try{
    String? accountID4 = await getAccountId();
 var body = {
      "amount": '20',
      "currency": 'usd',
      //"destination": accountID
    };
  var response = await http.post(Uri.parse('https://api.stripe.com/v1/payouts'),
  body: body,
  headers: {
    'Authorization': 'Bearer $_stripeSecretKey',
    'Content-Type': 'application/x-www-form-urlencoded',
    "Stripe-Account": accountID4
  }
  );
  if (response.statusCode == 200) {
  Map<String, dynamic> payoutResponse = json.decode(response.body);
  Future.delayed(
          const Duration(seconds: 1),
          () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payout successfully"),
              duration: Duration(seconds: 3),
            ));
          },
        );
 // print('payout Response -> ${payoutResponse.toString()}');
  print('success payout Response -> ${response.body.toString()}');
  // Handle successful payout
} else {
  print('unsuccess payout Response -> ${response.body.toString()}');
  // Handle unsuccessful payout
}
    }catch (e){
      print('error payout Response -> ${e.toString()}');
    }
}
}