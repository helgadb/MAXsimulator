#!/bin/bash

# este script calcula o número de ping-pongs com intervalo Xmax dado em número de scans e não em tempo conforme ocorreu no artigo do SBRC. Esta alteração foi implementada para este resultado ficar mais compatível com o resultado do teste de tradeoff, que também é baseado em número de scans.

function trata_pp {

file_in="$1"
# dado em número de scans e não em segundos
XmaxS="7"
#XmaxS="$2"
Nmin="1"
#Nmin="$3"
stats_out=$file_in".stats-XmaxS-$XmaxS-Nmin-$Nmin-dat"
file=$file_in"num_de_pp_e_handoffs_consecutivos_p_intervalo_XmaxS_"$XmaxS"_Nmin_"$Nmin".txt"

if [ -f $file ];then rm $file;fi
if [ -f $stats_out ];then rm $stats_out;fi
# gerando estatisticas:
# ns=numero de scans
# nr=numero roamings
# m0=numero de vezes que estava desassociado e fez a associação inicial
# m1=numero de vezes que fez desassociaçao porque não encontrou nenhum ap no scan
# m2=numero de vezes que fez handoff para outro ap porque nao achou o ap atual no scan
# m3=numero de vezes que se manteve no mesmo AP porque nao achou outros pretendentes
# m4=numero de vezes em que a mesma BSS foi escolhida
# m5=numero de vezes que fez handoff porque o ap pretendente tem vazao esperada maior
# m6=numero de vezes em que outra BSS foi escolhida, mas o nível da atual é melhor 
# m7=numero de vezes que outra foi escolhida mas o limiar nao foi ultrapassado (nao fez roaming)
# m8=numero de vezes que outra foi escolhida e o limiar foi ultrapassado (fez roaming)
# npps= numero de ping pongs, ou seja, estava em 1, foi para 2 em menos ou em 2 scans e voltou para 1 em menos ou em 2 scans. Neste caso, o limiar Nmin foi 2 e o dt Xmax foi 2 scans (roamings consecutivos ocorrendo em menos de 3 scans cada)
# n_last= numero do scan do último handoff no teste (handoff de estabilização)
# timestamp= tempo do último handoff no teste (handoff de estabilização)

exit_code=$(zcat $file_in | awk -v file="$file" -v stats_out="$stats_out" -v XmaxS="$XmaxS" -v Nmin="$Nmin" 'BEGIN {
	
	ns=0
	Ns=0
	nr=0
	npps=0
	# contabiliza num de scans entre roammings, será zerado após o primeiro roamming para começar a contagem
	dS=999999
	nppcms=-1 #numero de ping-pongs consecutivos máximo relativos a XmaxS
	m1=0
	m2=0
	m3=0
	m4=0
	m5=0
	m6=0
	m7=0
	m8=0
	n_last=-99999999999
	timestamp=-999999999
}
{
	# evento de scan ocorre a cada linha do log
	ns = ns + 1
	# contabiliza num de scans entre roammings
	dS = dS + 1
	
	# associação inicial
	if ( $2 ==  "M0") {
		m0 = m0 + 1
	}
	# Desassociado por falta de opções no scan
	if ( $2 ==  "M1") {
		m1 = m1 + 1
	}
	# nao achou ap atual no scan
	if ( $2 ==  "M2") {
		m2 = m2 + 1
		n_last=$1
		timestamp=$3
	}
	# nao achou ap pretendente
	if ( $2 ==  "M3") {
		m3 = m3 + 1
	}
	# pretendente é igual ao atual	
	if ( $2 ==  "M4") {
		m4 = m4 + 1
	}
	# ap pretendente tem vazao esperada maior
	if ( $2 ==  "M5") {
		m5 = m5 + 1
		n_last=$1
		timestamp=$3
	}
	# atual tem sinal melhor
	if ($2 == "M6") {
		m6 = m6 + 1
	}
	# diferença de sinal foi pequena
	if ( $2 == "M7") {
		m7 = m7 + 1
	}
	# diferença de sinal estava maior do que mindiff
	if ( $2 == "M8") {
		m8 = m8 + 1
		n_last=$1
		timestamp=$3
	}

	# contabilizar ping-pongs com base em numero de scans
	if( $2 == "M8" || $2 == "M5" || $2 == "M2"){
	#if( $2 == "M8" || $2 == "M5"){				
		if ( dS <= XmaxS ) {
			Ns=Ns+1
			if ( Ns >= Nmin ) npps=npps+1		
		}
		else {
			if ( (Ns-Nmin+1) > nppcms ) nppcms=Ns-Nmin+1
			if ( Ns >= Nmin ) {
				print Ns-Nmin+1";"Ns+1  >> file
			}
			Ns=0
		}
		dS=0
	}
}
END{

	nr = m8 + m2 + m5
	print "#scans;#ping-pongs para XmaxS "XmaxS" e Nmin "Nmin";#max de pp consecutivos;#handoffs;#associacao inicial;#desasociado por falta de opções;#handoff falta por de beacon do ap atual;#sem pretendente;#mesma BSS foi escolhida;#handoff por vazao esperada melhor;#nivel de sinal da atual melhor;#diferença de sinal pequena;#handoff por diferença de sinal grande;#do scan do ultimo handoff;timestamp do ultimo handoff" >> stats_out

	print ns";"npps";"nppcms";"nr";"m0";"m1";"m2";"m3";"m4";"m5";"m6";"m7";"m8";"n_last";"timestamp >> stats_out
	# codigo de erro	
	if ( m1 > 0 ) print "1"
	else if ( m2 > 0 ) print "2"
	else if ( m8 == 0 && m5 == 0 ) print "8"
	else print "0"
}'
)
}

