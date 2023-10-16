#!/bin/bash

#-------------------------------------------#
#  Trabalho realizado por:                  #
#                                           #
#  Danilo Micael Gregório Silva   n 113384  #
#  Tomás Santos Fernandos         n 112981  #
#-------------------------------------------#


#------------------------------------------------------------------------------#

# Funções a serem usadas no script:

# Verificar se o argumento existe como ficheiro ou diretório             
function exists() {
	if [ -e "$1" ]; then
		return 0 # 0 se o diretório ou ficheiro existe
	else
		return 1 # 1 se o diretório ou ficheiro não existe
	fi
}


# Verificar se o argumento é um ficheiro válido              		 
function is_file() {
	if [ -f "$1" ]; then
		return 0 # 0 se é ficheiro 
	else
		return 1 # 1 se não é ficheiro 
	fi
}


# Verificar se o argumento é um diretório válido
function is_dir() {
	if [ -d "$1" ]; then
		return 0 # 0 se é diretório 
	else
		return 1 # 1 se não é diretório 
	fi
}


# Verificar se o argumento é uma data válida
function is_date() {
	if date -d "$1" &>/dev/null; then # ao usar &>/dev/null os erros 
 					  # são redirecionados para não 
					  # erem exibidos
		return 0 # 0 se é uma data válida					 
	else
		return 1 # 1 se é uma data inválida
	fi
}


# Veriificar se o argumento é inteiro >=0
function is_integer_positive() {
	if [[ $1 =~ ^[0-9]+$ ]]; then
		return 0 # 0 se é inteiro positivo (inclui 0)
	else
		return 1 # 1 se não é inteiro positivo
	fi
}


#------------------------------------------------------------------------------#


# Passo 1: armazenar todos os argumentos passados ao executar o script

# Opções possíveis de serem fornecidas como argumento para definir a seleção 
# de ficheiros desejados ao executar o script:

option_n=false # expressão regular para filtrar nome dos ficheiros
option_d=false # data máxima de modificação dos ficheiros
option_s=false # tamanho mínimo do ficheiro
option_r=false # ordenar por ordem inversa (ou seja, pela ordem correta do tamanho)
option_a=false # ordenar por nome
option_l=false # limitar o número de linhas da tabela


# Valores passado pelo user correspondentes às opções fornecidas:

file_pattern="" # opção -n (variável)
date=""         # opção -d (variável)
size=""         # opção -s (variável)
limit=""        # opção -l (variável)
directories=()  # diretoria(s) a serem monitorizadas (array)


# Processamento dos argumentos:

# É usado um ciclo while para percorrer todos os argumentos: o argumento que 
# está a ser analisado é '$1', e a cada iteração o comando 'shift' desloca a     
# linha de argumentos para que o próximo seja o novo $1 até que o número de
# argumentos restantes (dado pelo comando '$#') seja 0

while [[ $# -gt 0 ]]; do  # '-gt 0' -> 'greater than' 0
	
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
				echo "E: data inválida."
			fi
			
			shift
			;;
		-s)
			option_s=true
			
			# verificar se $2 (tamanho mínimo do ficheiro) é número inteiro positivo 
			if is_integer_positive "$2"; then
				size="$2"
			else
				echo "E: O número introduzido para size não é >= 0."
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
			
			# verificar se $2 (n de linhas) é número inteiro positivo E maior que 0 
			if is_integer_positive "$2" && [ "$2" -gt 0 ]; then
				limit="$2"
			else
				echo "E: O número introduzido tem de ser > 0"
			fi
			
			shift
			;;
		*)
			if is_dir "$1"; then
				directories+=("$1")
			else
				echo "E: Diretório inválido"
			fi
			;;
	esac
	shift 
done


# As linhas seguintes servem para testar se os argumentos foram armazenados
# !! tirar posteriormente !!

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



