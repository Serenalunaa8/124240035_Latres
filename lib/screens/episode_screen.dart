import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/episode.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'episode_detail_screen.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  List<Episode> _allEpisodes = [];
  List<Episode> _filteredEpisodes = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedSeason = 'Season 1';
  final List<String> _seasons = [
    'Season 1',
    'Season 2',
    'Season 3',
    'Season 4',
    'Season 5',
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEpisodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final episodes = await ApiService.getEpisodes();
      if (mounted) {
        setState(() {
          _allEpisodes = episodes;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    final seasonNumber = _selectedSeason.replaceAll('Season ', '').padLeft(2, '0');
    final seasonCode = 'S$seasonNumber';

    setState(() {
      _filteredEpisodes = _allEpisodes.where((ep) {
        final matchesSeason = ep.episode.toUpperCase().startsWith(seasonCode);
        final matchesQuery = query.isEmpty ||
            ep.name.toLowerCase().contains(query) ||
            ep.episode.toLowerCase().contains(query);
        return matchesSeason && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kolom pencarian
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2128),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search episodes by name or code...',
                      hintStyle: GoogleFonts.dmSans(
                        color: const Color(0xFF75808A),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  ),
              ],
            ),
          ),
        ),

        // Filter season
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _seasons.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final season = _seasons[index];
              final isSelected = _selectedSeason == season;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSeason = season;
                  });
                  _applyFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.portalGreen
                        : const Color(0xFF1B2128),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.portalGreen
                          : const Color(0x1FFFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    season,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF151A20)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        // Daftar episode
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.portalGreen),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 54, color: AppColors.statusDead),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadEpisodes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.portalGreen,
                              foregroundColor: const Color(0xFF14191F),
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : _filteredEpisodes.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada episode untuk $_selectedSeason',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadEpisodes,
                          color: AppColors.portalGreen,
                          backgroundColor: const Color(0xFF1B2128),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: _filteredEpisodes.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final ep = _filteredEpisodes[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EpisodeDetailScreen(episode: ep),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B222A),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0x1AFFFFFF),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Badge kode episode
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF123947),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0x3382CFEA),
                                          ),
                                        ),
                                        child: Text(
                                          ep.episode,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF82CFEA),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      // Judul dan tanggal rilis
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    ep.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.spaceGrotesk(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 5,
                                                  height: 5,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.mortyYellow,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  ep.airDate,
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Icon panah
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.portalGreen,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
