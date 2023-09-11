#Installs and loads necessary packages
install.packages("devtools")
install.packages("RISmed")

library(devtools)
library(RISmed)
library(VennDiagram)
library(qgraph)
library(bipartite)

install_github("BuerkiLabTeam/G2PMineR")
library(G2PMineR)

source("GenesLookeRModified.R")



##MODULE 1: CONDUCT LIT SEARCH AND ASSESS EFFICIENCY##

#Runs the lit search and retrieves abstract IDs
res <- EUtilsSummary("plant AND drought AND tolerance AND gene", type = "esearch", db = "pubmed", retmax = 10000)#, datetype = "pdat")
VignetteIDs <- attr(res, "PMID")

#Randomly samples 100 abstracts for vignette
set.seed(pi)
VignetteIDs <- VignetteIDs[sample(1:length(VignetteIDs), size = 50, replace = F)]

#Writes out data
write.csv(VignetteIDs, "VignetteIDs.csv", row.names = F)

#Coerces IDs into correct class
VignetteIDs <- as.numeric(VignetteIDs)

#Gets abstracts associated to VignetteIDs
VignetteAbstractStrings <- AbstractsGetteR(VignetteIDs)

#Writes out data
write.csv(VignetteAbstractsStrings, "VignetteAbstractsStrings.csv", row.names = F)

#Reads in vignette data
IDs <- read.csv("VignetteIDs.csv")
AbstractsStrings <- read.csv("VignetteAbstractsStrings.csv")

#Converts IDs and AbstractsStrings to vector if data.frame
IDs <- as.vector(IDs[,1])
AbstractsStrings <- as.vector(AbstractsStrings[,1])

#Removes IDs and strings associated to corrupt or absent abstracts
IDs <- as.character(IDs[!is.na(AbstractsStrings)])
AbstractsStrings <- AbstractsStrings[!is.na(AbstractsStrings)]

#Performs clustering analysis of abstratcs
NetList <- AbstractsClusterMakeR(AbstractsStrings, IDs)

#Investigates membership of abstract cluster groups
meminv <- MembershipInvestigatoR(NetList$Membership, threshold = 0.4, singularize = F)

#Plots network to visualize the relationships
plot(NetList$Netowork)

#Removes HTML elements that may be present in the abstract text
AbstractsStrings <- HTMLElementRemoveR(AbstractsStrings)

#Remove non-ANSI characters from strings
AbstractsStrings <- AlphaNumericalizeR(AbstractsStrings)



##MODULE 2: MINING TAXONOMY##

#Performs taxonomical mining
AbstractsSpp <- SpeciesLookeR(AbstractsStrings, IDs, Kingdom = "P", Add = NULL)
write.csv(AbstractsSpp, "AbstractsSpp.csv")

#Abbreviates species names
SpeciesAbbrvs <- SpeciesAbbreviatoR(AbstractsSpp)



##MODULE 3: MINING GENES##

#Performs gene mining
GenesOut <- GenesLookeRModified(AbstractsStrings, IDs, Kingdom = "P", Add = NULL, SppAbbr = SpeciesAbbrvs)
write.csv(GenesOut, "GenesOutWithSyns.csv", row.names = F)

#Replaces gene synonyms with accepted gene names
GenesOut <- SynonymReplaceR(GenesOut, Kingdom = "P")

#(Optional) Creates artificial gene groups
GeneGroups <- GeneNamesGroupeR(as.vector(GenesOut[,1]))

#(Optional) Grades the usefulness of matches
GeneGrades <- UtilityGradeR(GenesOut, Kingdom = "P", Add = NULL, Groups = as.data.frame(GeneGroups))

#(Optional) Sifts genes by frequency
SiftedGenes <- GeneFrequencySifteR(GenesOut, IDs)



##MODULE 4: MINING PHENOTYPES##

#Mines for phenotype words
AbsPhen <- PhenotypeLookeR(AbstractsStrings, IDs, Kingdom = "P", Add = NULL)
write.csv(AbsPhen, "AbsPhen.csv", row.names = F)



##MODULE 5: SUMMARIZE AND CONSENSUS TA, G, AND, P DATA##

#Calculates proportion of abstracts with at least one G match
AbstractsProportionCalculator(GenesOut, IDs)

#Calculates proportion of abstracts with at least one Ta match
AbstractsProportionCalculator(AbstractsSpp, IDs)

#Calculates proportion of abstracts with at least one P match
AbstractsProportionCalculator(AbsPhen, IDs)

#Makes gene mining results longform
GenesOutLong <- MakeGenesOutLongform(GenesOut)

#Makes taxonomy mining results longform
AbstractsSppLong <- MakeAbstractsSppLongform(AbstractsSpp)

#Makes phenotype words mining results longform
AbsPhenLong <- MakeAbsPhenLongform(AbsPhen)

#Makes a consensus of all three
All_Consensus <- ConsensusInferreR(Ta = AbstractsSppLong, G = GenesOutLong, P = AbsPhenLong, AbstractsSpp = AbstractsSpp, GenesOut = GenesOut, AbsPhen = AbsPhen)

#Makes a consensus of just a pair, if one result is empty
GbyP_Consensus <- ConsensusInferreR(Ta = NULL, G = GenesOutLong, P = AbsPhenLong, AbstractsSpp = NULL, GenesOut = GenesOut, AbsPhen = AbsPhen)

#Gets out restricted consensus-only G and P results
GenesCon <- All_Consensus$"Genes Consensus-Only"
PhenoCon <- All_Consensus$"Phenotypes Consensus-Only"

#Plots the Venn diagram
ConsensusVenn <- All_Consensus$Venn
pdf("ConsensusVenn.pdf")
grid.draw(ConsensusVenn)
dev.off()

