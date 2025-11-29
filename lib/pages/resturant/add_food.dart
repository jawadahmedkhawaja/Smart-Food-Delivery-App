import 'package:flutter/material.dart';
import '../../resources/auth_methods.dart';
import '../../resources/data_to_db.dart';
import '../../utils/cloudnary_upload.dart';
import '../../utils/snack_bar.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  String? imagePath; // final Cloudinary image URL
  bool isUploadingImage = false;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFF8C42);
    const Color accentOrange = Color(0xFFFFA559);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Add item in Menu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Card(
              elevation: 6,
              shadowColor: primaryOrange.withAlpha(30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    // NAME
                    TextFormField(
                      controller: nameController,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Food Name is required'
                              : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.fastfood_sharp),
                        labelText: 'Food Name',
                        border: border,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // DESCRIPTION
                    TextFormField(
                      controller: descriptionController,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Description is required'
                              : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.description_outlined),
                        labelText: 'Description',
                        border: border,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // PRICE
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        try {
                          if (double.parse(value) <= 10) {
                            return 'Price must be greater than \$10';
                          }
                        } catch (_) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.monetization_on_outlined),
                        labelText: 'Price',
                        border: border,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // IMAGE UPLOAD SECTION
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            imagePath != null
                                ? 'Image Uploaded'
                                : 'No Image Selected',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: isUploadingImage
                              ? null
                              : () async {
                                  setState(() => isUploadingImage = true);

                                  final url =
                                      await CloudinaryService.uploadFile();

                                  setState(() {
                                    imagePath = url;
                                    isUploadingImage = false;
                                  });

                                  if (url != null) {
                                    showSnackBar(context, 'Image uploaded!');
                                  } else {
                                    showSnackBar(context,
                                        'Image upload failed. Try again.');
                                  }
                                },
                          child: isUploadingImage
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Choose Image'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // BUTTON
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;

                              if (imagePath == null) {
                                showSnackBar(
                                    context, 'Please select an image first');
                                return;
                              }

                              setState(() => isSaving = true);

                              final name = nameController.text.trim();
                              final description =
                                  descriptionController.text.trim();
                              final price = priceController.text.trim();

                              await uploadDetails(
                                context,
                                AuthMethods().currentUser!.uid,
                                name,
                                description,
                                price,
                                imagePath!,
                              );

                              setState(() => isSaving = false);

                              showSnackBar(
                                  context, 'Food item added successfully!');

                              Navigator.pushReplacementNamed(
                                  context, '/resturant');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Food Item'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
