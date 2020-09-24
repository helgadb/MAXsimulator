function scan_maximo {
scan_output="$1"
if [ -f $scan_output ];then rm $scan_output;fi
if [ -f $scan_output".gz" ];then rm $scan_output".gz";fi

zcat $scan_file".gz" | awk -v saida="$scan_output" -v noise="$ruido2GHz" -v janela="$janela" -v persistencia="$persistencia" 'BEGIN{debug=0;num=0;c=0;delete array_old;delete array_atual;GREAT_SNR=30;
}

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
		array1[i][10]=array2[10]
		array1[i][11]=array2[11]
		array1[i][12]=array2[12]
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
		array1[str][10]=array2[str][10]
		array1[str][11]=array2[str][11]
		array1[str][12]=array2[str][12]				
}

function qsort(A, left, right) {
  if (left >= right)
    return
  swap(A, left, left+int((right-left+1)*rand()))
  last = left
  for (i = left+1; i <= right; i++) {
    if (debug == 2) print "FOR 1"
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
	split(a,values_a,"@")
	split(b,values_b,"@")
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
		if (debug == 2) print "FOR 2"
		sortvalues[j] =  array[key][1] "@" array[key][2] "@" array[key][3] "@" array[key][4] "@" array[key][5] "@" array[key][6] "@" array[key][7] "@" array[key][8] "@" array[key][9] "@" array[key][10] "@" array[key][11] "@" array[key][12]
		#print sortvalues[j]
		j=j+1
	}
	
	qsort(sortvalues, 1, length(array));

	delete array_ordenado
	delete sort_a

	for (i = 1; i <= length(array); i++) {
		if (debug == 2) print "FOR 3"
		split(sortvalues[i],sort_a,"@")
		copy_array1(array_ordenado,sort_a,i)		
	}
}

function print_array(array,c,saidaprint) {
	for (i=1;i in array;i++) {
		if (debug == 2) print "FOR 4"
		print array[i][1]"\t"array[i][2]"\t"array[i][3]"\t"array[i][4]"\t"array[i][5]"\t"array[i][6]"\t"array[i][7]"\t"c"\t"array[i][12] >> saidaprint 
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
function calcula_snr(level,noise) {
	msnr = level - noise
	return msnr
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

function calcula_maximo(lista_de_amostras,win) {
	delete amostras
	delete amostras_janela
	if (debug == 1) print "amostras: "lista_de_amostras
	split(lista_de_amostras,amostras,"#")
	# se a janela nao foi preenchida ainda, retorna a maximo das ultimas amostras
	if (length(amostras) < win) win=length(amostras)
	if ( win != -1)	p=length(amostras)-win
	else if (win == -1) p=0
	j=1
	for (i=length(amostras); (i > p && i > 0) ; i--){
		if (debug == 2) print "FOR 7"
		amostras_janela[j]=amostras[i]
		j=j+1
		if (debug == 1) print "amostra: "amostras[i]" j: "j
	}
	# ordenar em ordem crescente
	length_amostras_janela=asort(amostras_janela)
	unew=amostras_janela[length_amostras_janela]
	if (debug == 1) print "win: "win" novo maximo: " unew
	return unew
}


function update_array_atual(mac) {
	# atualiza ou insere informação no array atual	
	mfound=0
	for (i in array_old) {
		if (debug == 2) print "FOR 10"
		if ( array_old[i][3] == mac ) { #atualiza
			mfound=1
			array_atual[mac][1]=$1  #timestamp
			array_atual[mac][2]=$2  #frame subtype
			array_atual[mac][3]=$3  #mac_src (AP) 
			array_atual[mac][4]=$4  #mac_dst
			array_atual[mac][10]=array_old[mac][10]"#"$5	# RSSIs recebidas separadas por #
			array_atual[mac][5]=calcula_maximo(array_atual[mac][10],janela)  # RSSI maximo considerando amostras antigas na janela + a atual
			array_atual[mac][6]=calcula_snr(array_atual[mac][5],noise) #SNR
			array_atual[mac][7]=calcula_vazao_estimada(array_atual[mac][5],noise)  #Rate	
			array_atual[mac][8]=$8  #scan number
			array_atual[mac][9]=0   # not found idx 
			array_atual[mac][11]=array_old[mac][11]+1   # numero de amostras
			array_atual[mac][12]=$9   # beacon dataRate
			
			break
		}
	}
	if ( mfound == 0 ) { # insere
		array_atual[mac][1]=$1  #timestamp
		array_atual[mac][2]=$2  #frame subtype
		array_atual[mac][3]=$3  #mac_src (AP) 
		array_atual[mac][4]=$4  #mac_dst
		array_atual[mac][10]=$5	# RSSIs recebidas separadas por #
		array_atual[mac][5]=calcula_maximo(array_atual[mac][10],janela)  # RSSI maximo considerando amostras antigas na janela + a atual
		array_atual[mac][6]=$6  #SNR
		array_atual[mac][7]=$7  #Rate
		array_atual[mac][8]=$8  #scan number
		array_atual[mac][9]=0   # not found idx
		array_atual[mac][11]=1   # numero de amostras
		array_atual[mac][12]=$9   # becon dataRate 
	}
}

{
	# se estou no scan contabilizado ...
	if ($8 == c) {
		# atualiza ou insere informação no array atual
		update_array_atual($3)		
	}
	# se mudou de scan
	else {
		while ($8 != c) {
			if (debug == 2) print "$8 " $8 " c "c
			# se resultados antigos de scan existem, vou verificar se algum expirou ou se posso utilizar
			if (length(array_old) > 0) {
				compara_array(array_old,array_atual,persistencia)
			}
			# organiza array e salva em array_ordenado
			sort_scan(array_atual,array_ordenado)
			# imprime array atual no arquivo				
			print_array(array_ordenado,c,saida)
			c=c+1
			# copiar array_atual para array_old
			delete array_old
			for (key in array_atual) {
				if (debug == 2) print "FOR 11"
				copy_array2(array_old,array_atual,key)
			}

			# reinicializa array atual
			delete array_atual
		}		
		# tratar a entrada atual
		if ($8 == c) {
			# atualiza ou insere informação no array atual
			update_array_atual($3)
		}
					
	}
}
END {
	# tratanto o ultimo registro
	if (length(array_old) > 0) {
		compara_array(array_old,array_atual,persistencia)
	}
	
	# imprime array atual no arquivo
	sort_scan(array_atual,array_ordenado)
	print_array(array_ordenado,c,saida)

}' 
}

maximo_result=""
function maximo {
	janela="$1"
	scan_file_out="saidas/$pcapfile/maximo_"$janela"_offset_"$offset"_scan_file_tratado.dat"
	if [ ! -d saidas/$pcapfile/ ]; then mkdir -p saidas/$pcapfile/; fi
	if [ ! -d resultados/$pcapfile/ ]; then mkdir -p resultados/$pcapfile/; fi
	scan_maximo "$scan_file_out"

	bhisterese="on"
	maximo_result="resultados/$pcapfile/maximo_"$janela"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	wpa_handoff_function "$scan_file_out" "$maximo_result"
	gzip -f -9 $maximo_result

	bhisterese="off"
	maximo_result="resultados/$pcapfile/maximo_"$janela"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	another_handoff_function "$scan_file_out" "$maximo_result"
	gzip -f -9 $maximo_result

	gzip -f -9 $scan_file_out
}
