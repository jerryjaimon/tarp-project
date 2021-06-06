import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';
import 'package:intl/intl.dart';

class addNewWasteBag extends StatefulWidget {
  const addNewWasteBag({Key key}) : super(key: key);

  @override
  _addNewWasteBagState createState() => _addNewWasteBagState();
}

class _addNewWasteBagState extends State<addNewWasteBag> {
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
  TextEditingController _weight = TextEditingController();
  TextEditingController _type = TextEditingController();
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

  Future<void> addingNewWasteBag(
      BigInt weight, String type, String date) async {
    funcstate = "Added New Bag";
    var response = await submit("addingNewWasteBag", [weight, type, date]);
    return response;
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
                        'Add new waste bag',
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
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _weight,
                    decoration: InputDecoration(
                      hintText: 'Weight',
                      filled: true,
                      isDense: true,
                    ),
                    autocorrect: false,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller: _type,
                    decoration: InputDecoration(
                      hintText: 'Type',
                      filled: true,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.amber)),
                      child: Text('Add new bag'),
                      onPressed: () {
                        String now = DateFormat("yyyy-MM-dd hh:mm:ss")
                            .format(DateTime.now());
                        print(now);
                        addingNewWasteBag(
                            BigInt.parse(_weight.text), _type.text, now);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${funcstate}'),
                            duration: const Duration(milliseconds: 1500),
                            width: 280.0, // Width of the SnackBar.
                            padding: const EdgeInsets.symmetric(
                              horizontal:
                                  8.0, // Inner padding for SnackBar content.
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
