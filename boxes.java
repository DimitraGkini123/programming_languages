import java.io.*;
import java.util.*;

public class boxes {

    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Χρήση: java ReadInputFile <filename>");
            return;
        }
        String filePath = args[0]; //diavasma arxeiou eisodou

;
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            // Read first line: N and M
            String[] firstLine = br.readLine().trim().split("\\s+");
            int N = Integer.parseInt(firstLine[0]);  //arithmos koutiwn
            int M = Integer.parseInt(firstLine[1]);  //ogkos pou theloume na ftasoume


            String[] secondLine = br.readLine().trim().split("\\s+");

            if (secondLine.length != N) {
                System.out.println("Error: Expected " + N + " integers, but found " + secondLine.length);
                return;
            }

            int[] numbers = new int[N];
            for (int i = 0; i < N; i++) {
                numbers[i] = Integer.parseInt(secondLine[i]); //apothikeusi twn koutiwn se pinaka
            }
            // Find and print combinations
            findCombinations(numbers, M);

        } catch (IOException e) {
            System.out.println("Error reading file: " + e.getMessage());
        } catch (NumberFormatException e) {
            System.out.println("Invalid number format: " + e.getMessage());
        }
    }

    // euresi olwn twn pithanwn sunduasmwn pou kanoyn AKRIVWS M.
    public static void findCombinations(int[] numbers, int target) {
        List<Integer> combination = new ArrayList<>();
        boolean[] found = new boolean[1];  //boolean metavliti pou tha elegxei an vrethike sundyuasmos h oxi.
        backtrack(numbers, target, 0, combination, found); //kalesma ths backtrack

        if(!found[0]) {  //den iparxei sundyasmos
                System.out.println("IMPOSSIBLE");
        }
}

/*
epeksigkhsh ths backtrack:
ksekiname apo target = M kai dokimazoume tous arithmous apo ton pinaka number. Stoxos einai na mhdenistei to target.
Me to for loop:
-Se kathe vima  epilegoume enan arithmo apo ton pinaka
-An arithmos <= target --> ton vazoume sthn lista
-Kaloume anadromika thn backtrack gia ton idio arithmo, exontas ws neo stoxo to target-arithmo, mexri na mhdenistei to target.
-Molis teleiwsei h anadromi afairoume ayton ton arithmo apo tin lista.
- Oi syndyasmooi apothikeyontai sthn lista current.
*/
    private static void backtrack(int[] numbers, int target, int start, List<Integer> current, boolean[] found) {
        if (target == 0) {
            found[0] = true; //vrethike sunduasmos.
            for (int num : current) {
                System.out.print(num + " ");  //typwnontai oi sunduasmoi
        }
            System.out.println();
            return;
        }

        for (int i = start; i < numbers.length; i++) {
            if (numbers[i] <= target) {
                current.add(numbers[i]);
                backtrack(numbers, target - numbers[i], i, current, found); // allow repetition (i instead of i+1)
                current.remove(current.size() - 1); // backtrack
            }
        }
    }
}