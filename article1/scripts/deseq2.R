# Analyse différentielle : persisters vs contrôles (Peyrusson et al. 2020)
# Usage : Rscript deseq2.R <counts.txt> <dossier_sortie>

args <- commandArgs(trailingOnly = TRUE)
counts_file <- args[1]
out_dir <- args[2]

suppressMessages(library(DESeq2))

# 1. Lire le tableau de featureCounts
counts <- read.table(counts_file, header = TRUE, sep = "\t",
                     comment.char = "#", check.names = FALSE)
gene_ids <- counts$Geneid
mat <- as.matrix(counts[, grep("\\.bam$", colnames(counts))])
rownames(mat) <- gene_ids
colnames(mat) <- sub(".*/(SRR[0-9]+)\\.bam$", "\\1", colnames(mat))

# 2. Dire quelle colonne est quelle condition
persisters <- c("SRR10379721", "SRR10379722", "SRR10379723")
condition <- ifelse(colnames(mat) %in% persisters, "persister", "control")
coldata <- data.frame(row.names = colnames(mat),
                      condition = factor(condition, levels = c("control", "persister")))

# 3. DESeq2
dds <- DESeqDataSetFromMatrix(countData = mat, colData = coldata, design = ~ condition)
dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "persister", "control"))

# 4. Sauvegarder le tableau de résultats
res_df <- as.data.frame(res)
res_df$Geneid <- rownames(res_df)
res_df$Name <- counts$Name[match(rownames(res_df), gene_ids)]
write.table(res_df, file.path(out_dir, "deseq2_results.tsv"),
            sep = "\t", quote = FALSE, row.names = FALSE)

# 5. MA-plot de tous les gènes (Supp. Fig. 3)
pdf(file.path(out_dir, "MA_plot_all_genes.pdf"))
plotMA(res, alpha = 0.05, main = "Persisters vs controles (tous les genes)")
dev.off()

cat("Genes significatifs (padj < 0.05) :", sum(res$padj < 0.05, na.rm = TRUE), "\n")
