import 'package:flutter/material.dart';
import '../bloc/add_deal_bloc.dart';
import '../widgets/auth_guard_widget.dart';
import '../widgets/add_deal_form_widget.dart';
import '../widgets/deal_preview_widget.dart';
import '../widgets/form_header.dart';

class AddDealPage extends StatefulWidget {
  const AddDealPage({super.key, this.onDealAdded});

  final VoidCallback? onDealAdded;

  @override
  State<AddDealPage> createState() => _AddDealPageState();
}

class _AddDealPageState extends State<AddDealPage> {
  late final AddDealBloc _addDealBloc;

  @override
  void initState() {
    super.initState();
    _addDealBloc = AddDealBloc();
  }

  @override
  void dispose() {
    _addDealBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuardWidget(
      child: AnimatedBuilder(
        animation: _addDealBloc,
        builder: (context, child) {
          return Scaffold(
            appBar: FormHeader(
              isSubmitting: _addDealBloc.isSubmitting,
              onPublish: _handleSubmit,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AddDealFormWidget(
                    bloc: _addDealBloc,
                    categories: _addDealBloc.categories,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prévisualisation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPreview(_addDealBloc),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview(AddDealBloc bloc) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        bloc.titleController,
        bloc.descriptionController,
        bloc.storeNameController,
        bloc.priceController,
        bloc.originalPriceController,
        bloc.imageUrlController,
      ]),
      builder: (context, child) {
        final title = bloc.titleController.text.trim();
        final description = bloc.descriptionController.text.trim();
        final storeName = bloc.storeNameController.text.trim();
        final priceText = bloc.priceController.text.trim();
        final originalPriceText = bloc.originalPriceController.text.trim();
        final imageUrl = bloc.imageUrlController.text.trim();

        final price = double.tryParse(priceText) ?? 0;
        final originalPrice = originalPriceText.isNotEmpty
            ? double.tryParse(originalPriceText)
            : null;

        return DealPreviewWidget(
          title: title,
          description: description,
          storeName: storeName,
          price: price,
          originalPrice: originalPrice,
          imageUrl: imageUrl,
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    try {
      await _addDealBloc.submitDeal(widget.onDealAdded);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deal publié avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
