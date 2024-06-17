import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_xterm_terminal/page/terminal_page.dart';
import 'package:flutter_xterm_terminal/page/user_cmd_page.dart';
import 'package:flutter_xterm_terminal/utils/utils.dart';

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

  _comConfig() {
    SerialPortConfig config = mSp!.config;
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

    String configCmd =
        // "plink -serial ${mSp!.name} -sercfg $menuBaudrate,8,1,N,N\n\r";
        'plink -serial \\\\.\\${mSp!.name} -sercfg $menuBaudrate,8,1,N,N\r';
    terminal.onOutput!(configCmd);
    // inputController.text = configCmd;
  }

  _comOpen() {
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
              // "plink -serial ${mSp!.name} -sercfg $menuBaudrate,8,1,N,N\n\r";
              'plink -serial \\\\.\\${mSp!.name} -sercfg $menuBaudrate,8,1,N,N\r';
          // TODO : Cannot fix problem here. If send here, com port open error happened. So copied text to inputcontroller and send via Send key
          // terminal.onOutput!(configCmd);
          inputController.text = configCmd;
          // terminal.onOutput!("${inputController.text}\r");
          // inputController.text = "";
          // terminal.write("ls\n\r");
          // utils.log(configCmd);
        }
      }
    }
  }

  _comPort() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            DropdownButton(
              // focusColor: Colors.white,
              value: mSp,
              items: portList.map((item) {
                return DropdownMenuItem(
                    value: item, child: Text("${item.name}"));
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
                // _comOpen();

                if (!mSp!.isOpen) {
                  _comConfig();
                } else {}

                setState(() {});
              },
              child: Text(openButtonText),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: inputController,
                // onSubmitted: (value) {   // Text 입력 후 커서가 그 상태 위치를 유지하지 않고 focus를 잃어버린다. 엔터키 입력 후 focus를 잃어버려 마우스로 다시 가져와야한다.
                //   String cmd = "${inputController.text}\r";
                //   terminal.onOutput!(cmd);
                //   inputController.text = "";
                // },
                onEditingComplete: () {
                  // Text 입력 후 커서가 그 상태 위치를 유지한다. 엔터키 입력 후 바로 text 입력해서 사용할 수 있다.
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
                inputController.text = "";
              },
              label: const Text("Send"),
              icon: const Icon(Icons.send),
            )
          ],
        ),
        const UserCmdPage(),
      ],
    );
  }
}
