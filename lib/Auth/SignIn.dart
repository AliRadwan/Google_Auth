
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/Screen/Home/HomeScreen.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool loading = false;
  bool isLogin = false;

@override
  void initState() {
  isSignedIN();
    super.initState();
  }

  void isSignedIN()async{
  setState(() {
    loading =true;
  });
  preferences = await SharedPreferences.getInstance();
  isLogin = await googleSignIn.isSignedIn();
  if(isLogin){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
  }
  setState(() {
    loading = false;
  });
  }

  Future signIn()async{
  preferences = await SharedPreferences.getInstance();
  setState(() {
    loading = true;
  });
  GoogleSignInAccount googleUser = await googleSignIn.signIn();
  GoogleSignInAuthentication googleSignInAuthentication  =await googleUser.authentication;
  FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);
  if(firebaseUser != null){
    final QuerySnapshot result = await Firestore.instance.collection("users").where("id",isEqualTo: firebaseUser.uid).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if(documents.length ==0){
      // enter to home
      Firestore.instance.collection("users").document(firebaseUser.uid).setData({
        "id":firebaseUser.uid,
        "username":firebaseUser.displayName,
        "profilePicture":firebaseUser.photoUrl
      });
      await preferences.setString("id", firebaseUser.uid);
      await preferences.setString("username", firebaseUser.displayName);
      await preferences.setString("photoUrl", firebaseUser.displayName);
    }else{
      await preferences.setString("id", documents[0]["id"]);
      await preferences.setString("username", documents[0]["username"]);
      await preferences.setString("photoUrl", documents[0]["photoUrl"]);
    }
    Fluttertoast.showToast(msg: "Success");
    setState(() {
      loading = false;
    });

  }else{

  }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Login"),),body: Stack(children: <Widget>[
      Center(child: FlatButton(onPressed: (){
        signIn();
      }, child: Text("Sgin In with google")),),
      Visibility(visible: loading?? true,child: Container(color: Colors.white.withOpacity(0.7),child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      ),))
    ],),);
  }
}
