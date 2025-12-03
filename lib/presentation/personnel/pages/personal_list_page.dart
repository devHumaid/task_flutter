// lib/presentation/personnel/pages/personnel_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/core/theme/app_theme.dart';
import 'package:flutter_task/data/models/personnel_model.dart';
import 'package:flutter_task/injection_container.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_bloc.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_event.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_state.dart';
import 'package:flutter_task/presentation/personnel/pages/personnel_form_page.dart';

class PersonnelListPage extends StatefulWidget {
  const PersonnelListPage({Key? key}) : super(key: key);

  @override
  State<PersonnelListPage> createState() => _PersonnelListPageState();
}

class _PersonnelListPageState extends State<PersonnelListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPersonnelList();
  }

  void _loadPersonnelList() {
    context.read<PersonnelBloc>().add(LoadPersonnelList(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomAppBar(),
              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                       Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
            ),
            child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
            ),
          ),
        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Text(
                              'GO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: _loadPersonnelList,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
            BlocConsumer<PersonnelBloc, PersonnelState>(
              listener: (context, state) {
                if (state is PersonnelError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PersonnelLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                if (state is PersonnelListLoaded) {
                  final filteredList = state.filteredList;
            
                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No personnel found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
            
                  return RefreshIndicator(
                    onRefresh: () async => _loadPersonnelList(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return _buildPersonnelCard(filteredList[index]);
                      },
                    ),
                  );
                }
            
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => sl<PersonnelBloc>()..add(LoadRoles()),
                child: const PersonnelFormPage(),
              ),
            ),
          );

          if (result == true && mounted) {
            _loadPersonnelList();
          }
        },
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add, color: Colors.black,size: 27,),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/app_bar_bg.png'), // Place your wave pattern image here
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Background overlay gradient (optional, for better readability)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/top_bg.png'), 
                fit: BoxFit.cover,
              ),
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     const Color(0xFFFFC107).withOpacity(0.9),
              //     const Color(0xFFFFC107).withOpacity(0.7),
              //   ],
              // ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar with icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left menu icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.grid_view, color: Colors.black),
                          onPressed: () {
                          },
                        ),
                      ),
                      // Right profile icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
shape: BoxShape.circle,                        ),
                        child: IconButton(
                          icon: const Icon(Icons.person, color: Colors.black),
                          onPressed: () {
                            // TODO: Implement profile/logout
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Personnel Details List',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Search bar
              
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonnelCard(PersonnelModel personnel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => sl<PersonnelBloc>()
                  ..add(LoadPersonnelDetails(personnel.id))
                  ..add(LoadRoles()),
                child: PersonnelFormPage(personnelId: personnel.id),
              ),
            ),
          );

          if (result == true && mounted) {
            _loadPersonnelList();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar with icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                    shape: BoxShape.circle,
                    ),
                    child:  Icon(
                      Icons.groups_2_outlined,
                      color: Colors.grey[800],
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${personnel.firstName}${personnel.lastName != null ? ' ${personnel.lastName}' : ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              personnel.contactNumber ?? 'N/A',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.person, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                personnel.roleNames ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: personnel.status == 1
                          ? Colors.green[100]
                          : Colors.red[100],
                          border: Border.all(color:  personnel.status == 1
                                ? Colors.green
                                : Colors.red,),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: personnel.status == 1
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                            
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          personnel.status == 1 ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: personnel.status == 1
                                ? Colors.green[900]
                                : Colors.red[900],
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(height: 0.5,color: Colors.grey[300],),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatAddress(personnel),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(PersonnelModel personnel) {
    final parts = [
      personnel.address,
      personnel.suburb,
      personnel.state,
      personnel.postcode,
      personnel.country,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }
}