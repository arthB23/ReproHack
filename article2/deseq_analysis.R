library(tximport)
library(DESeq2)
library(dplyr)
library(tibble)
library(ggplot2)
library(ggVennDiagram)

samples <- read.csv("sample.csv", stringsAsFactors = FALSE)
files <- file.path("quant", samples$sample, "quant.sf")
names(files) <- samples$sample
stopifnot(all(file.exists(files)))

samples$group <- factor(paste(samples$day, samples$condition, sep = "_"))
rownames(samples) <- samples$sample

tx2gene <- read.csv("Index/tx2gene.csv", stringsAsFactors = FALSE)
txi <- tximport(files,
                type = "salmon", 
                tx2gene = tx2gene,
                ignoreTxVersion = TRUE,
                dropInfReps=TRUE)

dds <- DESeqDataSetFromTximport(txi, colData = samples, design = ~ group)
dds <- dds[rowSums(counts(dds)) >= 10, ]
dds <- DESeq(dds)

res_day11 <- results(dds, contrast = c("group", "day11_infected", "day11_control")) %>%
  as.data.frame() %>%
  rownames_to_column("gene_id") %>%
  arrange(padj)

res_day33 <- results(dds, contrast = c("group", "day33_infected", "day33_control")) %>%
  as.data.frame() %>%
  rownames_to_column("gene_id") %>%
  arrange(padj)

dir.create("results", showWarnings = FALSE)
write.csv(res_day11,
          "results/DESeq2_day11_infected_vs_control.csv", 
          row.names = FALSE)
write.csv(res_day33, 
          "results/DESeq2_day33_infected_vs_control.csv",
          row.names = FALSE)

up_day11 <- res_day11 %>%
  filter(!is.na(padj), padj < 0.05, log2FoldChange > 1) %>%
  pull(gene_id)

down_day11 <- res_day11 %>%
  filter(!is.na(padj), padj < 0.05, log2FoldChange < -1) %>%
  pull(gene_id)

up_day33 <- res_day33 %>%
  filter(!is.na(padj), padj < 0.05, log2FoldChange > 1) %>%
  pull(gene_id)

down_day33 <- res_day33 %>%
  filter(!is.na(padj), padj < 0.05, log2FoldChange < -1) %>%
  pull(gene_id)

cat(sprintf("Day 11 -> Up: %d | Down: %d\n", length(up_day11), length(down_day11)))
cat(sprintf("Day 33 -> Up: %d | Down: %d\n", length(up_day33), length(down_day33)))

venn_list <- list(
  "Acute Up" = up_day11,
  "Acute Down" = down_day11,
  "Chronic Up" = up_day33,
  "Chronic Down" = down_day33
)

p <- ggVennDiagram(venn_list, label_alpha = 0, set_size = 3.8) +
  scale_fill_gradient(low = "grey90", high = "red") +
  scale_x_continuous(expand = expansion(mult = 0.2)) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA)
  )

ggsave("results/venn_acute_vs_chronic.pdf", plot = p, width = 8, height = 6)
ggsave("results/venn_acute_vs_chronic.png", plot = p, width = 8, height = 6, dpi = 300)

