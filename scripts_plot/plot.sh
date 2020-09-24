#!/bin/bash

# Script para plotar a RSSI obtida de cada AP em cada scan no tempo.
# Primeiro gera, a partir do arquivo de captura, um arquivo dat para cada MAC com: mac ";" epoch_time  ";" rssi ";" snr ";" taxa ";" frame_type ";"  scan_idx 

function gerar_all_dats {
for alg in "${algoritmos_plot[@]}"
do 
	#>&2 echo  $alg
	gera_rssi_dat $alg
done
}

function gera_rssi_dat {
algoritmo="$1" # tecnica avaliada opções: mmep_$alpha_, distnorm_$nTest_$nOutlier_$win_,testehip_$alpha_, wpa_sup_,mediana_$win_,moda_$win_
path="./saidas/" # caminho para a pasta com as capturas

#for i in $(ls -w1 -d $path/$pcapfile/* | grep $algoritmo | grep $pcapfile | grep "scan_file_" )
for i in $(find $path/$pcapfile/ -name *.dat.gz | grep $algoritmo | grep $pcapfile | grep "scan_file_" | grep "_offset_"$offset"_" )
do
	file=$i
	#>&2 echo  $file
	saida="dats/"$algoritmo$pcapfile$offset"/"
	#>&2 echo $saida 
	if [ ! -d $saida ] 
	then 
		mkdir -p $saida
	else
		rm $saida/*
		#echo "rm "$saida"/*"
	fi

	zcat $file | awk -v saida="$saida" 'BEGIN{ }
	{
		mac=$3
		# cortando entradas sem mac
		if (! match(mac, ":")) next
		# usado no nome do arquivo de saida
		macspecial=gensub(":", "-", "g", mac)
		epoch_time=$1
		rssi=$5
		snr=$6
		taxa=$7
		scan_idx=$8
		frame_type=$2
		taxa_beacon=$9
		print mac ";" epoch_time  ";" rssi ";" snr ";" taxa ";" frame_type ";"  scan_idx ";" taxa_beacon >> saida"/"macspecial".dat"		
	}'
	gzip -9 $saida/*.dat
done

}

# este arquivo de plot deve ser capaz de plotar a RSSI de diversos mecanismos simultaneamente 
function gera_arquivo_plot_selected {
	selector="$1"
	arrow1="$3"
	arrow2="$4"

	if [ -f rssixtempo.plot ]; then rm rssixtempo.plot; fi

cat << ! >> ./rssixtempo.plot
reset
set datafile separator ";"
set grid ls 3 lc 9
#set size 1,.9
set key box out horiz right top 
set key height .5
set mxtics 5
set rmargin 8
set lmargin 8	
#set xrange [0:]
#set yrange [-90:0]
set xtics font "helvetica,14"
set ytics font "helvetica,14" 
set key font "helvetica,14"
set xlabel font "helvetica,14" offset 0,-0.5
set ylabel font "helvetica,14" offset -0.5,0
set offset graph 0.05,0.05,0.05,0.0
set tics out nomirror 
set xtics rotate by -45

set xdata time
set timefmt "%s"
set format x "%H:%M:%S"

set xlabel "Time (H:M:S)"
set ylabel "RSSI (dBm)"
set term pdf dashed enhanced size 18cm,7cm	
!

echo "set arrow from \"$arrow2\",-90  to \"$arrow2\",-10 nohead lt 1 lw 2" >> ./rssixtempo.plot
echo "set arrow from \"$arrow1\",-90  to \"$arrow1\",-10 nohead lt 2 lw 2" >> ./rssixtempo.plot


if [ "$selector" == "mac" ]
then
	mac="$2"
	sufixo=""
	for alg in "${algoritmos_plot[@]}"
	do  
		sufixo=$sufixo"-per"$persistencia"-"$alg
	done
	echo "set output \""graficos/$pcapfile$offset/$mac$sufixo".pdf\"" >> ./rssixtempo.plot

	if [ ${#algoritmos_plot[@]} -gt 0 ]
	then
		for alg in "${algoritmos_plot[@]}"
		do
		algsp=$(echo $alg | sed 's@wpa_sup_@WPA Supplicant@g' | sed 's@distrnorm_@DistrNorm @g' | sed 's@mmep_@EWMA @g' | sed 's@testehip_@TesteHip @g' | sed 's@mediana_@Mediana @g' | sed 's@moda_@Moda @g' | sed 's@maximo_@Máximo @g' | sed 's@_@@g' )		
		# se so tem um elemento ...
		if [ ${#algoritmos_plot[@]} -eq 1 ]
		then	
			echo "plot \"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
			echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$algsp"\";" >> ./rssixtempo.plot
		# se o elemento atual for o ultimo ...
		else if [ "$alg" == "${algoritmos_plot[-1]}" ]
			then
				echo "\"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
				echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$algsp"\";" >> ./rssixtempo.plot	
			# se for o primeiro ...
			else if [ "$alg" == "${algoritmos_plot[0]}" ]
				then
					echo "plot \"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
					echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$algsp"\",\\" >> ./rssixtempo.plot
				# se estiver no meio ...				
				else
					echo "\"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
					echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$algsp"\",\\" >> ./rssixtempo.plot
				fi
			fi
		fi
	
		# plotar histograma para wpa_sup
		if [ $alg == "wpa_sup_" ]
		then
			echo "" >> ./rssixtempo.plot
			echo "reset" >> ./rssixtempo.plot 
			echo "set datafile separator \";\"" >> ./rssixtempo.plot 
			echo "stats \"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" using 3 nooutput"     >> ./rssixtempo.plot		
			echo "max=STATS_max" >> ./rssixtempo.plot
			echo "min=STATS_min" >> ./rssixtempo.plot
			echo "width=1" >> ./rssixtempo.plot
			echo "hist(x,width)=width*floor(x/width)" >> ./rssixtempo.plot
			echo "set yrange [0:]" >> ./rssixtempo.plot
			echo "set xrange [min-1:max+1]" >> ./rssixtempo.plot
			echo "set xtics min,2,max rotate by -45 " >> ./rssixtempo.plot
			echo "set boxwidth width*0.8" >> ./rssixtempo.plot
			echo "set style fill solid 0.5" >> ./rssixtempo.plot
			echo "set tics out nomirror" >> ./rssixtempo.plot
			echo "set xlabel \"Beacon SSI Signal (dBm)\"" >> ./rssixtempo.plot
			echo "set ylabel \"Frequency\"" >> ./rssixtempo.plot
			echo "set output \""graficos/$pcapfile$offset/$mac"-hist.pdf\"" >> ./rssixtempo.plot
			echo "plot \"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\"     >> ./rssixtempo.plot
			echo "u (hist(\$3,width)):(1.0) smooth freq w boxes lc rgb \"black\" notitle"  >> ./rssixtempo.plot
                fi
		done
	fi
fi

if [ "$selector" == "alg" ]
then
	alg="$2"
	sufixo=""
	for mac in "${lista_macs[@]}"
	do  
		sufixo=$sufixo"-per"$persistencia"-"$mac
	done
	echo "set output \""graficos/$pcapfile$offset/$alg$sufixo".pdf\"" >> ./rssixtempo.plot

	if [ ${#lista_macs[@]} -gt 0 ]
	then
		for mac in "${lista_macs[@]}"
		do
		# se so tem um elemento ...
		if [ ${#lista_macs[@]} -eq 1 ]
		then	
			echo "plot \"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
			echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$mac"\";" >> ./rssixtempo.plot
		# se o elemento atual for o ultimo ...
		else if [ "$mac" == "${lista_macs[-1]}" ]
			then
				echo "\"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
				echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$mac"\";" >> ./rssixtempo.plot	
			# se for o primeiro ...
			else if [ "$mac" == "${lista_macs[0]}" ]
				then
					echo "plot \"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
					echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$mac"\",\\" >> ./rssixtempo.plot
				# se estiver no meio ...				
				else
					echo "\"<zcat dats/"$alg$pcapfile$offset"/"$mac".dat.gz\" \\" 	>> ./rssixtempo.plot
					echo "using (\$2+(-3*3600)):3 w points ps 0.5 title \""$mac"\",\\" >> ./rssixtempo.plot
				fi
			fi
		fi
		done
	fi
	
fi
}

function gera_mac_list {
        for macsp in $(ls dats/$alg$pcapfile$offset/* | awk -F"/" '{split($3,a,".");print a[1]}' | sort -u )
        do
                nlines=$(zcat dats/*$pcapfile$offset/$macsp* | wc -l | tail -n1 | awk '{print $1}')    
                if [ $nlines -gt 10 ]
                then    
                        lista_macs+=($macsp)
                else echo "$mac não possui amostras suficientes para gerar gráfico"             
                fi
        done
}

function plotar_mac {
	# meu objetivo inicial é escolher um mac e plotar a rssi de todos os mecanismos para este mac. Repetir para todos os macs. então primeiro tenho que listar todos os macs.
	for macsp in "${lista_macs[@]}" 
	do
		gera_arquivo_plot_selected "mac" "$macsp" "$1" "$2" 
		#>&2 echo "1"
		gnuplot rssixtempo.plot	
	done
}

function plotar_alg {
	# plotar grafico com todos os macs para cada alg
	for alg in "${algoritmos_plot[@]}"
	do 
		# para cada alg terei que plotar um gráfico contendo todos os macs 
		gera_arquivo_plot_selected "alg" "$alg" "$1" "$2" 
		#>&2 echo "2"
		gnuplot rssixtempo.plot	
	done
}

function plotar {

	select="$1"
	arrow1="$2"
	arrow2="$3"
	output="./graficos/"$pcapfile$offset
	if [ ! -d $output ]; then mkdir -p  $output; fi
	
	gera_mac_list	
		
	if [ $select == "mac" ]
	then
		plotar_mac "$arrow1" "$arrow2"
	else
		if [ $select == "alg" ]
		then
			plotar_alg "$arrow1" "$arrow2"
		else
			if [ $select == "macalg" ]
			then
				plotar_mac "$arrow1" "$arrow2"
				plotar_alg "$arrow1" "$arrow2"
			fi
		fi
	fi
	
}

declare -a lista_macs=()
