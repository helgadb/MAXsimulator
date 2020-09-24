#!/bin/bash

pcapfiledir="$1" # arquivo de captura
pcapfile="$(echo $pcapfiledir | sed s@/@_@g)"
subtype="0x08" # filtrar beacon (scan passivo)
declare -a macs_para_filtrar=( "c0:4a:00:bd:c1:54" "c0:4a:00:1c:f4:90" ) # escolher macs que serao avaliados

rssi_file="saidas/rssi_file_"$pcapfile"_.dat" # registra valores de rssi dos APs e momento 
persistencia="10" # após não aparecer $persistencia vezes em scans consecutivos, a BSS é excluida da lista.
ruido2GHz="-89" # fonte: codigo do wpa supplicant - Utilizado para calcular a SNR a partir da RSSI
exit_code=-1

scan_interval="0.1024" # intervalo entre scans em segundos
MaxChannelTime="0.1024" # scan passivo em segundos, default é o intervalo entre beacons
offsetOn="1" # 1 = ligado; 0 = desligado -> insere ou nao offset no primeiro tscan para que a primeira amostra esteja em posição intermediaria no intervalo de scan.
offset=""

function define_offset {
	# definindo offset. Também adiciona o valor randomico dividido por 10 ao scaninterval e maxchanneltime
	if [ $offsetOn -eq 1 ] && [ "$1" == "" ]
	then
		offset=$(awk -v janela="$MaxChannelTime" 'BEGIN{srand(); randon=janela * rand();print randon}') # valor entre 0 <= x < janela que define o offset
		MaxChannelTime=$(awk -v mct="$MaxChannelTime" -v os="$offset" 'BEGIN{print mct+os/10 }')
		scan_interval=$(awk -v si="$scan_interval" -v os="$offset" 'BEGIN{print si+os/10 }')
	
	else 
		if [ $offsetOn -eq 1 ] && [ "$1" != "" ]
		then
			offset="$1"			
			MaxChannelTime=$(awk -v mct="$MaxChannelTime" -v os="$offset" 'BEGIN{print mct+os/10 }')
			scan_interval=$(awk -v si="$scan_interval" -v os="$offset" 'BEGIN{print si+os/10 }')
		else 
			if [ $offsetOn -eq 0 ]
			then
				offset=0
			fi
		fi
	fi
	scan_file="saidas/scan_file_int_"$scan_interval"_max_ch_time_"$MaxChannelTime"_offset_"$offset"_"$pcapfile".dat" # registra valores de RSSI na janela do scan para todos os APs escutados.
}


if [ ! -d "saidas" ]; then mkdir saidas; fi
if [ ! -d "resultados" ]; then mkdir resultados; fi
if [ ! -d "estatisticas" ]; then mkdir estatisticas; fi

[ -f ./scripts_filtragem_da_captura/filtragem.sh ] && . ./scripts_filtragem_da_captura/filtragem.sh

# função que simula um scan. Os resultados do scan puro são salvos em scan_file. 
# Este arquivo é utilizado pelas demais funções de scan como base, que irão ordenar o resultado, excluir repeticoes de APs e aplicar a persistencia caso seja desejado.
function scan {
if [ -f $scan_file".gz" ]; then rm $scan_file".gz"; fi
if [ -f $scan_file ]; then rm $scan_file; fi
	# salva no arquivo os valores de RSSI para todo os APs escutados a cada scan definido pelos intervalos. c é o índice do scan
	zcat $rssi_file".gz" | awk -v offset="$offset" -v offsetOn="$offsetOn" -v noise="$ruido2GHz" -v pcap="$scan_file" -v janela="$MaxChannelTime" -v scan_int="$scan_interval" 'BEGIN{c=0;f=0}
function calcula_snr(level,noise) {
	snr = level - noise
	return snr
}

function calcula_vazao_estimada(level,noise) {
	snr=calcula_snr(level,noise)
	
	# Get maximum legacy rate 
	# max legacy rate in 500 kb/s units 
	# 54 (Mbps) == 108 (500kbps)
	rate = 108; 

	# Limit based on estimated SNR 
	if (rate > 1 * 2 && snr < 1)
		rate = 1 * 2;
	else if (rate > 2 * 2 && snr < 4)
		rate = 2 * 2;
	else if (rate > 6 * 2 && snr < 5)
		rate = 6 * 2;
	else if (rate > 9 * 2 && snr < 6)
		rate = 9 * 2;
	else if (rate > 12 * 2 && snr < 7)
		rate = 12 * 2;
	else if (rate > 18 * 2 && snr < 10)
		rate = 18 * 2;
	else if (rate > 24 * 2 && snr < 11)
		rate = 24 * 2;
	else if (rate > 36 * 2 && snr < 15)
		rate = 36 * 2;
	else if (rate > 48 * 2 && snr < 19)
		rate = 48 * 2;
	else if (rate > 54 * 2 && snr < 21)
		rate = 54 * 2;
	est = rate * 500; # reconverteu rate para kbps

	return est
}
{
	split($5,levels,",")
	level=levels[1]
	# guardo resultados de scan no arquivo
	# primeira linha
	if ( NR == 1 ) {
		if (offsetOn == 1) {
			tscan=$1-offset	
			#print offset
		}
		else if (offsetOn == 0) {
			tscan=$1
			#print offset
		}
	}
	# se registro está dentro da janela de scan e do intervalo entre scans ...
	if ( $1 < (tscan + janela) && $1 >= tscan && $1 < (tscan + scan_int) ) {
		print $1"\t"$2"\t"$3"\t"$4"\t"level"\t"calcula_snr(level,noise)"\t"calcula_vazao_estimada(level,noise)"\t"c"\t"$6 >> pcap
		
	}
	# se eu saí da janela de scan, inicio um novo scan. c é o índice do scan.		
	else if ($1 >= (tscan + scan_int)) {				
		while ( $1 >= (tscan + scan_int) ) {
			tscan=tscan+scan_int
			c=c+1
		}
		if ( $1 < (tscan + janela) && $1 < (tscan + scan_int) ) {
			print $1"\t"$2"\t"$3"\t"$4"\t"level"\t"calcula_snr(level,noise)"\t"calcula_vazao_estimada(level,noise)"\t"c"\t"$6 >> pcap
		}
	}
}
'
	gzip -f -9 $scan_file
}

