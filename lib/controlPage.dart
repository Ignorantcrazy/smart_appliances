import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'alertDialog.dart';

class ControlPage extends StatefulWidget {
  ControlPage({Key key, this.isBindHost = true, @required this.onChanged})
      : super(key: key);
  final bool isBindHost;
  final ValueChanged<bool> onChanged;
  @override
  _ControlState createState() => _ControlState();
}

class _ControlState extends State<ControlPage> {
  Socket socket;
  bool isOpenLights = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sps) {
      Socket.connect(sps.getString('host'), sps.getInt('port')).then((soc) {
        socket = soc;
        soc.listen(_onData, onError: _onError, cancelOnError: false);
      }).catchError((error) {
        showDialogSelf(error.toString(), context);
        widget.onChanged(!widget.isBindHost);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (socket != null) {
      socket.destroy();
      socket.close();
    }
  }

  void _onChanged(bool value) {
    if (value) {
      socket.write(1);
    } else {
      socket.write(0);
    }
  }

  void _onData(List<int> datas) {
    for (var data in datas) {
      if (data == 1) {
        setState(() {
          isOpenLights = true;
        });
      } else {
        setState(() {
          isOpenLights = false;
        });
      }
    }
  }

  void _onError(error, StackTrace stackTrace) {
    // widget.onChanged(!widget.isBindHost);
    showDialogSelf(error.toString(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SwitchListTile(
                value: isOpenLights,
                onChanged: _onChanged,
                title: Text('lights'),
              ),
            ],
          ),
          RaisedButton(
            padding: const EdgeInsets.all(30.0),
            child: Text('Host UnBind'),
            onPressed: () {
              SharedPreferences.getInstance().then((sp) {
                sp.clear();
              });
              widget.onChanged(!widget.isBindHost);
            },
          ),
        ],
      ),
    );
  }
}
