import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/build_context_extension.dart';
import '../../core/themes.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/scalable_image.dart';


List<File> shopList = [];
int shopNo = 0;
int shopNoSelected = 0;

Future<dynamic> showShopListDialog (
  BuildContext context, { 
    required String shopName,
    required List<File> imageFileList,
    required void Function() onSelected,
  
}) async { 
  await showDialog<dynamic>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Color(0xFFfff4eb),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(  
                    onPressed: () {
                      Navigator.of(context).pop();
                    },    
                    icon: Icon(Icons.close, size: 20, color: Colors.grey[800]),
                  ),
                ),
              ), 
              const SizedBox(height: 8),
              Text (
                '写真を撮った店舗を選んでください', 
                style: context.textTheme.titleSmall, 
              ),
              const SizedBox(height:10),
              for(shopNo=0; shopNo < 3; shopNo++) ... {
                Stack( 
                  children: [ 
                      Container(
                        margin: const EdgeInsets.only(
                          top: 7,
                          bottom: 7,
                          left: 10,
                          right: 10,
                        ),
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 10,
                        ),                       
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: shopNoSelected == shopNo 
                            ? Themes.mainOrange
                            : const Color(0xFFd8cac1),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), 
                              blurRadius: 3, 
                              offset: const Offset(0, 5), 
                            ),
                          ],
                          color: Colors.white,
                        ), 
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 5),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  shopName,
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                            ), 
                            SizedBox(
                              height: 110,
                              child: Scrollbar(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imageFileList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: ScalableImage(
                                          imageFile: imageFileList[index],
                                          height: 100,
                                          width: 125,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (shopNo == shopNoSelected)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container( 
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Themes.mainOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check, 
                            color: Colors.white,
                            size: 20, 
                          ),
                        ),
                       ),
                  ],  
                ),
              },
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('次の３店鋪'),
            ),            
            const SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: SizedBox(
                height: 60,
                child: CustomElevatedButton(
                  onPressed: onSelected,
                  text: '決定',
                ),
              ),
            ),
            const SizedBox(height: 15,),
            ],
          ),
        ),
      );
    },
  );
}
