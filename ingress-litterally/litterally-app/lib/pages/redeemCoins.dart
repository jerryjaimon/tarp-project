import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';

class redeemCoin extends StatefulWidget {
  const redeemCoin({Key key}) : super(key: key);

  @override
  _redeemCoinState createState() => _redeemCoinState();
}

class _redeemCoinState extends State<redeemCoin> {
  BigInt littycoin;
  Client httpClient;
  Web3Client ethClient;
  List<dynamic> allWasteBags = List();
  int wasteBagLength = 0;
  final myAddress = "0x434A5bB1Ba4051bf9D550186234C2891e9A18Db4";
  String contractAddress = "0x080E159b4D104a60ef22c10FB0cd4b87dE1a4F07";
  String myPrivateKey =
      '76808404181e10b15e36b3d483cd81702c443b771746160765324af351edd6dd';
  String url = "HTTP://127.0.0.1:8545";
  TextEditingController _status = TextEditingController();
  TextEditingController _amount = TextEditingController();
  List<String> status = List();
  String funcstate = "Error";

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(url, httpClient);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('abi.json');
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "Wastemanagement"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(myPrivateKey);
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args));
  }

  Future<void> redeem(BigInt amt) async {
    print("working");
    funcstate = "Item bought!";
    var response = await submit("withdrawBalance", [amt]);
    return response;
  }

  int calculateValue(String str, int kg) {
    int value;
    if (str.toLowerCase() == 'glass') {
      value = 20 * kg;
    }
    if (str.toLowerCase() == 'plastic') {
      value = 10 * kg;
    }
    if (str.toLowerCase() == 'metal') {
      value = 50 * kg;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            //height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xff00F240), Color(0xff067C0A)]),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Redeem Coins',
                        style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 4.0),
                      child: Card(
                        color: Colors.white70,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.amber,
                            backgroundImage: AssetImage('images/glass.png'),
                          ),
                          title: Column(
                            children: [
                              Container(child: Text('Tomato Ketchup')),
                              Text('Price:10 coins'),
                              ElevatedButton(
                                  onPressed: () {
                                    redeem(BigInt.from(10));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${funcstate}'),
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        width: 280.0, // Width of the SnackBar.
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              8.0, // Inner padding for SnackBar content.
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text('Redeem'))
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
