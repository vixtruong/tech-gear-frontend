import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techgear/dtos/rating_review_dto.dart';

class RatingCard extends StatelessWidget {
  final RatingReviewDto rating;

  const RatingCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: rating.imgUrl.isNotEmpty
                    ? Image.network(
                        rating.imgUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                // 🔥 Để tự co giãn đúng chuẩn
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rating.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1, // 🔥 chỉ 1 dòng
                      overflow: TextOverflow.ellipsis, // 🔥 quá dài thì "..."
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${rating.sku}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1, // 🔥 chỉ 1 dòng
                      overflow: TextOverflow.ellipsis, // 🔥 quá dài thì "..."
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Star rating
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.star ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 8),
          // Content
          if (rating.content != null && rating.content!.isNotEmpty)
            Text(
              rating.content!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 8),
          // Last Update
          Text(
            'Reviewed on: ${DateFormat('dd/MM/yyyy HH:mm').format(rating.lastUpdate)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
