import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 70),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    "assets/image/logo/logo.png",
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "تسجيل الدخول",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Text("تسجيل الدخول لاستخدام التطبيق",
                  style: TextStyle(
                    color: Colors.grey[600],
                  )),
              SizedBox(height: 20),
              Text("الايميل"),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: "ادخل الايميل",
                  // make direction to right
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("الباسوورد"),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: "ادخل الباسوورد",
                  // make direction to right
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  suffixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
