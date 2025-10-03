import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/BusinessDetailComponent.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/BusinessService.dart';
import 'package:room_finder_flutter/services/UserService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class RFSearchResultsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? businessType;
  final String? location;
  final String? ordering;
  final String? title;

  const RFSearchResultsScreen({
    Key? key,
    this.searchQuery,
    this.businessType,
    this.location,
    this.ordering,
    this.title,
  }) : super(key: key);

  @override
  _RFSearchResultsScreenState createState() => _RFSearchResultsScreenState();
}

class _RFSearchResultsScreenState extends State<RFSearchResultsScreen> {
  List<Business> _searchResults = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery ?? '';
    _searchController.text = _currentQuery;
    _performSearch();
  }

  Future<void> _performSearch({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        // FIX: Removed the redundant 'if (!loadMore)' check here, since it's true when this block runs
        _searchResults.clear();
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // FIX 1: Change 'final results' to dynamic to match the UserService function
      final dynamic results = await BusinessService.searchBusinesses(
        query: _currentQuery,
        businessType: widget.businessType,
        location: widget.location,
        ordering: widget.ordering ?? '-created_at',
        page: _currentPage,
        pageSize: 10,
      );

      List<dynamic> businessesData = [];

      // FIX 2: Handle both Map (paginated) and List (raw) responses safely
      if (results is Map && results.containsKey('results')) {
        // Paginated response (Map with 'results' key)
        businessesData = results['results'] as List<dynamic>;
        _hasMore = results['next'] != null;
      } else if (results is List) {
        // Raw list response
        businessesData = results;
        _hasMore = false; // No pagination available
      } else {
        // Handle unexpected format (e.g., null, error map)
        print('Unexpected search results format: $results');
        _hasMore = false;
      }
      
      // FIX 3: Map the data and use .cast<Business>() to resolve type assignment errors
      final List<Business> newBusinesses = businessesData
          .map((business) => Business.fromJson(business as Map<String, dynamic>))
          .toList()
          .cast<Business>();

      setState(() {
        if (loadMore) {
          _searchResults.addAll(newBusinesses);
        } else {
          _searchResults = newBusinesses;
        }
        _currentPage++;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      toast('Search failed: $e');
    }
  }
  void _onSearchSubmitted(String value) {
    setState(() {
      _currentQuery = value.trim();
    });
    _performSearch();
  }

  String _getScreenTitle() {
    if (widget.title != null) return widget.title!;
    if (widget.businessType != null) return '${widget.businessType} Businesses';
    if (_currentQuery.isNotEmpty) return 'Search: $_currentQuery';
    return 'Browse Businesses';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle() ,style: boldTextStyle(color: Colors.white)),
        backgroundColor: rf_primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: context.cardColor,
            child: AppTextField(
              controller: _searchController,
              textFieldType: TextFieldType.NAME,

              decoration: rfInputDecoration(
                hintText: "Search businesses...",
                showPreFixIcon: true,
                showLableText: false,
                prefixIcon: Icon(Icons.search, color: rf_primaryColor),
              ),
              onFieldSubmitted: _onSearchSubmitted,
            ),
          ),

          // Results Count
          if (!_isLoading && _searchResults.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: context.width(),
              color: context.cardColor,
              child: Text(
                'Found ${_searchResults.length} businesses',
                style: secondaryTextStyle(),
              ),
            ),

          // Results List
          Expanded(
            child: _isLoading && _searchResults.isEmpty
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          16.height,
                          Text(
                            'No businesses found',
                            style: boldTextStyle(size: 18),
                          ),
                          8.height,
                          Text(
                            _currentQuery.isEmpty
                                ? 'Try searching with different terms'
                                : 'No results for "$_currentQuery"',
                            style: secondaryTextStyle(),
                            textAlign: TextAlign.center,
                          ),
                          16.height,
                          AppButton(
                            text: 'Browse All Businesses',
                            onTap: () {
                              _searchController.clear();
                              _onSearchSubmitted('');
                            },
                          ),
                        ],
                      ).paddingAll(16)
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _searchResults.length && _hasMore) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          final business = _searchResults[index];
                          return BusinessDetailComponent(businessListData: business);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}