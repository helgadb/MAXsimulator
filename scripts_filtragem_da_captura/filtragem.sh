# função que filtra o arquivo de captura para que as informações de beacons sejam salvas em rssi_file
function filtra_captura {
	if [ -f $rssi_file ]; then rm $rssi_file; fi
	if [ -f $rssi_file".gz" ]; then rm $rssi_file".gz"; fi
	string="(wlan.fc.type_subtype == $subtype "
	if [ ${#macs_para_filtrar[@]} -gt 0 ]
	then
		for mac in "${macs_para_filtrar[@]}"
		do
		# se so tem um elemento ...
		if [ ${#macs_para_filtrar[@]} -eq 1 ]
		then	
			string=$string"&& (wlan.ta == "$mac") "
		# se o elemento atual for o ultimo ...
		else if [ "$mac" == "${macs_para_filtrar[-1]}" ]
			then
			string=$string"wlan.ta == "$mac") "		
			# se for o primeiro ...
			else if [ "$mac" == "${macs_para_filtrar[0]}" ]
				then
					string=$string" && (wlan.ta == "$mac" || "
				else
					string=$string"wlan.ta == "$mac" || "
				fi
			fi
		fi
		done
	fi
	string=$string")"

	# receber como entrada .cap
	# saida do filtro: "epoch_time typeSubtype sourcemac destmac rssi"
	tshark -2 -R "$string" -r "$pcapfiledir" -Tfields -e frame.time_epoch -e wlan.fc.type_subtype -e wlan.sa -e wlan.da -e radiotap.dbm_antsignal -e radiotap.datarate > "$rssi_file"
	gzip -f -9 $rssi_file
}

