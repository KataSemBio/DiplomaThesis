# ==========================================
# 1. NAČTENÍ KNIHOVEN
# ==========================================
# Pokud ti nějaká chybí, nainstaluj ji přes install.packages("nazev")
graphics.off() 

library(svglite)
library(dplyr)
library(tidyr)
library(readr)
library(purrr)
library(pheatmap)
library(tibble)

# ==========================================
# 2. HROMADNÝ IMPORT .TSV SOUBORŮ
# ==========================================
# Nastav název složky, kde máš soubory uložené (musí být v tvém pracovním adresáři)
slozka <- "export_tables_rbcL"

# Najde všechny soubory končící na .tsv
soubory <- list.files(path = slozka, pattern = "\\.tsv$", full.names = TRUE)

# Načte všechny soubory a spojí je do jedné dlouhé tabulky.
# Nový sloupec "Vzorek" se pojmenuje podle názvu souboru (bez přípony .tsv)
data_vsechna <- soubory %>%
  set_names(basename(.) %>% tools::file_path_sans_ext()) %>%
  map_dfr(~ read_tsv(.x, show_col_types = FALSE), .id = "Vzorek")

# ==========================================
# 3. PŘÍPRAVA MATICE (DŮLEŽITÉ KONTROLY)
# ==========================================
# POZOR: Zde musíš zapsat PŘESNÉ názvy sloupců tak, jak je máš uvnitř těch .tsv souborů!
# Pokud se jmenují jinak, přepiš text v uvozovkách.
sloupec_taxon <- "Taxon"      # Např. název sloupce s rostlinami (může být "name", "species" atd.)
sloupec_hodnota <- "Reads"    # Např. název sloupce s počty (může být "count", "abundance" atd.)

heatmap_matrix <- data_vsechna %>%
  # Vybereme jen sloupce, které nás zajímají
  select(Vzorek, all_of(sloupec_taxon), all_of(sloupec_hodnota)) %>%
  
  # Převod na širokou tabulku (vzorky jako sloupce)
  pivot_wider(names_from = Vzorek, 
              values_from = all_of(sloupec_hodnota), 
              values_fill = 0,       # Chybějící rostliny doplní jako 0
              values_fn = sum) %>%   # Pojistka: pokud je rostlina ve vzorku 2x, sečte ji
  
  # Převod na matici
  column_to_rownames(sloupec_taxon) %>%
  as.matrix()
heatmap_matrix_for_plot <- heatmap_matrix
heatmap_matrix_for_plot[heatmap_matrix_for_plot == 0] <- NA

matice_cisel <- heatmap_matrix
matice_cisel[matice_cisel == 0] <- ""  # Tímto se matice automaticky převede na text

# ==========================================
# 4. VYKRESLENÍ HEATMAPY (STYL PODLE OBRÁZKU)
# ==========================================
svglite(filename = "final_heatmap_rbcL.svg", width = 12, height = 10)
pheatmap(heatmap_matrix_for_plot,
         # Vypnutí shlukování (graf bude řazen tak, jak jsou data)
         cluster_rows = FALSE,  
         cluster_cols = FALSE,  
         
         # Nastavení čísel uvnitř buněk
         display_numbers = matice_cisel, 
         number_format = "%.0f", 
         number_color = "black", 
         
         # Barvy přesně podle tvého obrázku: bílá (0) -> bledě žlutá -> sytě červená
         color = colorRampPalette(c("#fff3b0", "#ffba08", "#d00000"))(100),
         na_col = "white",
         border_color = "grey90",
         
         # Estetika textu a rozměry
         fontsize_row = 10,
         fontsize_col = 12,
         angle_col = 45,        # Otočí názvy vzorků svisle dolů
         cellwidth = 40,
         cellheight = 20
)

dev.off()

#plot_heat(heatmap_matrix_for_plot, "Heatmap trnL - Max normalized", "final_heatmap_rbcL.svg")