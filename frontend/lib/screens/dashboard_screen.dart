import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum ViewMode { list, grid, tree }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ViewMode _viewMode = ViewMode.grid;   // default view mode
  List<dynamic> _items = [];           // will hold folders/files data

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await ApiService.get('/api/dashboard/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _items = data;  // assume data is a list of folder/file objects
        });
      } else {
        // Handle error response (could use a snackbar or dialog to inform user)
        print('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions (e.g., network issues)
      print('Error fetching dashboard data: $e');
    }
  }

  void _changeViewMode(ViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
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

  /// Build the content based on selected view mode.
  Widget _buildContentView() {
    if (_items.isEmpty) {
      return Center(child: CircularProgressIndicator());  // or empty state message
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

  /// Display files/folders in a simple ListView.
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
              // Handle folder tap (e.g., navigate into folder if supported)
            } else {
              // Handle file tap (e.g., open or preview the file)
            }
          },
        );
      },
    );
  }

  /// Display files/folders in a GridView.
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,   // two columns in grid
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
                // Navigate into folder or expand it (if we implement that in grid)
              } else {
                // Open or view file
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

  /// Display files/folders in a hierarchical tree view using ExpansionTiles.
  Widget _buildTreeView() {
    // We assume each folder item may contain a list of children (files/subfolders).
    // Each child in 'children' can have its own 'children' for deeper nesting.
    List<Widget> buildNodes(List<dynamic> nodes) {
      return nodes.map((node) {
        final isFolder = node['type'] == 'folder';
        if (isFolder) {
          // Folder node: use ExpansionTile to show its children
          final List<dynamic> children = node['children'] ?? [];
          return ExpansionTile(
            leading: Icon(Icons.folder),
            title: Text(node['name']),
            children: buildNodes(children),  // recursive build for nested children
          );
        } else {
          // File node: simple ListTile
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


/*

In DashboardScreen, we maintain a _viewMode state (default to grid) and an _items list that will store the fetched folder/file data. On initState, _fetchDashboardData() is called to retrieve data from the API.
_fetchDashboardData uses ApiService.get('/api/dashboard/') to perform a GET request. Because ApiService automatically attaches the Authorization header with the JWT, the request will succeed if the user is authenticated. We parse the JSON response and store it in _items. (If the response status is not 200, we handle it by printing or could show an error message to the user.)
In the AppBar, we add three IconButtons for list, grid, and tree views. These call _changeViewMode to update the state. The icon color is toggled (white for active view, semi-transparent for inactive) to give a visual cue of the current mode.
_buildContentView() chooses which UI to display based on _viewMode. If data _items is empty, we show a loading indicator or a placeholder.
List view: _buildListView() creates a ListView.builder where each item is a ListTile with a folder icon or file icon, the item name, and a subtitle indicating type. Tapping a folder or file could be handled (e.g., navigating into a folder or opening a file), but that can be implemented as needed.
Grid view: _buildGridView() uses a 2-column GridView.builder. Each item is shown in a Card with an icon and name. This gives a thumbnail-style overview of folders and files. We use overflow: TextOverflow.ellipsis to truncate long names. The user can tap to navigate or open items.
Tree view: _buildTreeView() displays the hierarchical structure. We use Flutter’s ExpansionTile widget to represent folders that can be expanded to show their children. The code assumes that each folder item in _items has a children list of its contents (files or subfolders). We use a recursive helper buildNodes to build the tree: if an item is a folder, we create an ExpansionTile with its name and call buildNodes on its children to create nested widgets. If an item is a file, we simply create a ListTile. This hierarchical view lets the user expand and collapse folders to navigate the structure in a tree format.

*/