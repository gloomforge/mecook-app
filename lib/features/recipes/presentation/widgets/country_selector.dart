import 'package:flutter/material.dart';
import 'package:mecook_application/features/recipes/data/models/country.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mecook_application/core/constants.dart';

class CountrySelector extends StatelessWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final Function(Country) onCountrySelected;
  final bool isLoading;

  const CountrySelector({
    Key? key,
    required this.countries,
    this.selectedCountry,
    required this.onCountrySelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (countries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Страны не найдены",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: countries.length + 1, 
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCountry == null;
            return GestureDetector(
              onTap: () => onCountrySelected(Country(id: -1, name: "Все", imageUrl: null)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.accentColor : Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: isSelected 
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Все",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final country = countries[index - 1];
          final isSelected = selectedCountry?.id == country.id;
          
          return GestureDetector(
            onTap: () => onCountrySelected(country),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.accentColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: ClipOval(
                      child: country.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: country.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 