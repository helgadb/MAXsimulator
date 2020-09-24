function scan_wpa {
# v 2.1 ou 2.6
scan_output="$1"
if [ -f $scan_output ];then rm $scan_output;fi
if [ -f $scan_output".gz" ];then rm $scan_output".gz";fi

zcat $scan_file".gz" | awk -v saida="$scan_output" -v persistencia="$persistencia" 'BEGIN{c=0;delete array_old;GREAT_SNR=30}

function copy_array1(array1,array2,i) {
		array1[i][1]=array2[1]
		array1[i][2]=array2[2]
		array1[i][3]=array2[3]
		array1[i][4]=array2[4]
		array1[i][5]=array2[5]
		array1[i][6]=array2[6]
		array1[i][7]=array2[7]
		array1[i][8]=array2[8]
		array1[i][9]=array2[9]	
}

function copy_array2(array1,array2,str) {
		array1[str][1]=array2[str][1]
		array1[str][2]=array2[str][2]
		array1[str][3]=array2[str][3]
		array1[str][4]=array2[str][4]
		array1[str][5]=array2[str][5]
		array1[str][6]=array2[str][6]
		array1[str][7]=array2[str][7]
		array1[str][8]=array2[str][8]
		array1[str][9]=array2[str][9]	
}

function qsort(A, left, right) {
  if (left >= right)
    return
  swap(A, left, left+int((right-left+1)*rand()))
  last = left
  for (i = left+1; i <= right; i++) {
    if (!wpa_scan_result_compar(A[i],A[left])) {
	  swap(A, ++last, i)
    }
  }
  swap(A, left, last)
  qsort(A, left, last-1)
  qsort(A, last+1, right)
}

function swap(A, i, j) {
  t = A[i]; A[i] = A[j]; A[j] = t
}

function abs(v) {return v < 0 ? -v : v}

function wpa_scan_result_compar(a,b) {
	# a e b são strings com valores separados por #
	delete values_a
	delete values_b
	split(a,values_a,"#")
	split(b,values_b,"#")
	snr_a_full = values_a[6];
	snr_a = snr_a_full < GREAT_SNR ? snr_a_full : GREAT_SNR
	snr_b_full = values_b[6];
	snr_b = snr_b_full < GREAT_SNR ? snr_b_full : GREAT_SNR
	a_est_throughput=values_a[7]
	b_est_throughput=values_b[7]

	# if SNR is close, decide by max rate or frequency band 
	if (abs(snr_b - snr_a) < 5) {
		if (a_est_throughput != b_est_throughput)
			if (b_est_throughput > a_est_throughput) return 1
			else return 0
	}

	# all things being equal, use SNR; if SNRs are identical
	if (snr_b_full > snr_a_full) return 1
	else return 0
}

function sort_scan(array,array_ordenado){
	delete sortvalues
	j=1
	for (key in array){
		sortvalues[j] =  array[key][1] "#" array[key][2] "#" array[key][3] "#" array[key][4] "#" array[key][5] "#" array[key][6] "#" array[key][7] "#" array[key][8] "#" array[key][9]
		j=j+1
	}
	
	qsort(sortvalues, 1, length(array));

	delete array_ordenado
	delete sort_a

	for (i = 1; i <= length(array); i++) {
		split(sortvalues[i],sort_a,"#")
		copy_array1(array_ordenado,sort_a,i)
	}
}

function print_array(array,c,saidaprint) {
	for (i=1;i in array;i++) {
		print array[i][1]"\t"array[i][2]"\t"array[i][3]"\t"array[i][4]"\t"array[i][5]"\t"array[i][6]"\t"array[i][7]"\t"c >> saidaprint 
	}
}

function compara_array (old,new,persistencia) {
	# compara array atual com old para ver se algum elemento de old pode ser adicionado na lista new.
	# o elemento é adicionado na lista new se "not found idx" na lista old é menor (<) do que a persistencia. Se for >= persistencia, o elemento não é adicionado.
	# ao adicionar, incrementar o "not found idx" na lista atual.

	for (key1 in old) { 
		found=0
		for (key2 in new) {
			if ( old[key1][3] == new[key2][3] ) {
				found=1	
				break
			}
		}
		if ( found == 0 ) {
			if ( old[key1][9] < persistencia ) {
				copy_array2(new,old,key1)
				new[key1][9]=new[key1][9]+1 # inc not found idx
			}
		}
		
	}
}
{
	# se estou no scan contabilizado ...
	if ($8 == c) {
		
		mac=$3
		# atualiza ou insere informação no array atual
		array_atual[mac][1]=$1  #timestamp
		array_atual[mac][2]=$2  #frame subtype
		array_atual[mac][3]=$3  #mac_src (AP) 
		array_atual[mac][4]=$4  #mac_dst
		array_atual[mac][5]=$5  #RSSI
		array_atual[mac][6]=$6  #SNR
		array_atual[mac][7]=$7  #Rate
		array_atual[mac][8]=$8  #scan number
		array_atual[mac][9]=0   # not found idx
	}
	# se mudou de scan
	else {
		while ($8 != c) {
			# se resultados antigos de scan existem, vou verificar se algum expirou ou se posso utilizar
			if (length(array_old) > 0) {
				compara_array(array_old,array_atual,persistencia)
			}
			# imprime array atual no arquivo
			sort_scan(array_atual,array_ordenado)
			print_array(array_ordenado,c,saida)
			c=c+1
			# copiar array_atual para array_old
			delete array_old
			for (key in array_atual) {
				copy_array2(array_old,array_atual,key)
			}

			# reinicializa array atual
			delete array_atual
		}		
		# tratar a entrada atual
		if ($8 == c) {
			mac=$3
			# insere informação no array atual
			array_atual[mac][1]=$1  #timestamp
			array_atual[mac][2]=$2  #frame subtype
			array_atual[mac][3]=$3  #mac_src (AP) 
			array_atual[mac][4]=$4  #mac_dst
			array_atual[mac][5]=$5  #RSSI
			array_atual[mac][6]=$6  #SNR
			array_atual[mac][7]=$7  #Rate
			array_atual[mac][8]=$8  #scan number
			array_atual[mac][9]=0   # not found idx
		}
					
	}
}
END{
	# tratanto o ultimo registro
	if (length(array_old) > 0) {
		compara_array(array_old,array_atual,persistencia)
	}
	# imprime array atual no arquivo
	sort_scan(array_atual,array_ordenado)
	print_array(array_ordenado,c,saida)

}
'
}

