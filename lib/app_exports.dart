// Export commun pour toute l'application
export 'package:flutter/material.dart';
export 'package:firebase_auth/firebase_auth.dart' hide User;

// Core
export 'core/navigation/main_navigation.dart';
export 'core/theme/app_theme.dart';

// Widgets partagés
export 'core/widgets/shared/lebondeal_logo.dart';
export 'core/widgets/shared/search_bar.dart' hide SearchBar;
export 'core/widgets/shared/common_widgets.dart';

// Features - Auth
export 'features/auth/presentation/pages/login_page.dart';
export 'features/auth/presentation/pages/register_page.dart';

// Features - Deals
export 'features/deals/domain/entities/deal.dart';
export 'features/deals/presentation/pages/trending_page.dart';
export 'features/deals/presentation/pages/saved_deals_page.dart';
export 'features/deals/presentation/pages/add_deal_page.dart';
export 'features/deals/presentation/widgets/deal_card.dart';

// Features - Categories
export 'features/categories/data/models/category.dart';
export 'features/categories/presentation/widgets/category_chip.dart';

// Features - Profile
export 'features/profile/presentation/pages/profile_page.dart';

// Features - Home
export 'features/home/presentation/pages/home_page.dart';
