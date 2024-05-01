import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;
  final String type;
  const Invoice(
      {required this.info,
      required this.supplier,
      required this.customer,
      required this.items,
      required this.type});
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,

  });

  get type => null;
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}
