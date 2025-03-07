import 'dart:io';
import 'dart:math';

//
Map<String, int> rankMap = {
  '2': 2,
  '3': 3,
  '4': 4,
  '5': 5,
  '6': 6,
  '7': 7,
  '8': 8,
  '9': 9,
  '10': 10,
  'Bube': 10,
  'Dame': 10,
  'König': 10,
  'Ass': 11
};

void main() {
  // BlackJack:
  bool isGame = true;
  while (isGame) {
    isGame = Game();
  }
}

bool Game() {
  clearTerminal();
  print('BlackJack - Spielbeginn');
  print('-----------------------j');
  List<String> suitSymbols = ['♠', '♥', '♦', '♣'];

  //Spielereinsatz
  // int bet = GetBet();

  // Spieler erste Karte
  int playerRank = GetRank();
  List<String> playerCards = [rankMap.keys.elementAt(playerRank)];

  // hier als List, weil in Function der Inhalt ggF. verändert wird
  List<int> playerAsses = [0];
  if (playerCards[0] == 'Ass') playerAsses[0]++;
  EvalPlayingCard('1. Karte Spieler', playerCards, playerAsses);

  // Bank 1. Karte
  int bankRank = GetRank();
  List<String> bankCards = [rankMap.keys.elementAt(bankRank)];
  List<int> bankAsses = [0];
  if (bankCards[0] == 'Ass') bankAsses[0]++;

  EvalPlayingCard('1. Karte Bank   ', bankCards, bankAsses);
  print('');

  // Spieler restliche Karten
  bool isFold = false;
  bool isPlayerLost = false;

  int playerPointsSum = 0;
  while (!isFold && !isPlayerLost) {
    playerCards.add(rankMap.keys.elementAt(GetRank()));
    if (playerCards.last == 'Ass') playerAsses[0]++;
    playerPointsSum = EvalPlayingCard('Spieler', playerCards, playerAsses);
    switch (playerPointsSum) {
      case < 21:
        print("");
        print("Möchtest Du noch eine Karte ziehen 'J'a oder 'N'ein?");
        String drawCard = stdin.readLineSync() ?? 'J';
        print('');
        switch (drawCard) {
          case 'N' || 'n':
            isFold = true;
          case 'J' || 'j':
          default:
            isFold = false;
        }
      case == 21:
        isFold = true; // bei 21 wirst Du keine mehr ziehen
      case > 21:
        isPlayerLost = true;
        print('');
        print("Schade! Du hast Dich überzogen und leider verloren!");
        print('');
    }
  }
  // bank
  int bankPointsSum = 0;
  isFold = false;

  if (!isPlayerLost) {
    print('');
    bool isBankLost = false;
    while (!isFold && !isBankLost) {
      bankCards.add(rankMap.keys.elementAt(GetRank()));
      if (bankCards.last == 'Ass') playerAsses[0]++;
      bankPointsSum = EvalPlayingCard('Bank   ', bankCards, bankAsses);
      isFold = bankPointsSum >= 17;
      isBankLost = bankPointsSum > 21;
    }
    bool isPlayerBlackJack = IsBlackJack(playerCards, playerPointsSum);
    bool isBankBlackJack = IsBlackJack(bankCards, bankPointsSum);
    print('');
    if (isBankLost)
      print('Herzlichen Glückwunsch. Die Bank hat sich überzogen!');

    if (!isBankLost) {
      if (playerPointsSum > bankPointsSum) {
        isBankLost = true;
        print(
            'Herzlichen Glückwunsch. Du hast mehr Punkte als die Bank und hast gewonnen!');
      }
      if (isPlayerBlackJack && !isBankBlackJack) {
        isBankLost = true;
        print('Herzlichen Glückwunsch. Du hast mit BlackJack gewonnen!');
      }
    }
    if (!isBankLost) {
      if (bankPointsSum > playerPointsSum) {
        isPlayerLost = true;
        print(
            "Schade! Du hast weniger Punkte als die Bank und leider verloren!");
      }
      if (isBankBlackJack && !isPlayerBlackJack) {
        isPlayerLost = true;
        print("Schade! Die Bank hat mit BlackJack gewonnen!");
      }
    }
    if (!isPlayerLost && !isBankLost) {
      print("Noch mal gutgegangen! Ihr habt unentschieden gespielt!");
    }
  }
  print('');

  bool isNewGame = false;
  print("");
  print("Möchtest Du noch ein Spiel machen 'J'a oder 'N'ein?");
  String isNewGameStr = stdin.readLineSync() ?? 'J';
  print('');
  switch (isNewGameStr) {
    case 'N' || 'n':
      isNewGame = false;
    case 'J' || 'j':
    default:
      isNewGame = true;
  }
  return isNewGame;
}

int GetRank() {
  Random random = Random();
  int result = random.nextInt(13);
  return result;
}

int EvalPlayingCard(String actor, List<String> cards, List<int> asses) {
  String printCards = "$actor: ";
  int pointsSum = 0;

  for (int i = 0; i < cards.length; i++) {
    printCards += cards[i];
    pointsSum += rankMap[cards[i]] ?? 0;
    if (i != cards.length - 1) {
      printCards += " + ";
    }
  }

  if (pointsSum > 21) {
    if (asses[0] != 0) {
      pointsSum -= 10;
      asses[0]--;
    }
  }

  printCards += " -> $pointsSum Punkte";
  print(printCards);

  return pointsSum;
}

bool IsBlackJack(List<String> cards, int pointsSum) {
  return cards.length == 2 && pointsSum == 21;
}

void clearTerminal() {
  for (int i = 0; i < 10; i++) {
    print('');
  }
}
