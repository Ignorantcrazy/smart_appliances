import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'alertDialog.dart';

class HostBindPage extends StatefulWidget {
  HostBindPage({Key key, this.isBindHost: false, @required this.onChanged})
      : super(key: key);
  final bool isBindHost;
  final ValueChanged<bool> onChanged;

  @override
  HostBindPageState createState() => HostBindPageState();
}

class HostBindPageState extends State<HostBindPage> {
  var _hostController = new TextEditingController();
  var _portController = new TextEditingController();
  var _formkey = new GlobalKey<FormState>();
  bool _saving = false;

  void _hostBind(context) async {
    setState(() {
      _saving = true;
    });
    int port = int.parse(_portController.text.trim());
    String host = _hostController.text.trim();
    Socket.connect(host, port).then((data) {
      SharedPreferences.getInstance().then((sps) {
        sps.setInt('port', port);
        sps.setString('host', host);
      });
      widget.onChanged(!widget.isBindHost);
    }).catchError((err) {
      showDialogSelf(err.toString(), context);
    }).whenComplete(() {
      setState(() {
        _saving = false;
      });
    });
  }

  List<Widget> _buildForm(BuildContext context) {
    var form = Form(
      key: _formkey,
      autovalidate: true,
      child: Column(
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: _hostController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'host',
                hintText: 'input your host ip',
                icon: Icon(Icons.usb)),
            validator: (v) {
              return v.trim().length >= 7 && v.trim().split('.').length >= 4
                  ? null
                  : 'Please enter correct host ip!';
            },
          ),
          TextFormField(
            autofocus: false,
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'port',
                hintText: 'input your port',
                icon: Icon(Icons.usb)),
            validator: (v) {
              return int.tryParse(v.trim()) != null
                  ? null
                  : 'Please enter correct port!';
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return RaisedButton(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('save'),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          if (Form.of(context).validate()) {
                            _hostBind(context);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var widgets = new List<Widget>();
    widgets.add(form);
    if (_saving) {
      var modal = Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.3,
            child: const ModalBarrier(
              dismissible: false,
              color: Colors.grey,
            ),
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
      widgets.add(modal);
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Stack(
          children: _buildForm(context),
        ));
  }
}
