import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/BusinessDetailComponent.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/BusinessService.dart';
import 'package:room_finder_flutter/services/UserService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';

class RFViewAllBusinessesScreen extends StatefulWidget {
  @override
  _RFViewAllBusinessesScreenState createState() => _RFViewAllBusinessesScreenState();
}

class _RFViewAllBusinessesScreenState extends State<RFViewAllBusinessesScreen> {
  List<Business> _allBusinesses = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange &&
        _hasMore &&
        !_isLoading) {
      _loadBusinesses(loadMore: true);
    }
  }
Future<void> _loadBusinesses({bool loadMore = false}) async {
  if (!loadMore) {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
      _allBusinesses.clear();
    });
  } else {
    setState(() {
      _isLoading = true;
    });
  }

  try {
    final response = await BusinessService.getAllBusinesses(
      page: _currentPage,
      pageSize: _pageSize,
      ordering: '-created_at',
    );

    // FIX: Handle the response properly - it's a Map, not a List
    List<dynamic> businessesData = [];
    
    if (response != null && response.length > 0)  {
      // Paginated response
      businessesData = response;
      // _hasMore = response != null;
    // } else if (response is Map && response.containsKey('count')) {
    //   // Alternative paginated response format
    //   businessesData = response['results'] as List<dynamic>;
    //   _hasMore = response['next'] != null;
    // } else if (response is List) {
    //   // Non-paginated response (direct list)

    //   businessesData = response['results']; ;
    //   _hasMore = false;
    } else {
      // Fallback: try to extract any list from the response
      businessesData = [];
      _hasMore = false;
      print('Unexpected response format: $response');
    }

    setState(() {
      _allBusinesses.addAll(businessesData.map((business) => Business.fromJson(business as Map<String, dynamic>)).toList());
      _currentPage++;
      _isLoading = false;
    });

  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    toast('Failed to load businesses: $e');
    print('Error loading businesses: $e');
  }
}
  Future<void> _refresh() async {
    await _loadBusinesses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Businesses'),
        backgroundColor: rf_primaryColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // Header with count
            Container(
              padding: EdgeInsets.all(16),
              color: context.cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Businesses',
                    style: boldTextStyle(size: 18),
                  ),
                  Text(
                    '${_allBusinesses.length} businesses',
                    style: secondaryTextStyle(),
                  ),
                ],
              ),
            ),

            // Business List
            Expanded(
              child: _allBusinesses.isEmpty && _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _allBusinesses.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_center, size: 64, color: Colors.grey),
                            16.height,
                            Text(
                              'No businesses available',
                              style: boldTextStyle(size: 18),
                            ),
                            8.height,
                            Text(
                              'Check back later for new business listings',
                              style: secondaryTextStyle(),
                              textAlign: TextAlign.center,
                            ),
                            16.height,
                            AppButton(
                              text: 'Refresh',
                              onTap: _refresh,
                            ),
                          ],
                        ).paddingAll(16)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: _allBusinesses.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _allBusinesses.length) {
                              return _hasMore
                                  ? Container(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          'No more businesses to load',
                                          style: secondaryTextStyle(),
                                        ),
                                      ),
                                    );
                            }

                            final business = _allBusinesses[index];
                            return BusinessDetailComponent(businessListData: business);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}