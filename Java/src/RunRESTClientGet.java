import java.io.*;
import java.util.Scanner;
import java.util.ArrayList;

public class RunRESTClientGet {
    public static void main(String[] args) {
        File inputFile = new File("pmid.txt"); //Input file with list of pmid for each species
        File pmidList = new File("pmidList.txt"); //Pmid list for one specie at a time
        File outputFile = new File("output.txt"); //Output of RESTClientGet.java
        File chemicalFile = new File("chemical.tsv"); //Output file with chemical names for each species

        String[] currLine;
        String[] param = {"Chemical", "pmidList.txt", "PubTator"};

        int count = 0;

        try {
            pmidList.createNewFile();
            chemicalFile.createNewFile();

            Scanner s = new Scanner(inputFile);
            PrintStream stdOut = System.out;

            while(s.hasNextLine()) {
                currLine = s.nextLine().split("\t"); //String array with species name followed by pmid
                BufferedWriter bw = new BufferedWriter(new FileWriter(pmidList, false));

                for(int i = 1; i < currLine.length; i++) {
                    bw.write(currLine[i] + "\n");
                }

                outputFile.createNewFile();
                PrintStream ps = new PrintStream(outputFile);
                System.setOut(ps);

                RESTClientGet.main(param);
                processOutputFile(outputFile, chemicalFile, currLine[0]);

                System.setOut(stdOut);
                outputFile.delete();
                bw.close();

                count++;
                System.out.println(count + " species done.");
            }

            s.close();
        } catch(IOException e) {
            System.exit(1);
        }
    }

    private static void processOutputFile(File outputFile, File chemicalFile, String speciesName) {
        Scanner s = null;

        try {
            s = new Scanner(outputFile);
        } catch(FileNotFoundException e) {
            System.exit(1);
        }
        
        String currLine = "";
        String[] stringArray;
        ArrayList<String> chemicalArray = new ArrayList<>();

        while(s.hasNextLine()) {
            currLine = s.nextLine();

            if(currLine.contains("|t|") || currLine.contains("|a|") || currLine.isBlank()) {
                continue;
            } else {
                stringArray = currLine.split("\t");

                if(!chemicalArray.contains(stringArray[3])) {
                    chemicalArray.add(stringArray[3]);
                }
            }
        }

        s.close();
        String outputLine = speciesName + "\t";

        for(String chemical : chemicalArray) {
            outputLine += chemical + ", ";
        }

        outputLine = outputLine.substring(0, outputLine.length() - 2);

        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(outputFile, true));
            bw.write(outputLine + "\n");
            bw.close();
        } catch(IOException e) {
            System.exit(1);
        }
    }
}