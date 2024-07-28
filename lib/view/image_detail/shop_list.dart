import 'dart:io';

import 'package:flutter/material.dart';

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
          width: MediaQuery.of(context).size.width - 10.0,
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
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFfff4eb),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(  
                    onPressed: () {
                      Navigator.of(context).pop();
                    },    
                    icon: const Icon(Icons.close),
                  ),
                ),
              ), 
              const SizedBox(height: 8),
              const Text ('写真を撮った店舗を選んでください'),
              const SizedBox(height:20),

              for(shopNo=0; shopNo < 3; shopNo++) ... {
                  Container(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    margin: const EdgeInsets.only(
                      left: 10,
                      right:10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: shopNoSelected == shopNo ? 2 : 1,
                        color: shopNoSelected == shopNo 
                         ? Themes.mainOrange
                         : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ), 
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 5),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(shopName),
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
                                      //height: 150,
                                      width: 125,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                const SizedBox(height:15),
              },

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


