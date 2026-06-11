import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/favorites/favorites_view_model.dart';
import '../../viewmodels/favorites/favorites_event.dart';
import '../../viewmodels/favorites/favorites_state.dart';
import '../../viewmodels/places/places_view_model.dart';
import '../../viewmodels/places/places_event.dart';
import '../../viewmodels/places/places_state.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/places_repository.dart';
import '../../core/widgets/premium_image.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.place});

  final Place place;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FlutterTts tts = FlutterTts();
  bool isPlayingArabic = false;
  bool isPlayingEnglish = false;

  @override
  void initState() {
    super.initState();
    tts.setCompletionHandler(_resetAudioState);
    tts.setCancelHandler(_resetAudioState);
    tts.setErrorHandler((_) => _resetAudioState());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<PlacesBloc>().add(TrackPlaceView(widget.place.id));
    });
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  Future<void> _speak({
    required String text,
    required String languageCode,
    required bool isArabic,
  }) async {
    await tts.stop();
    _resetAudioState();
    await tts.setLanguage(languageCode);
    await tts.setSpeechRate(0.5);
    await tts.speak(text);
    if (!mounted) {
      return;
    }
    setState(() {
      isPlayingArabic = isArabic;
      isPlayingEnglish = !isArabic;
    });
  }

  Future<void> _stop() async {
    await tts.stop();
    _resetAudioState();
  }

  Future<void> _openMap() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.place.googleMapsQuery}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _resetAudioState() {
    if (!mounted) {
      return;
    }
    setState(() {
      isPlayingArabic = false;
      isPlayingEnglish = false;
    });
  }

  Future<void> _handleFavoriteToggle(bool isFavorite) async {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated) {
      await _showAuthRequiredSheet(
        titleKey: 'auth.favorites_lock_title',
        subtitleKey: 'auth.favorites_lock_subtitle',
      );
      return;
    }

    if (isFavorite) {
      context.read<FavoritesBloc>().add(RemoveFavorite(widget.place));
    } else {
      context.read<FavoritesBloc>().add(AddFavorite(widget.place));
    }
  }

  Future<void> _handleRatingSelected(double rating, {String? placeId}) async {
    final authState = context.read<AuthCubit>().state;
    final userId = authState.uid;

    if (!authState.isAuthenticated || userId == null) {
      await _showAuthRequiredSheet(
        titleKey: 'details.rating_lock_title',
        subtitleKey: 'details.rating_lock_subtitle',
      );
      return;
    }

    context.read<PlacesBloc>().add(
      RatePlace(
        placeId: placeId ?? widget.place.id,
        userId: userId,
        rating: rating,
      ),
    );
  }

  Future<void> _showAuthRequiredSheet({
    required String titleKey,
    required String subtitleKey,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleKey.tr(), style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  subtitleKey.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text('auth.sign_in'.tr()),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text('auth.create_account'.tr()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;

    final languageCode = context.locale.languageCode;
    final name = widget.place.localizedName(languageCode);
    final localizedDescription = widget.place.localizedDescription(
      languageCode,
    );

    return BlocListener<PlacesBloc, PlacesState>(
      listenWhen: (previous, current) {
        if (current is! PlacesLoaded) {
          return false;
        }

        final previousLoaded = previous is PlacesLoaded ? previous : null;
        return current.ratingErrorMessage !=
                previousLoaded?.ratingErrorMessage ||
            current.ratingSuccessPlaceId !=
                previousLoaded?.ratingSuccessPlaceId;
      },
      listener: (context, state) {
        if (state is! PlacesLoaded) {
          return;
        }

        if (state.ratingSuccessPlaceId == widget.place.id) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('details.rating_saved'.tr())));
        } else if (state.ratingErrorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('details.rating_error'.tr())));
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'place-image-${widget.place.id}',
                    child: PremiumImage(
                      imageUrl: widget.place.imageUrl,
                      height: 340,
                      width: double.infinity,
                      memCacheWidth: (MediaQuery.sizeOf(context).width * 2)
                          .round(),
                    ),
                  ),
                  Container(
                    height: 340,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: MediaQuery.paddingOf(context).top + 72,
                    end: 16,
                    child: _FloatingRatingBadge(place: widget.place),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
              StreamBuilder<Place>(
                stream: context.read<PlacesRepository>().watchPlace(
                  widget.place.id,
                ),
                initialData: widget.place,
                builder: (context, placeSnapshot) {
                  final currentPlace = placeSnapshot.data ?? widget.place;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _chip(
                              Icons.location_on,
                              _cityKey(widget.place.city).tr(),
                            ),
                            _chip(
                              Icons.category,
                              _categoryKey(widget.place.category).tr(),
                            ),
                            _chip(
                              Icons.star,
                              currentPlace.rating.toStringAsFixed(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _ImageGallery(place: currentPlace),
                        const SizedBox(height: 16),
                        BlocBuilder<PlacesBloc, PlacesState>(
                          buildWhen: (previous, current) {
                            if (current is! PlacesLoaded) {
                              return false;
                            }
                            if (previous is! PlacesLoaded) {
                              return true;
                            }
                            return current.ratingSubmissionPlaceId !=
                                previous.ratingSubmissionPlaceId;
                          },
                          builder: (context, state) {
                            final isSubmitting =
                                state is PlacesLoaded &&
                                state.isSubmittingRating(widget.place.id);
                            final userId = authState.uid;

                            if (authState.isAuthenticated && userId != null) {
                              return StreamBuilder<double?>(
                                stream: context
                                    .read<PlacesRepository>()
                                    .watchUserRating(
                                      placeId: widget.place.id,
                                      userId: userId,
                                    ),
                                builder: (context, ratingSnapshot) {
                                  return _RatingSection(
                                    place: currentPlace,
                                    userRating: ratingSnapshot.data,
                                    isSubmitting: isSubmitting,
                                    onRatingSelected: (rating) =>
                                        _handleRatingSelected(
                                          rating,
                                          placeId: currentPlace.id,
                                        ),
                                  );
                                },
                              );
                            }

                            return _RatingSection(
                              place: currentPlace,
                              userRating: null,
                              isSubmitting: isSubmitting,
                              onRatingSelected: (rating) =>
                                  _handleRatingSelected(
                                    rating,
                                    placeId: currentPlace.id,
                                  ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 430;

                            final arabicButton = ElevatedButton.icon(
                              onPressed: () async {
                                if (isPlayingArabic) {
                                  await _stop();
                                  return;
                                }
                                await _speak(
                                  text: widget.place.descriptionAr,
                                  languageCode: 'ar-EG',
                                  isArabic: true,
                                );
                              },
                              icon: Icon(
                                isPlayingArabic ? Icons.stop : Icons.mic,
                              ),
                              label: Text(
                                isPlayingArabic
                                    ? 'details.stop_audio'.tr()
                                    : 'details.listen_ar'.tr(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );

                            final englishButton = ElevatedButton.icon(
                              onPressed: () async {
                                if (isPlayingEnglish) {
                                  await _stop();
                                  return;
                                }
                                await _speak(
                                  text: widget.place.descriptionEn,
                                  languageCode: 'en-US',
                                  isArabic: false,
                                );
                              },
                              icon: Icon(
                                isPlayingEnglish
                                    ? Icons.stop
                                    : Icons.record_voice_over,
                              ),
                              label: Text(
                                isPlayingEnglish
                                    ? 'details.stop_audio'.tr()
                                    : 'details.listen_en'.tr(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );

                            if (stacked) {
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: arabicButton,
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: englishButton,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: arabicButton),
                                const SizedBox(width: 10),
                                Expanded(child: englishButton),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openMap,
                            icon: const Icon(Icons.map_outlined),
                            label: Text('details.open_in_maps'.tr()),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'details.about'.tr(),
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          localizedDescription,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 30),
                        BlocBuilder<FavoritesBloc, FavoritesState>(
                          builder: (context, state) {
                            final favorites = state is FavoritesLoaded
                                ? state.favorites
                                : const <Place>[];

                            final isFavorite = favorites.contains(widget.place);

                            return AnimatedScale(
                              scale: isFavorite ? 1.01 : 1,
                              duration: const Duration(milliseconds: 180),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _handleFavoriteToggle(isFavorite),
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: Icon(
                                      authState.isAuthenticated
                                          ? isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border
                                          : Icons.lock_outline_rounded,
                                      key: ValueKey(isFavorite),
                                    ),
                                  ),
                                  label: Text(
                                    authState.isAuthenticated
                                        ? isFavorite
                                              ? 'details.remove_from_favorites'
                                                    .tr()
                                              : 'details.add_to_favorites'.tr()
                                        : 'auth.sign_in_for_favorites'.tr(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Builder(
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.42,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 5),
              Expanded(
                child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingRatingBadge extends StatelessWidget {
  const _FloatingRatingBadge({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFD4AF37),
              size: 21,
            ),
            const SizedBox(width: 5),
            Text(
              place.rating.toStringAsFixed(1),
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('details.gallery'.tr(), style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 1,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return AspectRatio(
                aspectRatio: 1.35,
                child: Hero(
                  tag: 'place-gallery-${place.id}-$index',
                  child: PremiumImage(
                    imageUrl: place.imageUrl,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({
    required this.place,
    required this.userRating,
    required this.isSubmitting,
    required this.onRatingSelected,
  });

  final Place place;
  final double? userRating;
  final bool isSubmitting;
  final ValueChanged<double> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final summary = _RatingSummary(place: place);
              final controls = _RatingControls(
                rating: userRating ?? 0,
                isSubmitting: isSubmitting,
                onRatingSelected: onRatingSelected,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'details.rating_title'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (stacked) ...[
                    summary,
                    const SizedBox(height: 14),
                    controls,
                  ] else
                    Row(
                      children: [
                        Expanded(child: summary),
                        const SizedBox(width: 18),
                        SizedBox(width: 240, child: controls),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.star_rounded,
            color: Color(0xFFD4AF37),
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.rating.toStringAsFixed(1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
              ),
              Text(
                'details.rating_count'.tr(
                  namedArgs: {'count': place.ratingCount.toString()},
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingControls extends StatelessWidget {
  const _RatingControls({
    required this.rating,
    required this.isSubmitting,
    required this.onRatingSelected,
  });

  final double rating;
  final bool isSubmitting;
  final ValueChanged<double> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                rating > 0
                    ? 'details.your_rating'.tr()
                    : 'details.tap_to_rate'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (rating > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  rating.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9B7624),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _InteractiveStarRating(
                rating: rating,
                enabled: !isSubmitting,
                onChanged: onRatingSelected,
              ),
            ),
            if (isSubmitting) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _InteractiveStarRating extends StatelessWidget {
  const _InteractiveStarRating({
    required this.rating,
    required this.enabled,
    required this.onChanged,
  });

  final double rating;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          return _RatingStar(
            value: starValue,
            rating: rating,
            enabled: enabled,
            onChanged: onChanged,
          );
        }),
      ),
    );
  }
}

class _RatingStar extends StatelessWidget {
  const _RatingStar({
    required this.value,
    required this.rating,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final double rating;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final icon = rating >= value
        ? Icons.star_rounded
        : rating >= value - 0.5
        ? Icons.star_half_rounded
        : Icons.star_border_rounded;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (details) {
              final box = context.findRenderObject() as RenderBox?;
              final width = box?.size.width ?? 1;
              final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
              final isLeadingHalf = isRtl
                  ? details.localPosition.dx > width / 2
                  : details.localPosition.dx < width / 2;
              final selected = isLeadingHalf && value > 1 ? value - 0.5 : value;
              onChanged(selected.toDouble());
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Icon(
          icon,
          size: 34,
          color: enabled
              ? const Color(0xFFD4AF37)
              : const Color(0xFFD4AF37).withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

String _cityKey(String city) {
  return switch (city) {
    'Giza' => 'cities.giza',
    'Cairo' => 'cities.cairo',
    'Alexandria' => 'cities.alexandria',
    'Luxor' => 'cities.luxor',
    'Aswan' => 'cities.aswan',
    'Hurghada' => 'cities.hurghada',
    'Fayoum' => 'cities.fayoum',

    _ => 'cities.cairo',
  };
}

String _categoryKey(String category) {
  return switch (category) {
    'Temples' => 'categories.temples',
    'Museums' => 'categories.museums',
    'Beaches' => 'categories.beaches',
    'Bazaars' => 'categories.bazaars',
    _ => 'categories.temples',
  };
}
