import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter/material.dart'; // Importing for the use of the DateTime type

class Stock {
  final List<StockItem> items;
  const Stock({
    required this.items,
  });
}

class StockItem {
  final int stockId;
  final String stockName;
  final String stockCode;
  final String barcode;
  final String groupName;
  final String middleGroupName;
  final String unit;
  final int salesPrice;
  final int purchasePrice;
  final int warehouseId;
  final DateTime registrationDate;

  const StockItem({
    required this.stockId,
    required this.stockName,
    required this.stockCode,
    required this.barcode,
    required this.groupName,
    required this.middleGroupName,
    required this.unit,
    required this.salesPrice,
    required this.purchasePrice,
    required this.warehouseId,
    required this.registrationDate,
  });

}
