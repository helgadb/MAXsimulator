#!/bin/bash

function gera_plot_perdas_rssiXoffset_geral {
	data="$1"
	dir="$2"
	if [ ! -d ./graficos/perdas-$datas ]; then mkdir -p ./graficos/perdas-$datas; fi
	filename=$dir"/"$data"_stats_perdas_por_offset_.dat.gz"
	pdfname="./graficos/perdas-"$datas"/"$data"_perdas_rssiXoffset_geral.pdf"
	fileoutname="./graficos/perdas-"$datas"/"$data"_perdas_rssiXoffset_geral.txt"

	echo "filename="\"$filename\"" >> correlacao_perdasXrssi.r
	echo "pdfname="\"$pdfname\"" >> correlacao_perdasXrssi.r
	echo "sink(\""$fileoutname"\", append=FALSE, split=TRUE)"
cat << ! >> correlacao_perdasXrssi.r
# lendo arquivo em formato de matrix
library(readr)
library("Hmisc", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.4")

# apenas colunas rssi e perdas
m <- as.matrix(read_delim(filename, "\t", escape_double = FALSE, col_names = FALSE, col_types = cols(X1 = col_skip(), X10 = col_skip(), X2 = col_skip(), X3 = col_skip(), X4 = col_skip(), X5 = col_skip(), X6 = col_skip(), X7 = col_skip(), X9 = col_skip()), comment = "#",     trim_ws = TRUE))

rcorr(m,type=c("pearson"))

rcorr(C,type=c("spearman"))

#plot
pdf(pdfname,width=18,height=7)
plot(x <- m[,"X8"], y <- m[,"X11"] )
scat1d(x, tfrac=0)        # dots randomly spaced from axis
scat1d(y, 4, frac=-.03)   # bars outside axis
scat1d(y, 2, tfrac=.2)    # same bars with smaller random fraction
annotate(x=1.5, y=1.5, 
         label=paste("R = ", round(rcorr(m,type=c("pearson")),2)), 
         geom="text", size=5)

#plot(x <- m[,"X8"], y <- m[,"X11"] )
#scat1d(x)                 # density bars on top of graph
#scat1d(y, 4)              # density bars at right
#histSpike(x, add=TRUE)       # histogram instead, 100 bins
#histSpike(y, 4, add=TRUE)
#histSpike(x, type='density', add=TRUE)  # smooth density at bottom
#histSpike(y, 4, type='density', add=TRUE)
dev.off()
!
}
