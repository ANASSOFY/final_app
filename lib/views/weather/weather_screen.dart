import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/services/weather_service.dart';
import '../../data/models/weather_model.dart';

class WeatherSummaryCard extends StatefulWidget {
  const WeatherSummaryCard({super.key, required this.city, required this.name});

  final String city;
  final String name;

  @override
  State<WeatherSummaryCard> createState() => _WeatherSummaryCardState();
}

class _WeatherSummaryCardState extends State<WeatherSummaryCard> {
  late final WeatherService _weatherService;
  late Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService();
    _weatherFuture = _weatherService.getWeatherForGovernorate(widget.city);
  }

  void _retry() {
    setState(() {
      _weatherFuture = _weatherService.getWeatherForGovernorate(widget.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Weather>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        final weather = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting &&
            weather == null) {
          return const _WeatherLoadingCard();
        }

        if (snapshot.hasError && weather == null) {
          return _WeatherErrorCard(onRetry: _retry);
        }

        if (weather == null) {
          return const SizedBox.shrink();
        }

        return _WeatherCompactCard(
          weather: weather,
          name: widget.name,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WeatherScreen(
                  city: widget.city,
                  name: widget.name,
                  initialWeather: weather,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    required this.city,
    required this.name,
    this.initialWeather,
  });

  final String city;
  final String name;
  final Weather? initialWeather;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final WeatherService _weatherService;
  late Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService();
    _weatherFuture = _weatherService.getWeatherForGovernorate(widget.city);
  }

  void _retry() {
    setState(() {
      _weatherFuture = _weatherService.getWeatherForGovernorate(widget.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('weather.title'.tr())),
      body: SafeArea(
        child: FutureBuilder<Weather>(
          future: _weatherFuture,
          initialData: widget.initialWeather,
          builder: (context, snapshot) {
            final weather = snapshot.data;

            if (snapshot.connectionState == ConnectionState.waiting &&
                weather == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && weather == null) {
              return _WeatherFullError(onRetry: _retry);
            }

            if (weather == null) {
              return const SizedBox.shrink();
            }

            return RefreshIndicator(
              onRefresh: () async => _retry(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: [
                  _WeatherHero(weather: weather, name: widget.name),
                  const SizedBox(height: 18),
                  Text(
                    'weather.details'.tr(),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _WeatherDetailsGrid(weather: weather),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeatherCompactCard extends StatelessWidget {
  const _WeatherCompactCard({
    required this.weather,
    required this.name,
    required this.onTap,
  });

  final Weather weather;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF153F4A),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF153F4A).withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              _WeatherIcon(iconUrl: weather.iconUrl, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'weather.current'.tr(namedArgs: {'city': name}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _capitalize(weather.description),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${weather.temperature.round()}°',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherHero extends StatelessWidget {
  const _WeatherHero({required this.weather, required this.name});

  final Weather weather;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF153F4A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF153F4A).withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              _WeatherIcon(iconUrl: weather.iconUrl, size: 72),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${weather.temperature.round()}°C',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFFD4AF37),
              fontSize: 58,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _capitalize(weather.description),
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'weather.updated_at'.tr(
              namedArgs: {
                'time': DateFormat('h:mm a').format(weather.fetchedAt),
              },
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherDetailsGrid extends StatelessWidget {
  const _WeatherDetailsGrid({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 620 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: constraints.maxWidth > 620 ? 1.45 : 1.18,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _WeatherMetricTile(
              icon: Icons.thermostat_rounded,
              label: 'weather.feels_like'.tr(),
              value: '${weather.feelsLike.round()}°C',
            ),
            _WeatherMetricTile(
              icon: Icons.water_drop_outlined,
              label: 'weather.humidity'.tr(),
              value: '${weather.humidity}%',
            ),
            _WeatherMetricTile(
              icon: Icons.air_rounded,
              label: 'weather.wind'.tr(),
              value: 'weather.wind_value'.tr(
                namedArgs: {'value': weather.windSpeed.toStringAsFixed(1)},
              ),
            ),
            _WeatherMetricTile(
              icon: Icons.device_thermostat_rounded,
              label: 'weather.range'.tr(),
              value:
                  '${weather.minTemperature.round()}° / ${weather.maxTemperature.round()}°',
            ),
          ],
        );
      },
    );
  }
}

class _WeatherMetricTile extends StatelessWidget {
  const _WeatherMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 24),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherLoadingCard extends StatelessWidget {
  const _WeatherLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'weather.loading'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherErrorCard extends StatelessWidget {
  const _WeatherErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Color(0xFFB86A4F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'weather.error_message'.tr(),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          TextButton(onPressed: onRetry, child: Text('weather.retry'.tr())),
        ],
      ),
    );
  }
}

class _WeatherFullError extends StatelessWidget {
  const _WeatherFullError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Color(0xFFB86A4F),
            ),
            const SizedBox(height: 12),
            Text(
              'weather.error_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'weather.error_message'.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('weather.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.iconUrl, required this.size});

  final String iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      iconUrl,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.wb_sunny_rounded,
          size: size * 0.62,
          color: const Color(0xFFD4AF37),
        );
      },
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
}
