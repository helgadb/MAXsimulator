#!/bin/bash

# Este script le o dats do goto e gera em dats/stats-GOTO, para cada mac-interface que apresentar mais do que X beacons, estatisticas ponto	min	q1	median	q3	max	width	sum	sumsq	nsamples	ifs	ifi	ofs	ofi	mean	stddev	mac em diferentes pontos de medição.

# A partir das estatisticas geradas, são verificadas rajadas de outliers utilizando-se o processo indicado em https://pt.wikihow.com/Calcular-Outliers / http://www.itl.nist.gov/div898/handbook/prc/section1/prc16.htm
# 1) calcular mediana
# 2) calcular Q1
# 3) calcular Q3
# 4) encontrar as barreiras internas (inner fences), ou seja:
# ifs = Q3 + (Q3 - Q1)*1,5 
# ifi = Q1 - (Q3 - Q1)*1,5
# Amostras com valores fora deste intervalo são outliers moderados (mild outlier)
# 5) econtrar as barreiras externas (outer fences), ou seja:
# ofs = Q3 + (Q3 - Q1)*3 
# ofi = Q1 - (Q3 - Q1)*3
# Amostras com valores fora deste intervalo são outliers extremos (extreme outlier)
# (Obs: Q3 - Q1 = interquartile range)

# Além disso o script indica quais MACs apresentaram ao menos 1 outliers e ao menos 1 outlier max ou min.


