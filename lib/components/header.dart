import 'package:flutter/material.dart';

import 'package:acb/components/system.dart';

class Header extends StatelessWidget {
  final String? ip;
  final String? name;
  final Size size;
  final String title;

  const Header({
    super.key,
    required this.size,
    required this.title,
    required this.ip,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppBar(
        title: Text(title),
      ),
      Container(
        margin: EdgeInsets.only(
          bottom:
              size.width < size.height ? size.height * 0.01 : size.width * 0.01,
        ),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                bottom: responsiveSize(
                    size, size.height * 0.001, size.width * 0.01),
              ),
              height:
                  responsiveSize(size, size.height * 0.1, size.width * 0.07),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                    responsiveSize(size, size.width * 0.1, size.height * 0.065),
                  ),
                  bottomRight: Radius.circular(
                    responsiveSize(size, size.width * 0.1, size.height * 0.065),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    offset: Offset(
                      0,
                      responsiveSize(
                          size, size.height * 0.001, size.width * 0.002),
                    ),
                    blurRadius: responsiveSize(
                        size, size.height * 0.01, size.width * 0.005),
                    spreadRadius: responsiveSize(
                        size, size.height * 0.0025, size.width * 0.000125),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: size.width * 0.15,
                  top: responsiveSize(size, size.height * 0.015, 0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? '',
                    style: TextStyle(
                      fontSize: responsiveSize(
                          size, size.height * 0.035, size.width * 0.035),
                    ),
                  ),
                  Text(
                    ip ?? '',
                    style: TextStyle(
                      fontSize: responsiveSize(
                          size, size.height * 0.015, size.width * 0.015),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: size.width * 0.75,
                top: responsiveSize(
                    size, size.height * 0.015, size.width * 0.01),
              ),
              child: SizedBox(
                height:
                    responsiveSize(size, size.height * 0.05, size.width * 0.04),
                width:
                    responsiveSize(size, size.height * 0.05, size.width * 0.04),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/connect');
                  },
                  child: Icon(Icons.link,
                      size: responsiveSize(
                          size, size.height * 0.025, size.width * 0.03)),
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
