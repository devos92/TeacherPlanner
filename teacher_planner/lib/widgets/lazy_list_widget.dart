// lib/widgets/lazy_list_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/lazy_loading_service.dart';

/// A reusable lazy loading list widget with virtual scrolling and pagination
class LazyListWidget<T> extends StatefulWidget {
  final Future<LazyLoadResult<List<T>>> Function(int page, int pageSize) loadData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadMoreBuilder;
  final VoidCallback? onRefresh;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final int pageSize;
  final int preloadThreshold;
  final bool enablePullToRefresh;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String? cacheKey;

  const LazyListWidget({
    Key? key,
    required this.loadData,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadMoreBuilder,
    this.onRefresh,
    this.scrollController,
    this.padding,
    this.pageSize = 20,
    this.preloadThreshold = 5,
    this.enablePullToRefresh = true,
    this.shrinkWrap = false,
    this.physics,
    this.cacheKey,
  }) : super(key: key);

  @override
  State<LazyListWidget<T>> createState() => _LazyListWidgetState<T>();
}

class _LazyListWidgetState<T> extends State<LazyListWidget<T>> {
  final List<T> _items = [];
  late ScrollController _scrollController;
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.loadData(0, widget.pageSize);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          
          if (result.isError) {
            _error = result.error;
          } else if (result.data != null) {
            _items.clear();
            _items.addAll(result.data!);
            _currentPage = 0;
            _hasMore = _checkHasMore(result);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final result = await widget.loadData(nextPage, widget.pageSize);
      
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          
          if (!result.isError && result.data != null) {
            _items.addAll(result.data!);
            _currentPage = nextPage;
            _hasMore = _checkHasMore(result);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  bool _checkHasMore(LazyLoadResult<List<T>> result) {
    // Check if result has hasMore property (for paginated results)
    if (result is CurriculumResult) {
      return result.hasMore;
    } else if (result is TermEventsResult) {
      return result.hasMore;
    } else if (result is LongTermPlansResult) {
      return result.hasMore;
    }
    
    // Fallback: check if we got a full page
    return result.data?.length == widget.pageSize;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final scrollPosition = _scrollController.position;
    final maxScroll = scrollPosition.maxScrollExtent;
    final currentScroll = scrollPosition.pixels;
    
    // Calculate threshold for preloading
    final threshold = maxScroll * 0.8; // Load when 80% scrolled
    
    if (currentScroll >= threshold && _hasMore && !_isLoadingMore) {
      _loadMoreData();
    }
  }

  Future<void> _onRefresh() async {
    if (widget.onRefresh != null) {
      widget.onRefresh!.call();
    }
    await _loadInitialData();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return _buildLoadingWidget();
    }

    if (_error != null && _items.isEmpty) {
      return _buildErrorWidget();
    }

    if (_items.isEmpty) {
      return _buildEmptyWidget();
    }

    Widget listView = ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return _buildLoadMoreWidget();
        }
        
        return widget.itemBuilder(context, _items[index], index);
      },
    );

    if (widget.enablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildLoadingWidget() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pull to refresh or check back later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget() {
    if (widget.loadMoreBuilder != null) {
      return widget.loadMoreBuilder!(context);
    }

    if (_isLoadingMore) {
      return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Loading more...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}

/// Virtual scrolling widget for large datasets
class VirtualScrollWidget<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double itemHeight;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final int bufferSize;

  const VirtualScrollWidget({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.itemHeight,
    this.scrollController,
    this.padding,
    this.bufferSize = 10,
  }) : super(key: key);

  @override
  State<VirtualScrollWidget<T>> createState() => _VirtualScrollWidgetState<T>();
}

class _VirtualScrollWidgetState<T> extends State<VirtualScrollWidget<T>> {
  late ScrollController _scrollController;
  int _startIndex = 0;
  int _endIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_updateVisibleRange);
    _updateVisibleRange();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _updateVisibleRange() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    final itemsPerViewport = (viewportHeight / widget.itemHeight).ceil();
    final startIndex = (scrollOffset / widget.itemHeight).floor();
    
    setState(() {
      _startIndex = (startIndex - widget.bufferSize).clamp(0, widget.items.length);
      _endIndex = (startIndex + itemsPerViewport + widget.bufferSize).clamp(0, widget.items.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.items.length * widget.itemHeight;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            height: totalHeight,
            child: Stack(
              children: [
                // Render only visible items
                for (int i = _startIndex; i < _endIndex; i++)
                  Positioned(
                    top: i * widget.itemHeight,
                    left: 0,
                    right: 0,
                    height: widget.itemHeight,
                    child: widget.itemBuilder(context, widget.items[i], i),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Infinite scroll widget with automatic pagination
class InfiniteScrollWidget<T> extends StatefulWidget {
  final Future<LazyLoadResult<List<T>>> Function(int page) loadPage;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final int pageSize;
  final EdgeInsetsGeometry? padding;

  const InfiniteScrollWidget({
    Key? key,
    required this.loadPage,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.pageSize = 20,
    this.padding,
  }) : super(key: key);

  @override
  State<InfiniteScrollWidget<T>> createState() => _InfiniteScrollWidgetState<T>();
}

class _InfiniteScrollWidgetState<T> extends State<InfiniteScrollWidget<T>> {
  final List<T> _allItems = [];
  final ScrollController _scrollController = ScrollController();
  
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.loadPage(_currentPage);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          
          if (result.isError) {
            _error = result.error;
          } else if (result.data != null) {
            _allItems.addAll(result.data!);
            _currentPage++;
            _hasMore = result.data!.length == widget.pageSize;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allItems.isEmpty && _isLoading) {
      return widget.loadingBuilder?.call(context) ?? 
        Center(child: CircularProgressIndicator());
    }

    if (_allItems.isEmpty && _error != null) {
      return widget.errorBuilder?.call(context, _error!) ?? 
        Center(child: Text('Error: $_error'));
    }

    if (_allItems.isEmpty) {
      return widget.emptyBuilder?.call(context) ?? 
        Center(child: Text('No items'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _allItems.length + (_hasMore || _isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _allItems.length) {
          return Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: _isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
          );
        }

        return widget.itemBuilder(context, _allItems[index], index);
      },
    );
  }
} 