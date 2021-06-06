import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';

class authorizeTransaction extends StatefulWidget {
  const authorizeTransaction({Key key}) : super(key: key);

  @override
  _authorizeTransactionState createState() => _authorizeTransactionState();
}

class _authorizeTransactionState extends State<authorizeTransaction> {
  BigInt littycoin;
  Client httpClient;
  Web3Client ethClient;
  List<dynamic> allWasteBags = List();
  int wasteBagLength = 0;
  final myAddress = "0x31E6FDd1DD504DC8dd269230E9040448Ff48a456";
  String contractAddress = "0xa66653f74f411dB23a7c3CAF60E823D6Be070293";
  String myPrivateKey =
      'f32aec6d0ca33513350665ffbede1139880052157760276f781391ed2f40422f';
  String url = "HTTP://127.0.0.1:8545";
  TextEditingController _status = TextEditingController();
  TextEditingController _amount = TextEditingController();
  List<bool> status = List();

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
    List<dynamic> lastAuthorizedreq = await query("lastAuthorized", []);
    BigInt lastAuthorized = lastAuthorizedreq[0] - BigInt.one;
    print(lastAuthorized);
    for (BigInt i = currentWasteBinId; i > lastAuthorized; i = i - BigInt.one) {
      print(i);
      String id = i.toString();
      List<dynamic> result = await query("getWasteBagDetails", [id]);
      if (result[0][6].toString() == 'Recycled') continue;
      allWasteBags.add(result);
    }
    wasteBagLength = allWasteBags.length;
    print(wasteBagLength);
    print(allWasteBags);
    status = List.filled(wasteBagLength, false);
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
                      Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      Text(
                        'Authorize Requests',
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
                        onPressed: () => lastAuth(),
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
                                          Text('Status:'),
                                          CupertinoSwitch(
                                            value: status[index],
                                            onChanged: (value) {
                                              setState(() {
                                                status[index] = value;
                                              });
                                            },
                                          ),
                                          Column(children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                int val = calculateValue(
                                                    allWasteBags[index][0][2]
                                                        .toString(),
                                                    int.parse(
                                                        allWasteBags[index][0]
                                                                [1]
                                                            .toString()));
                                                print(status[index]);
                                                if (status[index] == false)
                                                  val = 0;
                                                print(val);
                                                authorizeRequest(status[index],
                                                    BigInt.from(val));
                                              },
                                              child: Text('Approve'),
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
