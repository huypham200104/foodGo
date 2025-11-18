import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddAddressWidget extends StatefulWidget {
  final String userId;

  const AddAddressWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _AddAddressWidgetState createState() => _AddAddressWidgetState();
}

class _AddAddressWidgetState extends State<AddAddressWidget> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _detailController = TextEditingController();
  final _cityController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = false;

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newAddress = AddressModel(
        id: '',
        userId: widget.userId,
        label: _labelController.text.trim(),
        name: _labelController.text.trim(),
        detail: _detailController.text.trim(),
        city: _cityController.text.trim(),
        ward: _wardController.text.trim(),
        district: _districtController.text.trim(),
        phone: _phoneController.text.trim(),
        isDefault: _isDefault,
        createdAt: DateTime.now(),
      );

      try {
        await AddressService.addAddress(newAddress);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Địa chỉ đã được thêm thành công!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm địa chỉ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm địa chỉ mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Tên địa chỉ'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên địa chỉ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: 'Địa chỉ chi tiết'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa chỉ chi tiết';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Thành phố'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập thành phố';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _wardController,
                decoration: const InputDecoration(labelText: 'Phường/Xã'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập phường/xã';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'Quận/Huyện'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập quận/huyện';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              SwitchListTile(
                title: const Text('Đặt làm địa chỉ mặc định'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Thêm địa chỉ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _detailController.dispose();
    _cityController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
