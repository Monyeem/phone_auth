import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';

class phone_auth extends StatefulWidget {
  @override
  _phone_authState createState() => _phone_authState();
}

class _phone_authState extends State<phone_auth> {

  String phoneNo;
  String smsCode;
  String verificationId;

  Future<void> varifyPhone() async{
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId,[int forceCodeResend]){
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        print("Signed in");
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print("verified");
    };

    // final PhoneVerificationCompleted verifiedSuccess = (AuthCredential phoneauthCredential) {
    //   print("verified");
    // };

    final PhoneVerificationFailed varificationfiled = (AuthException exception) {
      print("${exception.message}");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: varificationfiled,
    );

  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text("Enter SMS Code"),
          content: TextField(
            onChanged: (value) {
              this.smsCode = value;
            },
          ),
          contentPadding: EdgeInsets.all(10),
          actions: [
            new FlatButton(
              child: Text("Done"),
              onPressed: (){
                FirebaseAuth.instance.currentUser().then((user){
                  if(user !=null) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/homepage');
                  }
                  else{
                    Navigator.of(context).pop();
                    signIn();
                  }
                }
                );
              },
            ),
          ],
        );
      }
    );
  }

  signIn() {
    FirebaseAuth.instance
        .signInWithPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode
    ).then((user) {
      Navigator.of(context).pushReplacementNamed("/homepage");
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Auth"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                  hintText: "Enter Phone Number"
              ),
              onChanged: (value){
                this.phoneNo = value;
              },
            ),
            SizedBox(height: 10,),
            RaisedButton(
                onPressed: varifyPhone,
              child: Text("Verify"),
              textColor: Colors.black,
              elevation: 7.0,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
