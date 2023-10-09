import 'dart:convert';

import 'package:blog_explorer/blog_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curl/flutter_curl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class blog_page extends StatefulWidget {
  @override
  _blog_page createState() => _blog_page();
}

class _blog_page extends State<blog_page> {
  List<ApiData> dataList = [];
  bool checkInternet = false;

  var box = Hive.box('blogBox');

  void curlGet() async {
    Client client = Client(
      verbose: true,
      interceptors: [
        // HTTPCaching(),
      ],
    );
    await client.init();

    final res = await client.send(Request(
      method: "GET",
      url: "https://intent-kit-16.hasura.app/api/rest/blogs",
      headers: {
        "x-hasura-admin-secret":
            "32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6"
      },
    ));

    print("Status: ${res.statusCode}");

    var responseData = json.decode(res.text())["blogs"];
    dataList.clear();

    for (var data in responseData) {
      ApiData d = ApiData(data["id"], data["image_url"], data["title"]);
      dataList.add(d);
    }

    box.put("hiveBlogList", dataList);
    setState(() {});
  }

  void checkCon() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      checkInternet = true;
      setState(() {});
      curlGet();
    } else {
      checkInternet = false;
      if (!box.isEmpty) {
        for (var data in box.values) {
          List<dynamic> lst = data;
          for (int i = 0; i < lst.length; i++) {
            ApiData d = lst[i];
            dataList.add(ApiData(d.id, d.image_url, d.title));
            print(d.image_url);
          }
        }
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    checkCon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        title: Row(
          children: [
            Image.asset(
              "images/logo.png",
              width: 30,
            ),
            const Text(
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
                              curlGet();
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
          Expanded(child: list()),
        ],
      ),
    );
  }

  Widget list() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        itemCount: dataList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF1B1B1B),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: checkInternet
                            // ? Image.network(dataList[index].image_url)
                            ? CachedNetworkImage(
                                imageUrl: dataList[index].image_url,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : Image.asset("images/demo.png"),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.star,
                              color: box.containsKey(dataList[index].id)
                                  ? Colors.yellow
                                  : Colors.white,
                            ),
                          ),
                          onTap: () {
                            if (box.containsKey(dataList[index].id)) {
                              box.delete(dataList[index].id);
                            } else {
                              box.put(dataList[index].id, 1);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dataList[index].title,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => blog_detail(
                        title: dataList[index].title,
                        image: dataList[index].image_url,
                      )));
            },
          );
        });
  }
}

class UserAdapter extends TypeAdapter<ApiData> {
  @override
  final typeId = 0;

  @override
  ApiData read(BinaryReader reader) {
    return ApiData(reader.read(), reader.read(), reader.read());
  }

  @override
  void write(BinaryWriter writer, ApiData obj) {
    writer.write(obj.id);
    writer.write(obj.image_url);
    writer.write(obj.title);
  }
}

class ApiData {
  String id;
  String image_url;
  String title;

  ApiData(
    this.id,
    this.image_url,
    this.title,
  );
}
