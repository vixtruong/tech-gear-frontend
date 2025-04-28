import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techgear/dtos/rating_review_dto.dart';
import 'package:techgear/providers/user_provider/user_provider.dart';

class RatingCardSimple extends StatefulWidget {
  final RatingReviewDto rating;

  const RatingCardSimple({super.key, required this.rating});

  @override
  State<RatingCardSimple> createState() => _RatingCardSimpleState();
}

class _RatingCardSimpleState extends State<RatingCardSimple> {
  late UserProvider _userProvider;

  String? _userName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadInformations();
  }

  Future<void> _loadInformations() async {
    try {
      final userName = await _userProvider.fetchUserName(widget.rating.userId);

      setState(() {
        _userName = userName;
      });
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Avatar/Icon user
            const CircleAvatar(
              radius: 12, // nhỏ gọn
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              _userName ?? 'Unknown',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.rating.imgUrl.isNotEmpty
                  ? Image.network(
                      widget.rating.imgUrl,
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
            const SizedBox(width: 12),

            // Nội dung bên phải
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU: ${widget.rating.sku}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.rating.star
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  if (widget.rating.content != null &&
                      widget.rating.content!.isNotEmpty)
                    Text(
                      widget.rating.content!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Reviewed on: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.rating.lastUpdate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
