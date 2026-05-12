
import matplotlib.pyplot as plt
from matplotlib_venn import venn2

plt.figure(figsize=(20,10))


seda_TU823={'Convolvulus', 'Crepidiastrum', 'Chrysanthemum', 'Helianthus', 'Citrus','Eutrema','Ixeris', 'Ipomoea', 'Aldama', 'Calamagrostis', 'Agrostis', 'Sanicula','Cannabis','Draba', 'Salvia', 'Sisymbrium','Heliconia','Carum','Lactuca','Beta'},
cal_TU823={'Beta','Convolvulus','Prunus'},

seda_ZH604={'Prunus', 'Urticaceae', 'Hansenia oviformis', 'Convolvuleae', 'Sisymbrium', 'Eutrema botschantzevii', 'Alliaria petiolata'}
cal_ZH604={'Fabeae','Trifolieae'}

seda_ZH628={'Hansenia oviformis', 'Convolvuleae', 'Epilobium', 'Prunus', 'Filipendula', 'Eutrema botschantzevii'}
cal_ZH628={'Cicer','Trifolium'}

# Creates Venn diagram
v = venn2([seda_TU823, cal_TU823], set_labels=('Sediment', 'Zubní kámen'), set_colors=('slategray', 'peru', 'burlywood'), 
          alpha=0.7)


# Adds the legend to the plot
plt.legend(handles=[seda_TU823, cal_TU823], loc='upper left', ncols=3, handlelength=1.0, handleheight=5.0, draggable=True, columnspacing= 1.0)

plt.show()