

graphics.off()
# Session -> Set Working Directory -> correct folder!

library(svglite)
library(tidyverse)
library(ggplot2)
library(patchwork)

# data loading
merge_tsv_files <- function(file_list) {
  file_list %>%
    set_names(basename(.) %>% str_remove("_(trnL|rbcL).*$") %>% str_remove("\\.tsv$")) %>%
    map(function(file) {
      df <- tryCatch(read_tsv(file, col_names = FALSE, show_col_types = FALSE),
                     error = function(e) return(tibble()))
      
      # manages empty files
      if (ncol(df) < 11 || nrow(df) == 0) return(tibble(Taxon = character(), Reads = integer()))
      
      # Filtration (Top hit)
      df_filtered <- df %>%
        rename(QueryID = 1, Evalue = 11, RawName = last_col()) %>%
        mutate(Evalue = as.numeric(Evalue)) %>%
        group_by(QueryID) %>%
        arrange(Evalue) %>%
        slice(1) %>%
        ungroup()
      
      # Taxon extraction, read count
      df_filtered %>% 
        mutate(Taxon = str_extract(RawName, "[A-Z][a-z]+")) %>%
        filter(!is.na(Taxon)) %>% 
        count(Taxon, name = "Reads")
    }) %>%
    bind_rows(.id = "Sample") %>%
    pivot_wider(names_from = Sample, values_from = Reads, values_fill = list(Reads = 0))
}

files_trnL <- list.files(pattern = ".*trnL.*\\.tsv", full.names = TRUE)
files_rbcL <- list.files(pattern = ".*rbcL.*\\.tsv", full.names = TRUE)

otu_table_trnL <- merge_tsv_files(files_trnL)
otu_table_rbcL <- merge_tsv_files(files_rbcL)

prepare_matrix_abs <- function(otu_table) {
  mat <- as.data.frame(otu_table)
  if (ncol(mat) <= 1) return(NULL) 
  rownames(mat) <- mat$Taxon
  mat <- mat[, -1, drop = FALSE]
  
  # Keeps taxa above >= 1%
  norm <- sweep(mat, 2, colSums(mat), FUN = "/") * 100
  norm[is.na(norm)] <- 0
  keep_taxa <- rownames(norm)[apply(norm, 1, max) >= 1]
  
  return(mat[keep_taxa, , drop = FALSE])
}

mat_trnL_filtered <- prepare_matrix_abs(otu_table_trnL)
mat_rbcL_filtered <- prepare_matrix_abs(otu_table_rbcL)


#-------------------colors--------------------------
all_taxa <- unique(c(rownames(mat_trnL_filtered), rownames(mat_rbcL_filtered)))
pocet_taxonu <- length(all_taxa)

base_colors <- c(
  "#e6194b", "#3cb44b", "#ffe119", "#4363d8", "#f58231", 
  "#911eb4", "#46f0f0", "#f032e6", "#bcf60c", "#fabebe", 
  "#008080", "#e6beff", "#9a6324", "#fffac8", "#800000", 
  "#aaffc3", "#808000", "#ffd8b1", "#000075", "#808080"
)

myPalette_huge <- colorRampPalette(base_colors)(pocet_taxonu)
myPalette_huge_named <- setNames(myPalette_huge, all_taxa)


# ---------------absolute + relative abundance graphs-------------------------
plot_dual_barplot <- function(norm_mat, primer_name, filename) {
  if (is.null(norm_mat) || nrow(norm_mat) == 0) return(NULL)
  
  df <- as.data.frame(norm_mat)
  df$Taxon <- rownames(df)
  
  data_long <- pivot_longer(df, cols = -Taxon, names_to = "Sample", values_to = "Abundance") %>%
    filter(Abundance > 0)
  
  # UPPER GRAPH: Absolute a.
  p_abs <- ggplot(data_long, aes(x = Sample, y = Abundance, fill = Taxon)) +
    geom_bar(position = "stack", stat = "identity") +
    scale_fill_manual(name = "Taxon", values = myPalette_huge_named, limits = all_taxa, drop = FALSE) +
    theme_minimal() +
    labs(x = "Vzorek", y = "Absolutní počet čtení", title = paste(primer_name, "- Absolutní")) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 15))
  
  # LOWER GRAPH: Relative a. (to 100 %)
  p_rel <- ggplot(data_long, aes(x = Sample, y = Abundance, fill = Taxon)) +
    geom_bar(position = "fill", stat = "identity") +
    scale_fill_manual(name = "Taxon", values = myPalette_huge_named, limits = all_taxa, drop = FALSE) +
    theme_minimal() +
    scale_y_continuous(labels = scales::percent) + 
    labs(x = "Vzorek", y = "Relativní počet čtení", title = paste(primer_name, "Relativní - (100%)")) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 15))
  
  # layout
  combined_plot <- (p_abs / p_rel) + 
    plot_layout(guides = "collect", heights = c(3, 1)) & 
    theme(legend.position = "bottom",
          legend.text = element_text(size = 10),
          legend.key.size = unit(0.4, "cm")) &
    guides(fill = guide_legend(
      ncol = 10, 
      title.position = "top", 
      override.aes = list(color = "gray30", linewidth = 0.2)
    ))
  
  print(combined_plot)
  
  # SAVE
  ggsave(filename, plot = combined_plot, width = 16, height = 22.6, bg = "white")
  message("Done:", filename)
}

# RUN
plot_dual_barplot(mat_trnL_filtered, "trnL", "dual_barplot_trnL.svg")
plot_dual_barplot(mat_rbcL_filtered, "rbcL", "dual_barplot_rbcL.svg")


  
  # -----------------export taxa----------------------------------------
  
  export_taxa_per_sample <- function(mat, marker_name) {
    
    if (is.null(mat) || ncol(mat) == 0) {
      message(paste("No data:", marker_name))
      return(invisible(NULL))
    }
    
    # Output folder
    export_dir <- paste0("export_tables_", marker_name)
    dir.create(export_dir, showWarnings = FALSE)
    
    # Matrix filtering
    df_long <- as.data.frame(mat) %>%
      rownames_to_column(var = "Taxon") %>%
      pivot_longer(cols = -Taxon, names_to = "Sample", values_to = "Reads") %>%
      filter(Reads > 0) 
    
    # Sample splitting
    list_of_samples <- split(df_long, df_long$Sample)
    
    # Sample iteration
    iwalk(list_of_samples, function(sample_data, sample_name) {
      
      out_data <- sample_data %>% 
        select(Taxon, Reads) %>%
        mutate(Percentage = round((Reads / sum(Reads)) * 100, 2)) %>%
        arrange(desc(Reads))
      
      file_path <- file.path(export_dir, paste0(sample_name, "_", marker_name, ".tsv"))
      
    })
    
    message(paste("Done:", marker_name,))
  }
  
  # Runs export
   export_taxa_per_sample(mat_trnL_filtered, "trnL")
   export_taxa_per_sample(mat_rbcL_filtered, "rbcL")
}