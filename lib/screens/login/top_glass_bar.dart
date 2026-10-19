import 'dart:ui';

import 'package:flutter/material.dart';

const _deepForest = Color(0xFF071B14);
const _mint = Color(0xFFBBF5D8);

class TopGlassBar extends StatelessWidget {
  final String userName;
  final String status;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;

  const TopGlassBar({
    super.key,
    required this.userName,
    this.status = 'Logged On',
    this.onProfileTap,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        // --------------------------------------------------------------
        // SOFT BACKGROUND BLUR
        // --------------------------------------------------------------
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),

        child: Container(
          width: double.infinity,
          height: 64,

          decoration: BoxDecoration(
            // ----------------------------------------------------------
            // VERY LIGHT GLASS
            // ----------------------------------------------------------

            color: _deepForest.withValues(
              alpha: .16,
            ),

            // ----------------------------------------------------------
            // NO BORDER
            // ----------------------------------------------------------
            //
            // ไม่มี border เพื่อให้รู้สึกว่า Top Bar
            // เป็นส่วนหนึ่งของ Background
            //
            border: null,

            // ----------------------------------------------------------
            // SUBTLE BOTTOM SHADOW
            // ----------------------------------------------------------

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: .08,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),

          child: Stack(
            children: [
              // ========================================================
              // SOFT TOP-TO-BOTTOM GRADIENT
              // ========================================================

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(
                            alpha: .10,
                          ),
                          Colors.black.withValues(
                            alpha: .04,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [
                          0.0,
                          0.45,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ========================================================
              // CONTENT
              // ========================================================

              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ==================================================
                      // LEFT BRAND
                      // ==================================================

                      const _BrandSection(),

                      // ==================================================
                      // SPACE
                      // ==================================================

                      const Spacer(),

                      // ==================================================
                      // RIGHT PROFILE
                      // ==================================================

                      _ProfileSection(
                        userName: userName,
                        status: status,
                        profileImageUrl: profileImageUrl,
                        onTap: onProfileTap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// BRAND SECTION
// ========================================================================

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ================================================================
        // LOGO
        // ================================================================

        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: Colors.white.withValues(
              alpha: .08,
            ),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: .14,
              ),
              width: 1,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/ICONWITHNOBACKGROUND.png',

              fit: BoxFit.cover,

              filterQuality: FilterQuality.high,

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.eco_rounded,
                  color: _mint,
                  size: 43,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 11),

        // ================================================================
        // BRAND TEXT
        // ================================================================

        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seqotia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -.2,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    offset: Offset(
                      0,
                      1,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5),

            Text(
              'WorkSpace',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ========================================================================
// PROFILE SECTION
// ========================================================================

class _ProfileSection extends StatelessWidget {
  final String userName;
  final String status;
  final String? profileImageUrl;
  final VoidCallback? onTap;

  const _ProfileSection({
    required this.userName,
    required this.status,
    this.profileImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        // --------------------------------------------------------------
        // NO CAPSULE BACKGROUND
        // --------------------------------------------------------------

        borderRadius: BorderRadius.circular(14),

        splashColor: Colors.white.withValues(
          alpha: .06,
        ),

        highlightColor: Colors.white.withValues(
          alpha: .03,
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ========================================================
              // PROFILE AVATAR
              // ========================================================

              _ProfileAvatar(
                imageUrl: profileImageUrl,
              ),

              const SizedBox(width: 10),

              // ========================================================
              // USER INFO
              // ========================================================

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: -.1,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          offset: Offset(
                            0,
                            1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ------------------------------------------------
                      // STATUS DOT
                      // ------------------------------------------------

                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _mint,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _mint.withValues(
                                alpha: .50,
                              ),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // ------------------------------------------------
                      // STATUS
                      // ------------------------------------------------

                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// PROFILE AVATAR
// ========================================================================

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ProfileAvatar({
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: Colors.white.withValues(
          alpha: .10,
        ),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: .18,
          ),
          width: 1,
        ),
      ),

      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 22,
                  );
                },
              )
            : const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 22,
              ),
      ),
    );
  }
} 