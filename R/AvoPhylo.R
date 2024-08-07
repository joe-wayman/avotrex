utils::globalVariables(c("phylo_id", "group",
                         "BLFamilyLatin", "Order",
                         "Clade", "i", "stopCluster",
                         "type", "jetz_family",
                         "jetz_order"))

#' AvoPhylo: Building phylogenies based on the AvoTrex extinct bird trait
#' database and BirdTree backbone
#' 
#' @description
#' Grafting extinct species onto BirdTree phylogenies using the AvoTrex database
#' 
#' @usage AvoPhylo(ctrees, avotrex, tax, PER = 0.2, PER_FIXED = 0.75, mindist =
#'   0.1, ord = FALSE, Ntree, n.cores = 1, cluster.ips = NULL)
#' 
#' @details
#' Function to build phylogenies incorporating the extinct species from the
#' AvoTrex extinct birds database (Sayol et al.). AvoTrex provides data on
#' geographical location, island endemicity, volancy, body size and standard
#' external and skeleton morphological measurements for 610 extinct bird
#' species. The AvoPhylo function provides a pipeline to incorporate the extinct
#' species from AvoTrex into the "BirdTree" phylogenies of extant birds (Jetz et
#' al. 2012). Utilising codes assigned to each species based on their known
#' taxonomic affinities, the function binds each species in turn to a provided
#' BirdTree phylogeny. Input phylogenies (i.e., BirdTree trees) must be of class
#' 'phylo', see \code{\link[ape]{phylo}}.
#' 
#' BirdTree phylogenies can be sourced from: https://birdtree.org/
#' 
#' As certain species need to be grafted onto the tree before
#' other species, a number of the species are grafted in a set
#' order. This ordering is controlled through the “sp_id”,
#' “phylo_id” and “group” columns in the extinct species
#' phylogeny database. Before grafting, the database is ordered
#' by the “sp_id” column, with the “phylo_id” and “group” columns
#' used to filter out particular groups of species (i.e., those
#' classified as "xS" in the "phylo_id" column) to be grafted in
#' different orders (i.e., either a randomised order within
#' groups, or a fixed order within groups). See the package
#' vignette, as  well as Sayol et al. and Matthews et al., for
#' further details.
#' 
#' For a subset of species (primarily those in older clades), we
#' have constrained the grafting to take place at a specific time
#' point (value in the 'time_fixed' column) along a given branch,
#' rather than at a randomly selected point. If, due to the
#' topology of the underlying BirdTree tree, it is not possible
#' to undertake this grafting along a given branch (i.e., the
#' time point for grafting is either older than the parent node
#' or younger than the child node, in respect to a given focal
#' branch), we graft the species just below the parent node or
#' just above the child node (using a branch length set by
#' \code{mindist} - if \code{mindist} is longer than the focal
#' branch in a given grafting event, it is adjusted accordingly).
#' 
#' As some of the grafting codes (see table below) randomly place
#' the given species within a group of species, a genus, or a
#' family, and some species groups are randomised before grafting
#' (see above), it is useful to run the grafting procedure over a
#' a number of trees to average out the randomisation. Therefore,
#' the function can be run in parallel using the argument
#' \code{n.cores}. Note that the function will run on one core as
#' default and if only one tree is supplied. Trees for grafting
#' can be randomly selected from a number of input trees by
#' giving the function a group of input trees using the argument
#' \code{ctrees} and then defining a smaller number using
#' \code{Ntree}. If the maximum number of input trees is to be
#' used, \code{Ntree} should equal \code{length(ctrees)}. If you
#' want the outputted list of trees to match the order of trees
#' in \code{ctrees}, set \code{ord = TRUE}.
#' 
#' If \code{Ntree} > 1, a progress bar will be displayed.
#' 
#' A variety of different plotting options are available, see
#' the \code{\link{plot.avophylo}} documentation.
#' 
#' 
#' 
#' Codes | Full name                   | Definition                                                                          |
#' ------|-----------------------------|-------------------------------------------------------------------------------------|
#' S     | Sister                      | Grafted as a sister to a known extant or extinct species already in the tree        |
#' SSG   | Sister species group        | Grafted as a sister to a group of extant and/or extinct species already in the tree |
#' SGG   | Sister genus group          | Grafted as a sister to an entire extant or extinct genus (i.e., for the first grafted representative of an extinct genus)       |
#' SGG2  | Sister genus group 2        | Grafted as sister to multiple genera. This was for when a species was sister to a subfamily or some other large specific clade  |
#' SFG   | Sister family group         | Grafted as a sister to an entire extant or extinct family already present in the  tree (i.e., for the first grafted representative of an extinct family)    |
#' SOG   | Sister order group          | Grafted as a sister to an entire order already present in the tree (i.e., for the first grafted representative of an extinct order)   |
#' RSG   | Random species group        | Grafted to a randomly selected species from a pre-defined group of species (i.e., from which is believed to have close affinities    | 
#' RGG   | Random genus group          | Grafted to a randomly selected species from a given genus. For example, if an  extinct species was believed to be a finch derived from a European finch species, but the exact sister species is unknown.          |
#' RGG2  | Random genus group 2        | Grafted to a randomly selected species from a group of genera (e.g. when all that is known is that the species is from a specific subfamily). Currently not used in the database, but the relevant functionality has been kept in the R script, as it could be useful for future studies. | 
#' RFG   | Random family group         | Grafted to a randomly selected species from a given family                          |  
#' RSGG  | Random sister genus group   | Grafted as sister to a randomly selected genus from a pre-defined group of genera   | 
#' RSGG2 | Random sister genus group 2 | Grafted as sister to a randomly selected genus from a pre-defined family            |                                                                                                   
#'
#' @md     
#'     
#' @references Matthews et al. (IN REVIEW) The global loss of avian functional and phylogenetic diversity from extinctions in 
#' the Holocene and Late Pleistocene
#' 
#' Sayol et al. (IN PREP) The global loss of avian functional and phylogenetic diversity 
#' from extinctions in the Holocene and Late Pleistocene 
#' 
#' @param ctrees Either (i) object (of class multiPhylo) containing multiple
#'   BirdTree phylogenies. Individual trees within the multiPhylo object must be
#'   of class 'phylo', see the \code{ape} package. Or (ii) an individual tree
#'   object of class 'phylo'.
#' @param avotrex The AvoTrex extinct species phylogeny database. This database
#'   contains the information and commands required to graft the extinct species
#'   on to the BirdTree trees. If edited, column names must remain unchanged.
#' @param tax The Jetz et al. (2012) BirdTree taxonomy .csv. Supplied as data
#'   within the package.
#' @param PER Percentage/fraction for branch truncation based on random grafting
#'   (see \code{\link{AvoBind}} for more details). Can be left at the default
#'   value.
#' @param PER_FIXED Point along a branch (expressed as a fraction
#'   of the branch length, rootward) to graft the species in the
#'   phylogeny database (\code{avotrex} argument) which are set
#'   to TRUE in the per_fixed column (to reduce very short branch
#'   lengths) (see \code{\link{AvoBind}} for more details). Can
#'   be left at the default value.
#' @param mindist When fixing the grafting of a given species at
#'   a specific time point, but the provided grafting time point
#'   is too old (i.e., older than the parent node) or too young
#'   (i.e., younger than the child node) relative to the focal
#'   branch, grafting will occur \code{mindist} below the parent
#'   node or above the child node.
#' @param ord Should the trees within \code{ctrees} be kept in
#'   order (TRUE) and all used (i.e., the output list of trees is
#'   in the same order as \code{ctrees}) in the grafting, or
#'   should trees be randomly sampled from \code{ctrees} (FALSE;
#'   the default) prior to grafting. If \code{ord == TRUE},
#'   \code{Ntree} must equal the length of \code{ctrees}. If only
#'   a single tree is provided, this argument does nothing.
#' @param Ntree The number of trees to sample from the supplied
#'   number of BirdTree trees (i.e., \code{ctrees}), if \code{ord
#'   == FALSE}. Value must be greater or equal to the number of
#'   supplied trees (\code{length(ctrees))}. If \code{ord ==
#'   TRUE}, \code{Ntree} must equal the length of \code{ctrees}.
#' @param n.cores Number of cores used to build the phylogeny.
#'   Default is one (will run with parallel processing)
#' @param cluster.ips Cluster location. Keep as default. 
#' @return The function returns an object of class
#'   'multiAvophylo', which is a list consisting of N trees (each
#'   of class 'avophylo' and 'phylo') that were selected from the
#'   supplied set of input trees. These ouput trees have all had
#'   the extinct species from AvoTrex grafted on.
#' @importFrom parallel makeCluster
#' @importFrom parallel stopCluster
#' @importFrom snow makeSOCKcluster
#' @importFrom doParallel registerDoParallel
#' @importFrom doSNOW registerDoSNOW
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @importFrom foreach foreach `%dopar%` `%do%`
#' @importFrom dplyr filter
#' @importFrom stringr str_split
#' @importFrom stats runif
#' @importFrom utils getFromNamespace
#' @import ape
#' @examples 
#' # data(BirdTree_trees)
#' # data(BirdTree_tax)
#' # data(AvotrexPhylo)
#' # trees <- AvoPhylo(ctrees = BirdTree_trees,
#' # avotrex = AvotrexPhylo, PER = 0.2, PER_FIXED = 0.75,
#' # mindist = 0.1, ord = FALSE, 
#' # tax = BirdTree_tax, Ntree = 1, n.cores = 1, cluster.ips = NULL)
#' # class(trees)
#' # trees[[1]]
#' # class(trees[[1]])
#' 
#' #See the plot.avophylo documentation for the different available
#' #plotting options.
#' @export 

