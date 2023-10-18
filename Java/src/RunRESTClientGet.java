import java.io.*;
import java.util.Scanner;

public class RunRESTClientGet {
    public static void main(String[] args) {
        try {
            File outputFile = new File("output.txt");
            File chemicalFile = new File("chemical.txt");
            outputFile.createNewFile();
            chemicalFile.createNewFile();

            PrintStream ps = new PrintStream(outputFile);
            System.setOut(ps);
        } catch(IOException e) {
            System.exit(1);
        }

        String[] param = {"Chemical", "pub_id.csv", "PubTator"};
        RESTClientGet.main(param);
    }

    private static void processOutputFile(File outputFile, File chemicalFile) {
        Scanner s = null;

        try {
            s = new Scanner(outputFile);
        } catch(FileNotFoundException e) {
            System.exit(1);
        }
        
        String currLine = "";
        String[] stringArray;

        while(s.hasNextLine()) {
            currLine = s.nextLine();

            if(currLine.contains("|t|") || currLine.contains("|a|")) {
                continue;
            } else {
                stringArray = currLine.split("  ");
            }
        }
    }
}