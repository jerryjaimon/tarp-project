import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';

class viewMyWasteBags extends StatefulWidget {
  const viewMyWasteBags({Key key}) : super(key: key);

  @override
  _viewMyWasteBagsState createState() => _viewMyWasteBagsState();
}

class _viewMyWasteBagsState extends State<viewMyWasteBags> {
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

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(url, httpClient);
    myWasteBags();
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

  Future<void> myWasteBags() async {
    allWasteBags.clear();
    status.clear();
    List<dynamic> myWasteBag = await query(
        "getMyWasteBagDetails", [EthereumAddress.fromHex(myAddress)]);
    int numberOfWasteBags = int.parse(myWasteBag[0][0].toString());
    List<dynamic> myBags = myWasteBag[0][1];
    var j = 0;
    for (var i = numberOfWasteBags - 1; i >= 0; i--, j++) {
      List<dynamic> request =
          await query("getWasteBagDetails", [myWasteBag[0][1][i].toString()]);
      allWasteBags.add(request);
      if (request[0][4].toString().toLowerCase() == 'true')
        status.add('true');
      else if (request[0][5].toString().toLowerCase() == 'false')
        status.add('to_be_verified');
      else if (request[0][4].toString().toLowerCase() == 'false')
        status.add('false');
    }
    wasteBagLength = numberOfWasteBags;
    setState(() {});
  }

  Future<void> authorizeRequest(bool status, BigInt amt) async {
    print("working");
    var response = await submit("authorizeRequest", [status, amt]);
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
                        'History',
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
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          myWasteBags();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Refreshed'),
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
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.amber),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Icon(Icons.refresh), Text('Refresh')]),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Container(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: wasteBagLength,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 4.0),
                                child: Card(
                                  color: Colors.white70,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.amber,
                                      backgroundImage: AssetImage(
                                          'images/${status[index]}.png'),
                                    ),
                                    title: Column(
                                      children: <Widget>[
                                        Container(
                                            child: Text(
                                          allWasteBags[index][0][3].toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              child: Text(
                                                  "Weight:${allWasteBags[index][0][1].toString()} kg"),
                                            ),
                                            Container(
                                              child: Text(
                                                  "Type:${allWasteBags[index][0][2].toString()}"),
                                            ),
                                            /*
                                            Container(
                                              child: Text(
                                                  "Date:${allWasteBags[index][0][3].toString()}"),
                                            ),
                                            Container(
                                              child: Text(
                                                  "Approved:${allWasteBags[index][0][4].toString()}"),
                                            ),
                                            Container(
                                              child: Text(
                                                  "Verified:${allWasteBags[index][0][5].toString()}"),
                                            ),*/
                                            Container(
                                              child: Text(
                                                  "Status:${allWasteBags[index][0][6].toString()}"),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
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
