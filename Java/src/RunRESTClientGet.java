import java.io.*;
import java.util.Scanner;

public class RunRESTClientGet {
    public static void main(String[] args) {
        Scanner s = null;
        String[] param = {"Chemical", "PUBIDs", "PubTator"};
        String[] currLine;

        try {
            File inputFile = new File("pmid.txt");
            File pmidList = new File("pmidList.txt");
            File outputFile = new File("output.txt");
            File chemicalFile = new File("chemical.txt");
            pmidList.createNewFile();
            outputFile.createNewFile();
            chemicalFile.createNewFile();

            PrintStream ps = new PrintStream(outputFile);
            System.setOut(ps);

            s = new Scanner(inputFile);
            
            BufferedWriter bw = new BufferedWriter(new FileWriter(pmidList));
        } catch(IOException e) {
            System.exit(1);
        }

        while(s.hasNextLine()) {
            currLine = s.nextLine().split("\t");
            RESTClientGet.main(param);
        }
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