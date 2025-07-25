#!/bin/bash

if pgrep -x nginx >/dev/null; then
	echo "nginx"
	DIR=$(find /etc/nginx -type f \( -name '*.crt' -o -name '*.key' -o -name '*.pem' -o -iname '*bundle*' \) 2>/dev/null | xargs -r dirname | sort -u)
	if [ -d "$DIR" ]; then
		echo "Diretório encontrado: $DIR" 
		cd "$DIR"
       		for arq in *.crt *.key *bundle*; do
			[ -f "$arq" ] && mv "$arq" "$arq.bak"
		done
		cp /tmp/novo_cert/* "$DIR"
	else
		echo "Diretório não encontrado"
		exit 1
	
	fi

elif pgrep -x httpd >/dev/null || pgrep -x apache2 >/dev/null; then
       	echo "apache"
	DIR=$(find /etc/httpd -type f \( -name '*.crt' -o -name '*.key' -o -name '*.pem' -o -iname '*bundle*' \) 2>/dev/null | xargs -r dirname | sort -u)
	if [ -d "$DIR" ]; then
		echo "Diretório encontrado: $DIR" 
		cd "$DIR"
       		for arq in *.crt *.key *bundle*; do
			[ -f "$arq" ] && mv "$arq" "$arq.bak"
		done
		cp /tmp/novo_cert/* "$DIR"
	else
		echo "Diretório não encontrado"
		exit 1
else
       	echo "Nenhum servidor web detectado."
fi


#busca_cert_web(){

#cert=$(grep certificate "$conf" | grep -vE '_key|_bundle' | awk '{print $2}' | tr -d ';' | head -n 1)


#}

