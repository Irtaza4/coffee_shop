import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/coffee.dart';
import '../viewmodels/shop_view_model.dart';
import '../widgets/controls.dart';
import '../widgets/product_card.dart';
import 'product_view.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({
    super.key,
    required this.model,
    this.explore = false,
    this.favorites = false,
  });
  final ShopViewModel model;
  final bool explore, favorites;
  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final PageController _pages = PageController(viewportFraction: .82);
  int _page = 0;
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _open(Coffee coffee, String tag) => Navigator.of(context).push(
    coffeeRoute(ProductView(coffee: coffee, shop: widget.model, heroTag: tag)),
  );
  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final items = widget.favorites ? model.favorites : model.filtered;
    final grid = widget.explore || widget.favorites;
    return Column(
      children: [
        if (grid)
          PageHeading(
            widget.favorites ? 'Favorites' : 'Explore',
            onBack: () => model.selectTab(0),
            trailing: widget.explore
                ? RoundButton(
                    icon: Icons.tune_rounded,
                    onTap: () => _showFilters(context),
                    label: 'Filter coffee',
                  )
                : null,
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hello,\nJenny Wilson',
                    style: TextStyle(
                      fontSize: 23,
                      height: 1.22,
                      letterSpacing: -.8,
                    ),
                  ),
                ),
                RoundButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) => const SizedBox(
                      height: 280,
                      child: EmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: 'All caught up',
                        message:
                            'Fresh coffee and good things are on their way.',
                      ),
                    ),
                  ),
                  label: 'Notifications',
                ),
                const SizedBox(width: 10),
                Pressable(
                  onTap: () => model.selectTab(4),
                  label: 'Open profile',
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFF2E1D1),
                    child: Text(
                      'JW',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF79543D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (!widget.favorites && !widget.explore) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextFormField(
              initialValue: model.query,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onChanged: (value) {
                model.search(value);
                if (_pages.hasClients) _pages.jumpToPage(0);
              },
              decoration: const InputDecoration(
                hintText: 'Search your favorite coffee',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 5,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = [
                  'All',
                  'Latte',
                  'Cappuccino',
                  'Mocha',
                  'Americano',
                ][index];
                final selected = model.category == category;
                return Pressable(
                  onTap: () {
                    model.selectCategory(category);
                    _page = 0;
                    if (_pages.hasClients) _pages.jumpToPage(0);
                  },
                  label: '$category category',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.ink : const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : AppTheme.ink,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
        ],
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: widget.favorites
                      ? Icons.favorite_border_rounded
                      : Icons.search_off_rounded,
                  title: widget.favorites
                      ? 'Love at first sip'
                      : 'No coffee found',
                  message: widget.favorites
                      ? 'Tap the heart on any coffee to keep your favorites here.'
                      : 'Try another name or coffee category.',
                )
              : grid
              ? _grid(items)
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pages,
                        itemCount: items.length,
                        onPageChanged: (value) => setState(() => _page = value),
                        itemBuilder: (context, index) {
                          final coffee = items[index],
                              tag = 'home-${items[index].id}';
                          return AnimatedScale(
                            scale: _page == index ? 1 : .94,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: ProductCard(
                                coffee: coffee,
                                onOpen: () => _open(coffee, tag),
                                onFavorite: () => model.toggleFavorite(coffee),
                                favorite: model.isFavorite(coffee),
                                heroTag: tag,
                                large: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 14, 26, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: List.generate(
                                items.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.only(right: 5),
                                  width: index == _page ? 22 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index == _page
                                        ? AppTheme.ink
                                        : const Color(0xFFDCE0E5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => model.selectTab(2),
                            child: const Row(
                              children: [
                                Text(
                                  'Explore all',
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 15),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _grid(List<Coffee> items) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        2,
        (column) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: column == 1 ? 7 : 0,
              right: column == 0 ? 7 : 0,
            ),
            child: Column(
              children: [
                if (column == 1)
                  Container(
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.mist,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${items.length} coffees',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Icon(Icons.coffee_outlined, size: 18),
                      ],
                    ),
                  ),
                for (int index = column; index < items.length; index += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SizedBox(
                      height: 252,
                      child: ProductCard(
                        coffee: items[index],
                        onOpen: () => _open(
                          items[index],
                          '${widget.favorites ? 'favorite' : 'explore'}-${items[index].id}',
                        ),
                        onFavorite: () =>
                            widget.model.toggleFavorite(items[index]),
                        favorite: widget.model.isFavorite(items[index]),
                        heroTag:
                            '${widget.favorites ? 'favorite' : 'explore'}-${items[index].id}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  void _showFilters(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find your next favorite',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Latte', 'Cappuccino', 'Mocha', 'Americano']
                .map(
                  (category) => ChoiceChip(
                    label: Text(category),
                    selected: widget.model.category == category,
                    onSelected: (_) {
                      widget.model.selectCategory(category);
                      widget.model.search('');
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_outline_rounded),
            title: const Text('Highest rated first'),
            trailing: Switch(
              value: widget.model.topRated,
              onChanged: (value) {
                widget.model.toggleSort();
                Navigator.pop(context);
              },
            ),
            onTap: () {
              widget.model.toggleSort();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
