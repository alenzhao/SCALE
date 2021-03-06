library(SCALE)
####################################################
####################################################
##########                                ##########
##########           data input           ##########
##########                                ##########
####################################################
####################################################

data(mouse.blastocyst)
alleleA=mouse.blastocyst$alleleA
alleleB=mouse.blastocyst$alleleB
spikein_input=mouse.blastocyst$spikein_input
genename=rownames(alleleA)
sampname=colnames(alleleA)
head(colnames(alleleA))
head(rownames(alleleA))
rownames(spikein_input)
head(colnames(spikein_input))

####################################################
####################################################
##########                                ##########
##########      gene classification       ##########
##########                                ##########
####################################################
####################################################

# only first 10 genes are computed
# for genome-wide results, parallel computing on HPC is recommended
gene.class.obj=gene_classify(alleleA=alleleA[1:10,],alleleB=alleleB[1:10,])
A.prop=gene.class.obj$A.prop
B.prop=gene.class.obj$B.prop
gene.category=gene.class.obj$gene.category
results.list=gene.class.obj$results.list


data(gene.class.obj)
A.prop=gene.class.obj$A.prop
B.prop=gene.class.obj$B.prop
gene.category=gene.class.obj$gene.category
results.list=gene.class.obj$results.list


####################################################
####################################################
##########                                ##########
##########     technical variability      ##########
##########                                ##########
####################################################
####################################################

abkt=tech_bias(spikein_input=spikein_input, alleleA = alleleA, 
               alleleB = alleleB, pdf=TRUE)


####################################################
####################################################
##########                                ##########
##########   allelic bursting kinetics    ##########
##########                                ##########
####################################################
####################################################

cellsize=rep(1,ncol(alleleA))  # cell size input
allelic.kinetics.obj=allelic_kinetics(alleleA = alleleA[1:1000,], 
                                      alleleB = alleleB[1:1000,], 
                                      abkt = abkt, 
                                      gene.category = gene.category[1:1000], 
                                      cellsize = cellsize, pdf=TRUE)

data(allelic.kinetics.obj)
bandwidth=allelic.kinetics.obj$bandwidth
konA=allelic.kinetics.obj$konA
koffA=allelic.kinetics.obj$koffA
sA=allelic.kinetics.obj$sA
konB=allelic.kinetics.obj$konB
koffB=allelic.kinetics.obj$koffB
sB=allelic.kinetics.obj$sB
sizeA=sA/koffA
sizeB=sB/koffB


####################################################
####################################################
##########                                ##########
########## differential bursting kinetics ##########
##########                                ##########
####################################################
####################################################
diff.allelic.obj=diff_allelic_bursting(alleleA = alleleA,
                                        alleleB = alleleB,
                                        cellsize = cellsize,
                                        gene.category = gene.category,
                                        abkt = abkt,
                                        allelic.kinetics.obj = allelic.kinetics.obj,
                                        mode = 'corrected')
pval.kon = diff.allelic.obj$pval.kon; pval.size = diff.allelic.obj$pval.size

data(diff.allelic.obj)
pval.kon = diff.allelic.obj$pval.kon; pval.size = diff.allelic.obj$pval.size

####################################################
####################################################
##########                                ##########
##########    non-independent bursting    ##########
##########                                ##########
####################################################
####################################################

non.ind.obj=non_ind_bursting(alleleA = alleleA, alleleB = alleleB,
                             gene.category = gene.category,
                             results.list = results.list)
pval.ind=non.ind.obj$pval.ind
non.ind.type=non.ind.obj$non.ind.type


####################################################
####################################################
##########                                ##########
##########            plot genes          ##########
##########                                ##########
####################################################
####################################################

i=which(genename=='Btf3l4')
allelic_plot(alleleA = alleleA, alleleB = alleleB,
             gene.class.obj = gene.class.obj,
             allelic.kinetics.obj = allelic.kinetics.obj,
             diff.allelic.obj = diff.allelic.obj,
             non.ind.obj = non.ind.obj, i= i)

####################################################
####################################################
##########                                ##########
##########     generate output tables     ##########
##########                                ##########
####################################################
####################################################

SCALE.output=output_table(alleleA=alleleA, alleleB=alleleB,
                          gene.class.obj = gene.class.obj,
                          allelic.kinetics.obj = allelic.kinetics.obj,
                          diff.allelic.obj = diff.allelic.obj,
                          non.ind.obj = non.ind.obj)
head(SCALE.output)
write.table(SCALE.output,file='SCALE.output.txt',col.names = T,row.names = F,quote = F,sep='\t')