function wpa_handoff_function_26 {
	# version 2.6
	file_scan="$1"
	saida="$2"
	if [ -f $saida ]; then rm $saida; fi
	cat $file_scan | awk -v saida="$saida" 'BEGIN{c=0;bfound=0;bfound2=0;ap_pretendente_info="";ap_atual_scan=""}
	
	function abs(v) {return v < 0 ? -v : v}

	function verifica_handoff(ap_pretendente_info,ap_atual_scan,c,str_saida){
		delete a			
		split(ap_atual_scan,a,"\t")
		delete b			
		split(ap_pretendente_info,b,"\t")
		mac_old=a[3]
		mac=b[3]

		if (ap_atual_scan == "" && ap_pretendente_info == "") {
			registra_log(c,"M1 "$1" DESASSOCIADO POR FALTA DE OPCOES NESTE SCAN. AGUARDAR O PROXIMO",str_saida)
			return ""	
		}
		if (ap_atual_scan == "" ) {
			registra_log(c,"M2 "$1" FEZ HANDOFF PARA "mac" PORQUE NAO ACHOU AP ATUAL NO SCAN",str_saida)
			return mac
		}
		if (ap_pretendente_info == "" ) {
			registra_log(c,"M3 "$1" MANTEVE-SE ASSOCIADO A "mac_old" PORQUE NAO ACHOU AP PRETENDENTE",str_saida)
			return mac_old
		}
		if (a[3] == b[3] ) {
			registra_log(c,"M4 "$1" MANTEVE-SE ASSOCIADO A "mac_old" PORQUE O AP PRETENDENTE E IGUAL AO ATUAL",str_saida)
			return mac_old
		}
		if (b[7] > a[7] + 5000) {
			registra_log(c,"M5 "$1" FAZ HANDOFF de "mac_old" para "mac": Allow reassociation - selected BSS has better estimated throughput "a[5]" "b[5],str_saida)
			return mac		
		}
		if (a[5] > b[5]) {
			registra_log(c,"M6 "$1" De "mac_old" para "mac": Skip roam - Current BSS has better signal level",str_saida)
			return mac_old
		}
		
		min_diff = 2;
		if (a[5] < -85)
			min_diff = 1;
		else if (a[5] < -80)
			min_diff = 2;
		else if (a[5] < -75)
			min_diff = 3;
		else if (a[5] < -70)
			min_diff = 4;
		else
			min_diff = 5;

		if (abs(a[5] - b[5]) < min_diff) {
			registra_log(c,"M7 "$1" De "mac_old" para "mac": Skip roam - too small difference in signal level "a[5]" "b[5],str_saida)
			return mac_old
		}
		else {
			registra_log(c,"M8 "$1" FAZ HANDOFF de "mac_old" para "mac": DIFERENCA NO SINAL E MAIOR OU IGUAL "min_diff" "a[5]" "b[5],str_saida)
			return mac
		}

	}
	
	
	function registra_log (n_scan,str_mensagem,str_saida) {
		print n_scan"\t"str_mensagem"\t" >> str_saida
	}

	{
		# primeiro scan define apenas o AP inicial e pula para próximo scan
		if (c==0) {
			c=$8
			
			ap_atual_mac=$3
			# logar associação inicial
			registra_log(c,"M0 "$1" ASSOCIOU-SE INICIALMENTE AO AP "$3,saida)
			c=c+1
			
			next;
		}
		
		# se estou no scan contabilizado ...
		if ($8 == c) {
			
			# escolher pretendente a partir dos resultados de scan guardados para cada scan
			if (bfound == 0) {
				ap_pretendente_info=$0
				bfound=1
				
			}
			# alem disso, procurar o AP atual nos resultados de scan
			if ( ap_atual_mac == $3 ) {
				bfound2=1
				ap_atual_scan=$0
				
			}						
		}
		# se mudou de scan, considerar que scans podem ser pulados
		else if ($8 > c){ 	
			while ($8 != c) {
				# verifica roaming e atualiza ap atual mac
				ap_atual_mac=verifica_handoff(ap_pretendente_info,ap_atual_scan,c,saida)

				# zera bfound1 e 2 e infos dos aps 
				bfound=0
				bfound2=0			
				ap_pretendente_info=""
				ap_atual_scan=""
				c=c+1
			}

			# contabiliza registro atual
			if ( $8 == c) {
				# se não conseguiu se associar a ninguem (está desassociado), associa ao pretendente
				if (ap_atual_mac == "") {
					ap_atual_mac=$3
					# logar associação inicial
					registra_log(c,"M0 ASSOCIOU-SE INICIALMENTE AO AP "$3,saida)
					c=c+1 # pulo este scan								
				}
				else {
					# escolher pretendente a partir dos resultados de scan guardados para cada scan
					if (bfound == 0) {
						ap_pretendente_info=$0
						bfound=1
					}
					# alem disso, procurar o AP atual nos resultados de scan
					if ( ap_atual_mac == $3 ) {
						bfound2=1
						ap_atual_scan=$0
					}						
				}
	 		}		
		}

	}

	END{
		# tratar o último scan
		ap_atual_mac=verifica_handoff(ap_pretendente_info,ap_atual_scan,c,saida)
	}
'

}

