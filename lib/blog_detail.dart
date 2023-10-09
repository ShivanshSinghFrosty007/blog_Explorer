import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class blog_detail extends StatefulWidget {
  final title, image;

  const blog_detail({super.key, required this.title, required this.image});

  _blog_detail createState() => _blog_detail();
}

class _blog_detail extends State<blog_detail> {
  bool checkInternet = false;

  @override
  void initState() {
    checkCon();
  }

  void checkCon() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      checkInternet = true;
      setState(() {});
    } else {
      checkInternet = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF303030),
        title: Row(
          children: [
            Image.asset(
              "images/logo.png",
              width: 30,
            ),
            Text(
              "ubSpace",
              style: TextStyle(color: Colors.white, fontSize: 25),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          checkInternet
              ? Container()
              : Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.indigo),
                  child: Row(
                    children: [
                      const Text(
                        "No Internet",
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              checkCon();
                            },
                            child: const Text(
                              "try Again",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                )),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(10),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: checkInternet
                    // ? Image.network(widget.image)
                    ? CachedNetworkImage(
                        imageUrl: widget.image,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )
                    : Image.asset("images/demo.png")),
          ),
        ],
      ),
    );
  }
}
