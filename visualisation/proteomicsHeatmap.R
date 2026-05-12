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
my_data <- read.csv('prot_data2.csv', sep=";")
loupec_hodnota <- "Počet unikátních peptidů"    # Např. název sloupce s počty (může být "count", "abundance" atd.)

heatmap_matrix <- my_data %>%
  select("Vzorek", "Protein", "Počet_unikatnich_peptidu") %>%
  # Roztáhne data, chybějící nahradí 0
  pivot_wider(names_from = "Vzorek", 
              values_from = "Počet_unikatnich_peptidu", 
              values_fill = 0,
              values_fn = sum) %>%
  # Názvy proteinů přesune do názvů řádků
  column_to_rownames("Protein") %>%
  # Převede na čistou matici čísel
  as.matrix()

matice_cisel <- heatmap_matrix
matice_cisel = matice_cisel["Počet_unikatnich_peptidu"== 0] <- "" 

# ==========================================
# 4. VYKRESLENÍ HEATMAPY (STYL PODLE OBRÁZKU)
# ==========================================
pheatmap(heatmap_matrix_for_plot,
         # Vypnutí shlukování (graf bude řazen tak, jak jsou data)
         cluster_rows = FALSE,  
         cluster_cols = FALSE,  
         
         # Nastavení čísel uvnitř buněk
         display_numbers = TRUE, 
         number_format = "%.0f", 
         number_color = "black", 
         
         # Barvy přesně podle tvého obrázku: bílá (0) -> bledě žlutá -> sytě červená
         color = colorRampPalette(c("#fff3b0", "#ffba08", "#d00000"))(3),
         na_col = "white",
         border_color = "grey90",
         
         # Estetika textu a rozměry
         fontsize_row = 10,
         fontsize_col = 12,
         angle_col = 270,        # Otočí názvy vzorků svisle dolů
         cellwidth = 40,
         cellheight = 20
)
svglite(filename = "final_prot_heatmap.svg", width = 12, height = 8)

dev.off()

pheatmap(heatmap_matrix)