#Gets the consensus matrix proper
ConsensusMatrix <- All_Consensus$IntersectionMatrix

#Gets the list of consensus IDs
ConsensusIDs <- All_Consensus$ConsensusIDs



##MODULE 6: INTERNAL NETWORK ANALYSES FOR G, TA, AND P DATA##

#Makes T matches barplot matrix
SppBarPlotDF <- MatchesBarPlotteR(AbstractsSpp$Species, AbstractsSpp$Matches, n = 25)

#Cleans G output
Genez <- as.data.frame(GenesOut[which(GenesOut$InOrNot == "Yes"),]) #Selects those with at least one match
Genez <- data.frame(Genez$Gene, Genez$Matches) #Forms new matrix
Genez <- unique(Genez)

#Makes G matches barplot matrix
GenesBarPlotDF <- MatchesBarPlotteR(Genez[,1], Genez[,2], n = 25)

#Makes P matches barplot matrix
PhenoBarPlotDF <- MatchesBarPlotteR(AbsPhen$PhenoWord, AbsPhen$AbsMatches, n = 25)

pdf("barplots.pdf")

#Makes Ta barplot
barplot(SppBarPlotDF[,2], names.arg = SppBarPlotDF[,1], las = 2, ylim = c(0,250), ylab = "Number of Abstracts")

#Makes G barplot
barplot(GenesBarPlotDF[,2], names.arg = GenesBarPlotDF[,1], las = 2, ylim = c(0,100), ylab = "Number of Abstrcts")

#Makes P barplot
barplot(PhenoBarPlotDF[,2], names.arg = PhenoBarPlotDF[,1], las = 2, ylim = c(0,1000), ylab = "Number of Abstracts", cex.names = 0.75)

dev.off()

#Calculates internal matchwise distance matrix for Ta
SppInt <- InternalPairwiseDistanceInferreR(AbstractsSpp$Species, AbstractsSpp$Matches, allabsnum = length(IDs))

#Selects only the top 50
SppIntSmall <- TopN_PickeR_Internal(SppInt, n = 50, decreasing = T)

#Assigns result to distance matrix class
rwmsS <- as.dist(SppIntSmall, diag = F, upper = FALSE)

#Calculates internal matchwise distance matrix for G
GenInt <- InternalPairwiseDistanceInferreR(Genez[,1], Genez[,2], allabsnum = length(IDs))

#Selects only the top 50
GenIntSmall <- TopN_PickeR_Internal(GenInt, n = 50, decreasing = T)

#Assigns result to distance matrix class
rwmsG <- as.dist(GenIntSmall, diag = F, upper = FALSE)

#Calculates internal matchwise distance matrix for P
PhenInt <- InternalPairwiseDistanceInferreR(AbsPhen$PhenoWord, AbsPhen$AbsMatches, allabsnum = length(IDs))

#Selects only the top 100
PhenIntSmall <- TopN_PickeR_Internal(PhenInt, n = 100, decreasing = T)

#Assigns result to distance matrix class
rwmsP <- as.dist(PhenIntSmall, diag = FALSE, upper = FALSE)

pdf("qgraphs.pdf")

#Plots Ta internal matchwise relations network based on the distance matrix
qgraph(rwmsS, layout = "circle", labels = gsub("_", " ", rownames(SppIntSmall)), DoNotPlot = F, label.cex = 0.4)

#Plots G internal matchwise relations network based on the distance matrix
qgraph(rwmsG, layout = "circle", labels = rownames(GenIntSmall), DoNotPlot = F, label.cex = 0.4)

#Plots P internal matchwise relations network based on the distance matrix
qgraph(rwmsP, layout = "circle",labels = rownames(PhenIntSmall), DoNotPlot = F, label.cex = 0.4)

dev.off()



##MODULE 7: INFER BIPARTITE GRAPHS TO LINK G, TA AND P DATA##

#Calculates phenotypes vs species inter-dataype matchwise distances
PhenoSpecies <- PairwiseDistanceInferreR(AbstractsSpp$Species, AbstractsSpp$Matches, AbsPhen$PhenoWord, AbsPhen$AbsMatches, allabsnum = length(IDs))

#Selects only the top 100
PhenoSpeciesSmall <- TopN_PickeR(PhenoSpecies, n = 100, decreasing = T)

#Calculates genes vs species inter-datatype matchwise distances
GenesSpecies <- PairwiseDistanceInferreR(AbstractsSpp$Species, AbstractsSpp$Matches, Genez, Genez[,2], allabsnum = length(IDs))

#Selects only the top 100
GenesSpeciesSmall <- TopN_PickeR(GenesSpecies, n = 100, decreasing = T)

#Calculates phenotypes vs genes inter-datatype matchwise distances
PhenoGenes <- PairwiseDistanceInferreR(AbsPhen$PhenoWord, AbsPhen$AbsMatches, Genez[,1], Genez[,2], allabsnum = length(IDs))

#Selects only the top 50
PhenoGenesSmall <- TopN_PickeR(PhenoGenes, n = 50, decreasing = T)

pdf("bipartites.pdf")

#Plots G2P internal matchwise relations network based on the distace matrix
plotweb(PhenoGenesSmall, text.rot = 90, col.interaction = "gray", labsize = 0.75)

#Plots Ta2G internal matchwise relations network based on the distance matrix
plotweb(GenesSpeciesSmall, text.rot = 90, col.interaction = "gray", labsize = 0.75)

#Plots Ta2P internal matchwise relations network based on the distance matrix
plotweb(PhenoSpeciesSmall, text.rot = 90, col.interaction = "gray", labsize = 0.75)

dev.off()