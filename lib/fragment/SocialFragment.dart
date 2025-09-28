import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:room_finder_flutter/components/PostDetailScreen.dart';

class SocialFragment extends StatefulWidget {
  const SocialFragment({Key? key}) : super(key: key);

  @override
  State<SocialFragment> createState() => _SocialFragmentState();
}

class _SocialFragmentState extends State<SocialFragment> {
  static const String url = 'http://127.0.0.1:8000';
  static const String apiUrl = '$url/api/social-posts/';
  static const String likeUrl = '$url/like/';
  final TextEditingController _postController = TextEditingController();
  String get bearerToken => 'Bearer $token';
  bool _isLoading = false;
  List<dynamic> _posts = [];
  Map<int, bool> _expandedPosts = {}; // Track which posts show replies
  Map<int, bool> _expandedComments = {}; // Track which comments show replies
  int? _replyingToPostId; // Track which post we're replying to
  String _replyingToUsername = ''; // Track username we're replying to

  late String token;
  final FocusNode _postFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    token = getStringAsync('auth_token', defaultValue: 'a7d8d4bd1b1eb3de13886c9c3b075ea891b21e82');
    fetchPosts();
  }

  @override
  void dispose() {
    _postFocusNode.dispose();
    super.dispose();
  }

  // Add this new method to fetch child posts
  Future<void> fetchChildPosts(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?parent_pk=$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': '1.0.0',
          'X-Client-Platform': 'flutter-ios',
          'Authorization': 'Token $token'
        },
      );
      
      if (response.statusCode == 200) {
        print('Child posts response data: ${response.body}');
        final childPosts = json.decode(response.body);
        setState(() {
          // Update the post to include its child posts
          final postIndex = _posts.indexWhere((post) => post['id'] == postId);
          if (postIndex != -1) {
            _posts[postIndex]['child_posts'] = childPosts;
          }
        });
      }
    } catch (e) {
      print('Error fetching child posts: $e');
    }
  }

  Future<void> fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': '1.0.0',
          'X-Client-Platform': 'flutter-ios',
          'Authorization': 'Token $token'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          print('Response data: ${response.body}');
          _posts = json.decode(response.body);
          // Initialize expanded state for all posts
          for (var post in _posts) {
            _expandedPosts[post['id']] = false;
          }
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> createPost(String content, {int? parentId}) async {
    if (content.trim().isEmpty) return;
    try {
      final Map<String, dynamic> postData = {'content': content};
      if (parentId != null) {
        postData['parent'] = parentId;
      }
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': '1.0.0',
          'X-Client-Platform': 'flutter-ios',
          'Authorization': 'Token $token',
        },
        body: json.encode(postData),
      );
      if (response.statusCode == 201) {
        _postController.clear();
        setState(() {
          _replyingToPostId = null;
          _replyingToUsername = '';
        });
        fetchPosts();
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  Future<void> likePost(int postId) async {
    try {
      final response = await http.post(
        Uri.parse(likeUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Token $token',
        },
        body: {
          'object_type': 'post',
          'object_id': postId.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        // Update the like count locally
        setState(() {
          final postIndex = _posts.indexWhere((post) => post['id'] == postId);
          if (postIndex != -1) {
            final data = json.decode(response.body);
            _posts[postIndex]['likesCount'] = data['likes_count'];
          }
        });
      }
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Widget _buildMedia(List<dynamic> media) {
    if (media.isEmpty) return SizedBox.shrink();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: media.length == 1 ? 1 : 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: media.length,
      itemBuilder: (context, index) {
        final mediaItem = media[index];
        final mediaUrl = '$url${mediaItem['file']}';
        
        return CachedNetworkImage(
          imageUrl: mediaUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        );
      },
    );
  }

  Widget _buildCommentItem(dynamic comment, int postId, {int depth = 0}) {
    final isExpanded = _expandedComments[comment['id']] ?? false;
    final hasReplies = comment['commentCount'] != null && comment['commentCount'] > 0;
    
    // Minimal scaling for deeper levels - only reduce slightly after level 3
    final scale = depth > 3 ? 0.9 : 1.0;
    
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(
            left: 16.0 + (depth * 12.0), // Moderate indentation increase
            right: 8.0,
          ),
          leading: CircleAvatar(
            radius: 16.0,
            child: Text(
              comment['user']['username'][0].toUpperCase(),
              style: TextStyle(fontSize: 12.0),
            ),
          ),
          title: Text(
            comment['user']['username'],
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            comment['content'],
            style: TextStyle(fontSize: 13.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up, size: 16.0),
                onPressed: () {}, // Implement comment like if needed
              ),
              Text('${comment['likesCount'] ?? 0}', style: TextStyle(fontSize: 12.0)),
              SizedBox(width: 8.0),
              if (hasReplies)
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 16.0),
                  onPressed: () {
                    setState(() {
                      _expandedComments[comment['id']] = !isExpanded;
                    });
                  },
                ),
              SizedBox(width: 8.0),
              IconButton(
                icon: Icon(Icons.reply, size: 16.0),
                onPressed: () {
                  setState(() {
                    _replyingToPostId = postId;
                    _replyingToUsername = comment['user']['username'];
                    _postController.text = '@${_replyingToUsername} ';
                    _postFocusNode.requestFocus();
                  });
                },
              ),
            ],
          ),
        ),
        if (hasReplies && isExpanded) ...[
          Padding(
            padding: EdgeInsets.only(left: 16.0 + (depth * 12.0)),
            child: Row(
              children: [
                Container(
                  width: 2,
                  color: Colors.grey[300],
                  margin: EdgeInsets.only(right: 8),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // Show child posts as replies to comments
                      if (comment['child_posts'] != null)
                        ...comment['child_posts'].map((reply) => 
                          _buildPostItem(reply, isChild: true, depth: depth + 1)
                        ).toList(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _expandedComments[comment['id']] = false;
                          });
                        },
                        child: Text('Hide replies', style: TextStyle(fontSize: 12.0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPostItem(dynamic post, {bool isChild = false, int depth = 0}) {
    final isExpanded = _expandedPosts[post['id']] ?? false;
    final childPosts = post['child_posts'] ?? [];
    final comments = post['comments'] ?? [];
    final totalReplies = childPosts.length + comments.length;
    
    // Minimal scaling - only reduce slightly after level 3
    final scale = depth > 3 ? 0.9 : 1.0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              post: post,
              token: token,
              url: url,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: isChild ? 8.0 : 12.0, // Minimal margin reduction for nested posts
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.0,
                    child: Text(
                      post['user']['username'][0].toUpperCase(),
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['user']['username'],
                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          post['created_at'].toString().substring(0, 16).replaceFirst('T', ' '),
                          style: TextStyle(fontSize: 11.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              Text(
                post['content'],
                style: TextStyle(fontSize: 14.0),
              ),
              SizedBox(height: 12.0),
              _buildMedia(post['media']),
              SizedBox(height: 12.0),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up,
                      color: Colors.grey[600],
                      size: 20.0,
                    ),
                    onPressed: () => likePost(post['id']),
                  ),
                  Text('${post['likesCount']}', style: TextStyle(fontSize: 12.0)),
                  SizedBox(width: 16.0),
                  IconButton(
                    icon: Icon(Icons.comment, color: Colors.grey[600], size: 20.0),
                    onPressed: () async {
                      // Fetch child posts when comment button is clicked
                      print('Fetching child posts for post ID: ${post['id']}');
                      await fetchChildPosts(post['id']);
                      
                      setState(() {
                        _expandedPosts[post['id']] = !isExpanded;
                      });
                    },
                  ),
                  Text('$totalReplies', style: TextStyle(fontSize: 12.0)),
                  SizedBox(width: 16.0),
                  IconButton(
                    icon: Icon(Icons.reply, color: Colors.grey[600], size: 20.0),
                    onPressed: () {
                      setState(() {
                        _replyingToPostId = post['id'];
                        _replyingToUsername = post['user']['username'];
                        _postController.text = '@${_replyingToUsername} ';
                        _postFocusNode.requestFocus();
                      });
                    },
                  ),
                  Spacer(),
                  if (totalReplies > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _expandedPosts[post['id']] = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? 'Hide Replies' : 'Show Replies',
                        style: TextStyle(fontSize: 11.0),
                      ),
                    ),
                ],
              ),
              if (isExpanded && totalReplies > 0) ...[
                Divider(thickness: 1.0),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Replies ($totalReplies)',
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ),
                // Show existing comments
                ...comments.map((comment) => _buildCommentItem(comment, post['id'], depth: depth)).toList(),
                // Show child posts as full post objects
                ...childPosts.map((childPost) => _buildPostItem(childPost, isChild: true, depth: depth + 1)).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // optional: flat look
        toolbarHeight: 40.0, // 👈 makes AppBar shorter/skinnier
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
        automaticallyImplyLeading: false,
        
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPosts,
          ),

          // Add logo in the center of the AppBar
        ],
      ),

      body: Column(
        children: [
          if (_replyingToPostId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    "Replying to @$_replyingToUsername",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _replyingToPostId = null;
                        _replyingToUsername = '';
                        _postController.clear();
                      });
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchPosts,
                    child: ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) => _buildPostItem(_posts[index]),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    focusNode: _postFocusNode,
                    decoration: InputDecoration(
                      hintText: _replyingToPostId != null 
                        ? "Replying to @$_replyingToUsername" 
                        : "What's on your mind?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => createPost(
                    _postController.text, 
                    parentId: _replyingToPostId
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}