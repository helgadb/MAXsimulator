function scan_distrnorm {
scan_output="$1"
rajada_output="$2"
rajada_perdas_output="$3"
stats_perdas_output="$4"
if [ -f $scan_output ];then rm $scan_output;fi
if [ -f $scan_output".gz" ];then rm $scan_output".gz";fi
zcat $scan_file".gz" | awk -v output_stats_perdas="$stats_perdas_output" -v output_rajada_perdas="$rajada_perdas_output" -v output_rajada="$rajada_output" -v saida="$scan_output" -v noise="$ruido2GHz" -v max_outliers_consecutivos="$max_outliers_consecutivos" -v nstdev="$nstdev" -v janela="$janela" -v nstdevoutlier="$nstdevoutlier" -v persistencia="$persistencia" 'BEGIN{debug=0;num=0;c=0;delete array_old;delete array_atual;GREAT_SNR=30; delete outliers_array; delete perdas_array; delete rssi_array
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
		array1[i][13]=array2[13]
		array1[i][14]=array2[14]
		array1[i][15]=array2[15]
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
		array1[str][13]=array2[str][13]
		array1[str][14]=array2[str][14]		
		array1[str][15]=array2[str][15]		
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
		sortvalues[j] =  array[key][1] "@" array[key][2] "@" array[key][3] "@" array[key][4] "@" array[key][5] "@" array[key][6] "@" array[key][7] "@" array[key][8] "@" array[key][9] "@" array[key][10] "@" array[key][11] "@" array[key][12] "@" array[key][13] "@" array[key][14] "@" array[key][15]
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
		print array[i][1]"\t"array[i][2]"\t"array[i][3]"\t"array[i][4]"\t"array[i][5]"\t"array[i][6]"\t"array[i][7]"\t"c"\t"array[i][15] >> saidaprint 
	}
}

function compara_array(old,new,persistencia,scanIdx) {
	# compara array atual com old para ver se algum elemento de old pode ser adicionado na lista new.
	# o elemento é adicionado na lista new se "not found idx" na lista old é menor (<) do que a persistencia. Se for >= persistencia, o elemento não é adicionado.
	# ao adicionar, incrementar o "not found idx" na lista atual.
	if (debug == 2) for ( jj in old ) print "OLD "old[jj][3]" scanidx "scanIdx
	if (debug == 2) for ( jj in new ) print "NEW "new[jj][3]" scanidx "scanIdx
	for (key1 in old) {
		if (debug == 2) print "FOR 5 "key1 
		found=0
		for (key2 in new) {
			if (debug == 2) print "FOR 6 "key2" scanidx "scanIdx
			if ( old[key1][3] == new[key2][3] ) {
				found=1	
				verifica_rajada_perdas(1,old[key1][3],scanIdx,old[key1][15])
				break
			}
		}
		if ( found == 0 ) {
			verifica_rajada_perdas(0,old[key1][3],scanIdx,old[key1][15])
			if ( old[key1][9] < persistencia ) {
				copy_array2(new,old,key1)
				new[key1][9]=new[key1][9]+1 # inc not found idx
			}
		}
		
	}
}

function verifica_rajada_perdas (foundIdx,mac,scanIdx,dataRate) {
	if (foundIdx == 0) { # se não achou o AP anterior no scan atual
		# incrementar rajada
		perdas_array[mac][1] = perdas_array[mac][1]+1 # tamanho da rajada
		if ( perdas_array[mac][1] == 1 ) {
			perdas_array[mac][2] = scanIdx # scans idx da rajada separados por ,
		}
		else {
			perdas_array[mac][2] = perdas_array[mac][2]","scanIdx # scans idx da rajada separados por ,
		}
		perdas_array[mac][3] = perdas_array[mac][3]+1 # total de perdidos
		perdas_array[mac][5] = dataRate # taxa de transmissao do beacon
	}
	else { # se achou o AP anterior no scan atual
		if ( perdas_array[mac][1] > 0 ) { # se havia rajada, anotar tamanho e scanIDX. Zerar rajada e scanidx				
			print_perdas(perdas_array,mac)
			perdas_array[mac][1] = 0 # tamanho da rajada
			perdas_array[mac][2] = "" # scans idx da rajada separados por ,
			perdas_array[mac][5] = "" # taxa de transmissao do beacon 
		}
	}
}

