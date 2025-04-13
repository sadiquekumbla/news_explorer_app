import 'package:flutter/material.dart';
import '../models/category.dart';
import '../providers/news_provider.dart';
import 'package:provider/provider.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        final categories = newsProvider.categories;
        final currentCategory = newsProvider.currentCategory;
        final isLoading = newsProvider.isLoading;

        if (isLoading && categories.isEmpty) {
          return _buildLoadingGrid();
        }

        if (categories.isEmpty) {
          return Center(
            child: Text(
              'No categories available',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.id == currentCategory;

            return _buildCategoryCard(
              context,
              category,
              isSelected,
              newsProvider,
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Category category,
    bool isSelected,
    NewsProvider newsProvider,
  ) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isSelected ? Theme.of(context).primaryColor : Colors.white,
      child: InkWell(
        onTap: () => newsProvider.selectCategory(category.id),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
} 