function gera_interseccao_R {

if [ -f "interseccao-R" ]; then rm "interseccao-R"; fi
inpath="/home/helgadb/gdrive/Doutorado/ping-pong/meta2A/v3-META2A/dats/"
inputAP1=$inpath"/wpa_sup_"$pcapfile"/c0-4a-00-bd-c1-54.dat.gz"
inputAP2=$inpath"/wpa_sup_"$pcapfile"/c0-4a-00-1c-f4-90.dat.gz"

cat << ! >> ./interseccao-R
library(readr)

# este é o AP1 (RSSI maior no inicio)
dat54 <- read_delim("$inputAP1", 
    ";", escape_double = FALSE, col_names = FALSE, 
    trim_ws = TRUE,col_types = cols())

dat90 <- read_delim("$inputAP2", 
    ";", escape_double = FALSE, col_names = FALSE, 
    trim_ws = TRUE,col_types = cols())

AP1 <- subset(dat54, dat54\$X7 >= 45 & dat54\$X7 <= 184)
AP2 <- subset(dat90, dat90\$X7 >= 45 & dat90\$X7 <= 184)
plAP1 <- lm(AP1\$X3 ~ log(AP1\$X7))
plAP2 <- lm(AP2\$X3 ~ log(1.05*max(AP2\$X7)-AP2\$X7))
#summary(plAP1)
#summary(plAP2)
plot(AP1\$X7, AP1\$X3, col = "blue")
points(AP2\$X7, AP2\$X3, col = "red")
curveplAP1 <- predict(plAP1)
lines(AP1\$X7,curveplAP1)
curveplAP2 <- predict(plAP2)
lines(AP2\$X7,curveplAP2)

plot(dat54\$X7, dat54\$X3, col = "blue")
points(dat90\$X7, dat90\$X3, col = "red")
lines(AP1\$X7,curveplAP1)
lines(AP2\$X7,curveplAP2)

# coeficientes linear e angular

clAP1 = coefficients(plAP1)[1]
clAP2 = coefficients(plAP2)[1]
caAP1 = coefficients(plAP1)[2]
caAP2 = coefficients(plAP2)[2]

f <- function(x,A=caAP1,B=clAP1,C=caAP2,D=clAP2) {
    y <- numeric(2)
    y[1] <- A * log(x[1]) + B - x[2]
    y[2] <- C * log(1.05*max(AP2\$X7)-x[1]) + D - x[2]
    y   
}

xstart <- c(125,-125)
fstart <- f(xstart)
o=xstart
o=fstart
p<-data.frame(nleqslv::nleqslv(xstart, f, control=list(btol=.01),jacobian=TRUE,method="Newton"))
# retorna o ponto ideal
cat(as.numeric(p[1,1]))
!
	
}