[ -f ./scripts_wpa_supplicant/wpa_supplicant.sh ] && . ./scripts_wpa_supplicant/wpa_supplicant.sh
[ -f ./scripts_mmep/mmep.sh ] && . ./scripts_mmep/mmep.sh
[ -f ./scripts_histerese/histerese.sh ] && . ./scripts_histerese/histerese.sh
[ -f ./scripts_trata_dados/trata-dados-baseado-n-scan.sh ] && . ./scripts_trata_dados/trata-dados-baseado-n-scan.sh
[ -f ./scripts_META2A/distribuicao_normal.sh ] && . ./scripts_META2A/distribuicao_normal.sh
[ -f ./scripts_META2A/mediana.sh ] && . ./scripts_META2A/mediana.sh
[ -f ./scripts_META2A/moda.sh ] && . ./scripts_META2A/moda.sh
[ -f ./scripts_META2A/maximo.sh ] && . ./scripts_META2A/maximo.sh
[ -f ./scripts_META2A/another_handoff_function.sh ] && . ./scripts_META2A/another_handoff_function.sh
[ -f ./scripts_plot/plot.sh ] && . ./scripts_plot/plot.sh
[ -f ./scripts_plot/plot_resumo_atraso_handoffs.sh ] && . ./scripts_plot/plot_resumo_atraso_handoffs.sh


if [ $2 == "filtra" ]; then
	filtra_captura 
fi

if [ $2 == "scan" ]; then
	define_offset ""
	scan 
	exit_code=$offset
fi

if [ $2 == "wpa" ]; then
	define_offset "$3"
	wpa_supplicant
	wpa_result="resultados/$pcapfile/wpa_sup_offset_"$offset"_histerese_on_result.dat"
	trata_pp "$wpa_result".gz
fi

if [ $2 == "mmep" ]; then
	define_offset "$5"
	mmep "$3"
	bhisterese="$4"
	mmep_result="resultados/$pcapfile/mmep_"$3"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	trata_pp "$mmep_result".gz
fi

if [ $2 == "distrnorm" ]; then
	define_offset "$8"
	# multiplicador do desvio padrão, multiplicador do desvio padrão para deteccao de outliers, janela, max outliers consecutivos
	distribuicao_normal "$3" "$4" "$5" "$6"
	#distribuicao_normal "3" "4" "5" "4"
	bhisterese="$7"
	distrnorm_result="resultados/$pcapfile/distrnorm_"$3"_"$4"_"$5"_"$6"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	trata_pp "$distrnorm_result".gz
fi

if [ $2 == "mediana" ]; then
	define_offset "$5"
	mediana "$3"
	bhisterese="$4"
	mediana_result="resultados/$pcapfile/mediana_"$3"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	trata_pp "$mediana_result".gz
fi

if [ $2 == "moda" ]; then
	define_offset "$5"
	moda "$3"
	bhisterese="$4"
	moda_result="resultados/$pcapfile/moda_"$3"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	trata_pp "$moda_result".gz
fi

if [ $2 == "maximo" ]; then
	define_offset "$5"
	maximo "$3"
	bhisterese="$4"
	maximo_result="resultados/$pcapfile/maximo_"$3"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	trata_pp "$maximo_result".gz
fi

if [ $2 == "histerese" ]; then
	define_offset "$4"
	histerese "$3"
	trata_pp "$histerese_result".gz
fi

if [ $2 == "plot" ]; then
	define_offset "$4"
	select="$3" #mac, alg ou macalg ou resumo 
	teste="$5" # se for resumo
	arrow1="$(echo $6 | awk '{a=$0-10800; printf "%f",a}')"
	arrow2="$(echo $7 | awk '{a=$0-10800; printf "%f",a}')"
	#arrow2="$(awk -v delay="$5" -v wpa="$arrow1" 'BEGIN{a=wpa+(delay*0.1024)+0.0512; printf "%f",a}')"
	[ -f ./scripts_plot/algs_plot.sh ] && . ./scripts_plot/algs_plot.sh
	if [ $select == "resumo" ]
	then
		plot_resumo_handoffs_atraso "$teste" 
	else
		gerar_all_dats
		plotar $select $arrow1 $arrow2 # plotar por mac ou por algoritmo		
	fi
fi

if [ $2 == "resumo" ]; then
	define_offset "$4"
	offset_stats="$4" # deve ser igual ao offset utilizado para criar os resultados
	teste="$3"
	Nmin_stats="1" #por enquanto estes stats devem ser iguais aos da funcao trata_pp
	XmaxS_stats="7"
	[ -f ./scripts_trata_dados/algs_trata.sh ] && . ./scripts_trata_dados/algs_trata.sh
	gera_estatisticas_pp_atraso "$teste"   
fi

# retorna codigo de saida
# 1 ou 2: falta de beacons ; 8: Falta de handoffs;  0: OK
echo $exit_code