AvoPhylo <- function(
    ctrees,
    avotrex,
    tax, 
    PER = 0.2,
    PER_FIXED = 0.75,
    mindist = 0.1,
    ord = FALSE,
    Ntree,
    n.cores = 1,
    cluster.ips = NULL
    ){
  
  avotrex <- as.data.frame(avotrex)
  
  if (!all(avotrex$type %in% c("AP","RFG","RGG", "RGG2", "RSG", 
                               "RSGG","RSGG2","S","SFG", 
                               "SGG","SGG2","SOG","SSG",
                               "RCG", "ROG"))){
    stop("group column in avotrex argument contains invalid codes")
  }
  
  if (PER < 0 | PER > 1){
    stop ("PER must be numeric and >= 0 and <= 1")
  }
  
  if (!inherits(ctrees, "multiPhylo")){
   if (!inherits(ctrees, "phylo")){
     stop("Tree object should be of class 'phylo'")
   }
  } else{
    lapply(ctrees, function(y){
      if (!inherits(y, "phylo")){
        stop("Tree objects should be of class 'phylo'")
      }
    })
  }
  
  if (length(ord) != 1 | !is.logical(ord)){
    stop("ord should be logical and of length 1")
  }
  
  avotrex$time_fixed <- suppressWarnings(as.numeric(avotrex$time_fixed))#NA warning fine (just because already NAs in column)
  
  if (!all(sapply(avotrex$time_fixed, 
                  function(y) (is.na(y) | is.numeric(y))))){
    stop("time_fixed values should be either NA or numeric")
  }
  
  #subset a number of trees you want to run
  if (inherits(ctrees, "phylo")){ #ie one tree not in list
    if (Ntree != 1){stop("Error: Number of sampled trees greater than the number of supplied trees.")}
    ctrees <- list(ctrees)
    class(ctrees) <- "multiPhylo"
  } else {
    if (length(ctrees) < Ntree){stop("Error: Number of sampled trees greater than the number of supplied trees.")}
    if (!ord){
      ctrees <- sample(ctrees, Ntree, replace = F)
    } else {
      if (length(ctrees) != Ntree) {stop("Error: Ntree must equal length of ctrees if ord == TRUE")}
    }
  }
  
  if (Ntree < n.cores){
    message(paste0("As Ntree == ",Ntree," only ",Ntree," core(s) will be used\n"))
  }
  
  # Set up the cluster for parallel processing 
  if (is.null(cluster.ips)) {
    if (n.cores == 1) {
      `%dopar%` <- foreach::`%do%`
      on.exit(`%dopar%` <- foreach::`%dopar%`)
      cluster.ips <- NULL
    }
    else {
      temp.cluster <- parallel::makeCluster(n.cores, type = "PSOCK")
    }
  }
  if (exists("temp.cluster")) {
    doParallel::registerDoParallel(cl = temp.cluster)
    doSNOW::registerDoSNOW(temp.cluster)
    on.exit(stopCluster(temp.cluster))
  }
  
  #Set a progress bar to return progress of the foreach loop: for one core this is updated within the loop
  #for multiple cores it is set using .options.snow
  if (Ntree > 1){
    if(n.cores == 1){
      opts <- NULL
      pb <- txtProgressBar(min = 0, max = Ntree, style = 3)
    }else{
      pb <- txtProgressBar(min = 0, max = Ntree, style = 3)
      progress <- function(n) setTxtProgressBar(pb, n)
      opts <- list(progress=progress)
    }
  } else {
    opts <- NULL
  }
  
  avotrex$group <- suppressWarnings(as.numeric(avotrex$group))#NA warning fine (just because already NAs in group)
  
  #Run the parallel dataprep
  ctreesComplete <- foreach(
    i = 1:Ntree,
    .options.snow = opts, 
    .packages = c("phytools")) %dopar%
    {
      
      ctree <- ctrees[[i]]   # Each loop we do one tree
      
      ult <- ape::is.ultrametric(ctree)
      neg <- any(ctree$edge.length < 0)
      if (neg) warning("Input tree contains negative branch lengths")
      
      ## Reorder the dataset 
      ex <- avotrex
      ex <- ex[order(ex$sp_id),]
      row.names(ex) <- 1:nrow(ex)
      
      if (any(ex$phylo_id == "xS")){
      
      ## Subset the species to randomly shuffle
      shuff <- dplyr::filter(ex, phylo_id == "xS")

      ## Remove those species from the initial DB
      ex <- dplyr::filter(ex, !phylo_id == "xS")
      ## Set the order
      groups <- as.numeric(unique(shuff$group))
      groups <- sort(groups)
      
      for(p in 1:length(groups)){
        
        shuff2 <- dplyr::filter(shuff, group == groups[p])
        shuff2 <- shuff2[sample(1:nrow(shuff2)), ]
        ex <- rbind(ex, shuff2)
        
      }
      
      row.names(ex) <- 1:nrow(ex)
      }#eo if xs
      
      #create copy which is used in the check_ext() function;
      #this adds extinct order, family and genus names to the
      #jetz columns
      ex2 <- ex
      Bl_levs <- c("order", "family", "genus")
      BT_levs <- c("jetz_order", "jetz_family", "jetz_genus")
      for (z in 1:length(Bl_levs)){
        wlevs <- which(ex2[,BT_levs[z]] == "Extinct")
        ex2[wlevs,BT_levs[z]] <- ex2[wlevs,Bl_levs[z]]
      }
      ex2$jetz_order <- toupper(ex2$jetz_order)
      
      # For each extinct species find the optimum place to bind 
      for (j in 1:nrow(ex)){
        
        #First check if species is time_fixed, and if so, extract the time point
        #info. If not extract the species' per code and set the PER_VAL and
        #per_fixed values.
        #For the clades with many closely related extinct species,
        #they have a per_fixed value of TRUE in the database. For these,
        #set per to 0.75 (or PER_FIXED provided value) to try to avoid 
        #really short terminal branches
        #(although sometimes this is forced due to BirdTree typology)
        time_fix <- ex$time_fixed[j]
        if (is.na(time_fix)){
          time_graft <- FALSE
        per_val <- ex$per_fixed[j]
        if (per_val){
          PER_VAL <- PER_FIXED
          pfv <- TRUE
        } else {
          PER_VAL <- PER
          pfv <- FALSE
        }#eo if per_val
        } else {
          time_graft <- TRUE
          PER_VAL <- time_fix
          pfv <- NULL
          if (length(mindist) > 1 | (!is.numeric(mindist))){
            stop("mindist must be a numeric vector of length 1")
          }
          if (ex$type[j] == "S"){
            terminal <- TRUE
          } else {
            terminal <- FALSE
          }#eo if type == S
          }#eo if time_val
        
        # Code for checking where individual trees break
        # vec <- paste0(j, ex[j,]$species)
        # write.csv(vec, paste0("Broke/broke_", i, ".csv"), row.names = F)
        
        # AP = Already present - Nothing needs to be done  
        if (ex$type[j] == "AP"){
          next
        } else if (ex$type[j] == "S"){
          ## Scenario 1.1: Add target species as a single sister of species X 
          ## - S (SISTER SPECIES)
          
          # Get the tip location for the sister sp.
          nodeX <- which(ctree$tip.label == paste0(ex$sister_genus[j], 
                                                   "_", ex$sister_species[j])) 
          
        } else if (ex$type[j] %in% c("SSG", "SGG", "SGG2", "SFG", "SOG")){
          ## Scenario 1.2: Add species as a sister (outgroup) of a group of
          ## species ## - SSG (SISTER SPECIES GROUP) & SGG (SISTER GENUS GROUP)
          ## & SFG (SISTER FAMILY GROUP) & SOG (SISTER ORDER GROUP)
          
          if (ex$type[j] == "SSG"){
            
            # Separate the species in the "sister_species_group" column
            sp <- stringr::str_split(ex$sister_species_group[j], pattern = ";")
            spv <- sp[[1]]

            # This selects the most recent common ancestor for the group of species
            nodeX <- getMRCA(ctree, spv) 
          } else if (ex$type[j] == "SGG"){
            
            # If only one species is present within the genus, then make a
            # sister to that species
            if (length(ctree$tip.label[grep(paste0(ex$sister_genus[j], "_"), 
                                            ctree$tip.label)]) == 1){
              # Get the tip location for the sister sp.
              nodeX <- which(ctree$tip.label == 
                               ctree$tip.label[grep(paste0(ex$sister_genus[j], 
                                                           "_"), ctree$tip.label)]) 

            } else {

              # Get most recent common ancestor of genus 
              nodeX <- getMRCA(ctree, 
                               ctree$tip.label[grep(paste0(ex$sister_genus[j], 
                                                           "_"), ctree$tip.label)]) 
 
            }
          } else if (ex$type[j] == "SGG2"){
            
            sp <- stringr::str_split(ex$sister_genus[j], pattern = ";")
            spv <- vector()
            
            # Get all the species in the genera
            for (x in 1:length(sp[[1]])){
              
              spv <- c(spv, ctree$tip.label[grep(paste0(sp[[1]][x], "_"),
                                                 ctree$tip.label)])
              
            }
            # Get most recent common ancestor of species group
            nodeX <- getMRCA(ctree, spv)  
          } else if (ex$type[j] == "SFG"){
            
            # Get all species within the family 
            fam <- dplyr::filter(tax, 
                                 BLFamilyLatin == ex$sister_family[j])
            spv <- fam$TipLabel
            #add in extinct sp already grafted
            spv <- check_ext(ex2, level = ex$sister_family[j], 
                             ctree, spv, code = "SFG")
            
            # This selects the most recent common ancestor for the group of species
            nodeX <- getMRCA(ctree, spv)
          } else if (ex$type[j] == "SOG"){
            
            # Get all species within the family 
            ord <- dplyr::filter(tax, Order == ex$sister_order[j])
            spv <- ord$TipLabel
            #add in extinct sp already grafted
            spv <- check_ext(ex2, level = ex$sister_order[j], 
                             ctree, spv, code = "SOG")
         
            # This selects the most recent common ancestor for the group of species
            nodeX <- getMRCA(ctree, spv) 
          }
          
        } else if (ex$type[j] %in% c("RSG", "RGG", "RGG2", "RCG", "RFG", "ROG")){
          ## Scenario 2.1: Add species randomly within of a group of species ##
          ## - RSG (RANDOM SPECIES GROUP) & RGG (RANDOM GENUS GROUP) & RFG
          ## (RANDOM FAMILY GROUP) & ROG (RANDOM ORDER GROUP)
          
          if (ex$type[j] == "RSG"){
            
            # Separate the species in the "sister_species_group" column
            sp <- stringr::str_split(ex$sister_species_group[j], 
                                     pattern = ";")
            spv <- sp[[1]]
    
            ## Randomly select one of the species from the listed group. If it
            ## is not present in the tree yet, remove from the list and select
            ## again. Will break if all species have been attempted and there
            ## were none present in the tree.
            repeat{
              #Randomly select one of the species
              spv2 <- sample(spv, 1)
              # Get the tip location for the sister sp.
              nodeX <- which(ctree$tip.label == spv2) 
              # Break if there is a node value
              if (length(nodeX) != 0) break else{
                spv <- spv[!spv == spv2]
              }
              if (length(spv) == 0) break
              
            }
            
            ## Check if the node still is length zero
            if (length(nodeX) == 0){message(paste0("Node is still zero length for ", 
                                                ex$type[j], " for species ", 
                                                ex$species[j],
                                                " (row ", j, ") after random species selection."))}

          } else if (ex$type[j] == "RGG"){
            
            # Get all the species in the genus
            sp <- ex$sister_genus[j]
            spv <- ctree$tip.label[grep(paste0(sp, "_"), 
                                        ctree$tip.label)]
            
            #Randomly select one of the species
            spv2 <- sample(spv, 1)
            
            # Get the tip location for the sister sp.
            nodeX <- which(ctree$tip.label == spv2) 
          } else if (ex$type[j] == "RGG2"){
            
            sp <- stringr::str_split(ex$sister_genus[j], pattern = ";")
            spv <- vector()
            
            # Get all the species in the genera (incl extinct 
            # already grafted)
            for (x in 1:length(sp[[1]])){
              
              spv <- c(spv, ctree$tip.label[grep(paste0(sp[[1]][x], "_"), 
                                                 ctree$tip.label)])
              
            } 
            
            #Randomly select one of the species
            spv2 <- sample(spv, 1)
            
            # Get the tip location for the sister sp.
            nodeX <- which(ctree$tip.label == spv2) 
          } else if (ex$type[j] == "RFG"){
            
            # Get all species within the family 
            fam <- dplyr::filter(tax, 
                                 BLFamilyLatin == ex$sister_family[j])
            spv <- fam$TipLabel
            #add in extinct sp already grafted in this family
            spv <- check_ext(ex2, level = ex$sister_family[j], 
                             ctree, spv, code = "RFG")

            #Randomly select one of the species
            spv2 <- sample(spv, 1)
            
            # Get the tip location for the sister sp.
            nodeX <- which(ctree$tip.label == spv2) 
           } # else if (ex$type[j] == "RCG"){
          # 
          #   # Get all species within the family
          #   fam <- dplyr::filter(tax, Clade == ex$sister_clade[j])
          #   spv <- vector()
          # 
          #   for (x in 1:nrow(fam)){
          # 
          #     spv <- c(spv, paste0(fam$Genus[x], "_", fam$Species[x]))
          # 
          #   } # Make the species group as a vector
          # 
          #   #Randomly select one of the species
          #   spv2 <- sample(spv, 1)
          # 
          #   # Get the tip location for the sister sp.
          #   nodeX <- which(ctree$tip.label == spv2)
          # } else if (ex$type[j] == "ROG"){
          # 
          #   # Get all species within the family
          #   ord <- dplyr::filter(tax, Order == ex$sister_family[j])
          #   spv <- vector()
          # 
          #   for(x in 1:nrow(fam)){
          # 
          #     spv <- c(spv, paste0(ord$Genus[x], "_", ord$Species[x]))
          # 
          #   } # Make the species group as a vector
          # 
          #   #Randomly select one of the species
          #   spv2 <- sample(spv, 1)
          # 
          #   # Get the tip location for the sister sp.
          #   nodeX <- which(ctree$tip.label == spv2)
          # }
          # 
        } else if (ex$type[j] %in% c("RSGG", "RSGG2")){
          ## Scenario 3.1: Add species as a sister to a genus selected randomly
          ## from a supplied group of genera (RSGG) or a random genus from a
          ## supplied family (RSGG2)
          
          if (ex$type[j] == "RSGG"){
            
            #Split the supplied genera
            sp <- stringr::str_split(ex$sister_genus[j], pattern = ";")
            
            #Randomly select one of the genera
            spv2 <- sample(sp[[1]], 1)
            
            if (length(ctree$tip.label[grep(paste0(spv2, "_"), 
                                           ctree$tip.label)]) == 1){
              
              # Get the tip location for single species in the genus
              nodeX <- which(ctree$tip.label == 
                               ctree$tip.label[grep(paste0(spv2, "_"), 
                                                    ctree$tip.label)]) 
              
            } else {
              # Get most recent common ancestor of genus 
              nodeX <- getMRCA(ctree, ctree$tip.label[grep(paste0(spv2, "_"), 
                                                           ctree$tip.label)]) 
            }
          }
          
          if (ex$type[j] == "RSGG2"){
            
            # Get all genera within the family 
            fam <- dplyr::filter(tax, BLFamilyLatin == ex$sister_family[j])
            spv <- unique(fam$Genus)

            #Randomly select one of the genera
            spv2 <- sample(spv, 1)
            
            if (length(ctree$tip.label[grep(paste0(spv2, "_"), 
                                           ctree$tip.label)]) == 1){
              # Get the tip location for single species in the genus
              nodeX <- which(ctree$tip.label == 
                               ctree$tip.label[grep(paste0(spv2, "_"), 
                                                    ctree$tip.label)]) 
            } else {
              # Get most recent common ancestor of genus 
              nodeX <- getMRCA(ctree,ctree$tip.label[grep(paste0(spv2, "_"), 
                                                          ctree$tip.label)]) 
            }
          } #eo if RSGG2
          
        } else {
          stop("Code / type not recognised")
        }#eo main if statements
        
        # As a final step, Bind the extinct sp. on to tree
        ctree <- AvoBind(tree = ctree, node = nodeX,
                         per = PER_VAL, per_fixed = pfv,
                         sp_name = ex$species[j],
                         time_graft = time_graft,
                         terminal = terminal, mindist = mindist)

      } #eo for j

      # Update the progress bar if using one core
      if(Ntree > 1 & n.cores == 1){
        setTxtProgressBar(pb, i)
      }
      
      #checks at end
      if (length(ctree$edge.length) == 0) stop("No edge lengths in grafted tree")
      if (!neg){
        if (any(ctree$edge.length < 0)) stop("Negative branch lengths present")
      }
      if (ult){
        if (!is.ultrametric(ctree)) stop("Input tree ultrametric, but grafted tree is not")
      }

      #change class of individual trees to include avophylo
      class(ctree) <- c("avophylo", "phylo")
      return(ctree)          # Return the tree object
      
    }#eo for each
  
  ## Finish Tree ## 
  class(ctreesComplete) <- c("multiAvophylo", "multiPhylo")    # Change the class
  
  fun <- utils::getFromNamespace(".foreachGlobals", "foreach")
  rm(list=ls(name=fun), pos=fun)
  
  return(ctreesComplete)
  
}

#Internal function to check which extinct species from
#a given family or order have already been grafted, and
#to select those that have
#' @importFrom dplyr filter
check_ext <- function(ex2, level, ctree, spv, code){
  if (code == "RFG" | code == "SFG"){
    spvE <- dplyr::filter(ex2, 
                          type != "AP",
                          jetz_family == level)
  } else if (code == "SOG"){
    spvE <- dplyr::filter(ex2, 
                          type != "AP",
                          jetz_order == level)
  }
  if (nrow(spvE) > 0){
    if (any(spvE$species %in% ctree$tip.label)){
      wspvE <- which(spvE$species %in% ctree$tip.label)
      spv <- c(spv, spvE$species[wspvE])
    }
  }#eo if 0
  return(spv)
}#eo function
