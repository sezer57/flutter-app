import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter/material.dart'; // Importing for the use of the DateTime type

class Client {

  final List<ClientItem> items;
  const Client({

    required this.items,
  });
}

class ClientItem {
  final int clientCode;
  final String commercialTitle;
  final String name;
  final String surname;
  final String address;
  final String country;
  final String city;
  final String phone;
  final String gsm;
  final DateTime registrationDate;

  const ClientItem({
    required this.clientCode,
    required this.commercialTitle,
    required this.name,
    required this.surname,
    required this.address,
    required this.country,
    required this.city,
    required this.phone,
    required this.gsm,
    required this.registrationDate,
  });

}
