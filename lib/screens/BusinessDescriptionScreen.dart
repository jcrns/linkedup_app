import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/FavoritesService.dart';
import 'package:room_finder_flutter/services/UserService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class BusinessDescriptionScreen extends StatefulWidget {
  final Business businessData;

  const BusinessDescriptionScreen({Key? key, required this.businessData}) : super(key: key);

  @override
  _BusinessDescriptionScreenState createState() => _BusinessDescriptionScreenState();
}

class _BusinessDescriptionScreenState extends State<BusinessDescriptionScreen> {
  bool isFavorite = false;
  bool isOwner = false;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    _checkIfFavorited();
    _checkOwnership();
  }

  // In both BusinessDescriptionScreen and ProductDescriptionScreen
  Future<void> _checkOwnership() async {
    try {
      // Get current user's business
      final myBusiness = await UserService.getMyBusiness();
      if (myBusiness != null) {
        final myBusinessObj = Business.fromJson(myBusiness);
        
        // For BusinessDescriptionScreen:
        isOwner = myBusinessObj.id == widget.businessData.id;
        
        
        setState(() {
          // BusinessDescriptionScreen
          isOwner = myBusinessObj.id == widget.businessData.id;
          
        });
      } else {
        setState(() {
          isOwner = false;
        });
      }
    } catch (e) {
      print('Error checking ownership: $e');
      setState(() {
        isOwner = false;
      });
    }
  }

  Future<void> _checkIfFavorited() async {
    final favorited = await FavoritesService.isBusinessFavorited(widget.businessData.id!);
    setState(() {
      isFavorite = favorited;
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await FavoritesService.removeBusiness(widget.businessData.id!);
      toast('Removed from favorites');
    } else {
      await FavoritesService.addBusiness(widget.businessData.toJson());
      toast('Added to favorites');
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _editBusiness() {
    toast('Edit business functionality coming soon');
    // Navigate to business edit screen
    // BusinessEditScreen(business: widget.businessData).launch(context);
  }

  void _manageProducts() {
    toast('Product management coming soon');
    // Navigate to product management screen
  }

  void _viewAnalytics() {
    toast('Analytics coming soon');
    // Navigate to analytics screen
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: rf_primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: rf_primaryColor, size: 20),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: secondaryTextStyle(size: 12)),
                4.height,
                Text(value, style: boldTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String? content) {
    if (content == null || content.isEmpty) return SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: boldTextStyle(size: 16)),
        8.height,
        Text(content, style: primaryTextStyle()),
        16.height,
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: boldTextStyle(size: 20, color: color)),
          4.height,
          Text(label, style: secondaryTextStyle(size: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.cardColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: white),
                    onPressed: () => finish(context),
                  ),
                ),
                actions: [
                  if (isOwner) // Edit button for owner
                    Container(
                      margin: EdgeInsets.all(8),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: white),
                        onPressed: _editBusiness,
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.all(8),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.share, color: white),
                      onPressed: () {
                        toast('Share business');
                      },
                    ),
                  ),
                ],
                expandedHeight: 280,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      widget.businessData.image.isNotEmpty
                          ? Image.network(
                              widget.businessData.image,
                              fit: BoxFit.cover,
                              width: context.width(),
                              height: 300,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.business, size: 80, color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.business, size: 80, color: Colors.grey),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.businessData.name,
                                    style: boldTextStyle(color: white, size: 24),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isOwner)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: boxDecorationWithRoundedCorners(
                                      backgroundColor: Colors.green.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Your Business',
                                      style: boldTextStyle(color: white, size: 10),
                                    ),
                                  ),
                              ],
                            ),
                            8.height,
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: white),
                                4.width,
                                Expanded(
                                  child: Text(
                                    widget.businessData.location,
                                    style: secondaryTextStyle(color: white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            8.height,
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: boxDecorationWithRoundedCorners(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, size: 14, color: Colors.amber),
                                      4.width,
                                      Text(
                                        widget.businessData.rating.toStringAsFixed(1),
                                        style: boldTextStyle(color: white, size: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                8.width,
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: boxDecorationWithRoundedCorners(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility, size: 14, color: white),
                                      4.width,
                                      Text(
                                        '${widget.businessData.views}',
                                        style: boldTextStyle(color: white, size: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: rf_primaryColor,
                    labelColor: rf_primaryColor,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: boldTextStyle(),
                    unselectedLabelStyle: primaryTextStyle(),
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Details'),
                      Tab(text: 'Products'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Overview Tab
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner Actions Section
                    if (isOwner) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('Business Owner Tools', style: boldTextStyle(size: 18, color: Colors.blue)),
                            12.height,
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: 'Edit Business',
                                    textColor: Colors.blue,
                                    color: Colors.blue.withOpacity(0.1),
                                    onTap: _editBusiness,
                                  ),
                                ),
                                12.width,
                                Expanded(
                                  child: AppButton(
                                    text: 'Edit Products',
                                    textColor: Colors.green,
                                    color: Colors.green.withOpacity(0.1),
                                    onTap: _manageProducts,
                                  ),
                                ),
                              ],
                            ),
                            8.height,
                            AppButton(
                              text: 'View Analytics',
                              textColor: Colors.purple,
                              color: Colors.purple.withOpacity(0.1),
                              onTap: _viewAnalytics,
                            ),
                          ],
                        ),
                      ),
                      16.height,
                    ],

                    Text('Quick Info', style: boldTextStyle(size: 18)),
                    16.height,
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildInfoCard('Category', widget.businessData.businessType, Icons.category),
                        _buildInfoCard('Contact', widget.businessData.contactInfo ?? 'Not provided', Icons.phone),
                        if (widget.businessData.website != null)
                          _buildInfoCard('Website', 'Visit site', Icons.language),
                        if (widget.businessData.businessHours != null)
                          _buildInfoCard('Hours', widget.businessData.businessHours!, Icons.access_time),
                      ],
                    ),
                    24.height,
                    _buildDetailSection('About', widget.businessData.description),
                    if (widget.businessData.targetAudience != null)
                      _buildDetailSection('Target Audience', widget.businessData.targetAudience),
                    if (widget.businessData.valuation != null && widget.businessData.valuation! > 0) ...[
                      Text('Business Metrics', style: boldTextStyle(size: 18)),
                      16.height,
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          _buildMetricCard(
                            'Valuation',
                            '\$${widget.businessData.valuation!.toStringAsFixed(0)}',
                            Colors.green,
                          ),
                          _buildMetricCard(
                            'Investment',
                            '\$${widget.businessData.totalInvestment ?? 0}',
                            Colors.blue,
                          ),
                          _buildMetricCard(
                            'Growth Rate',
                            '${((widget.businessData.monthlyGrowthRate ?? 0) * 100).toStringAsFixed(1)}%',
                            Colors.orange,
                          ),
                          _buildMetricCard(
                            'Views',
                            '${widget.businessData.views}',
                            Colors.purple,
                          ),
                        ],
                      ),
                      24.height,
                    ],
                  ],
                ),
              ),
              // Details Tab
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Full Description', widget.businessData.description),
                    _buildDetailSection('Address', widget.businessData.address),
                    _buildDetailSection('Contact Information', widget.businessData.contactInfo),
                    _buildDetailSection('Business Hours', widget.businessData.businessHours),
                    _buildDetailSection('Target Audience', widget.businessData.targetAudience),
                    _buildDetailSection('Special Deals', widget.businessData.deals),
                    if (widget.businessData.socialMedia != null)
                      _buildDetailSection('Social Media', widget.businessData.socialMedia),
                  ],
                ),
              ),
              // Products Tab
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (isOwner) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('Product Management', style: boldTextStyle(size: 18, color: Colors.green)),
                            12.height,
                            AppButton(
                              text: 'Add New Product',
                              textColor: white,
                              color: Colors.green,
                              onTap: () {
                                toast('Add product functionality coming soon');
                              },
                            ),
                          ],
                        ),
                      ),
                      16.height,
                    ],
                    Text('Products & Services', style: boldTextStyle(size: 18)),
                    16.height,
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
                          16.height,
                          Text('No products listed yet', style: boldTextStyle()),
                          8.height,
                          Text(
                            isOwner 
                              ? 'Start adding products to showcase your offerings'
                              : 'This business hasn\'t added any products or services yet.',
                            style: secondaryTextStyle(),
                            textAlign: TextAlign.center,
                          ),
                          16.height,
                          AppButton(
                            text: isOwner ? 'Add Your First Product' : 'Contact for Services',
                            textColor: white,
                            color: rf_primaryColor,
                            onTap: () {
                              if (isOwner) {
                                toast('Add product functionality coming soon');
                              } else {
                                toast('Contact business for services');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            border: Border.all(color: context.dividerColor),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Contact',
                    textColor: rf_primaryColor,
                    color: context.cardColor,
                    onTap: () {
                      toast('Contact business');
                    },
                  ),
                ),
                12.width,
                Expanded(
                  child: AppButton(
                    text: 'Visit',
                    textColor: white,
                    color: rf_primaryColor,
                    onTap: () {
                      if (widget.businessData.website != null) {
                        toast('Opening website');
                      } else {
                        toast('No website available');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}