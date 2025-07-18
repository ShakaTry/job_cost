import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:job_cost/main.dart';
import 'package:job_cost/screens/profile_selection_screen.dart';

void main() {
  testWidgets('Profile selection screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with ProfileSelectionScreen
    expect(find.byType(ProfileSelectionScreen), findsOneWidget);
    
    // Verify that we have an AppBar with the correct title
    expect(find.text('Sélection du profil'), findsOneWidget);
    
    // Verify that we have a floating action button for adding profiles
    expect(find.byType(FloatingActionButton), findsOneWidget);
    
    // Verify that the add icon is present
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Test tapping the demo profile button if it exists
    final demoButton = find.text('Créer un profil de démonstration');
    if (demoButton.evaluate().isNotEmpty) {
      await tester.tap(demoButton);
      await tester.pumpAndSettle();
      
      // After creating demo profile, we should see Sophie Martin
      expect(find.text('Sophie Martin'), findsOneWidget);
    }
  });
}