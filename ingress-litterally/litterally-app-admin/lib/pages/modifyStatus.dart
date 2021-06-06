import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';

class modifyState extends StatefulWidget {
  const modifyState({Key key}) : super(key: key);

  @override
  _modifyStateState createState() => _modifyStateState();
}

class _modifyStateState extends State<modifyState> {
  BigInt littycoin;
  Client httpClient;
  Web3Client ethClient;
  List<dynamic> allWasteBags = List();
  int wasteBagLength = 0;
  final myAddress = "0x078cbdf050B2955C6d89dA9F2B5FF8CC80FaE608";
  String contractAddress = "0x080E159b4D104a60ef22c10FB0cd4b87dE1a4F07";
  String myPrivateKey =
      '09f8ae4b55b7b7b81abe920595bed1c145edab0ad573ccd56846a621c1f42ca5';
  String url = "HTTP://127.0.0.1:8545";
  TextEditingController _status = TextEditingController();
  List<BigInt> bagIndex = List();
  String funcstate = "Error";
  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(url, httpClient);
    lastAuth();
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

  Future<void> lastAuth() async {
    allWasteBags.clear();
    List<dynamic> currentWasteBinIdreq = await query("wasteBagId", []);
    BigInt currentWasteBinId = currentWasteBinIdreq[0] - BigInt.one;
    print(currentWasteBinId);
    for (BigInt i = currentWasteBinId; i >= BigInt.zero; i = i - BigInt.one) {
      print("Running");
      String id = i.toString();
      List<dynamic> result = await query("getWasteBagDetails", [id]);
      print(result);
      if (result[0][6].toString().toLowerCase() == 'recycled') continue;
      if (result[0][4].toString().toLowerCase() == 'false') continue;
      if (result[0][5].toString().toLowerCase() == 'true') {
        if (result[0][4].toString().toLowerCase() == 'false') {
          continue;
        }
      }
      bagIndex.add(i);
      allWasteBags.add(result);
    }
    print(allWasteBags);
    wasteBagLength = allWasteBags.length;
    funcstate = "Modified";
    setState(() {});
  }

  Future<void> modifyStatus(String status, BigInt id) async {
    print("working");
    var response = await submit("changeState", [status, id]);
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
                        'Modify Requests',
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
                          lastAuth();
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
                                          'images/${allWasteBags[index][0][2].toString().toLowerCase()}.png'),
                                    ),
                                    title: Column(
                                      children: <Widget>[
                                        Container(
                                            child: Text(
                                          allWasteBags[index][0][0].toString(),
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
                                            ),
                                            Container(
                                              child: Text(
                                                  "Status:${allWasteBags[index][0][6].toString()}"),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('Current Status:'),
                                          Expanded(
                                            child: TextField(
                                              controller: _status,
                                              decoration: InputDecoration(
                                                hintText: 'Status',
                                                filled: true,
                                                isDense: true,
                                              ),
                                              autocorrect: false,
                                            ),
                                          ),
                                          Column(children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                print(bagIndex[index]);
                                                modifyStatus(
                                                  _status.text,
                                                  bagIndex[index],
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text('Modified'),
                                                    duration: const Duration(
                                                        milliseconds: 1500),
                                                    width:
                                                        280.0, // Width of the SnackBar.
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal:
                                                          8.0, // Inner padding for SnackBar content.
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text('Modify'),
                                            ),
                                          ])
                                        ]),
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
