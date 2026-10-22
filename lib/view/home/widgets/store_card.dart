import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "/models/store_model.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_card.dart";

class StoreCard extends StatelessWidget {
  final StoreModel store;

  const StoreCard({
    super.key,
    required this.store,
  });

  void _copyCoordinates(BuildContext context) {
    Clipboard.setData(ClipboardData(text: "${store.latitude}, ${store.longitude}"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Coordinates copied: ${store.latitude}, ${store.longitude}"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MonochromeCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc950,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.zinc300, width: 1),
                ),
                child: Text(
                  AppFormatters.maskToken(store.id, prefix: 6, suffix: 4),
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: "monospace",
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.location_on_outlined, size: 16, color: AppColors.zinc500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  store.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.zinc700,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.my_location, size: 14, color: AppColors.zinc500),
                  const SizedBox(width: 6),
                  Text(
                    "${store.latitude}, ${store.longitude}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "monospace",
                      fontWeight: FontWeight.w500,
                      color: AppColors.zinc600,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _copyCoordinates(context),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 13, color: AppColors.zinc700),
                      SizedBox(width: 4),
                      Text(
                        "Copy",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
