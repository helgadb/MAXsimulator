# margem de histerese desligada
function another_handoff_function {
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
		
		if ( b[5] <= a[5] ) {
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
