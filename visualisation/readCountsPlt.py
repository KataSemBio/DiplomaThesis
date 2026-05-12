#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.ticker as ticker


# Write correct file name
CSV_FILE = "file.csv"

#check delimiter
DELIMITER = ','

print(f"Loading {CSV_FILE}...")

try:
    df = pd.read_csv(CSV_FILE, sep=';')
except FileNotFoundError:
    print(f"Error: file '{CSV_FILE}' not found.")
    exit()

df.columns = df.columns.str.strip()

# Naming columns
col_sample = 'Vzorek'
col_trnl_tot = 'Počet všech čtení trnL'
col_trnl_Kraken_ass = 'Počet přiřazených čtení trnL'
col_rbcl_tot = 'Počet všech čtení rbcL'
col_rbcl_Kraken_ass = 'Počet přiřazených čtení rbcL'

# X axis data prep
x = np.arange(len(df[col_sample]))  # Sample position
width = 0.35  # Column width

from matplotlib.ticker import ScalarFormatter

# --- GRAPH ---
print("Generating graphs...")
fig, (ax1, ax2) = plt.subplots(nrows=2, ncols=1, figsize=(12, 15), sharex=True)

# ----------- 1. trnL
rects1 = ax1.bar(x - width/2, df[col_trnl_tot], width, label='Všechna čtení', color='#ff9896', edgecolor='black', linewidth=0.5)
rects2 = ax1.bar(x + width/2, df[col_trnl_Kraken_ass], width, label='Přiřazená čtení', color='#d62728', edgecolor='black', linewidth=0.5)


# Values
ax1.bar_label(rects1, labels=[f"{int(v):,}".replace(',', ' ') for v in df[col_trnl_tot]], padding=3, fontsize=16, rotation=90)
ax1.bar_label(rects2, labels=[f"{int(v):,}".replace(',', ' ') for v in df[col_trnl_Kraken_ass]], padding=3, fontsize=16, rotation=90)


ax1.set_title(r'A', fontsize=28, )
ax1.set_ylabel('Počet čtení (log)', fontsize=16)
ax1.legend()
ax1.grid(axis='y', linestyle='--', alpha=0.7)

ax1.set_yscale('log')
ax1.yaxis.set_major_formatter(ticker.LogFormatterMathtext())

ax1.set_ylim(top=df[col_trnl_tot].max() * 5)

# ------------ 2. rbcL
rects4 = ax2.bar(x - width/2, df[col_rbcl_tot], width, label='Všechna čtení', color="#80b2f5", edgecolor='black', linewidth=0.5)
rects5 = ax2.bar(x + width/2, df[col_rbcl_Kraken_ass], width, label='Přiřazená čtení', color="#287be9", edgecolor='black', linewidth=0.5)


# Values
ax2.bar_label(rects4, labels=[f"{int(v):,}".replace(',', ' ') for v in df[col_rbcl_tot]], padding=3, fontsize=16, rotation=90)
ax2.bar_label(rects5, labels=[f"{int(v):,}".replace(',', ' ') for v in df[col_rbcl_Kraken_ass]], padding=3, fontsize=16, rotation=90)

ax2.set_title(r'B', fontsize=28, ha='left')
ax2.set_ylabel('Počet čtení (log)', fontsize=16)
ax2.legend()
ax2.grid(axis='y', linestyle='--', alpha=0.7)

ax2.set_yscale('log')
ax2.yaxis.set_major_formatter(ticker.LogFormatterMathtext())
ax2.set_ylim(top=df[col_rbcl_tot].max() * 5)

# Shared axis X
ax2.set_xticks(x)
ax2.set_xticklabels(df[col_sample], rotation=45, ha='right', fontsize=16)
ax2.set_xlabel('Vzorek', fontsize=14)

plt.tight_layout()

output_file = 'kamen_log_hodnoty.svg'
plt.savefig(output_file, dpi=300, bbox_inches='tight')
print(f"Done: '{output_file}'.")
plt.show()