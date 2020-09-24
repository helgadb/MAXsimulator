#!/bin/bash
function plot_resumo_handoffs_atraso {
	teste="$1"
	filein="resultados/$teste/resumo-atraso-e-handoffs-persistencia-"$persistencia"-offset-"$offset"-scan_interval-"$scan_interval"-MaxChannelTime-"$MaxChannelTime".dat"	
	outputhandoffs="graficos/"$teste"/histograma-resumo-handoffs-persistencia-"$persistencia"-offset-"$offset"-scan_interval-"$scan_interval"-MaxChannelTime-"$MaxChannelTime"_"
	outputatraso="graficos/"$teste"/histograma-resumo-atrasos-persistencia-"$persistencia"-offset-"$offset"-scan_interval-"$scan_interval"-MaxChannelTime-"$MaxChannelTime"_"
	handoffs="dats/"$teste"/handoffs-persistencia-"$persistencia"-offset-"$offset"-scan_interval-"$scan_interval"-MaxChannelTime-"$MaxChannelTime"_"
	atraso="dats/"$teste"/atraso-persistencia-"$persistencia"-offset-"$offset"-scan_interval-"$scan_interval"-MaxChannelTime-"$MaxChannelTime"_"
	#ponto	alg	handoffs	ultimo_handoff	atraso
	
	if [ -f hist_x_idteste_delay_handoffs.plot ]; then rm hist_x_idteste_delay_handoffs.plot; fi

	# gerando arquivos dat no formato de histograma do gnuplot
	if [ ! -d "dats/$teste/" ]; then mkdir -p "dats/$teste/"; else rm dats/$teste/* ;fi
	if [ ! -d "graficos/$teste/" ]; then mkdir -p "graficos/$teste/"; else rm graficos/$teste/* ; fi
	grep -v "#" $filein |  awk -v atraso="$atraso" -v handoffs="$handoffs" '
	BEGIN{delete array; c=1; old=0}
	{
		if ($1 != old) c=c+1
		if (NR == 1) {
		        ci=c
		        array[c][1]=$1 # ID teste
		        array[c][2]=$2 # alg
		        array[c][3]=$3 # handoffs
		        array[c][4]=$4 # ultimo handoff
		        if ( $5 < -10000 ) atr="60"; else atr=$5
		        array[c][5]=atr # atraso
		}
		else {
		        array[c][1]=$1 # ID teste
		        array[c][2]=array[c][2]"\011"$2 # alg
		        array[c][3]=array[c][3]"\011"$3 # handoffs
		        array[c][4]=array[c][4]"\011"$4 # ultimo handoff
		        if ( $5 < -10000 ) atr="60"; else atr=$5
		        array[c][5]=array[c][5]"\011"atr # atraso
		}
		old=$1
	}
	END{
		# handoffs
		for (i=1;i<=c;i++){
			printf ("Nr\tID\t") >> handoffs array[i][1]"_.dat"
			j=gensub("_","","g",array[ci][2])
			printf ("%s\n",j) >> handoffs array[i][1]"_.dat"
		        printf (i"\t"array[i][1]"\t") >> handoffs array[i][1]"_.dat"
		        printf ("%s\n",array[i][3]) >> handoffs array[i][1]"_.dat"
		}


		# atraso 
		for (i=1;i<=c;i++){
			printf ("Nr\tID\t") >> atraso array[i][1]"_.dat"
			j=gensub("_","","g",array[ci][2])
			printf ("%s\n",j) >> atraso array[i][1]"_.dat"
		        printf (i"\t"array[i][1]"\t") >> atraso array[i][1]"_.dat"
		        printf ("%s\n",array[i][5]) >> atraso array[i][1]"_.dat"
		}
		


	}
	'

cat << ! >> ./hist_x_idteste_delay_handoffs.plot
reset
set grid ls 3 lc 9
#set size 1,.9
set key  out horizontal left top spacing 5 width 35
#set key height .5
set mxtics 5
set rmargin -5
set lmargin 10
set tmargin 25
set bmargin 5
#set xrange [0:]
set auto x
set yrange [-15:15]
set xtics font "helvetica,30"
set ytics font "helvetica,30" 
set key font "helvetica,30"
set xlabel font "helvetica,30" offset 0,-0.5
set ylabel font "helvetica,30" offset -2,0
set offset graph -0.25,-0.5,0,0
set tics out nomirror 
set xlabel "Test ID"


set style data histogram
set style histogram cluster gap 5 
set style fill solid 0.40 border 
set boxwidth 0.9
#set xtic rotate by -45 scale 0
#set bmargin 10 

set term pdf dashed enhanced size 100cm,32cm	
!

#for i in $(ls -w1 -d dats/$teste/* | awk -F"_" '{print $3}'| sort -g -u)
#do
#obs: fim max = 419
i=0
	echo "set ylabel \"Delay\"" >> ./hist_x_idteste_delay_handoffs.plot
	echo "set output \""$outputatraso$i"_.pdf\"  " >> ./hist_x_idteste_delay_handoffs.plot
	echo "plot \""$atraso$i"_.dat\" u 3:xtic(2) ti col, for [i=4:12] '' using i ti col, for [i=31:39] '' using i ti col, for [i=44:54] '' using i ti col, for [i=222:230] '' using i ti col, for [i=249:257] '' using i ti col, for [i=357:365] '' using i ti col , for [i=60:68] '' using i ti col;"	 >> ./hist_x_idteste_delay_handoffs.plot
	echo "set ylabel \"Handoffs\"" >> ./hist_x_idteste_delay_handoffs.plot
	echo "set yrange [0:15]" >> ./hist_x_idteste_delay_handoffs.plot
	echo "plot \""$handoffs$i"_.dat\" u 3:xtic(2) ti col, for [i=4:12] '' using i ti col, for [i=31:39] '' using i ti col, for [i=44:54] '' using i ti col, for [i=222:230] '' using i ti col, for [i=249:257] '' using i ti col, for [i=357:365] '' using i ti col, for [i=60:68] '' using i ti col ;" >> ./hist_x_idteste_delay_handoffs.plot

#done


gnuplot hist_x_idteste_delay_handoffs.plot

}

#plot_resumo_handoffs_atraso teste3-tplink
#plot_resumo_handoffs_atraso teste3-airpcap
#plot_resumo_handoffs_atraso teste4-tplink
#plot_resumo_handoffs_atraso teste4-airpcap