function stats_GOTO_quartis {

# arquivo com lista de macs com outliers
outputliers="dats/GOTO_resumo_outliers/resumo_macs_x_outliers.txt"
# limiar de amostras que a captura deve conter para ser considerada nas estatisticas
limiar_samples="0"

# script que le a saida do stats, show variables do gnuplot e gera um arquivo com dados estatisticos
if [ ! -d "dats/GOTO_quartis/" ]; then mkdir -p dats/GOTO_quartis/; else rm -rf dats/GOTO_quartis/;mkdir -p dats/GOTO_quartis/; fi
if [ ! -d "dats/GOTO_resumo_outliers/" ]; then mkdir -p dats/GOTO_resumo_outliers/; else rm dats/GOTO_resumo_outliers/*; fi
echo "#interf	mac-------------	ponto	mild	extreme	mildmax	extrmax	mildmin	extrmin median	mnfix10	mnfix15	mnfix20	mxfix10	maxfix15	mxfix20" > $outputliers

for file in $( find /home/helgadb/gdrive/Doutorado/ping-pong/meta1A/testes-GOTO/*/dats/* -type f -name '*.dat' | sort -t"/" -k11,11 -g )
do
	macsp=$(echo $file | awk -F"/" '{split($12,a,".");print a[1]}')	
	ponto=$(echo $file | awk -F"/" '{split($11,a,"G");print a[1]}')
	interface=$(echo $file | awk -F"/" '{split($11,a,"GOTO");print a[2]}')
	outfile="dats/GOTO_quartis/"$macsp"_"$interface"_stats.dat"

	gnuplot -e "reset; set datafile separator ';'; stats '$file' using 3 nooutput  ; show variables" 2>&1  | sed 's/ //g' | sed 's/\t//g' | awk -v interface="$interface" -v limiar_samples="$limiar_samples" -v outputliers="$outputliers" -v output="$outfile" -v mac="$macsp" -v ponto="$ponto" -F"=" 'BEGIN{min=-1;q1=-1;median=-1;q3=-1;max=-1;mean=-1;stddev=-1;sum=-1;sumsq=-1;nsamples=-1;}{
	if ($1 == "STATS_min") min=$2
	else if ($1 == "STATS_lo_quartile") q1=$2
	else if ($1 == "STATS_median") median=$2
	else if ($1 == "STATS_up_quartile") q3=$2
	else if ($1 == "STATS_max") max=$2
	else if ($1 == "STATS_mean") mean=$2
	else if ($1 == "STATS_stddev") stddev=$2
	else if ($1 == "STATS_sum") sum=$2
	else if ($1 == "STATS_sumsq") sumsq=$2
	else if ($1 == "STATS_records") nsamples=$2
	}
	END{
		if ( nsamples >= limiar_samples && max <=0 && min <= 0) {	
			system("if [ ! -f "output" ]\073 then echo \042\043ponto	min	q1-	median	q3-	max-	width	sum-----	sumsq----	nspl	ifs-	ifi-	ofs-	ofi-	mean------------	stddev----------	mac--------\042 \076 "output"\073 fi")
			width=q3-q1
			ifs=q3+(width*1.5)
			ifi=q1-(width*1.5)
			ofs=q3+(width*3)
			ofi=q1-(width*3)
			print ponto"	"min"	"q1"	"median"	"q3"	"max"	"width"	"sum"	"sumsq"	"nsamples"	"ifs"	"ifi"	"ofs"	"ofi"	"mean"	"stddev"	"mac >> output
			#printf ("%d\t%d\t%.2f\t%.2f\t%.2f\t%d\t%.2f\t%d\t%.2f\t%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%s\n",ponto,min,q1,median,q3,max,width,sum,sumsq,nsamples,ifs,ifi,ofs,ofi,mean,stddev,mac) >> output
			# verificar se houve ao menos 1 outlier extremo ou leve, maximo ou minimo
			if ( max > ifs || min < ifi  )  bfound_mild=1
				else bfound_mild=0
			if ( max > ofs || min < ofi  ) bfound_extreme=1
				else bfound_extreme=0
			if ( max > ifs ) bfound_mild_max=1
				else bfound_mild_max=0
			if ( max > ofs ) bfound_extreme_max=1
				else bfound_extreme_max=0
			if ( min < ifi ) bfound_mild_min=1
				else bfound_mild_min=0
			if ( min < ofi ) bfound_extreme_min=1
				else bfound_extreme_min=0
			if ( min < median-10 ) bfound_minfix10=1
				else bfound_minfix10=0
			if ( min < median-15 ) bfound_minfix15=1
				else bfound_minfix15=0
			if ( min < median-20 ) bfound_minfix20=1
				else bfound_minfix20=0
			if ( min > median+10 ) bfound_maxfix10=1
				else bfound_maxfix10=0
			if ( min > median+15 ) bfound_maxfix15=1
				else bfound_maxfix15=0
			if ( min > median+20 ) bfound_maxfix20=1
				else bfound_maxfix20=0
			
			print interface"\t"mac"\t"ponto"\t"bfound_mild"\t"bfound_extreme"\t"bfound_mild_max"\t"bfound_extreme_max"\t"bfound_mild_min"\t"bfound_extreme_min"\t"median"\t"bfound_minfix10"\t"bfound_minfix15"\t"bfound_minfix20"\t"bfound_maxfix10"\t"bfound_maxfix15"\t"bfound_maxfix20 >> outputliers
			
		}
	}'

done
}

function stats_GOTO_rajadas {
# INICIO do registro das rajadas

limiar_width_inf=0
limiar_nsamples_inf=400
scan_interval="0.1024" # intervalo entre scans em segundos
MaxChannelTime="0.1024" # scan passivo em segundos, default é o intervalo entre beacons
offsetOn="0" # 1 = ligado; 0 = desligado -> insere ou nao offset no primeiro tscan para que a primeira amostra esteja em posição intermediaria no intervalo de scan.
# definindo offset
if [ $offsetOn -eq 1 ]
then
	offset=$(awk -v janela="$MaxChannelTime" 'BEGIN{srand(); randon=janela * rand();print randon}') # valor entre 0 <= x < janela que define o offset
else
	offset=0
fi
if [ $(ls -w1 dats/GOTO_rajadas_mac_*/* 2> /dev/null | wc -l) -gt 0 ]; then rm dats/GOTO_rajadas_mac_*/*;fi
if [ $(ls -w1 dats/GOTO_rajadas_rssi_*/* 2> /dev/null | wc -l) -gt 0 ]; then rm dats/GOTO_rajadas_rssi_*/*;fi

for file in $( find /home/helgadb/gdrive/Doutorado/ping-pong/meta1A/testes-GOTO/*/dats/* -type f -name '*.dat' | sort -t"/" -k11,11 -g )
do

	macsp=$(echo $file | awk -F"/" '{split($12,a,".");print a[1]}')	
	ponto=$(echo $file | awk -F"/" '{split($11,a,"G");print a[1]}')
	interface=$(echo $file | awk -F"/" '{split($11,a,"GOTO");print a[2]}')
	outfile="dats/GOTO_quartis/"$macsp"_"$interface"_stats.dat"
	# se o arquivo para o mac existe
	if [ -f $outfile ]
	then
		median=$(cat $outfile | grep "^$ponto\>" | awk '{print $4}')
		width=$(cat $outfile | grep "^$ponto\>" | awk '{print $7}')
		ifs=$(cat $outfile | grep "^$ponto\>" | awk '{print $11}')
		ifi=$(cat $outfile | grep "^$ponto\>" | awk '{print $12}')
		ofs=$(cat $outfile | grep "^$ponto\>" | awk '{print $13}')
		ofi=$(cat $outfile | grep "^$ponto\>" | awk '{print $14}')
		nsamples=$(cat $outfile | grep "^$ponto\>" | awk '{print $10}')	
		# se o mac existe no ponto de teste
		if [ $(cat $outfile | grep -c "^$ponto\>") -eq 1 ]
		then 
			cat $file | awk -F";" -v nsamples="$nsamples" -v limiar_nsamples_inf="$limiar_nsamples_inf" -v limiar_width_inf="$limiar_width_inf" -v file="$file" -v interface="$interface" -v ponto="$ponto" -v macsp="$macsp" -v median="$median" -v width="$width" -v ifs="$ifs" -v ifi="$ifi" -v ofs="$ofs" -v ofi="$ofi" -v offset="$offset" -v offsetOn="$offsetOn" -v janela="$MaxChannelTime" -v scan_int="$scan_interval" 'BEGIN{c=0;f=0; delete rssi_array}
			# le os valores de RSSI do APs a cada scan definido pelos intervalos. c é o índice do scan
			{
				if ( width >= limiar_width_inf && nsamples >= limiar_nsamples_inf) {
					# primeira linha
					if ( NR == 1 ) {
						if (offsetOn == 1) {
							tscan=$2-offset	
							#print offset
						}
						else if (offsetOn == 0) {
							tscan=$2
							#print offset
						}
					}
					# se registro está dentro da janela de scan e do intervalo entre scans ...
					if ( $2 < (tscan + janela) && $2 >= tscan && $2 < (tscan + scan_int) ) {
						rssi_array[c]=$3		
					}
					# se eu saí da janela de scan, inicio um novo scan. c é o índice do scan.		
					else if ($2 >= (tscan + scan_int)) {				
						while ( $2 >= (tscan + scan_int) ) {
							tscan=tscan+scan_int
							c=c+1
						}
						if ( $2 < (tscan + janela) && $2 < (tscan + scan_int) ) {
							rssi_array[c]=$3		
						}
					}
				}
			}

			function define_outputfile(string,median) {
				comando="if [ ! -d \"dats/GOTO_rajadas_mac_"string"/\" ]; then mkdir -p dats/GOTO_rajadas_mac_"string"/;fi"
				system(comando)
				comando="if [ ! -d \"dats/GOTO_rajadas_rssi_"string"/\" ]; then mkdir -p dats/GOTO_rajadas_rssi_"string"/; fi"
				system(comando)

				rajcount=0

				if (string == "outliers_mild_min") {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_mild_min.dat"
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_mild_min.dat"
					teste="ifi"
				}
				else if ( string == "outliers_mild_max" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_mild_max.dat"
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_mild_max.dat"	
					teste="ifs"
				}
				else if ( string == "outliers_extr_min" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_extr_min.dat"
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_extr_min.dat"	
					teste="ofi"
				}
				else if ( string == "outliers_extr_max" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_extr_max.dat"
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_extr_max.dat"	
					teste="ifs"
				}
				else if ( string == "outliers_mild" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_mild.dat"	
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_mild.dat"	
					teste1="ifi"
					teste2="ifs"
				}
				else if ( string == "outliers_extr" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_extr.dat"	
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_extr.dat"	
					teste1="ofi"
					teste2="ofs"
				}
				else if ( string == "outliers_minfixed_10" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_minfixed_10.dat"
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_minfixed_10.dat"	
					teste="min10"
				}
				else if ( string == "outliers_minfixed_15" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_minfixed_15.dat"
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_minfixed_15.dat"	
					teste="min15"
				}
				else if ( string == "outliers_minfixed_20" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_outliers_minfixed_20.dat"
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_outliers_minfixed_20.dat"	
					teste="min20"
				}
				else if ( string == "perdas" ) {
					outputfile="dats/GOTO_rajadas_mac_"string"/"macsp"_"interface"_array_rajadas_perdas.dat"	
					outputfile2="dats/GOTO_rajadas_rssi_"string"/"int(median*(-1))"_"interface"_array_rajadas_perdas.dat"
					teste=""
				}	
	
			}
			END {
				# observar as amostras para o mac e verificar perdas e outliers com base nas estatisticas
				rajcount=0
				outputfile=""
				outputfile2=""
				teste=""
				if ( width >= limiar_width_inf ) {
			
					# MILD_MIN
					define_outputfile("outliers_mild_min",median)
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] < ifi) {	
								rajcount=rajcount+1
								#print "OUTLIER: Rssi:"rssi_array[i]" Rajada: "rajcount " Median: "median" ifi: "ifi" w:" width 
							}
							else {
								#print "NADA: Rssi:" rssi_array[i]" Rajada: "rajcount" Median: "median" ifi: "ifi" w:" width
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"ifi"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"ifi"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# MILD_MAX
					define_outputfile("outliers_mild_max",median)
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] > ifs) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"ifs"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"ifs"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# EXTR_MIN
					define_outputfile("outliers_extr_min",median)
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] < ofi) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"ofi"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"ofi"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# EXTR_MAX
					define_outputfile("outliers_extr_max",median)
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] > ofs) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"ofs"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"ofs"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# MILD
					define_outputfile("outliers_mild",median)
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] < ifi || rssi_array[i] > ifs ) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste1"	"teste2"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste1"	"teste2"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"ifi"\t"ifs"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"ifi"\t"ifs"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# EXTR
					define_outputfile("outliers_extr",median)
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] < ofi || rssi_array[i] > ofs ) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste1"	"teste2"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste1"	"teste2"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"ofi"\t"ofs"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"ofi"\t"ofs"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# MINFIXED_10
					define_outputfile("outliers_minfixed_10",median)
					fixed=median-10
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] < fixed) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"fixed"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"fixed"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# MINFIXED_15
					define_outputfile("outliers_minfixed_15",median)
					fixed=median-15
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] < fixed) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"fixed"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"fixed"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}

					# MINFIXED_20
					define_outputfile("outliers_minfixed_20",median)
					fixed=median-20
					for (i=0; i<length(rssi_array); i++) {	
						if (rssi_array[i] != ""){	
							if ( rssi_array[i] < fixed) {	
								rajcount=rajcount+1
							}
							else {
								if (rajcount != 0) {
									comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile"\073 fi"
									system(comando)
									comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	"teste"	width\042 \076 "outputfile2"\073 fi"
									system(comando)
									print ponto"\t"i-1"\t"rajcount"\t"median"\t"fixed"\t"width >> outputfile
									print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"fixed"\t"width >> outputfile2
									rajcount=0			
								}
							}
						}
		
					}


					# PERDAS
					define_outputfile("perdas",median)
					for (i=0; i<length(rssi_array); i++) {	
						if ( rssi_array[i] == "") {	
							rajcount=rajcount+1
						}
						else {
							if (rajcount != 0) {
								comando="if [ ! -f "outputfile" ]\073 then echo \042\043ponto	nscan	nrajada	median	width\042 \076 "outputfile"\073 fi"
								system(comando)
								comando="if [ ! -f "outputfile2" ]\073 then echo \042\043macsp----------	ponto	nscan	nrajada	median	width\042 \076 "outputfile2"\073 fi"
								system(comando)
								print ponto"\t"i-1"\t"rajcount"\t"median"\t"width >> outputfile
								print macsp"\t"ponto"\t"i-1"\t"rajcount"\t"median"\t"width >> outputfile2
								rajcount=0			
							}
						}
					}
				}
				delete rssi_array
			}		
			'
		fi
	fi
done
}



function calcular_percent_raj1 {
	# calcula a porcentagem de rajadas == 1 para cada mac e para cada RSSI, para cada teste
	for teste in "${testes[@]}"
	do
		if [ ! -d dats/GOTO_percent_raj1_mac/ ]; then mkdir -p dats/GOTO_percent_raj1_mac/; else rm dats/GOTO_percent_raj1_mac/*; fi
		if [ ! -d dats/GOTO_percent_raj1_rssi/ ]; then mkdir -p dats/GOTO_percent_raj1_rssi/; else rm dats/GOTO_percent_raj1_rssi/*; fi
		
		for file in $(find "dats/GOTO_rajadas_mac_"$teste"/" -type f -name '*.dat')
		do
			macsp="$(echo $file | awk -F"/" '{split($3,a,"_");print a[1]}')"
			interface="$(echo $file | awk -F"/" '{split($3,a,"_");print a[2]}')"
			percent_raj1=$(tail -n +2 $file | awk ' BEGIN{total=0;raj1=0}{if($3=="1") raj1=raj1+1; total=total+1}END{printf ("%.2f",100*(raj1/total))}')
			fileout="dats/GOTO_percent_raj1_mac/"$interface"_"$teste".dat"
			echo $macsp"	"$percent_raj1 >> $fileout
		done

		for file in $(find "dats/GOTO_rajadas_rssi_"$teste"/" -type f -name '*.dat')
		do
			rssisp="$(echo $file | awk -F"/" '{split($3,a,"_");print a[1]}')"
			interface="$(echo $file | awk -F"/" '{split($3,a,"_");print a[2]}')"
			percent_raj1=$(tail -n +2 $file | awk ' BEGIN{total=0;raj1=0}{if($4=="1") raj1=raj1+1; total=total+1}END{printf ("%.2f",100*(raj1/total))}')
			fileout="dats/GOTO_percent_raj1_rssi/"$interface"_"$teste".dat"
			echo $rssisp"	"$percent_raj1 >> $fileout
		done	
	done	
	
}

function plot_raj1 {
	for teste in "${testes[@]}"
	do
		for interface in "${interfaces[@]}"
		do
			if [ ! -d graficos/GOTO_CDF_raj1_mac/ ]; then mkdir -p graficos/GOTO_CDF_raj1_mac/; fi
			if [ ! -d graficos/GOTO_CDF_raj1_rssi/ ]; then mkdir -p graficos/GOTO_CDF_raj1_rssi/; fi
			filein="dats/GOTO_percent_raj1_mac/"$interface"_"$teste".dat"
			fileout="graficos/GOTO_CDF_raj1_mac/raj1-mac-"$interface"-"$teste"-PDF.pdf"
			fileout2="graficos/GOTO_CDF_raj1_mac/raj1-mac-"$interface"-"$teste"-CDF.pdf"

			fileinr="dats/GOTO_percent_raj1_rssi/"$interface"_"$teste".dat"
			fileoutr="graficos/GOTO_CDF_raj1_rssi/raj1-rssi-"$interface"-"$teste"-PDF.pdf"
			fileout2r="graficos/GOTO_CDF_raj1_rssi/raj1-rssi-"$interface"-"$teste"-CDF.pdf"
			if [ -f  hist_rajadas_1.plot ]; then rm  hist_rajadas_1.plot; fi


cat << ! >> ./hist_rajadas_1.plot
reset
stats "$filein" using 2 nooutput
max=STATS_max
min=STATS_min
width=10
hist(x,width)=width*floor(x/width)-width/2.0
set xtics min,10,max
set boxwidth width*0.8
set style fill solid 0.5
set tics out nomirror
set term pdf dashed enhanced size 7cm,5cm
set output "$fileout"
set xlabel "Percentage of bursts of size 1"
set ylabel "Frequency"
plot "$filein" \
u (hist(\$2,width)):(1.0) smooth freq w boxes lc rgb "black" notitle

set ytics 0,0.1,1
set output "$fileout2"
set xlabel "Percentage of bursts of size 1"
set ylabel "Cumulative Probability"
nsamples=STATS_records
plot "$filein" \
using 2:(1/nsamples) lw 3 lt 5 smooth cumul t "";

reset
stats "$fileinr" using 2 nooutput
max=STATS_max
min=STATS_min
width=10
hist(x,width)=width*floor(x/width)-width/2.0
set xtics min,10,max
set boxwidth width*0.8
set style fill solid 0.5
set tics out nomirror
set term pdf dashed enhanced size 7cm,5cm
set output "$fileoutr"
set xlabel "Percentage of bursts of size 1"
set ylabel "Frequency"
plot "$fileinr" \
u (hist(\$2,width)):(1.0) smooth freq w boxes lc rgb "black" notitle

set ytics 0,0.1,1
set output "$fileout2r"
set xlabel "Percentage of bursts of size 1"
set ylabel "Cumulative Probability"
nsamples=STATS_records
plot "$fileinr" \
using 2:(1/nsamples) lw 3 lt 5 smooth cumul t "";

!

gnuplot hist_rajadas_1.plot

		done
	done
}


function plot_rajadas_macsp {
macsp="$1"
interface="$2"
teste="$3"
if [ ! -d graficos/GOTO_rajadas_mac_"$teste"/ ]; then mkdir -p graficos/GOTO_rajadas_mac_"$teste"/; fi
if [ -f hist_rajadas.plot ]; then rm hist_rajadas.plot; fi

filein="dats/GOTO_rajadas_mac_"$teste"/"$macsp"_"$interface"_array_rajadas_"$teste".dat"
fileout="graficos/GOTO_rajadas_mac_"$teste"/"$macsp"-"$interface"-hist.pdf"
fileout2="graficos/GOTO_rajadas_mac_"$teste"/"$macsp"-"$interface"-CDF.pdf"

cat << ! >> ./hist_rajadas.plot
reset
stats "$filein" using 3 nooutput
max=STATS_max
min=STATS_min
width=1
hist(x,width)=width*floor(x/width)
set xtics min,1,max
set boxwidth width*0.8
set style fill solid 0.5
set tics out nomirror
set term pdf dashed enhanced size 7cm,5cm
set output "$fileout"
set yrange [:]
set xrange [min-1:max+1]
set xlabel "Size of outliers bursts"
set ylabel "Frequency"
plot "$filein" \
u (hist(\$3,width)):(1.0) smooth freq w boxes lc rgb "black" notitle

set yrange [0:1]
set xrange [1:]
set ytics 0,0.1,1
set output "$fileout2"
set xlabel "Size of outliers bursts"
set ylabel "Cumulative Probability"
nsamples=STATS_records
plot "$filein" \
using 3:(1/nsamples) lw 3 lt 5 smooth cumul t '$macsp';

!

gnuplot hist_rajadas.plot

}



function plot_rajadas_rssisp {
rssisp="$1"
interface="$2"
teste="$3"
if [ ! -d graficos/GOTO_rajadas_rssi_"$teste"/ ]; then mkdir -p graficos/GOTO_rajadas_rssi_"$teste"/; fi
if [ -f hist_rajadas.plot ]; then rm hist_rajadas.plot; fi

filein="dats/GOTO_rajadas_rssi_"$teste"/"$rssisp"_"$interface"_array_rajadas_"$teste".dat"
fileout="graficos/GOTO_rajadas_rssi_"$teste"/"$rssisp"-"$interface"-hist.pdf"
fileout2="graficos/GOTO_rajadas_rssi_"$teste"/"$rssisp"-"$interface"-CDF.pdf"
rssi="-"$rssisp

cat << ! >> ./hist_rajadas.plot
reset
stats "$filein" using 4 nooutput
max=STATS_max
min=STATS_min
width=1
hist(x,width)=width*floor(x/width)
set xtics min,1,max
set boxwidth width*0.8
set style fill solid 0.5
set tics out nomirror
set term pdf dashed enhanced size 7cm,5cm
set output "$fileout"
set yrange [:]
set xrange [min-1:max+1]
set xlabel "Size of outliers bursts"
set ylabel "Frequency"
plot "$filein" \
u (hist(\$4,width)):(1.0) smooth freq w boxes lc rgb "black" notitle

set yrange [0:1]
set xrange [1:]
set ytics 0,0.1,1
set output "$fileout2"
set xlabel "Size of outliers bursts"
set ylabel "Cumulative Probability"
nsamples=STATS_records
plot "$filein" \
using 4:(1/nsamples) lw 3 lt 5 smooth cumul t '$rssi';
!

gnuplot hist_rajadas.plot

}

function plot_hist_cdf_rajadas {
	for teste in "${testes[@]}"
	do
		# mac
		for file in $(ls -w1 dats/GOTO_rajadas_mac_"$teste"/)
		do
			macsp="$(echo $file | awk -F"_" '{print $1}')"
			interface="$(echo $file | awk -F"_" '{print $2}')"
			plot_rajadas_macsp "$macsp" "$interface" "$teste"
	
		done

		# rssi
		for file in $(ls -w1 dats/GOTO_rajadas_rssi_"$teste"/)
		do
			rssisp="$(echo $file | awk -F"_" '{print $1}')"
			interface="$(echo $file | awk -F"_" '{print $2}')"
			plot_rajadas_rssisp "$rssisp" "$interface" "$teste"
		done
	done
}

function unificar_resultados_rajadas {
	for teste in "${testes[@]}"
        do
		if [ ! -d dats/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste" ]; then mkdir -p dats/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"; else rm dats/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"/*; fi
		for file in $(find "dats/GOTO_rajadas_mac_"$teste"/" -type f -name '*.dat')
		do
			interface="$(echo $file | awk -F"/" '{split($3,a,"_");print a[2]}')"
			output="dats/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"/rajadas_unificadas_"$interface"_.dat"
			if [ ! -f $output ]
			then
				cat $file > $output	
			else
				tail -n +2 $file >> $output
			fi
		done
	done
}

function unificar_resultados_quartis {
	if [ ! -d dats/GOTO_quartis_unificados/ ]; then mkdir -p dats/GOTO_quartis_unificados/; else rm dats/GOTO_quartis_unificados/*; fi
        for interface in "${interfaces[@]}"
        do
		for file in $(find "dats/GOTO_quartis/" -type f -name '*_'$interface'_stats.dat')
		do
			output="dats/GOTO_quartis_unificados/quartis_de_todos_macs_"$interface".dat"
			if [ ! -f $output ]
			then
				cat $file > $output	
			else
				tail -n +2 $file >> $output
			fi
		done
	done
}

function plot_resultado_rajadas_unificado {
	for teste in "${testes[@]}"
        do
                for interface in "${interfaces[@]}"
                do
			filein="dats/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"/rajadas_unificadas_"$interface"_.dat"
			fileout="graficos/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"/PDF_rajadas_unificadas_"$interface"_.pdf"
			fileout2="graficos/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"/CDF_rajadas_unificadas_"$interface"_.pdf"
			if [ ! -d graficos/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"/ ]; then mkdir -p graficos/GOTO_rajadas_unificadas/GOTO_rajadas_unificadas_"$teste"/ ; fi
			if [ -f hist_rajadas_unificadas.plot ]; then rm  hist_rajadas_unificadas.plot; fi

cat << ! >> ./hist_rajadas_unificadas.plot
reset
stats "$filein" using 3 nooutput
max=STATS_max
min=STATS_min
width=1
nsamples=STATS_records
sum=floor(nsamples)
hist(x,width)=width*floor(x/width)
set xtics 1 offset 0,0.7
set grid ls 0 lc 9
set rmargin 2
set lmargin 7.1
set bmargin 2.1
set ytics 0,0.2,1
set mytics 2 
set boxwidth width*0.8
set style fill solid 0.5
set tics out nomirror
set xlabel offset 0,1.3 	 						
set ylabel offset 1.5,0
set term pdf dashed monochrome enhanced size 5cm,4cm font "helvetica,14"
set output "$fileout"
set yrange [0:1]
set xrange [0:10]
set xlabel "Size of outliers bursts"
set ylabel "Normalized Frequency"
plot "$filein" \
u (hist(\$3,width)):(1./(sum*width)) smooth freq w boxes lc rgb "black" notitle

#perc88=system("tail -n +2 $filein | awk '{print \$3}' | sort -n | awk 'BEGIN{i=1}{s[i]=\$1; i++;}END{print s[int(NR*0.88)]}'")
#set arrow from perc88,0 to perc88,0.88 nohead lt 5 lw 2
#perc90=system("tail -n +2 $filein | awk '{print \$3}' | sort -n | awk 'BEGIN{i=1}{s[i]=\$1; i++;}END{print s[int(NR*0.90)]}'")
#set arrow from perc90,0 to perc90,0.9 nohead lt 5 lw 2
perc99=system("tail -n +2 $filein | awk '{print \$3}' | sort -n | awk 'BEGIN{i=1}{s[i]=\$1; i++;}END{print s[int(NR*0.99)]}'")
set arrow from perc99,0 to perc99,0.99 nohead lt 5 lw 2

set yrange [0:1]
set xrange [1:]
set output "$fileout2"
set xlabel "Size of outliers bursts"
set ylabel "Cumulative Probability"
plot "$filein" \
using 3:(1/nsamples) lw 3 lt 5 smooth cumul t '';

!

gnuplot hist_rajadas_unificadas.plot
		done
	done
}

function plot_corr_rssi_x_desvio {
	if [ ! -d ./graficos/GOTO_corr_rssi_desvio/ ]; then mkdir -p ./graficos/GOTO_corr_rssi_desvio/ ; fi
	for interface in "${interfaces[@]}"
	do
		        if [ -f correlacao_desvioXrssi.r ]; then rm correlacao_desvioXrssi.r; fi
			filename="./dats/GOTO_quartis_unificados/quartis_de_todos_macs_"$interface".dat"
			#filename="quartis_de_todos_macs_"$interface".dat"
			pdfname="./graficos/GOTO_corr_rssi_desvio/GOTO_corr_rssi_desvio_"$interface".pdf"
			#pdfname="GOTO_corr_rssi_desvio_"$interface".pdf"
			fileoutname="./graficos/GOTO_corr_rssi_desvio/quartis_de_todos_macs_Rsink_"$interface".txt"
			#fileoutname="quartis_de_todos_macs_Rsink_"$interface".txt"
			rm $fileoutname
			limiaramostrasmax=2000000
			limiaramostrasmin=400

		        echo "filename=\""$filename"\"" >> correlacao_desvioXrssi.r
		        echo "pdfname=\""$pdfname"\"" >> correlacao_desvioXrssi.r
		        echo "sink(\""$fileoutname"\", append=TRUE, split=TRUE)" >> correlacao_desvioXrssi.r
		        echo "limiaramostrasmax=$limiaramostrasmax" >> correlacao_desvioXrssi.r
			echo "limiaramostrasmin=$limiaramostrasmin" >> correlacao_desvioXrssi.r

cat << ! >> correlacao_desvioXrssi.r
# lendo arquivo em formato de matrix
library(readr)
library("Hmisc")
m2 <- as.matrix(read_delim(filename, "\t", escape_double = FALSE, col_names = FALSE, col_types = cols(X1 = col_skip(), X11 = col_skip(),     X12 = col_skip(), X13 = col_skip(),     X14 = col_skip(), X17 = col_skip(),     X2 = col_skip(), X3 = col_skip(),     X4 = col_skip(), X5 = col_skip(),     X6 = col_skip(), X7 = col_skip(),     X8 = col_skip(), X9 = col_skip()), comment = "#", trim_ws = TRUE))
# numero total de amostras e perdas encontradas para o AP
m=m2[m2[,"X10"] >= limiaramostrasmin & m2[,"X10"] <= limiaramostrasmax, ]
res <- rcorr(m[,2:3],type = c("pearson"))
res

res2 <- rcorr(m[,2:3],type = c("spearman"))
res2

print(m,digits = 10)


sink()
#plot
pdf(pdfname,width=10/2.54,height=10/2.54,colormodel="grey")
par(mar=c(4,4,0.5,0.5)+0.1) #b, l, t, r
plot(x <- m[,"X15"], y <- m[,"X16"],xlab="RSSI (dBm)", ylab="Standard Deviation", xlim=c(-95, -30), ylim=c(0, 30),pch=1, cex.lab=1.3, cex.axis=1.2)
scat1d(x)                 # density bars on top of graph
scat1d(y, 4)              # density bars at right
#histSpike(x, add=TRUE)       # histogram instead, 100 bins
#histSpike(y, 4, add=TRUE)
#histSpike(x, type='density', add=TRUE)  # smooth density at bottom
#histSpike(y, 4, type='density', add=TRUE)
legend(x=-63,y=32, legend=paste('r =',round(cor(x <- m[,"X15"], y <- m[,"X16"],method="pearson"),2)),bty = "n", cex=1.3)
legend(x=-63,y=28, legend=paste('rho =',round(cor(x <- m[,"X15"], y <- m[,"X16"],method="spearman"),2)),bty = "n", cex=1.3)
#legend(x=-63,y=24, legend=paste('tau =',round(cor(x <- m[,"X15"], y <- m[,"X16"],method="kendall"),2)),bty = "n", cex=1.3)
dev.off()
!

		R CMD BATCH correlacao_desvioXrssi.r
	done
}


declare -a testes=(
	# TESTES
	#"outliers_mild_min"
	#"outliers_mild_max"
	"outliers_extr_min"
	#"outliers_extr_max"
	#"outliers_mild"
	#"outliers_extr"
	#"perdas"
	#"outliers_minfixed_10"
	#"outliers_minfixed_15"
	#"outliers_minfixed_20"
)
declare -a interfaces=(
	"tplink"
	"airpcap"
)


#stats_GOTO_quartis

#stats_GOTO_rajadas
#plot_hist_cdf_rajadas

#unificar_resultados_rajadas
plot_resultado_rajadas_unificado

#unificar_resultados_quartis
#plot_corr_rssi_x_desvio

#calcular_percent_raj1
#plot_raj1


