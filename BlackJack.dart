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

String colorRedWhite = '\x1B[1;31;47m'; // rot auf weiß
String colorBlackWhite = '\x1B[1;30;47m'; // schwarz auf weiß
String colorBlackGreen = '\x1B[1;97;42m'; // Dunkel auf grün
String colorBlackRed = '\x1B[1;97;41m'; // weiß auf rot
String colorBlackYellow = '\x1B[1;30;43m'; // dunkel auf gelb

String colorEnd = '\x1B[0m';

void main() {
  // BlackJack:
  bool isGame = true;
  while (isGame) {
    isGame = blackjack();
  }
}

bool blackjack() {
  printHeader('BlackJack - Spielbeginn');

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
      nextCard(++playerNumberCard, playerCards, playerSuits, playerAsses);

  // Bank: Kommentare analog Spieler
  List<String> bankCards = [];
  List<String> bankSuits = [];
  List<int> bankAsses = [0];
  int bankNumberCard = 0;

  // Erste Karte Bank
  int bankPointsSum =
      nextCard(++bankNumberCard, bankCards, bankSuits, bankAsses);

  // Spieler restliche Karten
  bool isFold = false;
  bool isPlayerLost = false;

  while (!isFold && !isPlayerLost) {
    playerPointsSum =
        nextCard(++playerNumberCard, playerCards, playerSuits, playerAsses);
    printCardsCurrent(
        bankNumberCard, bankPointsSum, 'Bank', bankCards, bankSuits, bankAsses);
    print('');
    printCardsCurrent(playerNumberCard, playerPointsSum, 'Spieler', playerCards,
        playerSuits, playerAsses);

    switch (playerPointsSum) {
      case < 21:
        printLine();
        isFold = !jaNein("Möchtest Du noch eine Karte ziehen?");
        printLine();
        if (!isFold) printHeader("Nächste Karte gezogen.");

      case == 21:
        isFold = true; // bei 21 wirst Du keine mehr ziehen
      case > 21:
        isPlayerLost = true;
        printHeader('Spielende');
        printCardsCurrent(bankNumberCard, bankPointsSum, 'Bank', bankCards,
            bankSuits, bankAsses);
        print('');
        printCardsCurrent(playerNumberCard, playerPointsSum, 'Spieler',
            playerCards, playerSuits, playerAsses);
        printLost("Du hast Dich überzogen!");
    }
  }

  if (!isPlayerLost) {
    // Spieler noch nicht verloren => bank zieht Karten
    isFold = false;
    print('');
    bool isBankLost = false;
    while (!isFold && !isBankLost) {
      printHeader("Die Bank zieht.");
      printCardsCurrent(playerNumberCard, playerPointsSum, 'Spieler',
          playerCards, playerSuits, playerAsses);
      print('');
      printCardsCurrent(bankNumberCard, bankPointsSum, 'Bank', bankCards,
          bankSuits, bankAsses);

      sleep(Duration(seconds: 1)); // Hält das Programm für 3 Sekunden an
      bankPointsSum =
          nextCard(++bankNumberCard, bankCards, bankSuits, bankAsses);

      isFold = bankPointsSum >= 17;
      isBankLost = bankPointsSum > 21;
    }
    printHeader("Die Bank hat gezogen.");
    printCardsCurrent(playerNumberCard, playerPointsSum, 'Spieler', playerCards,
        playerSuits, playerAsses);
    print('');
    printCardsCurrent(
        bankNumberCard, bankPointsSum, 'Bank', bankCards, bankSuits, bankAsses);

    bool isPlayerBlackJack = isBlackJack(playerCards, playerPointsSum);
    bool isBankBlackJack = isBlackJack(bankCards, bankPointsSum);

    if (isBankLost)
      printWin('Die Bank hat sich überzogen!');
    else {
      if (playerPointsSum > bankPointsSum) {
        isBankLost = true;
        printWin('Du hast mehr Punkte als die Bank');
      } else if (playerPointsSum < bankPointsSum) {
        isPlayerLost = true;
        printLost("Du hast weniger Punkte als die Bank!");
      } else if (isPlayerBlackJack && !isBankBlackJack) {
        isBankLost = true;
        printWin('Du hast mit BlackJack gewonnen!');
      } else if (isBankBlackJack && !isPlayerBlackJack) {
        isPlayerLost = true;
        printLost("Die Bank hat mit BlackJack gewonnen!");
      }
    }
    if (!isPlayerLost && !isBankLost) printDraw();
    // PrintWin('WinTest');
    // PrintLost('WinTest');
    // PrintDraw();
  }

  return jaNein("Möchtest Du noch ein Spiel machen?");
}

int nextCard(
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

void printCardsCurrent(int numberCard, int pointsSum, String actor,
    List<String> cards, List<String> suits, List<int> asses) {
  String actor1 = actor.length < 7 ? actor + '   ' : actor;
  String printCards0 = "$actor1: ";
  String printCards1 = '         ';
  String printCards2 = '         ';
  String color = '';
  for (int i = 0; i < cards.length; i++) {
    switch (suits[i]) {
      case '♦' || '♥':
        color = '\x1B[31;47m'; // rot auf weiß
      case '♠' || '♣':
        color = '\x1B[30;47m'; // schwarz auf weiß
    }

    // printCards += ' ${suits[i]} ${cards[i]} \x1B[0m';
    String card = cards[i];
    if (card.length == 1) card += ' ';
    printCards0 += '$color ${suits[i]} ${suits[i]} $colorEnd ';
    printCards1 += '$color  ${card} $colorEnd ';
    printCards2 += '$color ${suits[i]} ${suits[i]} $colorEnd ';
  }

  if (isBlackJack(cards, pointsSum)) {
    printCards0 += '(BlackJack)';
  } else {
    printCards0 += '($pointsSum Punkte)';
  }

  print(printCards0);
  print(printCards1);
  print(printCards2);
}

int GetRandom(int nRandom) {
  Random random = Random();
  int result = random.nextInt(nRandom);
  return result;
}

bool isBlackJack(List<String> cards, int pointsSum) {
  return cards.length == 2 && pointsSum == 21;
}

bool jaNein(String header) {
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

void printHeader(String header) {
  clearTerminal();
  printLine();
  print(header);
  printLine();
}

void printLine() {
  print(
      '----------------------------------------------------------------------------');
}

void printWin(String text) {
  sleep(Duration(seconds: 1)); // Hält das Programm für 1 Sekunden an
  printLine();
  print('$colorBlackGreen Glückwunsch, Du hast gewonnen! $text $colorEnd');
  printLine();
}

void printLost(String text) {
  sleep(Duration(seconds: 1)); // Hält das Programm für 1 Sekunden an
  printLine();
  print('$colorBlackRed Schade, Du hast verloren! $text $colorEnd');
  printLine();
}

void printDraw() {
  sleep(Duration(seconds: 1)); // Hält das Programm für 1 Sekunden an
  printLine();
  print(
      '$colorBlackYellow Noch mal gutgegangen! Ihr habt unentschieden gespielt!$colorEnd');
  printLine();
}

void clearTerminal() {
  // ANSI-Escape-Sequenz zum Löschen des Bildschirms und Zurücksetzen des Cursors
  stdout.write('\x1B[2J\x1B[0;0H');
}