function print_perdas(array,mac){
	macsp=gensub(":", "-", "g", mac)
	print array[mac][1]"\t"array[mac][2]"\t"array[mac][5] >> output_rajada_perdas"_"macsp"_.dat"	
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

function calcula_media(lista_de_amostras,win) {
	delete amostras
	split(lista_de_amostras,amostras,"#")
	if ( win != -1)	p=length(amostras)-win
	else if (win == -1) p=0
	somatorio=0
	samples=0
	for (i=length(amostras); (i > p && i > 0) ; i--){
		if (debug == 2) print "FOR 7"
		somatorio = somatorio + amostras[i]
		samples=samples+1
		if (debug == 1) print "amostra: "amostras[i]" somatorio: "somatorio" samples: "samples
	}
	if (debug == 1) print "somatorio: "somatorio
	unew = somatorio/samples
	if (debug == 1) print "nova media: " unew
	return unew
}

function calcula_desvio(lista_de_amostras,media,win) {
	delete amostras
	split(lista_de_amostras,amostras,"#")
	if ( win != -1)	p=length(amostras)-win
	else if (win == -1) p=0
	somatorio=0
	samples=0
	if (length(amostras) > 1){
		for (i=length(amostras); (i > p && i > 0) ; i--) {
			if (debug == 2) print "FOR 8"
			somatorio = somatorio + ((amostras[i]-media)^2)
			samples=samples+1
		}
		snew=sqrt(somatorio/(samples-1))
		if (debug == 1) print "Novo desvio: "snew
		return snew
	}
	else { 
		print "Erro no calculo do desvio: "lista_de_amostras","media; 
		return 0
	}
}

function teste_normal(media,amostra_atual,desv_pad,num_amostras,nstdev,nstdevoutlier,win) {
	if (debug == 1) print "Num amostras "num_amostras
	if ( num_amostras < win ) { # preencher a janela
		return 3
	}
	if (debug == 1) print "media = "media" desvio = "desv_pad
	if (desv_pad == 0) {  # pode ocorrer de todas as amostras na janela terem o mesmo valor
		if (debug == 1) print "Gambiarra: "media","amostra_atual","desv_pad","num_amostras","nstdev","nstdevoutlier","win","lista_de_amostras
		desv_pad=2	
	}
	rcop = desv_pad*nstdevoutlier
	rcon = (-1)*rcop
	rcp = desv_pad*nstdev
	rcn = (-1)*rcp
	if (debug == 1) print "rcp = "rcp" rcn = "rcn" rcop = "rcop" rcon = "rcon
	if (amostra_atual < media+rcon || amostra_atual > media+rcop ){ 
			return 2   #outlier
	}
	else if (amostra_atual < media+rcn || amostra_atual > media+rcp ) {
		return 0 # não passou no teste
	}
	return 1 # passou no teste, amostra pertence à distribuição atual
}

function verifica_rajada_outlier(mac,scan_idx,media,desvio,rssi) {
	# verificar a cada scan se houve outlier. Contar quantos outliers consecutivos ocorreram. Anotar as rajadas. 
	# Zerar contador se em um scan não houver outlier. Guarda tamanho da rajada  media  desvio  outliers separados por "," e scan IDX do último outlier
	
	if ( scan_idx == outliers_array[mac][5] ) { # se o outlier foi encontrado no mesmo scan que o anterior, substituo o último por este novo
		split(outliers_array[mac][4],new_outl_array,"#")
		for (i in new_outl_array) {
			if (debug == 2) print "FOR 9"
			if (i == "1" && i == length(new_outl_array) ) {
				outliers_array[mac][4]=rssi
			}
			else {
				if (i =="1" && i != length(new_outl_array)) {
					outliers_array[mac][4]=new_outl_array[i]
				}
				else {
					outliers_array[mac][4]=outliers_array[mac][4]"#"new_outl_array[i]
				}
			}
		}
		if (length(new_outl_array) != "1") {
			outliers_array[mac][4]=outliers_array[mac][4]"#"rssi
		}
	}
	else {
		if ( scan_idx == outliers_array[mac][5] + 1 || outliers_array[mac][5] == "") { 
			# se o outlier ocorreu no scan consecutivo ao no qual ocorreu o outlier anterior ou é o primeiro da rajada
			outliers_array[mac][1]= outliers_array[mac][1]+1 # tamanho da rajada
			outliers_array[mac][2]= media # media
			outliers_array[mac][3]= desvio # desvio
			if (outliers_array[mac][5] == ""){
				outliers_array[mac][4]= rssi # rajada de outliers separados por #
			}		
			else{
				outliers_array[mac][4]= outliers_array[mac][4]","rssi # rajada de outliers separados por #
			}
			outliers_array[mac][5]= scan_idx # scan IDX anterior
		}
		else { # se houve uma quebra na consecutividade dos outliers, guardo a anterior e começo uma nova rajada.
			print_rajada(outliers_array,mac)
			outliers_array[mac][1]= 1 # tamanho da rajada
			outliers_array[mac][2]= media # media
			outliers_array[mac][3]= desvio # desvio
			outliers_array[mac][4]= rssi # rajada de outliers separados por #
			outliers_array[mac][5]= scan_idx # scan IDX anterior
		}
	}
}

function print_rajada(array,mac){
	macsp=gensub(":", "-", "g", mac)
	print array[mac][1]"\t"array[mac][2]"\t"array[mac][3]"\t"array[mac][4]"\t"array[mac][5] >> output_rajada"_"macsp"_.dat"	
}

function update_array_atual(mac) {
	mfound=0
	for (i in array_old) {
		if (debug == 2) print "FOR 10"
		if ( array_old[i][3] == mac ) { #atualiza
			mfound=1
			array_atual[mac][1]=$1  #timestamp
			array_atual[mac][2]=$2  #frame subtype
			array_atual[mac][3]=$3  #mac_src (AP) 
			array_atual[mac][4]=$4  #mac_dst
			array_atual[mac][8]=$8  #scan number
			array_atual[mac][9]=0   # not found idx
			array_atual[mac][15]=$9   # beacon dataRate
		
			# faz o teste para saber se o valor esta ou nao dentro da distribuicao
			if (debug == 1) print "Ínicio Teste "mac
			resteste=teste_normal(array_old[mac][5],$5,array_old[mac][11],array_old[mac][12],nstdev,nstdevoutlier,janela)
			if (resteste == 1) { # passou no teste, a média não será atualizada, mas a amostra será guardada.
				if (debug == 1) print mac" scan idx: "$8" Passou no teste - media antiga: "array_old[mac][5]", amostra atual: "$5", desvio antigo: "array_old[mac][11]", rssis recebidas antigas: "array_old[mac][10]
				array_atual[mac][12]=array_old[mac][12]+1   # numero de amostras
				array_atual[mac][5]=array_old[mac][5]	# RSSI media considerando passado
				array_atual[mac][10]=array_old[mac][10]"#"$5  #RSSIs recebidas separadas por #
				array_atual[mac][11]=array_old[mac][11]  # desvio			
				array_atual[mac][13]=0   # found outliers idx (0 se passou no teste,  +1 se achou outlier)
				array_atual[mac][6]=array_old[mac][6] #SNR
				array_atual[mac][7]=array_old[mac][7] #Rate
				array_atual[mac][14]=array_old[mac][14]  #RSSIs OUTLIERs recebidos separadas por #
				array_atual[mac][15]=array_old[mac][15]  # beacon dataRate
			}
			else if (resteste == 0 || resteste == 3) { # nao passou no teste, a média é atualizada com base na janela de amostras guardadas , ou preenchendo janela inicial
				if (resteste == 3) { 
					if (debug == 1) print "preencher janela"
					if (debug == 1) print mac " scan idx: "$8" media antiga: "array_old[mac][5]", amostra atual: "$5", desvio antigo: "array_old[mac][11]", rssis recebidas antigas: "array_old[mac][10]
				}
				else {
					if (debug == 1) print mac " INICIANDO NOVA MEDIA scan idx: "$8 
					if (debug == 1) print mac " scan idx: "$8" Não passou no teste - media antiga: "array_old[mac][5]", amostra atual: "$5", desvio antigo: "array_old[mac][11]", rssis recebidas antigas: "array_old[mac][10]	
				}		
				array_atual[mac][13]=0   # found outliers idx (0 se passou no teste,  +1 se achou outlier)
				array_atual[mac][12]=array_old[mac][12]+1   # numero de amostras
				array_atual[mac][10]=array_old[mac][10]"#"$5	# RSSIs recebidas separadas por # 
				array_atual[mac][5]=calcula_media(array_atual[mac][10],janela)  # RSSI media considerando amostras antigas na janela + a atual
				array_atual[mac][11]=calcula_desvio(array_atual[mac][10],array_atual[mac][5],janela)   # desvio
				array_atual[mac][6]=calcula_snr(array_atual[mac][5],noise) #SNR
				array_atual[mac][7]=calcula_vazao_estimada(array_atual[mac][5],noise)  #Rate	
				array_atual[mac][14]=array_old[mac][14]  #RSSIs OUTLIERs recebidos separadas por #			
				array_atual[mac][15]=array_old[mac][15]  # beacon dataRate			

			}
			else { # Outlier. Verificar se houve mudança brusca de sinal
				if (debug == 1) print "OUTLIER"
				verifica_rajada_outlier(mac,$8,array_old[mac][5],array_old[mac][11],$5)				
				if (debug == 1) print mac " scan idx: "$8" media antiga: "array_old[mac][5]", amostra atual: "$5", desvio antigo: "array_old[mac][11]", rssis recebidas antigas: "array_old[mac][10]", outliers recebidos antigos: "array_old[mac][14]
				if ( array_old[mac][14] == "" )  array_atual[mac][14]=$5
				else array_atual[mac][14]=array_old[mac][14]"#"$5  #RSSIs OUTLIERs recebidos separadas por #
				array_atual[mac][13]=array_old[mac][13]+1 #(0 se passou no teste,  +1 se achou outlier)
				array_atual[mac][15]=array_old[mac][15] # beacon dataRate
				if (array_atual[mac][13] >= max_outliers_consecutivos) { # inicio uma nova média considerando outliers antigos
					if (debug == 1) print mac " INICIANDO NOVA MEDIA COM OUTLIERS scan idx: "$8 
					array_atual[mac][12]=1   # numero de amostras
					array_atual[mac][13]=0   # found outliers idx
					array_atual[mac][10]=array_atual[mac][14] # RSSIs recebidas separadas por # 
					array_atual[mac][5]=calcula_media(array_atual[mac][10],max_outliers_consecutivos)  # RSSI media considerando passado
					array_atual[mac][11]=calcula_desvio(array_atual[mac][10],array_atual[mac][5],max_outliers_consecutivos)   # desvio
					array_atual[mac][6]=calcula_snr(array_atual[mac][5],noise) #SNR
					array_atual[mac][7]=calcula_vazao_estimada(array_atual[mac][5],noise)  #Rate	
				}
				else {
					array_atual[mac][12]=array_old[mac][12]   # numero de amostras
					array_atual[mac][5]=array_old[mac][5]	# RSSI media considerando passado
					array_atual[mac][10]=array_old[mac][10]  #RSSIs recebidas separadas por #
					array_atual[mac][11]=array_old[mac][11]   # desvio			
					array_atual[mac][6]=array_old[mac][6]  #SNR
					array_atual[mac][7]=array_old[mac][7]  #Rate					
				}
			}
			
			break
		}
	}
	if ( mfound == 0 ) { # insere
		array_atual[mac][1]=$1  #timestamp
		array_atual[mac][2]=$2  #frame subtype
		array_atual[mac][3]=$3  #mac_src (AP) 
		array_atual[mac][4]=$4  #mac_dst
		array_atual[mac][5]=$5  #RSSI media considerando passado
		array_atual[mac][6]=$6  #SNR
		array_atual[mac][7]=$7  #Rate
		array_atual[mac][8]=$8  #scan number
		array_atual[mac][9]=0   # not found idx
		array_atual[mac][10]=$5	# RSSIs recebidas separadas por # 
		array_atual[mac][11]=0   # desvio
		array_atual[mac][12]=1   # numero de amostras
		array_atual[mac][13]=0   # found outliers idx
		array_atual[mac][15]=$9   # becon dataRate 
	}
}

{
	# guardar amostras para calculo da media e desvio de RSSI da captura inteira 
	if (length(rssi_array[$3]) != 0) rssi_array[$3]=rssi_array[$3]"#"$5
	else {
		rssi_array[$3]=$5
		perdas_array[$3][4]=$8 # indice de scan no qual o AP apareceu pela primeira
	}
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
				compara_array(array_old,array_atual,persistencia,c)
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
		compara_array(array_old,array_atual,persistencia,c)
	}
	# imprime estatísticas sobre perdas de beacons
	for (m in perdas_array) {
		if (debug == 2) { print "FOR 12" }
		if (c != 0){
			stat=(perdas_array[m][3]*100)/(c+1)
			stat2=(perdas_array[m][3]*100)/(c+1-perdas_array[m][4])
		}
		else { stat = "-" }
		i = m
		if (length(rssi_array[i]) > 1) {	
			amostrasrssi=rssi_array[i]
			media=calcula_media(amostrasrssi,-1)
			desvio=calcula_desvio(amostrasrssi,media,-1)
		}
		else { media=-1;desvio=-1}
		print m"\t"c+1"\t"perdas_array[m][3]"\t"stat"\t"media"\t"desvio"\t"perdas_array[m][4]"\t"stat2"\t"perdas_array[m][5] >>  output_stats_perdas"_.dat"
	}
	
	# imprime array atual no arquivo
	sort_scan(array_atual,array_ordenado)
	print_array(array_ordenado,c,saida)

	# imprime estatisticas de rajadas de outliers das ultimas entradas
	for ( i in outliers_array ) {	
		print_rajada(outliers_array,i)
	}
}' 
}

