args <- commandArgs(trailingOnly = TRUE)
suppressMessages(library(DESeq2))
suppressMessages(library(ggplot2))

counts <- read.table(args[1], header = TRUE, sep = "\t", comment.char = "#", check.names = FALSE)
mat <- as.matrix(counts[, grep("\\.bam$", colnames(counts))])
rownames(mat) <- counts$Geneid
colnames(mat) <- sub(".*/(SRR[0-9]+)\\.bam$", "\\1", colnames(mat))

persisters <- c("SRR10379721", "SRR10379722", "SRR10379723")
coldata <- data.frame(row.names = colnames(mat),
  condition = factor(ifelse(colnames(mat) %in% persisters, "persister", "control")))

dds <- DESeqDataSetFromMatrix(countData = mat, colData = coldata, design = ~ condition)
vsd <- vst(dds, blind = TRUE)

pca <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
var <- round(100 * attr(pca, "percentVar"))

p <- ggplot(pca, aes(PC1, PC2, colour = condition)) +
  geom_point(size = 4) +
  geom_text(aes(label = name), vjust = -1, size = 3, show.legend = FALSE) +
  labs(x = paste0("PC1 (", var[1], " %)"), y = paste0("PC2 (", var[2], " %)"),
       title = "ACP des 6 echantillons") +
  theme_bw()
ggsave(args[2], p, width = 7, height = 5)
