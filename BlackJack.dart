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
  print('-----------------------');
  print('BlackJack - Spielbeginn');
  print('-----------------------');
  List<String> suitSymbols = ['♠', '♥', '♦', '♣'];

  //Spielereinsatz
  // int bet = GetBet();

  // Spieler Karten
  List<String> playerCards = [];
  // Spieler Asse; als List, weil in Function der Inhalt ggF. verändert wird
  List<int> playerAsses = [0];
  // Anzahl Spielerkarte
  int playerNumberCard = 0;

  // Erste Karte Spieler
  int playerPointsSum =
      NextCard(++playerNumberCard, 'Spieler', playerCards, playerAsses);

  // Bank: Kommentare analog Spieler
  List<String> bankCards = [];
  List<int> bankAsses = [0];
  int bankNumberCard = 0;

  // Erste Karte Bank
  int bankPointsSum =
      NextCard(++bankNumberCard, 'Bank   ', bankCards, bankAsses);

  print('');

  // Spieler restliche Karten
  bool isFold = false;
  bool isPlayerLost = false;

  while (!isFold && !isPlayerLost) {
    playerPointsSum =
        NextCard(++playerNumberCard, 'Spieler', playerCards, playerAsses);
    switch (playerPointsSum) {
      case < 21:
        isFold = !JaNein("Möchtest Du noch eine Karte ziehen?");
      case == 21:
        isFold = true; // bei 21 wirst Du keine mehr ziehen
      case > 21:
        isPlayerLost = true;
        print('');
        print("Schade! Du hast Dich überzogen und leider verloren!");
        print('');
    }
  }

  if (!isPlayerLost) {
    // Spieler noch nicht verloren => bank zieht Karten
    isFold = false;
    print('');
    bool isBankLost = false;
    while (!isFold && !isBankLost) {
      bankPointsSum =
          NextCard(++bankNumberCard, 'Bank   ', bankCards, bankAsses);
      isFold = bankPointsSum >= 17;
      isBankLost = bankPointsSum > 21;
    }
    bool isPlayerBlackJack = IsBlackJack(playerCards, playerPointsSum);
    bool isBankBlackJack = IsBlackJack(bankCards, bankPointsSum);

    print('');
    if (isBankLost)
      print('Herzlichen Glückwunsch. Die Bank hat sich überzogen!');
    else {
      if (playerPointsSum > bankPointsSum) {
        isBankLost = true;
        print(
            'Herzlichen Glückwunsch. Du hast mehr Punkte als die Bank und hast gewonnen!');
      } else if (playerPointsSum < bankPointsSum) {
        isPlayerLost = true;
        print(
            "Schade! Du hast weniger Punkte als die Bank und leider verloren!");
      } else if (isPlayerBlackJack && !isBankBlackJack) {
        isBankLost = true;
        print('Herzlichen Glückwunsch. Du hast mit BlackJack gewonnen!');
      } else if (isBankBlackJack && !isPlayerBlackJack) {
        isPlayerLost = true;
        print("Schade! Die Bank hat mit BlackJack gewonnen!");
      }
    }
    if (!isPlayerLost && !isBankLost) {
      print("Noch mal gutgegangen! Ihr habt unentschieden gespielt!");
    }
  }
  print('-----------------------');
  print('BlackJack - Spielende');
  print('-----------------------');

  return JaNein("Möchtest Du noch ein Spiel machen?");
}

int NextCard(
    int numberCard, String actor, List<String> cards, List<int> asses) {
  cards.add(rankMap.keys.elementAt(GetRank()));
  if (cards.last == 'Ass') asses[0]++;

  String printCards = "$numberCard Karte $actor: ";
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

int GetRank() {
  Random random = Random();
  int result = random.nextInt(13);
  return result;
}

bool IsBlackJack(List<String> cards, int pointsSum) {
  return cards.length == 2 && pointsSum == 21;
}

bool JaNein(String header) {
  print('');
  print("$header 'J'a oder 'N'ein?");

  String answerStr = stdin.readLineSync() ?? 'J';
  bool answer;
  print('');
  switch (answerStr) {
    case 'N' || 'n':
      answer = false;
    case 'J' || 'j':
    default:
      answer = true;
  }
  return answer;
}

void clearTerminal() {
  for (int i = 0; i < 10; i++) {
    print('');
  }
}
