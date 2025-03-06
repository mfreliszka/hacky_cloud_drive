import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum ViewMode { list, grid, tree }

class DashboardScreen extends StatefulWidget {
  // You can pass the root folder id when navigating to DashboardScreen,
  // or fetch it from a user provider if it's stored there.
  final int rootFolderId;
  const DashboardScreen({Key? key, required this.rootFolderId}) : super(key: key);
  
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ViewMode _viewMode = ViewMode.grid; // default view mode
  List<dynamic> _items = [];         // will hold folders/files data
  int _currentFolderId = 0;          // current folder id being viewed

  @override
  void initState() {
    super.initState();
    // Start at user's root folder.
    _currentFolderId = widget.rootFolderId;
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // Pass the current folder id as a query parameter.
      final response = await ApiService.get('/api/dashboard/?folder_id=$_currentFolderId');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _items = data; // data is a list of folder/file objects for this folder
        });
      } else {
        // Handle error response
        print('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }

  void _changeViewMode(ViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  // Navigate into a folder: update _currentFolderId and fetch new data.
  void _openFolder(int folderId) {
    setState(() {
      _currentFolderId = folderId;
    });
    _fetchDashboardData();
  }

  // Optionally, you can add a back button that resets _currentFolderId to the root.
  void _goToRoot() {
    setState(() {
      _currentFolderId = widget.rootFolderId;
    });
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          // Optionally, a back-to-root button if not in root folder:
          if (_currentFolderId != widget.rootFolderId)
            IconButton(
              icon: Icon(Icons.home),
              tooltip: 'Back to Root',
              onPressed: _goToRoot,
            ),
          // Buttons to toggle view modes: list, grid, tree
          IconButton(
            icon: Icon(Icons.list),
            color: _viewMode == ViewMode.list ? Colors.white : Colors.white54,
            onPressed: () => _changeViewMode(ViewMode.list),
            tooltip: 'List view',
          ),
          IconButton(
            icon: Icon(Icons.grid_on),
            color: _viewMode == ViewMode.grid ? Colors.white : Colors.white54,
            onPressed: () => _changeViewMode(ViewMode.grid),
            tooltip: 'Grid view',
          ),
          IconButton(
            icon: Icon(Icons.account_tree),
            color: _viewMode == ViewMode.tree ? Colors.white : Colors.white54,
            onPressed: () => _changeViewMode(ViewMode.tree),
            tooltip: 'Tree view',
          ),
        ],
      ),
      body: _buildContentView(),
    );
  }

  /// Build content based on selected view mode.
  Widget _buildContentView() {
    if (_items.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    switch (_viewMode) {
      case ViewMode.list:
        return _buildListView();
      case ViewMode.grid:
        return _buildGridView();
      case ViewMode.tree:
        return _buildTreeView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isFolder = item['type'] == 'folder';
        return ListTile(
          leading: Icon(isFolder ? Icons.folder : Icons.insert_drive_file),
          title: Text(item['name']),
          subtitle: isFolder ? Text('Folder') : Text('File'),
          onTap: () {
            if (isFolder) {
              _openFolder(item['id']);
            } else {
              // Handle file tap, e.g., open/preview file.
            }
          },
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isFolder = item['type'] == 'folder';
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              if (isFolder) {
                _openFolder(item['id']);
              } else {
                // Handle file tap.
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isFolder ? Icons.folder : Icons.insert_drive_file, size: 48),
                const SizedBox(height: 8),
                Text(
                  item['name'],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// For tree view, assume API returns a nested structure.
  Widget _buildTreeView() {
    List<Widget> buildNodes(List<dynamic> nodes) {
      return nodes.map((node) {
        final isFolder = node['type'] == 'folder';
        if (isFolder) {
          final List<dynamic> children = node['children'] ?? [];
          return ExpansionTile(
            leading: Icon(Icons.folder),
            title: Text(node['name']),
            children: buildNodes(children),
          );
        } else {
          return ListTile(
            leading: Icon(Icons.insert_drive_file),
            title: Text(node['name']),
          );
        }
      }).toList();
    }
    return ListView(
      children: buildNodes(_items),
    );
  }
}
