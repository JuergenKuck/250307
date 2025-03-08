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
  'B': 10,
  'D': 10,
  'K': 10,
  'A': 11
};

List<String> suitSymbols = ['♦', '♥', '♠', '♣'];

void main() {
  // BlackJack:
  bool isGame = true;
  while (isGame) {
    isGame = Game();
  }
}

bool Game() {
  PrintHeader('BlackJack - Spielbeginn');

  // Spieler Karten
  List<String> playerCards = [];
  // Spieler Spielfarbe
  List<String> playerSuits = [];
  // Spieler Asse; als List, weil in Function der Inhalt ggF. verändert wird
  List<int> playerAsses = [0];
  // Anzahl Spielerkarte
  int playerNumberCard = 0;

  // Erste Karte Spieler
  int playerPointsSum =
      NextCard(++playerNumberCard, playerCards, playerSuits, playerAsses);

  // Bank: Kommentare analog Spieler
  List<String> bankCards = [];
  List<String> bankSuits = [];
  List<int> bankAsses = [0];
  int bankNumberCard = 0;

  // Erste Karte Bank
  int bankPointsSum =
      NextCard(++bankNumberCard, bankCards, bankSuits, bankAsses);

  // Spieler restliche Karten
  bool isFold = false;
  bool isPlayerLost = false;

  while (!isFold && !isPlayerLost) {
    playerPointsSum =
        NextCard(++playerNumberCard, playerCards, playerSuits, playerAsses);
    PrintCardsCurrent(bankNumberCard, bankPointsSum, 'Bank   ', bankCards,
        bankSuits, bankAsses);

    PrintCardsCurrent(playerNumberCard, playerPointsSum, 'Spieler', playerCards,
        playerSuits, playerAsses);

    switch (playerPointsSum) {
      case < 21:
        PrintLine();
        isFold = !JaNein("Möchtest Du noch eine Karte ziehen?");
        PrintLine();
        if (!isFold) PrintHeader("Nächste Karte gezogen.");

      case == 21:
        isFold = true; // bei 21 wirst Du keine mehr ziehen
      case > 21:
        isPlayerLost = true;
        PrintHeader('Spielende');
        PrintCardsCurrent(bankNumberCard, bankPointsSum, 'Bank   ', bankCards,
            bankSuits, bankAsses);
        PrintCardsCurrent(playerNumberCard, playerPointsSum, 'Spieler',
            playerCards, playerSuits, playerAsses);
        PrintLost("Du hast Dich überzogen!");
    }
  }

  if (!isPlayerLost) {
    // Spieler noch nicht verloren => bank zieht Karten
    isFold = false;
    print('');
    bool isBankLost = false;
    while (!isFold && !isBankLost) {
      bankPointsSum =
          NextCard(++bankNumberCard, bankCards, bankSuits, bankAsses);
      isFold = bankPointsSum >= 17;
      isBankLost = bankPointsSum > 21;
    }
    PrintHeader("Bank hat gezogen.");
    PrintCardsCurrent(bankNumberCard, bankPointsSum, 'Bank   ', bankCards,
        bankSuits, bankAsses);
    PrintCardsCurrent(playerNumberCard, playerPointsSum, 'Spieler', playerCards,
        playerSuits, playerAsses);

    bool isPlayerBlackJack = IsBlackJack(playerCards, playerPointsSum);
    bool isBankBlackJack = IsBlackJack(bankCards, bankPointsSum);

    if (isBankLost)
      PrintWin('Die Bank hat sich überzogen');
    else {
      if (playerPointsSum > bankPointsSum) {
        isBankLost = true;
        PrintWin('Du hast mehr Punkte als die Bank');
      } else if (playerPointsSum < bankPointsSum) {
        isPlayerLost = true;
        PrintLost("Du hast weniger Punkte als die Bank!");
      } else if (isPlayerBlackJack && !isBankBlackJack) {
        isBankLost = true;
        PrintWin('Du hast mit BlackJack gewonnen!');
      } else if (isBankBlackJack && !isPlayerBlackJack) {
        isPlayerLost = true;
        PrintLost("Die Bank hat mit BlackJack gewonnen!");
      }
    }
    if (!isPlayerLost && !isBankLost) {
      PrintLine();
      print("Noch mal gutgegangen! Ihr habt unentschieden gespielt!");
      PrintLine();
    }
  }

  return JaNein("Möchtest Du noch ein Spiel machen?");
}

int NextCard(
    int numberCard, List<String> cards, List<String> suits, List<int> asses) {
  cards.add(rankMap.keys.elementAt(GetRandom(13)));
  suits.add(suitSymbols[GetRandom(4)]);
  if (cards.last == 'A') asses[0]++;

  int pointsSum = 0;

  for (int i = 0; i < cards.length; i++) {
    pointsSum += rankMap[cards[i]] ?? 0;
  }

  if (pointsSum > 21) {
    if (asses[0] != 0) {
      pointsSum -= 10;
      asses[0]--;
    }
  }
  return pointsSum;
}

void PrintCardsCurrent(int numberCard, int pointsSum, String actor,
    List<String> cards, List<String> suits, List<int> asses) {
  String printCards = "$actor (";
  if (IsBlackJack(cards, pointsSum)) {
    printCards += 'BlackJack): ';
  } else {
    if (pointsSum < 10) printCards += ' ';
    printCards += ' $pointsSum Punkte): ';
  }
  for (int i = 0; i < cards.length; i++) {
    switch (suits[i]) {
      case '♦' || '♥':
        printCards += '\x1B[31;47m'; // rot auf weiß
      case '♠' || '♣':
        printCards += '\x1B[30;47m'; // schwarz auf weiß
    }

    printCards += ' ${suits[i]} ${cards[i]} \x1B[0m';
    if (i != cards.length - 1) {
      //printCards += " + ";
    }
  }
  // printCards += " -> $pointsSum Punkte";
  print(printCards);
}

int GetRandom(int nRandom) {
  Random random = Random();
  int result = random.nextInt(nRandom);
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

void PrintHeader(String header) {
  clearTerminal();
  PrintLine();
  print(header);
  PrintLine();
}

void PrintLine() {
  print('--------------------------------------------------------------------');
}

void PrintWin(String text) {
  PrintLine();
  print('Herzlichen Glückwunsch, Du hast gewonnen! $text');
  PrintLine();
}

void PrintLost(String text) {
  PrintLine();
  print('Schade Du hast verloren! $text');
  PrintLine();
}

void clearTerminal() {
  // ANSI-Escape-Sequenz zum Löschen des Bildschirms und Zurücksetzen des Cursors
  stdout.write('\x1B[2J\x1B[0;0H');
}
