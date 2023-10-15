#!/bin/bash

#-------------------------------------------#
#  Trabalho realizado por:                  #
#                                           #
#  Danilo Micael Gregório Silva    n113384  #
#  Tomás Santos Fernandos          n______  #
#-------------------------------------------#


#------------------------------------------------------------------------------#

# Funções a serem usadas no script:

function is_dir() {
	if [ -d "$1" ]; then
		return 0 # o diretório existe
	else
		return 1 # o diretório não existe
	fi
}


function is_date() {
	if date -d "$1" &>/dev/null; then # ao usar &>/dev/null são redirecionados
					  # os erros para não serem exibidos
		return 0 # data válida
	else
		return 1 # data inválida
	fi
}


function is_integer_positive() {
	if [[ $1 =~ ^[0-9]+$ ]]; then
		return 0 # é inteiro positivo (inclui 0)
	else
		return 1 # não é inteiro positivo
	fi
}


#------------------------------------------------------------------------------#


# Primeiro passo: armazenar todos os argumentos passados ao executar o script

# Opções possíveis de serem fornecidas ao executar o script:

option_n=false # nome para seleção dos ficheiros
option_d=false # data máxima de modificação dos ficheiros
option_s=false # tamanho mínimo do ficheiro
option_r=false # ordenar por ordem inversa (tamanho)
option_a=false # ordenar por nome
option_l=false # limitar número de linhas da tabela


# Valores correspondestes às opções fornecidas:

file_pattern="" # opção -n
date=""         # opção -d
size=""         # opção -s
limit=""        # opção -l
directories=()  # diretoria(s) a serem monitorizadas


# Processamento dos argumentos:

# é usado um ciclo while para percorrer todos os argumentos: o argumento que 
# está a ser analisado é $1 e a cada iteração o comando 'shift' desloca a 
# linha de argumentos para que o próximo seja o novo $1 até que o número de
# argumentos restantes seja 0

while [[ $# -gt 0 ]]; do
	
	case "$1" in
		-n)
			option_n=true
			
			# necessário testar o $2
			file_pattern="$2"
			shift
			;;
		-d)
			option_d=true
			
			# verificar se $2 é uma data
			if is_date "$2"; then
				echo "data válida"
				date="$2"
			else
				echo "data inválida"
			fi
			
			shift
			;;
		-s)
			option_s=true
			
			# verificar se $2 é número inteiro positivo (tamanho min)
			if is_integer_positive "$2"; then
				size="$2"
			else
				echo "o número introduzido para size não é >= 0"
			fi
			
			shift
			;;
		-r)
			option_r=true
			;;
		-a)
			option_a=true
			;;
		-l)
			option_l=true
			
			# verificar se $2 é número inteiro positivo maior que 0 (n linhas)
			if is_integer_positive "$2" && [ "$2" -gt 0 ]; then
				limit="$2"
			else
				echo "o número introduzido para limit não é > 0"
			fi
			
			shift
			;;
		*)
			if is_dir "$1"; then
				directories+=("$1")
			else
				echo "diretório inválido"
			fi
			;;
	esac
	shift
done

# as seguintes linhas são usadas apenas para testar se os argumentos foram armazenados
# tirar posteriormente **

if [ "$option_n" = true ]; then
	echo "option_n -> true"
	echo "file_pattern: $file_pattern"
else
	echo "option_n -> false"
fi

if [ "$option_d" = true ]; then
	echo "option_d -> true"
	echo "date: $date"
else
	echo "option_d -> false"
fi

if [ "$option_s" = true ]; then
	echo "option_s -> true"
	echo "size: $size"
else
	echo "option_s -> false"
fi

if [ "$option_r" = true ]; then
	echo "option_r -> true"
else
	echo "option_r -> false"
fi

if [ "$option_a" = true ]; then
	echo "option_a -> true"
else
	echo "option_a -> false"
fi

if [ "$option_l" = true ]; then
	echo "option_l -> true"
	echo "limit: $limit"
else
	echo "option_l -> false"
fi

echo "diretorios: ${directories[@]}"

#------------------------------------------------------------------------------------#



