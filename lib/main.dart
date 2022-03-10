import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rxdart/subjects.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

BluetoothDevice? device;
BehaviorSubject<BluetoothDevice?> blueStreamController = BehaviorSubject();
Sink<BluetoothDevice?> get inputBlue => blueStreamController.sink;
Stream<BluetoothDevice?> get outputBlue => blueStreamController.stream;
final blue = FlutterBluetoothSerial.instance;
List addressList = [];
BluetoothConnection? connection;

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Future<bool> connectToMyHome() async {
    blue.startDiscovery().listen((devicesResult) async {
      if (devicesResult.device.name == "HC-05") {
        device = devicesResult.device;
      }
    });
    if (device != null) {
      return await BluetoothConnection.toAddress(device?.address).then((value) {
        connection = value;
        inputBlue.add(device);
        return connection!.isConnected;
      });
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 5,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<BluetoothDevice?>(
              stream: outputBlue,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  BluetoothDevice? device = snapshot.data;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black87,
                        ),
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(10),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "My Room",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red[200],
                                ),
                                onPressed: () {},
                                child: Text(
                                  "Desconectar",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[800],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const DeviceControll(),
                    ],
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black87,
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "My Room",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green[200],
                            ),
                            onPressed: () async {
                              await connectToMyHome().then((isConnected) {
                                if (isConnected == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text("conectado com sucesso"),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text("tente novamente"),
                                    ),
                                  );
                                }
                              });
                            },
                            child: Text(
                              "Conectar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}

BehaviorSubject<bool?> lightStreamController = BehaviorSubject();
Sink<bool?> get inputLighOn => lightStreamController.sink;
Stream<bool?> get outputLighOn => lightStreamController.stream;

class DeviceControll extends StatelessWidget {
  const DeviceControll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black87,
      ),
      child: StreamBuilder<bool?>(
          initialData: false,
          stream: outputLighOn,
          builder: (context, snapshot) {
            bool lightOn = snapshot.data!;

            return Container(
              height: 150,
              width: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: lightOn == true ? 50 : 30,
                    color: lightOn == true ? Colors.green : Colors.red,
                    onPressed: () async {
                      lightOn == true
                          ? connection?.output
                              .add(Uint8List.fromList('b \n'.codeUnits))
                          : connection?.output
                              .add(Uint8List.fromList('a \n'.codeUnits));
                      await connection?.output.allSent.then((value) {
                        lightOn = !lightOn;
                        inputLighOn.add(lightOn);
                      });
                    },
                    icon: const Icon(Icons.power_settings_new_rounded),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