distrnorm_result=""
function distribuicao_normal {
	nstdev="$1" # multiplicador do desvio padrao
	nstdevoutlier="$2"
	janela="$3"
	max_outliers_consecutivos="$4" # TODO: verificar quantos outliers comumente consecutivos eu encontro. Acredito que seja um.
	
	scan_file_out="saidas/$pcapfile/distrnorm_"$nstdev"_"$nstdevoutlier"_"$janela"_"$max_outliers_consecutivos"_offset_"$offset"_scan_file_tratado.dat"
	
	rajada_outliers_stats_file_out="estatisticas/$pcapfile/rajadas_outliers_scanint_"$scan_interval"_maxcht_"$MaxChannelTime"_ofset_"$offset"_mult_dvpad_"$nstdev"_mult_dvpad_outlier_"$nstdevoutlier"_janela_"$janela"_persist_"$persistencia"_max_outl_consec_"$max_outliers_consecutivos
	rajada_perdas_stats_file_out="estatisticas/$pcapfile/rajadas_perdas_scanint_"$scan_interval"_maxcht_"$MaxChannelTime"_ofset_"$offset"_mult_dvpad_"$nstdev"_mult_dvpad_outlier_"$nstdevoutlier"_janela_"$janela"_persist_"$persistencia"_max_outl_consec_"$max_outliers_consecutivos
	perdas_stats_file_out="estatisticas/$pcapfile/stats_perdas_scanint_"$scan_interval"_maxcht_"$MaxChannelTime"_ofset_"$offset"_mult_dvpad_"$nstdev"_mult_dvpad_outlier_"$nstdevoutlier"_janela_"$janela"_persist_"$persistencia"_max_outl_consec_"$max_outliers_consecutivos

	if [ ! -d saidas/$pcapfile/ ]; then mkdir -p saidas/$pcapfile/; fi
	if [ ! -d resultados/$pcapfile/ ]; then mkdir -p resultados/$pcapfile/; fi
	if [ ! -d estatisticas/$pcapfile/ ]; then mkdir -p estatisticas/$pcapfile/; else rm estatisticas/$pcapfile/*; fi
	
	scan_distrnorm "$scan_file_out" "$rajada_outliers_stats_file_out" "$rajada_perdas_stats_file_out" "$perdas_stats_file_out"
	
	bhisterese="on"
	distrnorm_result="resultados/$pcapfile/distrnorm_"$nstdev"_"$nstdevoutlier"_"$janela"_"$max_outliers_consecutivos"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	wpa_handoff_function "$scan_file_out" "$distrnorm_result"
	gzip -f -9 $distrnorm_result
	
	bhisterese="off"
	distrnorm_result="resultados/$pcapfile/distrnorm_"$nstdev"_"$nstdevoutlier"_"$janela"_"$max_outliers_consecutivos"_offset_"$offset"_histerese_"$bhisterese"_result.dat"
	another_handoff_function "$scan_file_out" "$distrnorm_result"
	gzip -f -9 $distrnorm_result

	gzip -f -9 $scan_file_out
	gzip -f -9 $rajada_outliers_stats_file_out*
	gzip -f -9 $rajada_perdas_stats_file_out*
	gzip -f -9 $perdas_stats_file_out*
}
