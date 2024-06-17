import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xterm_terminal/page/terminal_page.dart';
import 'package:flutter_xterm_terminal/utils/utils.dart';

class UserCmdPage extends StatefulWidget {
  const UserCmdPage({super.key});

  @override
  State<UserCmdPage> createState() => _UserCmdPageState();
}

class _UserCmdPageState extends State<UserCmdPage> {
  List<String> userCmdList = [];
  String fileName = "user_cmd.txt";
  String currCmd = "";

  late File myFile;

  Future _getCmdList() async {
    String pathStr = Directory.current.path;
    pathStr += "\\$fileName";
    utils.log("pathStr = $pathStr");
    // myFile = File(pathStr);
    userCmdList = await File(pathStr)
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .toList();

    if (userCmdList.isNotEmpty) {
      currCmd = userCmdList[0];
    } else {
      utils.log("there is no user commands");
    }

    if (userCmdList.isEmpty) {
      utils.log("userCmd is empty");
    } else {
      for (int i = 0; i < userCmdList.length; i++) {
        utils.log("userCmdList[$i] -> ${userCmdList[i]}");
      }
      setState(() {
        currCmd = userCmdList.first;
      });
      utils.log("currCmd = $currCmd");
    }
  }

  Future _readCmdList(String path) async {
    utils.log("read path = $path");

    userCmdList.clear();
    currCmd = "";
    userCmdList = await File(path)
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .toList();

    if (userCmdList.isNotEmpty) {
      currCmd = userCmdList[0];
    } else {
      utils.log("there is no user commands");
    }

    if (userCmdList.isEmpty) {
      utils.log("userCmd is empty");
    } else {
      for (int i = 0; i < userCmdList.length; i++) {
        utils.log("userCmdList[$i] -> ${userCmdList[i]}");
      }
      setState(() {
        currCmd = userCmdList.first;
      });
      utils.log("currCmd = $currCmd");
    }
  }

  String? _extension;
  String? _fileName;

  List<PlatformFile>? _paths;
  final bool _multiPick = false;
  final FileType _pickingType = FileType.any;
  final bool _lockParentWindow = false;

  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();

  void _pickFiles() async {
    // _resetState();
    try {
      _paths = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        type: _pickingType,
        allowMultiple: _multiPick,
        onFileLoading: (FilePickerStatus status) =>
            utils.log(status.toString()),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      ))
          ?.files;
    } on PlatformException catch (e) {
      utils.log('Unsupported operation$e');
    } catch (e) {
      utils.log(e.toString());
    }
    if (!mounted) {
      utils.log("pick file mounted error...");
      return;
    }

    setState(() {
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
      utils.log("Opened file name : $fileName");
      String tempPath = _paths!.map((e) => e.path).toString();
      tempPath = tempPath.replaceAll('(', '');
      tempPath = tempPath.replaceAll(')', '');
      utils.log("Opened path : $tempPath");

      _readCmdList(tempPath);
    });
  }

  @override
  void initState() {
    super.initState();

    // _getCmdList();
  }

  @override
  Widget build(BuildContext context) {
    // _getCmdList();

    return Row(
      children: [
        const SizedBox(width: 20),
        // IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
        ElevatedButton.icon(
          label: Text(_multiPick ? 'Open scripts' : 'Open script'),
          icon: const Icon(Icons.file_open),
          onPressed: () => _pickFiles(),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          label: const Text("Command"),
          icon: const Icon(Icons.send),
          onPressed: () {
            terminal.onOutput!("$currCmd\r\n");
          },
        ),
        const SizedBox(width: 20),
        DropdownButton(
          value: currCmd,
          items: userCmdList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              currCmd = value!;
              utils.log("onChanged : $currCmd");
            });
          },
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          // style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          // padding: const EdgeInsets.all(10),
          // isExpanded: true,
          // isDense: true,
        ),
      ],
    );
  }
}
