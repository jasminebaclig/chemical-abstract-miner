import java.io.*;
import java.util.Scanner;

public class RunRESTClientGet {
    public static void main(String[] args) {
        String[] param = {"Chemical", "PUBIDs", "PubTator"};
        String[] currLine;

        try {
            File inputFile = new File("pmid.txt"); //Input file with list of pmid for each species
            File pmidList = new File("pmidList.txt"); //Pmid list for one specie at a time
            File outputFile = new File("output.txt"); //Output of RESTClientGet.java
            File chemicalFile = new File("chemical.txt"); //Output file with chemical names for each species
            pmidList.createNewFile();
            outputFile.createNewFile();
            chemicalFile.createNewFile();

            PrintStream ps = new PrintStream(outputFile);
            System.setOut(ps);

            Scanner s = new Scanner(inputFile);
            BufferedWriter bw = new BufferedWriter(new FileWriter(pmidList));

            while(s.hasNextLine()) {
                currLine = s.nextLine().split("\t"); //String array with species name followed by pmid

                for(int i = 1; i < currLine.length; i++) {
                    bw.write(currLine[i] + "\n");
                }

                param[1] = "pmidList.txt";
                RESTClientGet.main(param);
                processOutputFile(outputFile, chemicalFile);
            }
        } catch(IOException e) {
            System.exit(1);
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