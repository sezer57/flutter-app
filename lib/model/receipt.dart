import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter_application_1/model/customer.dart';

class Receipt {
  final List<ReceiptItem> items;
  final String type;
  final Customer customer;
  final Supplier supplier;

  Receipt({
    required this.items,
    required this.type,
    required this.customer,
    required this.supplier,
  });
}


  get type => null;

  get dueDate => null;

class ReceiptItem {
  final String description;
  final DateTime date;
  final double balance;
  final double amount;

  ReceiptItem({
    required this.description,
    required this.date,
    required this.balance,
    required this.amount,
  });
}

