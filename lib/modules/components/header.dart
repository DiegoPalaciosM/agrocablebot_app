import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agrocablebot/modules/connector/connector.dart';

class Header extends PreferredSize {
  const Header({super.key, required super.preferredSize, required super.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: SizedBox(
              height: 60.h,
              child: FittedBox(fit: BoxFit.contain, child: child)),
        ),
        Expanded(
          child: Container(
            //height: preferredSize.height,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                  70.dg,
                ),
                bottomRight: Radius.circular(
                  70.dg,
                ),
              ),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    offset: Offset(
                      0,
                      5.dg,
                    ),
                    blurRadius: 10.dg,
                    spreadRadius: 1.dg),
                BoxShadow(
                  color: Theme.of(context).primaryColor,
                  offset: Offset(
                    0,
                    -5.dg,
                  ),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              MqttClient.connect();
                            },
                            child: Container(
                              height: Configuration.name.isNotEmpty ? 30.dg : 0,
                              width: Configuration.name.isNotEmpty ? 30.dg : 0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: MqttClient.status()
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              margin: EdgeInsets.only(right: 10.dg),
                            ),
                          ),
                          SizedBox(
                            height: 45.h,
                            child: FittedBox(
                              child: Text(
                                Configuration.name,
                                style: TextStyle(
                                  fontSize: 35.dg,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                      child: FittedBox(
                        child: Text(
                          Configuration.ip,
                          style: TextStyle(
                            fontSize: 20.dg,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 60.w,
                  height: 60.h,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/connect');
                    },
                    child: Icon(
                      Icons.link,
                      size: 40.dg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
