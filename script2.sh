#!/bin/bash

if pgrep -a nginx >/dev/null; then
    echo "NGINX"
    DIRS=$(sudo find /etc/nginx -type f \( -name '*.crt' -o -name '*.key' -o -name '*.pem' -o -iname '*bundle*' \) 2>/dev/null | xargs -r dirname | sort -u)
	echo "$DIRS"
    DIR_CONT=$(echo "$DIRS" | wc -l)
	echo "$DIR_CONT"
    	
    if [ "$DIR_CONT" -eq 0 ]; then
        echo "Nenhum diretório com certificados encontrado."
        exit 1
    elif [ "$DIR_CONT" -gt 1 ]; then
        echo "Mais de um diretório encontrado com certificados:"
        echo "$DIRS"
        echo "Cancelando execução do script"
        exit 1
    else
        echo "Diretório encontrado: $DIRS"
        cd "$DIRS" || exit 1
        for arq in *.crt; do
            [ -f "$arq" ] && mv "$arq" "$arq.bak2"
            echo "Backup realizado"
            novo=$(find /tmp/novo_cert -maxdepth 1 -type f \( -iname '*.crt' \) | head -n 1)
            if [ -n "$novo" ]; then
                echo "Copiando novo arquivo $novo para $DIRS como  $arq"
                cp "$novo" "$arq"
                rm "$novo"
            else
                echo "Nenhum novo arquivo disponível para substituir $arq"
            fi
        done
	    for arq in *.key; do
            [ -f "$arq" ] && mv "$arq" "$arq.bak2"
            echo "Backup realizado"
            novo=$(find /tmp/novo_cert -maxdepth 1 -type f \( -iname '*.key' \) | head -n 1)
            if [ -n "$novo" ]; then
                echo "Copiando novo arquivo $novo para $DIRS como  $arq"
                cp "$novo" "$arq"
                rm "$novo"
            else
                echo "Nenhum novo arquivo disponível para substituir $arq"
            fi
        done
        for arq in ufpe*.pem; do
            [ -f "$arq" ] || continue
            mv "$arq" "$arq.bak2"
            echo "Backup realizado"
            novo=$(find /tmp/novo_cert -maxdepth 1 -type f -iname '*.pem' | head -n 1)
            if [ -n "$novo" ]; then
                echo "Copiando novo arquivo $novo para $DIRS como $arq"
                cp "$novo" "$arq"
                rm "$novo"
            else
                echo "Nenhum novo arquivo disponível para substituir $arq"
            fi
        done
        if sudo nginx -t; then
            echo "Configuração válida. Reiniciando serviço."
            sudo systemctl restart nginx
            echo "Serviço reiniciado com sucesso."
        else
            echo "Erro na checagem, verifique as configurações."
            exit 1
        fi
    fi

elif pgrep -a httpd >/dev/null || pgrep -a apache2 >/dev/null; then
    echo "APACHE/HTTPD"
    DIRS=$(sudo find /etc/httpd /etc/apache2 -type f \( -name '*.crt' -o -name '*.key' -o -name '*.pem' \) 2>/dev/null | xargs -r dirname | sort -u)
	echo "$DIRS"
    DIR_CONT=$(echo "$DIRS" | wc -l)
	echo "$DIR_CONT"

    if [ "$DIR_CONT" -eq 0 ]; then
        echo "Nenhum diretório com certificados encontrado."
        exit 1
    elif [ "$DIR_CONT" -gt 1 ]; then
        echo "Mais de um diretório encontrado com certificados:"
        echo "$DIRS"
        echo "Cancelando execução do script"
        exit 1
    else
        echo "Diretório encontrado: $DIRS"
        cd "$DIRS" || exit 1
        for arq in *.crt; do
            [ -f "$arq" ] && mv "$arq" "$arq.bak2"
            echo "backup realizado"
            novo=$(find /tmp/novo_cert -maxdepth 1 -type f \( -iname '*.crt' \) | head -n 1)
            if [ -n "$novo" ]; then
                echo "Copiando novo arquivo $novo para $DIRS como  $arq"
                cp "$novo" "$arq"
                rm "$novo"
            else
                echo "Nenhum novo arquivo disponível para substituir $arq"
            fi
        done
	    for arq in *.key; do
            [ -f "$arq" ] && mv "$arq" "$arq.bak2"
            echo "backup realizado"
            novo=$(find /tmp/novo_cert -maxdepth 1 -type f \( -iname '*.key' \) | head -n 1)
            if [ -n "$novo" ]; then
                echo "Copiando novo arquivo $novo para $DIRS como  $arq"
                cp "$novo" "$arq"
                rm "$novo"
            else
                echo "Nenhum novo arquivo disponível para substituir $arq"
            fi
        done
	
        if sudo httpd -t || apachectl -t; then
            echo "Configuração válida. Reiniciando serviço."
            sudo systemctl restart httpd || sudo systemctl restart apache2 || sudo httpd -k restart || sudo apachectl restart
            echo "Serviço reiniciado com sucesso."
        else
            echo "Erro na checagem, verifique as configurações."
            exit 1
        fi
    fi

else
    echo "Nenhum servidor web detectado."
fi