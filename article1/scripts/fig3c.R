# Fig. 3c : MA-plot des gènes de la traduction (KEGG : ribosome + aminoacyl-tRNA)
# Usage : Rscript fig3c.R <deseq2_results.tsv> <kegg_links.tsv> <kegg_genes.tsv> <figure.pdf> <table.tsv>

args <- commandArgs(trailingOnly = TRUE)
suppressMessages(library(ggplot2))

# 1. Résultats DESeq2 (tous les gènes)
res <- read.delim(args[1])

# 2. Liste des gènes de la traduction selon KEGG ("sao:SAOUHSC_xxxxx" -> "gene-SAOUHSC_xxxxx")
links <- read.delim(args[2], header = FALSE, quote = "")
translation_ids <- unique(sub("^sao:", "gene-", links$V2))

# 3. Noms courts des gènes (ex. "rplI"), pris dans la liste KEGG
genes <- read.delim(args[3], header = FALSE, quote = "")
genes$Geneid <- sub("^sao:", "gene-", genes$V1)
desc <- genes[[ncol(genes)]]
genes$symbol <- ifelse(grepl(";", desc), sub(";.*", "", desc), sub("^gene-", "", genes$Geneid))

# 4. Garder seulement les gènes de la traduction
tr <- res[res$Geneid %in% translation_ids, ]
tr$symbol <- genes$symbol[match(tr$Geneid, genes$Geneid)]
tr$significatif <- !is.na(tr$padj) & tr$padj < 0.05
write.table(tr, args[5], sep = "\t", quote = FALSE, row.names = FALSE)

# 5. Le MA-plot
p <- ggplot(tr, aes(x = log2(baseMean), y = log2FoldChange, colour = significatif)) +
  geom_hline(yintercept = 0, colour = "grey40") +
  geom_point() +
  geom_text(aes(label = symbol), size = 2.5, vjust = -0.7,
            check_overlap = TRUE, show.legend = FALSE) +
  scale_colour_manual(values = c("FALSE" = "grey60", "TRUE" = "red"),
                      labels = c("padj >= 0.05", "padj < 0.05")) +
  labs(title = "Genes de la traduction : persisters vs controles",
       x = "log2(expression moyenne)", y = "log2 fold change", colour = "") +
  theme_bw()
ggsave(args[4], p, width = 8, height = 6)

cat("Genes de la traduction trouves :", nrow(tr),
    "| significatifs :", sum(tr$significatif), "\n")
