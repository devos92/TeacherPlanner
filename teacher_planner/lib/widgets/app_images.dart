// lib/widgets/app_images.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImages {
  // Banner Images
  static Widget bannerImage({
    required String imagePath,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height ?? 200,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Background Image with Overlay (supports PNG, JPG, and SVG)
  static Widget backgroundImage({
    required String imagePath,
    required Widget child,
    Color overlayColor = Colors.black54,
    BoxFit fit = BoxFit.cover,
  }) {
    return Stack(
      children: [
        // Background Image (supports SVG and regular images)
        Positioned.fill(
          child: imagePath.toLowerCase().endsWith('.svg')
            ? SvgPicture.asset(
                imagePath,
                fit: fit,
                placeholderBuilder: (context) => Container(color: Colors.grey[300]),
              )
            : Image.asset(
                imagePath,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[300]);
                },
              ),
        ),
        // Overlay
        Positioned.fill(
          child: Container(
            color: overlayColor,
          ),
        ),
        // Content
        child,
      ],
    );
  }

  // Home Page Hero Image
  static Widget heroImage({
    required String imagePath,
    String? title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Text Content
              if (title != null || subtitle != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Circular Profile Image
  static Widget profileImage({
    required String imagePath,
    double size = 100,
    Border? border,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ?? Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  // Decorative Background Pattern
  static Widget decorativeBackground({
    required String imagePath,
    required Widget child,
    double opacity = 0.1,
    BoxFit fit = BoxFit.cover,
  }) {
    return Stack(
      children: [
        // Background Pattern
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              imagePath,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.transparent);
              },
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
} 