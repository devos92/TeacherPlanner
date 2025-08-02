// lib/widgets/loading_shimmer.dart

import 'package:flutter/material.dart';

/// Fast, lightweight loading shimmer for weekly plan cells
class LoadingShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const LoadingShimmer({
    Key? key,
    required this.child,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(LoadingShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isLoading) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(_animation.value * 200, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Fast skeleton cell for weekly planner
class WeeklyPlanSkeleton extends StatelessWidget {
  final int periods;
  final bool isVerticalLayout;

  const WeeklyPlanSkeleton({
    Key? key,
    required this.periods,
    required this.isVerticalLayout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isVerticalLayout) {
      return _buildVerticalSkeleton();
    } else {
      return _buildHorizontalSkeleton();
    }
  }

  Widget _buildVerticalSkeleton() {
    return Column(
      children: [
        // Header row
        Container(
          height: 40,
          color: Colors.grey[100],
          child: Row(
            children: [
              Container(width: 60, color: Colors.grey[200]),
              ...List.generate(5, (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )),
            ],
          ),
        ),
        // Period rows
        ...List.generate(periods, (periodIndex) => Container(
          height: 80,
          margin: EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ...List.generate(5, (dayIndex) => Expanded(
                child: Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: LoadingShimmer(
                    isLoading: true,
                    child: Container(),
                  ),
                ),
              )),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildHorizontalSkeleton() {
    return Row(
      children: List.generate(5, (dayIndex) => Expanded(
        child: Column(
          children: [
            // Day header
            Container(
              height: 40,
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Period cells
            ...List.generate(periods, (periodIndex) => Container(
              height: 80,
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: LoadingShimmer(
                isLoading: true,
                child: Container(),
              ),
            )),
          ],
        ),
      )),
    );
  }
}