function seta_hist_status_e_gera {
        for alg in "${algoritmos_stats_pp_atraso[@]}"
        do
                input="resultados/"$pcapfile"/"$alg"offset_"$offset_stats"_histerese_"$histerese_stats"_result.dat.gz.stats-XmaxS-$XmaxS_stats-Nmin-$Nmin_stats-dat"
                if [ -f $input ]
                then
                        handoffs=$(tail -n -1  $input | awk -F";" '{print $4}')
                        ultimo_handoff=$(tail -n -1  $input | awk -F";" '{print $14}')
			timestamp_ultimo_handoff=$(tail -n -1  $input | awk -F";" '{print $15}')
                        atraso=$(( $ultimo_handoff - $ultimo_handoff_wpa ))
			atraso_segundos=$( awk -v a="$timestamp_ultimo_handoff" -v b="$timestamp_ultimo_handoff_wpa" 'BEGIN{print a-b}' )
			
                        
			if [[ $teste = *"teste3-"* ]] || [[ $teste = *"teste7-"* ]] || [[ $teste = *"teste9-"* ]] || [[ $teste = *"teste8-"* ]];
			then 
				ponto=$(echo  $input | awk -F"-" '{print $5}'); 		
				atraso=$( awk -v a="$ultimo_handoff" -v b="$momento_handoff_ideal" 'BEGIN{print (a-b)}')
				atraso_segundos=$( awk -v a="$atraso" 'BEGIN{print (a*0.1024)}' )
			# testes 4.1, 4.2, 4.3 e 4.4 nao tem ponto porque sao feitos por offset
                        else if [[ $teste = *"teste4-"* ]]; then ponto=$(echo  $input | awk -F"-" '{print $5}'); 
                        else if [[ $teste = *"teste5-"* ]]; then ponto=$(echo  $input | awk -F"-" '{print $5}'); 
			else if  [[ $teste = *"teste6-"* ]]; then ponto=$(echo  $input | awk -F"." '{split($2,a,"cap"); print a[2]}'); 
			fi
			fi
			fi
			fi	
			if [ $histerese_stats == "on" ]; then string="hm"; else string="";fi
                        echo "$ponto    $alg$string     $handoffs       $ultimo_handoff $atraso	$timestamp_ultimo_handoff	$atraso_segundos" >> $fileoutput
                else
                        >&2 echo "$alg $histerese_stats não existe"
                fi
        done

}

# função que deve ser chamada apos rodar todos os experimentos, para que resultados comparativos entre diversos mecanismos sejam obtidos.
function gera_estatisticas_pp_atraso {
	teste="$1"		
	if [ ! -d resultados/$teste ]; then mkdir resultados/$teste; fi
	fileoutput="resultados/$teste/resumo-pers-"$persistencia"-offset-"$offset"-scan_int-"$scan_interval"-MChanTime-"$MaxChannelTime"-"$pcapfile".dat"
	fileoutput2="resultados/$teste/resumo-pers-"$persistencia"-offset-"$offset"-scan_int-"$scan_interval"-MChanTime-"$MaxChannelTime".dat"
	#echo "#ponto	algoritmo	handoffs	ultimohandoff	atraso"  > $fileoutput # nao posso apagar o arquivo aqui

	# relativo ao resutado do wpa_sup (implementação antiga)
	input="resultados/"$pcapfile"/wpa_sup_offset_"$offset_stats"_histerese_on_result.dat.gz.stats-XmaxS-$XmaxS_stats-Nmin-$Nmin_stats-dat"

	ultimo_handoff_wpa=$(tail -n -1 $input | awk -F";" '{print $14}')
	timestamp_ultimo_handoff_wpa=$(tail -n -1 $input | awk -F";" '{print $15}')

	if [[ $teste = *"teste3-"* ]]
	then 
		#gera_interseccao_R (implementação antiga)
		#momento_handoff_ideal=$(Rscript interseccao-R)
		idteste=$(echo "$pcapfile" | awk -F"-" '{print $5}')
		momento_handoff_ideal=$(awk -v id="$idteste" '
@include "./scripts_trata_dados/pontos-teste3.awk"
BEGIN{printf("%f",teste[id][1])}')
	fi

	if [[ $teste = *"teste7-"* ]]
	then 
		idteste=$(echo "$pcapfile" | awk -F"-" '{print $5}')
		momento_handoff_ideal=$(awk -v id="$idteste" '
@include "./scripts_trata_dados/pontos-teste7.awk"
BEGIN{printf("%f",teste[id][1])}')
	fi

	if [[ $teste = *"teste8-"* ]]
	then 
		idteste=$(echo "$pcapfile" | awk -F"-" '{print $5}')
		momento_handoff_ideal=$(awk -v id="$idteste" '
@include "./scripts_trata_dados/pontos-teste8.awk"
BEGIN{printf("%f",teste[id][1])}')

	fi
	
	if [[ $teste = *"teste9-"* ]]
	then 
		idteste=$(echo "$pcapfile" | awk -F"-" '{print $5}')
		momento_handoff_ideal=$(awk -v id="$idteste" '
@include "./scripts_trata_dados/pontos-teste9.awk"
BEGIN{printf("%f",teste[id][1])}')

	fi
	histerese_stats="on"
	seta_hist_status_e_gera
        histerese_stats="off"
	seta_hist_status_e_gera

	cat $fileoutput >> $fileoutput2
	gzip $fileoutput
}

