/**
 * Takes list of PMIDs for each plant species and extracts chemical names from their abstracts.
 * 
 * Author: @jasminebaclig
 */

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Scanner;

public class ChemicalMiner {
    /**
     * Main method for ChemicalMiner class.
     * @param args
     */
    public static void main(String[] args) {
        long startTime = System.nanoTime(); //Start timer to calculate execution time

        File inputFile = new File("pmid.txt"); //Input file with list of PMIDs for each species (from R code)
        File pmidList = new File("pmidList.txt"); //PMID list for one specie at a time
        File outputFile = new File("output.txt"); //Output of RESTClientGet.java
        File chemicalFile = new File("chemical.tsv"); //Output file with chemical names for each species

        String[] currLine; //Current line in pmid.text
        String[] param = {"Chemical", "pmidList.txt", "PubTator"}; //Parameters for runRESTfulAPI method

        int count = 0; //Number of species processed

        try {
            pmidList.createNewFile();
            chemicalFile.createNewFile();

            BufferedWriter bw = new BufferedWriter(new FileWriter(chemicalFile, false));
            bw.write("species\tchemical\tfrequency\tpmid\n"); //Column names for output file
            bw.close();

            Scanner s = new Scanner(inputFile);
            PrintStream stdOut = System.out; //Default System.out

            while(s.hasNextLine()) {
                currLine = s.nextLine().split("\t"); //String array with species name followed by PMIDs
                FileWriter fw = new FileWriter(pmidList, false);

                for(int i = 1; i < currLine.length; i++) { //Writes one PMID per line to pmidList.txt
                    fw.write(currLine[i] + "\n");
                    fw.flush();
                }

                outputFile.createNewFile();
                PrintStream ps = new PrintStream(outputFile);
                System.setOut(ps);

                runRESTfulAPI(param);
                processOutputFile(outputFile, chemicalFile, currLine[0]);

                System.setOut(stdOut);
                outputFile.delete(); //Resets output.txt
                fw.close();

                count++;
                System.out.println(count + " species done.");
            }

            s.close();
            pmidList.delete();
        } catch(IOException e) {
            System.exit(1);
        }

        long elapsedTime = System.nanoTime() - startTime;
        System.out.println("Elapsed time in hours: " + (elapsedTime / 1000000 / 60000 / 60));
    }

    /**
     * Runs a RESTful API service to extract chemical names from abstracts.
     * Code in method taken from Wei et al. (2016).
     * 
     * @param param parameters needed for service (bioconcept, input file, format)
     */
    private static void runRESTfulAPI(String[] param) {
        String bioconcept = param[0];
		String inputFile = param[1];
		String format = param[2];

		try {		
			BufferedReader fr = new BufferedReader(new FileReader(inputFile));
			String pmid = "";

			while((pmid = fr.readLine()) != null) {
				URL urlSubmit = new URL("https://www.ncbi.nlm.nih.gov/CBBresearch/Lu/Demo/RESTful/tmTool.cgi/" + bioconcept + "/" + pmid + "/" + format + "/");
				HttpURLConnection connSubmit = (HttpURLConnection) urlSubmit.openConnection();
				connSubmit.setDoOutput(true);
				BufferedReader brSubmit = new BufferedReader(new InputStreamReader(connSubmit.getInputStream()));
				String line = "";

				while((line = brSubmit.readLine()) != null) {
					System.out.println(line);
				}
				
                connSubmit.disconnect();
			}

			fr.close();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
    }

    /**
     * Formats and analyzes output.
     * 
     * @param outputFile output of runRESTfulAPI method
     * @param chemicalFile list of chemicals for each plant species
     * @param speciesName name of plant species
     */
    private static void processOutputFile(File outputFile, File chemicalFile, String speciesName) {
        Scanner s = null;

        try {
            s = new Scanner(outputFile);
        } catch(FileNotFoundException e) {
            System.exit(1);
        }
        
        String currLine = ""; //Current line in output.txt
        String[] stringArray;
        String chemicalName; //Chemical name in currLine
        String pmid; //PMID in currLine

        ArrayList<String> chemicalArray = new ArrayList<>(); //List of chemical names
        ArrayList<Integer> frequencyArray = new ArrayList<>(); //List of frequency for each chemical name
        ArrayList<LinkedList<String>> pmidArray = new ArrayList<>(); //List of PMIDs that contained each chemical name

        int index;

        while(s.hasNextLine()) {
            currLine = s.nextLine();

            if(!currLine.contains("|t|") && !currLine.contains("|a|") && !currLine.isBlank()) { //Checks if line contains a chemical name found in abstract
                stringArray = currLine.split("\t");
                chemicalName = stringArray[3].toLowerCase();
                pmid = stringArray[0];

                if(!chemicalArray.contains(chemicalName)) { //Checks if chemical name is not a duplicate
                    chemicalArray.add(chemicalName);
                    frequencyArray.add(Integer.valueOf(1)); //Sets frequency to 1
                    pmidArray.add(new LinkedList<>());
                    pmidArray.getLast().add(pmid); //Adds PMID of article to corresponding list
                } else {
                    index = chemicalArray.indexOf(chemicalName);
                    frequencyArray.set(index, Integer.valueOf(frequencyArray.get(index).intValue() + 1)); //Increments frequency if chemical name is found again

                    if(!pmidArray.get(index).contains(pmid)) { //Checks if PMID is not a duplicate
                        pmidArray.get(index).add(pmid); //Adds PMID of article to corresponding list
                    }
                }
            }
        }

        s.close();

        try {
            String outputLine; //Line containing one chemical name and details
            String pmidString; //List of PMIDs that contained a certain chemical name
            LinkedList<String> pmidList;
            int size;
            FileWriter fw = new FileWriter(chemicalFile, true);

            for(int i = 0; i < chemicalArray.size(); i++) {
                outputLine = speciesName + "\t" + chemicalArray.get(i) + "\t" + frequencyArray.get(i) + "\t";
                pmidList = pmidArray.get(i);
                size = pmidList.size();
                pmidString = ""; //Resets pmidString

                for(int j = 0; j < size; j++) {
                    pmidString += pmidList.removeFirst() + ", ";
                }

                pmidString = pmidString.substring(0, pmidString.length() - 2); //Removes last terminal comma and space
                outputLine += pmidString;

                fw.write(outputLine + "\n");
                fw.flush();
            }

            fw.close();
        } catch(IOException e) {
            System.exit(1);
        }
    }
}