import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:van_transport/src/common/style.dart';
import 'package:van_transport/src/pages/order/controllers/cart_merchant_controller.dart';
import 'package:van_transport/src/pages/order/widgets/cart_card.dart';
import 'package:van_transport/src/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:van_transport/src/services/string_service.dart';

class CartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cartController = Get.put(CartMerchantController());
  SlidableController slidableController = new SlidableController();

  @override
  void initState() {
    super.initState();
    slidableController = SlidableController();
    cartController.getCartMerchant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mCL,
        elevation: .0,
        centerTitle: true,
        leadingWidth: 62.0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Feather.arrow_left,
            color: colorTitle,
            size: width / 16.5,
          ),
        ),
        title: Text(
          'cart'.trArgs(),
          style: TextStyle(
            color: colorTitle,
            fontSize: width / 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
      ),
      body: Container(
        color: mCL,
        child: StreamBuilder(
          stream: cartController.getCartController,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            int quantity = 0;
            int price = 0;
            for (int i = 0; i < snapshot.data.length; i++) {
              quantity += snapshot.data[i]['quantity'];
              price += int.parse(snapshot.data[i]['product']['price']);
            }

            return Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(50.0),
                      ),
                      color: mCM.withOpacity(.85),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: NotificationListener<
                              OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowGlow();
                              return true;
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                left: 12.5,
                                right: 12.5,
                                top: 16.0,
                              ),
                              physics: ClampingScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.25,
                                    controller: slidableController,
                                    child: CartCard(
                                      name: StringService().formatString(
                                        20,
                                        snapshot.data[index]['product']['name'],
                                      ),
                                      quantity: snapshot.data[index]['quantity']
                                          .toString(),
                                      price: snapshot.data[index]['product']
                                              ['price']
                                          .toString(),
                                      urlToString: snapshot.data[index]
                                          ['product']['image'],
                                    ),
                                    secondaryActions: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          cartController.deleteCartMerchant(
                                              snapshot.data[index]['product']
                                                  ['_id']);
                                          slidableController.activeState
                                              .close();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.fromLTRB(
                                              12.0, 24.0, 6.0, 24.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            color: mCD,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: mCL,
                                                  offset: Offset(3, 3),
                                                  blurRadius: 3,
                                                  spreadRadius: -3),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Feather.trash_2,
                                            color: colorTitle,
                                            size: width / 15.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPriceText(
                                  context, 'product'.trArgs(), '$quantity'),
                              _buildPriceText(
                                context,
                                'subTotal'.trArgs(),
                                '${StringService().formatPrice(price.toString())} đ',
                              ),
                              _buildPriceText(
                                  context, 'taxes'.trArgs(), '100 đ'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomCheckout(
                    context, StringService().formatPrice(price.toString())),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriceText(context, title, value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              color: colorDarkGrey.withOpacity(.6),
              fontSize: width / 32.5,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: ':\t',
            style: TextStyle(
              color: colorDarkGrey.withOpacity(.6),
              fontSize: width / 26.0,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: colorBlack,
              fontSize: width / 26.0,
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(context, price) {
    return Container(
      color: mCM,
      child: Neumorphic(
        padding: EdgeInsets.fromLTRB(32.0, 32.0, 24.0, 32.0),
        style: NeumorphicStyle(
          shape: NeumorphicShape.convex,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.vertical(
              top: Radius.circular(30.0),
            ),
          ),
          depth: -20.0,
          intensity: .6,
          color: mCH.withOpacity(.12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$price đ',
              style: TextStyle(
                color: colorBlack,
                fontSize: width / 20.0,
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold,
                wordSpacing: 1.2,
                letterSpacing: 1.2,
              ),
            ),
            NeumorphicButton(
              onPressed: () => Get.toNamed(Routes.PICKADDRESSCART),
              duration: Duration(milliseconds: 200),
              style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(20.0),
                ),
                depth: 15.0,
                intensity: 1,
                color: colorPrimary.withOpacity(.85),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 28.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sensor_door_sharp,
                    color: mC,
                    size: width / 18.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'checkOut'.trArgs(),
                    style: TextStyle(
                      color: mC,
                      fontSize: width / 26.0,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