function wpa_handoff_function {	
	# version 2.1
	file_scan="$1"
	saida="$2"
	if [ -f $saida ]; then rm $saida; fi
	cat $file_scan | awk -v saida="$saida" 'BEGIN{c=0;bfound=0;bfound2=0;ap_pretendente_info="";ap_atual_scan=""}
	
	function abs(v) {return v < 0 ? -v : v}

	function verifica_handoff(ap_pretendente_info,ap_atual_scan,c,str_saida){
		delete a			
		split(ap_atual_scan,a,"\t")
		delete b			
		split(ap_pretendente_info,b,"\t")
		mac_old=a[3]
		mac=b[3]

		if (ap_atual_scan == "" && ap_pretendente_info == "") {
			registra_log(c,"M1 "$1" DESASSOCIADO POR FALTA DE OPCOES NESTE SCAN. AGUARDAR O PROXIMO",str_saida)
			return ""	
		}
		if (ap_atual_scan == "" ) {
			registra_log(c,"M2 "$1" FEZ HANDOFF PARA "mac" PORQUE NAO ACHOU AP ATUAL NO SCAN",str_saida)
			return mac
		}
		if (ap_pretendente_info == "" ) {
			registra_log(c,"M3 "$1" MANTEVE-SE ASSOCIADO A "mac_old" PORQUE NAO ACHOU AP PRETENDENTE",str_saida)
			return mac_old
		}
		if (a[3] == b[3] ) {
			registra_log(c,"M4 "$1" MANTEVE-SE ASSOCIADO A "mac_old" PORQUE O AP PRETENDENTE E IGUAL AO ATUAL",str_saida)
			return mac_old
		}
		#if (b[7] > a[7] + 5000) {
		#	registra_log(c,"M5 "$1" FAZ HANDOFF de "mac_old" para "mac": Allow reassociation - selected BSS has better estimated throughput "a[5]" "b[5],str_saida)
		#	return mac		
		#}
		if (a[5] > b[5]) {
			registra_log(c,"M6 "$1" De "mac_old" para "mac": Skip roam - Current BSS has better signal level",str_saida)
			return mac_old
		}
		
		min_diff = 2;
		if (a[5] < -85)
			min_diff = 1;
		else if (a[5] < -80)
			min_diff = 2;
		else if (a[5] < -75)
			min_diff = 3;
		else if (a[5] < -70)
			min_diff = 4;
		else
			min_diff = 5;

		if (abs(a[5] - b[5]) < min_diff) {
			registra_log(c,"M7 "$1" De "mac_old" para "mac": Skip roam - too small difference in signal level "a[5]" "b[5],str_saida)
			return mac_old
		}
		else {
			registra_log(c,"M8 "$1" FAZ HANDOFF de "mac_old" para "mac": DIFERENCA NO SINAL E MAIOR QUE "min_diff" "a[5]" "b[5],str_saida)
			return mac
		}

	}
	
	
	function registra_log (n_scan,str_mensagem,str_saida) {
		print n_scan"\t"str_mensagem"\t" >> str_saida
	}

	{
		# primeiro scan define apenas o AP inicial e pula para próximo scan
		if (c==0) {
			c=$8
			
			ap_atual_mac=$3
			# logar associação inicial
			registra_log(c,"M0 "$1" ASSOCIOU-SE INICIALMENTE AO AP "$3,saida)
			c=c+1
			
			next;
		}
		
		# se estou no scan contabilizado ...
		if ($8 == c) {
			
			# escolher pretendente a partir dos resultados de scan guardados para cada scan
			if (bfound == 0) {
				ap_pretendente_info=$0
				bfound=1
				
			}
			# alem disso, procurar o AP atual nos resultados de scan
			if ( ap_atual_mac == $3 ) {
				bfound2=1
				ap_atual_scan=$0
				
			}						
		}
		# se mudou de scan, considerar que scans podem ser pulados
		else if ($8 > c){ 	
			while ($8 != c) {
				# verifica roaming e atualiza ap atual mac
				ap_atual_mac=verifica_handoff(ap_pretendente_info,ap_atual_scan,c,saida)

				# zera bfound1 e 2 e infos dos aps 
				bfound=0
				bfound2=0			
				ap_pretendente_info=""
				ap_atual_scan=""
				c=c+1
			}

			# contabiliza registro atual
			if ( $8 == c) {
				# se não conseguiu se associar a ninguem (está desassociado), associa ao pretendente
				if (ap_atual_mac == "") {
					ap_atual_mac=$3
					# logar associação inicial
					registra_log(c,"M0 ASSOCIOU-SE INICIALMENTE AO AP "$3,saida)
					c=c+1 # pulo este scan								
				}
				else {
					# escolher pretendente a partir dos resultados de scan guardados para cada scan
					if (bfound == 0) {
						ap_pretendente_info=$0
						bfound=1
					}
					# alem disso, procurar o AP atual nos resultados de scan
					if ( ap_atual_mac == $3 ) {
						bfound2=1
						ap_atual_scan=$0
					}						
				}
	 		}		
		}

	}

	END{
		# tratar o último scan
		ap_atual_mac=verifica_handoff(ap_pretendente_info,ap_atual_scan,c,saida)
	}
'

}

wpa_result=""
function wpa_supplicant {
	scan_file_out="saidas/$pcapfile/wpa_sup_offset_"$offset"_scan_file_tratado.dat"
	wpa_result="resultados/$pcapfile/wpa_sup_offset_"$offset"_histerese_on_result.dat"
	if [ ! -d saidas/$pcapfile/ ]; then mkdir -p saidas/$pcapfile/; fi
	if [ ! -d resultados/$pcapfile/ ]; then mkdir -p resultados/$pcapfile/; fi
	scan_wpa "$scan_file_out"
	wpa_handoff_function "$scan_file_out" "$wpa_result"
	gzip -f -9 $scan_file_out
	gzip -f -9 $wpa_result
}

