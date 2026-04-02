import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category.dart';
import '../bloc/add_deal_bloc.dart';
import '../widgets/category_selector.dart';
import '../widgets/price_field.dart';
import '../widgets/description_field.dart';
import '../widgets/text_form_field.dart';

class AddDealFormWidget extends StatelessWidget {
  const AddDealFormWidget({
    super.key,
    required this.bloc,
    required this.categories,
  });

  final AddDealBloc bloc;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: bloc.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            controller: bloc.titleController,
            label: 'Titre du deal',
            hint: 'Ex: MacBook Pro M3 -30%',
          ),
          const SizedBox(height: 16),
          DescriptionField(
            controller: bloc.descriptionController,
            label: 'Description',
            hint: 'Décrivez le deal en détail...',
          ),
          const SizedBox(height: 16),
          CategorySelector(
            selectedCategoryId: bloc.selectedCategoryId,
            categories: categories,
            onChanged: (value) {
              if (value != null) {
                bloc.updateCategory(value);
              }
            },
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: bloc.storeNameController,
            label: 'Nom du magasin',
            hint: 'Ex: Apple Store',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PriceField(
                  controller: bloc.priceController,
                  label: 'Prix actuel',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PriceField(
                  controller: bloc.originalPriceController,
                  label: 'Prix original',
                  isRequired: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: bloc.imageUrlController,
            label: 'URL de l\'image',
            hint: 'https://exemple.com/image.jpg',
            isRequired: false,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}
