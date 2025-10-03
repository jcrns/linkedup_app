import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/models/RoomFinderModel.dart';
import 'package:room_finder_flutter/screens/FavortiesScreen.dart';
import 'package:room_finder_flutter/screens/RFAboutUsScreen.dart';
import 'package:room_finder_flutter/screens/RFHelpScreen.dart';
import 'package:room_finder_flutter/screens/RFNotificationScreen.dart';
import 'package:room_finder_flutter/screens/RFRecentlyViewedScreen.dart';
import 'package:room_finder_flutter/utils/RFImages.dart';

// List<RoomFinderModel> categoryList() {
//   List<RoomFinderModel> categoryListData = [];
//   categoryListData.add(RoomFinderModel(roomCategoryName: "Flat"));
//   categoryListData.add(RoomFinderModel(roomCategoryName: "Rooms"));
//   categoryListData.add(RoomFinderModel(roomCategoryName: "Hall"));
//   categoryListData.add(RoomFinderModel(roomCategoryName: "Rent"));
//   categoryListData.add(RoomFinderModel(roomCategoryName: "House"));

//   return categoryListData;
// }

// List<RoomFinderModel> hotelList() {
//   List<RoomFinderModel> hotelListData = [];
//   hotelListData.add(RoomFinderModel(
//       img: rf_hotel1, color: greenColor.withOpacity(0.6), roomCategoryName: "1 BHK at Chicago", price: "RS. 8000 / ", rentDuration: "per month", location: "Los Angeles Chicago", address: "Available", description: "9 Applied | ", views: "20 Views"));
//   hotelListData.add(RoomFinderModel(img: rf_hotel2, color: redColor, roomCategoryName: "Big Room", price: "RS. 5000 / ", rentDuration: "per day", location: "Cleveland", address: "Unavailable", description: "5 Applied | ", views: "10 Views"));
//   hotelListData.add(RoomFinderModel(
//       img: rf_hotel3, color: greenColor.withOpacity(0.6), roomCategoryName: "4 Room for Student", price: "RS. 6000 / ", rentDuration: "per week", location: "Atlanta", address: "Available", description: "10 Applied | ", views: "06 Views"));
//   hotelListData
//       .add(RoomFinderModel(img: rf_hotel4, color: redColor, roomCategoryName: "Hall and Room", price: "RS. 5000 / ", rentDuration: "per month", location: "Detroit Chicago", address: "Unavailable", description: "16 Applied | ", views: "12 Views"));
//   hotelListData
//       .add(RoomFinderModel(img: rf_hotel5, color: greenColor.withOpacity(0.6), roomCategoryName: "Big Room", price: "RS. 2000 / ", rentDuration: "per day", location: "Cleveland", address: "Available", description: "9 Applied | ", views: "25 Views"));
//   hotelListData.add(RoomFinderModel(img: rf_hotel2, color: redColor, roomCategoryName: "Big Room", price: "RS. 5000 / ", rentDuration: "per day", location: "Cleveland", address: "Unavailable", description: "5 Applied | ", views: "10 Views"));

//   return hotelListData;
// }

// List<RoomFinderModel> locationList() {
//   List<RoomFinderModel> locationListData = [];
//   locationListData.add(RoomFinderModel(img: rf_location1, price: "10 Found", location: "Chicago"));
//   locationListData.add(RoomFinderModel(img: rf_location2, price: "4 Found", location: "Cleveland"));
//   locationListData.add(RoomFinderModel(img: rf_location3, price: "12 Found", location: "Atlanta"));
//   locationListData.add(RoomFinderModel(img: rf_location4, price: "16 Found", location: " Chicago"));
//   locationListData.add(RoomFinderModel(img: rf_location5, price: "20 Found", location: "Los Angeles"));
//   locationListData.add(RoomFinderModel(img: rf_location6, price: "25 Found", location: "Detroit"));

//   return locationListData;
// }

// List<RoomFinderModel> faqList() {
//   List<RoomFinderModel> faqListData = [];
//   faqListData.add(
//       RoomFinderModel(img: rf_faq, price: "What do we get here in this app?", description: "That which doesn't kill you makes you stronger, right? Unless it almost kills you, and renders you weaker. Being strong is pretty rad though, so go ahead."));
//   faqListData
//       .add(RoomFinderModel(img: rf_faq, price: "What is the use of this App?", description: "Sometimes, you've just got to say 'the party starts here'. Unless you're not in the place where the aforementioned party is starting. Then, just shut up."));
//   faqListData.add(RoomFinderModel(
//       img: rf_faq, price: "How to get from location A to B?", description: "If you believe in yourself, go double or nothing. Well, depending on how long it takes you to calculate what double is. If you're terrible at maths, don't."));

