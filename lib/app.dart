import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'viewmodels/auth/auth_view_model.dart';
import 'viewmodels/favorites/favorites_event.dart';
import 'viewmodels/favorites/favorites_view_model.dart';
import 'viewmodels/places/places_view_model.dart';
import 'viewmodels/places/places_event.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/places_repository.dart';
import 'views/auth/auth_landing_screen.dart';
import 'views/explore/explore_screen.dart';
import 'views/favorites/favorites_screen.dart';
import 'views/home/home_screen.dart';
import 'views/settings/settings_screen.dart';

class NileExplorerApp extends StatelessWidget {
  const NileExplorerApp({super.key});

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => PlacesRepository()),
        RepositoryProvider(create: (_) => FavoritesRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                PlacesBloc(placesRepository: context.read<PlacesRepository>())
                  ..add(const LoadPlaces()),
          ),
          BlocProvider(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) {
              final authRepository = context.read<AuthRepository>();
              final bloc = FavoritesBloc(
                favoritesRepository: context.read<FavoritesRepository>(),
              );
              final currentUser = authRepository.currentUser;
              if (currentUser != null) {
                bloc.add(LoadFavorites(userId: currentUser.uid));
              }
              return bloc;
            },
          ),
        ],
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          title: 'app_title'.tr(),
          theme: NileAppTheme.light(),
          builder: (context, child) {
            return BlocListener<AuthCubit, AuthState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.uid != current.uid,
              listener: (context, state) {
                if (state.isAuthenticated && state.uid != null) {
                  context.read<FavoritesBloc>().add(
                    LoadFavorites(userId: state.uid),
                  );
                } else {
                  context.read<FavoritesBloc>().add(const ClearFavorites());
                }

                if (state.status == AuthStatus.unauthenticated) {
                  return;
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  rootNavigatorKey.currentState?.popUntil(
                    (route) => route.isFirst,
                  );
                });
              },
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AppEntryScreen(),
        ),
      ),
    );
  }
}

class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          return const AuthLandingScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget?> _loadedScreens = <Widget?>[
    const HomeScreen(),
    null,
    null,
    null,
  ];

  late final List<Widget> _screenFactories = const [
    HomeScreen(),
    ExploreScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _NavDestination(
        label: 'navigation.home'.tr(),
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      _NavDestination(
        label: 'navigation.explore'.tr(),
        icon: Icons.travel_explore_outlined,
        selectedIcon: Icons.travel_explore_rounded,
      ),
      _NavDestination(
        label: 'navigation.favorites'.tr(),
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
      ),
      _NavDestination(
        label: 'navigation.settings'.tr(),
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 900;

        if (isTablet) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    backgroundColor: Colors.white,
                    labelType: NavigationRailLabelType.all,
                    indicatorColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.18),
                    destinations: destinations
                        .map(
                          (destination) => NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                        )
                        .toList(),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _resolvedScreens,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _resolvedScreens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: destinations
                .map(
                  (destination) => NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _onDestinationSelected(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _loadedScreens[index] ??= _screenFactories[index];
      _currentIndex = index;
    });
  }

  List<Widget> get _resolvedScreens => _loadedScreens
      .map((screen) => screen ?? const SizedBox.shrink())
      .toList(growable: false);
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
