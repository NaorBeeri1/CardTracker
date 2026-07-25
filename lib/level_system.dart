class LevelSystem {
  static final List<String> levelTitles = [
    // Levels 1-5: Early Days & Motown
    'Got to Be There',
    'Ben',
    'Music and Me',
    'Forever, Michael',
    'Off the Wall',
    
    // Levels 6-10: Thriller Era
    'Wanna Be Startin\' Somethin\'',
    'The Girl Is Mine',
    'Thriller',
    'Beat It',
    'Billie Jean',
    
    // Levels 11-15: Bad Era
    'Bad',
    'Smooth Criminal',
    'The Way You Make Me Feel',
    'Man in the Mirror',
    'Dirty Diana',
    
    // Levels 16-20: Dangerous Era
    'Jam',
    'In the Closet',
    'Remember the Time',
    'Heal the World',
    'Black or White',
    
    // Levels 21-25: HIStory Era
    'Scream',
    'They Don\'t Care About Us',
    'Stranger in Moscow',
    'Earth Song',
    'You Are Not Alone',
    
    // Levels 26-30: Legacy & King of Pop
    'Blood on the Dance Floor',
    'Ghosts',
    'The Ultimate Collection',
    'Xscape',
    'King of Pop',
  ];

  static Map<String, dynamic> calculateLevel(int collectedCount) {
    // Every 10 cards = 1 level. Max level is 30.
    int currentLevel = (collectedCount ~/ 10) + 1;
    if (currentLevel > 30) currentLevel = 30;
    if (currentLevel < 1) currentLevel = 1;

    int totalXp = collectedCount * 10;
    int xpForCurrentLevel = (currentLevel - 1) * 100;
    int xpNextLevel = currentLevel * 100;
    
    // Cap progress at max level
    int currentLevelProgress = currentLevel == 30 ? 100 : (totalXp - xpForCurrentLevel);
    int xpNeededForNext = currentLevel == 30 ? 100 : 100;

    String title = levelTitles[currentLevel - 1];

    return {
      'level': currentLevel,
      'title': title,
      'xp': totalXp,
      'progress': currentLevel == 30 ? 1.0 : (currentLevelProgress / xpNeededForNext),
      'progressText': '$currentLevelProgress / $xpNeededForNext XP',
    };
  }
}