//   return faqListData;
// }

// List<RoomFinderModel> notificationList() {
//   List<RoomFinderModel> notificationListData = [];
//   notificationListData.add(RoomFinderModel(price: "Welcome", unReadNotification: false, description: "Don’t forget to complete your personal info."));
//   notificationListData.add(RoomFinderModel(price: "There are 4 available properties, you recently selected. ", unReadNotification: true, description: "Click here for more details."));

//   return notificationListData;
// }

// List<RoomFinderModel> yesterdayNotificationList() {
//   List<RoomFinderModel> yesterdayNotificationListData = [];
//   yesterdayNotificationListData.add(RoomFinderModel(price: "There are 4 available properties, you recently selected. ", unReadNotification: false, description: "Click here for more details."));
//   yesterdayNotificationListData.add(RoomFinderModel(price: "There are 4 available properties, you recently selected. ", unReadNotification: true, description: "Click here for more details."));
//   yesterdayNotificationListData.add(RoomFinderModel(price: "There are 4 available properties, you recently selected. ", unReadNotification: true, description: "Click here for more details."));

//   return yesterdayNotificationListData;
// }

List<Opportunity> opportunityList() {
  return [
    Opportunity(
      title: 'Senior Flutter Developer',
      company: 'Tech Innovators',
      location: 'Remote',
      salary: '\$80k - \$120k',
      type: 'Full-time',
      postedDate: '1d ago'
    ),
    Opportunity(
      title: 'UI/UX Designer',
      company: 'Design Studio',
      location: 'London',
      salary: '\$60k - \$90k',
      type: 'Contract',
      postedDate: '3d ago'
    ),
    Opportunity(
      title: 'Product Manager',
      company: 'StartUp Hub',
      location: 'San Francisco',
      salary: '\$100k - \$150k',
      type: 'Full-time',
      postedDate: '5d ago'
    ),
    Opportunity(
      title: 'Data Analyst',
      company: 'Big Data Corp',
      location: 'Berlin',
      salary: '\€50k - \€70k',
      type: 'Part-time',
      postedDate: '1w ago'
    ),
  ];
}

List<RoomFinderModel> categoryList() {
  List<RoomFinderModel> categoryListData = [];
  categoryListData.add(RoomFinderModel(roomCategoryName: "All"));
  categoryListData.add(RoomFinderModel(roomCategoryName: "Retail"));
  categoryListData.add(RoomFinderModel(roomCategoryName: "Tech"));
  categoryListData.add(RoomFinderModel(roomCategoryName: "Food"));
  categoryListData.add(RoomFinderModel(roomCategoryName: "Drop Off"));
  categoryListData.add(RoomFinderModel(roomCategoryName: "Digital"));

  return categoryListData;
}

List<RoomFinderModel> hotelList() {
  List<RoomFinderModel> businessListData = [];
  businessListData.add(RoomFinderModel(
      img: rf_location1, color: greenColor.withOpacity(0.6), roomCategoryName: "Tech Consultancy", price: "RS. 15000 / ", pricingModel: "per project", location: "Chicago", address: "Online Available", description: "12 Clients | ", views: "40 Views"));
  businessListData.add(RoomFinderModel(
      img: rf_location2, color: redColor, roomCategoryName: "E-commerce Store", price: "RS. 10000 / ", pricingModel: "per month", location: "Cleveland", address: "Physical Only", description: "8 Clients | ", views: "30 Views"));
  businessListData.add(RoomFinderModel(
      img: rf_location3, color: greenColor.withOpacity(0.6), roomCategoryName: "Retail Shop", price: "RS. 8000 / ", pricingModel: "per month", location: "Atlanta", address: "Physical and Online", description: "15 Clients | ", views: "50 Views"));
  businessListData.add(RoomFinderModel(
      img: rf_location4, color: redColor, roomCategoryName: "Software Development", price: "RS. 20000 / ", pricingModel: "per project", location: "Detroit", address: "Online Only", description: "20 Clients | ", views: "60 Views"));
  businessListData.add(RoomFinderModel(
      img: rf_location5, color: greenColor.withOpacity(0.6), roomCategoryName: "Law Consultancy", price: "RS. 12000 / ", pricingModel: "per consultation", location: "Cleveland", address: "Online Available", description: "10 Clients | ", views: "45 Views"));

  return businessListData;
}

