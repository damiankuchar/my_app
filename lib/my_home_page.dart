import 'package:flutter/material.dart';
import 'package:my_app/my_model.dart';
import 'package:intl/intl.dart';

import 'leaves_types.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MyModel myModel = MyModel();
  LeaveType? selectedItem;

  final dateFromController = TextEditingController();
  final dateToController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  static const int remainingDays = 10;

  @override
  void initState() {
    selectedItem = leavesTypes[0];
    super.initState();
  }

  @override
  void dispose() {
    dateFromController.dispose();
    dateToController.dispose();
    super.dispose();
  }

  Widget _buildFormTitle() {
    return const Text(
      "Dodaj",
      style: TextStyle(
        fontSize: 25,
      ),
    );
  }

  Widget _buildDropdownLeavesType() {
    return DropdownButtonFormField<LeaveType>(
      value: selectedItem,
      isExpanded: true,
      decoration: const InputDecoration(
          labelText: "Type",
          prefixIcon: Icon(
            Icons.person,
            color: Colors.blue,
          )),
      onChanged: (value) {
        setState(() {
          myModel.id = value?.id;
          selectedItem = value!;
        });
      },
      items: leavesTypes.map(
        (type) {
          return DropdownMenuItem<LeaveType>(
            value: type,
            child: Text(type.name),
          );
        },
      ).toList(),
    );
  }

  Widget _buildDateFromFieldForm(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Date from",
        prefixIcon: Icon(Icons.calendar_month_rounded),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      controller: dateFromController,
      onTap: () async {
        final pickedDate = await _pickDate(context, myModel.dateFrom);
        setState(() {
          myModel.dateFrom = pickedDate;
        });

        if (pickedDate != null) {
          dateFromController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        } else {
          dateFromController.text = "";
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter date";
        }
        return null;
      },
    );
  }

  Widget _buildDateToFieldForm(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Date to",
        prefixIcon: Icon(Icons.calendar_month_rounded),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      controller: dateToController,
      onTap: () async {
        final pickedDate = await _pickDate(context, myModel.dateTo);
        setState(() {
          myModel.dateTo = pickedDate;
        });

        if (pickedDate != null) {
          dateToController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        } else {
          dateToController.text = "";
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter date";
        } else if (myModel.dateFrom != null && myModel.dateTo != null) {
          if (myModel.dateTo!.isBefore(myModel.dateFrom!)) {
            return "Please enter valid range";
          }

          final daysOfLeave = _countLeaveDays();
          if (daysOfLeave > remainingDays) {
            return "You do not have enough days";
          }
        }
        return null;
      },
    );
  }

  Widget _buildLeavesDaysInfo() {
    if (myModel.dateFrom == null || myModel.dateTo == null) {
      return Container();
    }

    final daysOfLeave = _countLeaveDays();

    if (daysOfLeave < 1) {
      return Container();
    }

    return Column(
      children: [
        Text(
          "Days: $daysOfLeave",
          style: TextStyle(
            fontSize: 20,
            color: daysOfLeave > remainingDays ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Description",
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          myModel.description = value;
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        final isFormValid = formKey.currentState!.validate();

        if (isFormValid) {
          debugPrint("ID: ${myModel.id}");
          debugPrint("Date from: ${myModel.dateFrom}");
          debugPrint("Date to: ${myModel.dateTo}");
          debugPrint("Description: ${myModel.description}");
        }
      },
      child: const Text("Submit"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("App bar"),
        ),
        body: Form(
          autovalidateMode: AutovalidateMode.always,
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                _buildFormTitle(),
                const SizedBox(height: 20),
                _buildDropdownLeavesType(),
                const SizedBox(height: 30),
                _buildDateFromFieldForm(context),
                const SizedBox(height: 30),
                _buildDateToFieldForm(context),
                const SizedBox(height: 30),
                _buildLeavesDaysInfo(),
                _buildDescription(),
                // const SizedBox(height: 30),
                const Spacer(),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _pickDate(BuildContext context, DateTime? date) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: date ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (newDate == null) {
      return;
    }

    return newDate;
  }

  int _countLeaveDays() {
    return myModel.dateTo!.difference(myModel.dateFrom!).inDays + 1;
  }
}
