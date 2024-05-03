import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_xterm_terminal/page/terminal_page.dart';
import 'package:flutter_xterm_terminal/utils/utils.dart';
import 'package:flutter_xterm_terminal/widget/my_widget.dart';

List<SerialPort> portList = [];
SerialPort? mSp;

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int menuBaudrate = 115200;
  String openButtonText = 'N/A';
  List<int> baudRate = [3800, 9600, 115200, 1500000];

  final inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    openButtonText = mSp == null
        ? 'N/A'
        : mSp!.isOpen
            ? 'Close'
            : 'Open';

    return _comPort();
  }

  _initPort() {
    setState(() {
      var i = 0;

      portList.clear();

      for (final name in SerialPort.availablePorts) {
        final sp = SerialPort(name);
        if (kDebugMode) {
          print('${++i}) $name');
          print('\tDescription: ${sp.description ?? ''}');
          print('\tManufacturer: ${sp.manufacturer}');
          print('\tSerial Number: ${sp.serialNumber}');
          print('\tProduct ID: 0x${sp.productId?.toRadixString(16) ?? 00}');
          print('\tVendor ID: 0x${sp.vendorId?.toRadixString(16) ?? 00}');
        }
        portList.add(sp);
      }
      if (portList.isNotEmpty) {
        mSp = portList.first;
      }
    });
  }

  void changedDropDownItem(SerialPort sps) {
    setState(() {
      mSp = sps;
    });
  }

  _comPort() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        DropdownButton(
          // focusColor: Colors.white,
          value: mSp,
          items: portList.map((item) {
            return DropdownMenuItem(value: item, child: Text("${item.name}"));
            // "${item.name}: ${cp949.decodeString(item.description ?? '')}"));
          }).toList(),
          onChanged: (e) {
            setState(() {
              changedDropDownItem(e as SerialPort);
            });
          },
        ),
        const SizedBox(width: 20.0),
        DropdownButton(
          value: menuBaudrate,
          items: baudRate.map((value) {
            return DropdownMenuItem(
                value: value, child: Text(value.toString()));
          }).toList(),
          onChanged: (e) {
            setState(() {
              menuBaudrate = e!;
            });
            utils.showSnackbar(context, menuBaudrate.toString());
            utils.log("Baudrate set to $menuBaudrate");
          },
        ),
        const SizedBox(width: 20.0),
        ElevatedButton(
          onPressed: () {
            _initPort();
          },
          child: const Text("COM"),
        ),
        const SizedBox(width: 20.0),
        ElevatedButton(
          onPressed: () {
            if (mSp == null) {
              return;
            }
            if (mSp!.isOpen) {
              mSp!.close();
              utils.log('${mSp!.name} closed!');
            } else {
              if (mSp!.open(mode: SerialPortMode.readWrite)) {
                SerialPortConfig config = mSp!.config;
                // https://www.sigrok.org/api/libserialport/0.1.1/a00007.html#gab14927cf0efee73b59d04a572b688fa0
                // https://www.sigrok.org/api/libserialport/0.1.1/a00004_source.html
                // config.baudRate = 115200;
                config.baudRate = menuBaudrate;
                config.parity = 0;
                config.bits = 8;
                config.cts = 0;
                config.rts = 0;
                config.stopBits = 1;
                config.xonXoff = 0;
                mSp!.config = config;

                utils.log("baudrate : $menuBaudrate");
                if (mSp!.isOpen) {
                  utils.log('${mSp!.name} opened!');
                  // utils.showSnackbar(
                  //     context, "Serial port opened, ${mSp!.name}");
                  String configCmd =
                      "plink -serial ${mSp!.name} -sercfg $menuBaudrate,8,1,N,N\n\r";
                  // "plink -serial \\\\.\\${mSp!.name} -sercfg $menuBaudrate,8,1,N,N\n\r";
                  terminal.onOutput!(configCmd);
                  // terminal.write("ls\n\r");
                  utils.log(configCmd);
                }
                final reader = SerialPortReader(mSp!);
                reader.stream.listen((data) {
                  // if (makeMessage(context, data, data.length) == true) {
                  //   setState(() {});
                  // }
                  utils.log(
                      'received: ${data.length}, ${String.fromCharCodes(data)}');
                  // receiveDataList.add(data);
                  // setState(() {});
                }, onError: (error) {
                  if (error is SerialPortError) {
                    utils.log(
                        'error: ${error.message}, code: ${error.errorCode}');
                  }
                });
              }
            }
            setState(() {});
          },
          child: Text(openButtonText),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 200,
          child: TextField(
            controller: inputController,
            onSubmitted: (value) {
              String cmd = "${inputController.text}\r";
              terminal.onOutput!(cmd);
              inputController.text = "";
            },
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {
            String cmd = "${inputController.text}\r";
            // terminal.write("${inputController.text}\r");
            terminal.onOutput!(cmd);
          },
          label: const Text("Send"),
          icon: const Icon(Icons.send),
        )
      ],
    );
  }
}