List<RoomFinderModel> locationList() {
  List<RoomFinderModel> locationListData = [];
  locationListData.add(RoomFinderModel(img: rf_location1, price: "10 Found", location: "Wallets"));
  locationListData.add(RoomFinderModel(img: rf_location2, price: "8 Found", location: "Wellness Kits"));
  locationListData.add(RoomFinderModel(img: rf_location3, price: "12 Found", location: "Digital Products"));
  locationListData.add(RoomFinderModel(img: rf_location4, price: "16 Found", location: "Clothes"));
  locationListData.add(RoomFinderModel(img: rf_location5, price: "20 Found", location: "Accessories"));
  locationListData.add(RoomFinderModel(img: rf_location6, price: "25 Found", location: "Books"));

  return locationListData;
}

// List<Product> productList() {
//   return [
//     Product(
//       img: rf_location1,
//       title: 'Luxury Studio',
//       price: '\$450/month',
//       description: 'Modern studio with city views',
//       views: '1.8k',
//       rating: 4.7,
//       color: Colors.blue.shade100,
//     ),
//     Product(
//       img: rf_location2,
//       title: 'Downtown Loft',
//       price: '\$680/month',
//       description: 'Spacious industrial-style loft',
//       views: '2.3k',
//       rating: 4.9,
//       color: Colors.amber.shade100,
//     ),
//     Product(
//       img: rf_location3,
//       title: 'Garden Cottage',
//       price: '\$320/month',
//       description: 'Quiet garden-side studio',
//       views: '956',
//       rating: 4.3,
//       color: Colors.green.shade100,
//     ),
//     Product(
//       img: rf_location4,
//       title: 'Executive Suite',
//       price: '\$850/month',
//       description: 'Luxury high-rise apartment',
//       views: '3.1k',
//       rating: 4.8,
//       color: Colors.purple.shade100,
//     ),
//   ];
// }

List<RoomFinderModel> faqList() {
  List<RoomFinderModel> faqListData = [];
  faqListData.add(
      RoomFinderModel(img: rf_faq, price: "What services does this app offer?", description: "We provide a range of options for finding business services, from tech solutions to retail spaces."));
  faqListData.add(
      RoomFinderModel(img: rf_faq, price: "How can I find consultation services?", description: "Browse by category or search directly. Our app offers listings for tech, law, and business consultations."));
  faqListData.add(
      RoomFinderModel(img: rf_faq, price: "What are the pricing models?", description: "Each business listing includes details about pricing models: per project, per consultation, or monthly rentals."));

  return faqListData;
}

List<RoomFinderModel> notificationList() {
  List<RoomFinderModel> notificationListData = [];
  notificationListData.add(RoomFinderModel(price: "Welcome", unReadNotification: false, description: "Don’t forget to complete your business profile."));
  notificationListData.add(RoomFinderModel(price: "You have 5 new business connections.", unReadNotification: true, description: "Click here to view and connect."));

  return notificationListData;
}

List<RoomFinderModel> yesterdayNotificationList() {
  List<RoomFinderModel> yesterdayNotificationListData = [];
  yesterdayNotificationListData.add(RoomFinderModel(price: "Your business has 4 new inquiries.", unReadNotification: false, description: "Click here to view details."));
  yesterdayNotificationListData.add(RoomFinderModel(price: "Check out the latest business listings!", unReadNotification: true, description: "Click here for more information."));
  yesterdayNotificationListData.add(RoomFinderModel(price: "Your business has received 2 new reviews.", unReadNotification: true, description: "Click here to read them."));

  return yesterdayNotificationListData;
}

List<RoomFinderModel> settingList() {
  List<RoomFinderModel> settingListData = [];
  settingListData.add(RoomFinderModel(img: rf_notification, roomCategoryName: "Notifications", newScreenWidget: RFNotificationScreen()));
  settingListData.add(RoomFinderModel(img: rf_recent_view, roomCategoryName: "Favorite", newScreenWidget: FavoritesScreen()));
  settingListData.add(RoomFinderModel(img: rf_faq, roomCategoryName: "My Business", newScreenWidget: RFHelpScreen()));
  // settingListData.add(RoomFinderModel(img: rf_faq, roomCategoryName: "Investments", newScreenWidget: RFHelpScreen()));
  settingListData.add(RoomFinderModel(img: rf_about_us, roomCategoryName: "About us", newScreenWidget: RFAboutUsScreen()));
  settingListData.add(RoomFinderModel(img: rf_sign_out, roomCategoryName: "Sign Out", newScreenWidget: SizedBox()));

  return settingListData;
}

List<RoomFinderModel> applyHotelList() {
  List<RoomFinderModel> applyHotelListData = [];
  applyHotelListData.add(RoomFinderModel(roomCategoryName: "Transactions"));
  applyHotelListData.add(RoomFinderModel(roomCategoryName: "Favorites"));

  return applyHotelListData;
}

List<RoomFinderModel> availableHotelList() {
  List<RoomFinderModel> availableHotelListData = [];
  availableHotelListData.add(RoomFinderModel(roomCategoryName: "All Available(14)"));
  availableHotelListData.add(RoomFinderModel(roomCategoryName: "Booked"));

  return availableHotelListData;
}

// List<RoomFinderModel> appliedHotelList() {
//   List<RoomFinderModel> appliedHotelData = [];
//   appliedHotelData.add(RoomFinderModel(img: rf_hotel1, roomCategoryName: "1 BHK at Chicago", price: "RS 8000 ", rentDuration: "1.2 km from Gwarko", location: "Los Angeles Chicago", address: "Booked", views: "3.0"));
//   appliedHotelData.add(RoomFinderModel(img: rf_hotel2, roomCategoryName: "Big Room", price: "RS 5000 ", rentDuration: "1.2 km from Los Angeles", location: "Cleveland", address: "Booked", views: "4.0"));
//   appliedHotelData.add(RoomFinderModel(img: rf_hotel3, roomCategoryName: "4 Room for Student", price: "RS 6000 ", rentDuration: "1.2 km from Cleveland", location: "Atlanta", address: "Booked", views: "2.5"));
//   appliedHotelData.add(RoomFinderModel(img: rf_hotel4, roomCategoryName: "Hall and Room", price: "RS 5000 ", rentDuration: "1.2 km from Atlanta", location: "Detroit Chicago", address: "Booked", views: "4.5"));
//   appliedHotelData.add(RoomFinderModel(img: rf_hotel5, roomCategoryName: "Big Room", price: "RS 2000 ", rentDuration: "1.2 km from Detroit", location: "Cleveland", address: "Booked", views: "5.0"));

//   return appliedHotelData;
// }
List<RoomFinderModel> appliedHotelList() {
  List<RoomFinderModel> appliedHotelData = [];
  appliedHotelData.add(RoomFinderModel(img: rf_hotel1, roomCategoryName: "Tech Office Space", price: "RS 15000 ", rentDuration: "2.5 km from Atlanta", location: "Los Angeles Chicago", address: "Booked", views: "3.5"));
  appliedHotelData.add(RoomFinderModel(img: rf_hotel2, roomCategoryName: "Retail Space", price: "RS 10000 ", rentDuration: "3.0 km from Gwarko", location: "Cleveland", address: "Booked", views: "4.2"));
  appliedHotelData.add(RoomFinderModel(img: rf_hotel3, roomCategoryName: "Consultancy Office", price: "RS 12000 ", rentDuration: "1.8 km from Atlanta", location: "Atlanta", address: "Booked", views: "4.0"));
  appliedHotelData.add(RoomFinderModel(img: rf_hotel4, roomCategoryName: "E-commerce Warehouse", price: "RS 13000 ", rentDuration: "2.0 km from Los Angeles", location: "Detroit", address: "Booked", views: "3.8"));
  appliedHotelData.add(RoomFinderModel(img: rf_hotel5, roomCategoryName: "Startup Hub", price: "RS 8000 ", rentDuration: "1.5 km from Cleveland", location: "Chicago", address: "Booked", views: "4.5"));

  return appliedHotelData;
}

List<RoomFinderModel> hotelImageList() {
  List<RoomFinderModel> hotelImageListData = [];
  hotelImageListData.add(RoomFinderModel(img: rf_hotel1));
  hotelImageListData.add(RoomFinderModel(img: rf_hotel2));
  hotelImageListData.add(RoomFinderModel(img: rf_hotel3));
  hotelImageListData.add(RoomFinderModel(img: rf_hotel4));

  return hotelImageListData;
}
