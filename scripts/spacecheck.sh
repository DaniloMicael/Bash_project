#!/bin/bash

#-------------------------------------------#
#  Trabalho realizado por:                  #
#                                           #
#  Danilo Micael Gregório Silva   n 113384  #
#  Tomás Santos Fernandos         n 112981  #
#-------------------------------------------#

# ---------------------------------------------------------------------------------------------------------------------------------------#
# NOTAS A RETIRAR NO FIM DO TRABALHO:

# Podemos assumir que a pasta vem no final das opções, mas não podemos assumir que é só uma pasta
# O output deve de ser com espaços e não tabs
# A ordem normal vem do menor para o maior
# Quando há um erro, um arg inválido, O VALOR RETORNO NÃO É ZERO, é diferente de zero, e não é obrigatório ter uma mensagem de erro

# NA: verificar se o diretório tem permissão de leitura

# Para a função regex podemos usar =~ para a maior parte das coisas
# Não podemos assumira nada sobre a opção regular, ou seja, qualquer uma tem de ser validada 

# Ordem: usar -r e -a ordena por ordem decrescente do nome

# No relatório: forma como organizámos a solução, não devemos colocar muito código, forma como validámos a solução, testesao código, etc
# ---------------------------------------------------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#

# Funções a serem usadas no script:

# Função para imprimir o cabeçalho
function print_head() {
	d1=$(date --rfc-3339=date | cut -d "-" -f1)$(date --rfc-3339=date | cut -d "-" -f2)$(date --rfc-3339=date | cut -d "-" -f3)
	# O pipe 'date --rfc-3339=date | cut -d "-" -fx' permite extrair a parte que 
	# interessa da data e dividi-la (cut) pelo delimitador "-". Depois ordena a data na forma YMD através de -f1, -f2, -f3

	cabecalho="SIZE  NAME  $d1$d2$d3"
	
	for option in "$@" ; do
		cabecalho="$cabecalho $option"
	done
	echo $cabecalho
}


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
#------------------------------------------------------------------------------#


# Passo 1: armazenar todos os argumentos passados ao executar o script

# Opções possíveis de serem fornecidas como argumento para definir a seleção 
#de ficheiros desejados ao executar o script:

option_n=false # expressão regular para filtrar nome dos ficheiros
option_d=false # data máxima de modificação dos ficheiros
option_s=false # tamanho mínimo do ficheiro
option_r=false # ordenar por ordem inversa (ou seja, pela ordem correta do tamanho)
option_a=false # ordenar por nome
option_l=false # limitar o número de linhas da tabela


# Valores passados pelo user correspondentes às opções fornecidas:

file_pattern="" # opção -n (variável)
date=""         # opção -d (variável)
size="0"        # opção -s (variável)
limit=""        # opção -l (variável)
directories=()  # diretoria(s) a serem monitorizadas (array)

sort="-n -r"	# variável com as opções de ordenação default

#----------------#

# Processamento dos argumentos:

# O comando 'getops' guarda as opções inseridas;
# Estas são especificadas na string abaixo '"n:d:s:ral:"';
# As letras significam as opções disponíveis para o utizizador;
# Os dois pontos a seguir a cada letra identificam as opções que necessitam de argumento;
# As opções inseridas são então todas percorridas e é usado um case para verificar se 
# a opção armazenada na variável "$option" é uma das especificadas
while getopts "n:d:s:ral:" option; do
	case $option in	
		n)	
			option_n=true

			# necessário avaliar e testar a expressão inserida     		
			file_pattern="$OPTARG"
		;;
		d)
			option_d=true
			
			# verificar se $OPTARG é uma data válida
			if is_date "$OPTARG"; then
				echo "data válida"		
				date="$OPTARG"
			else
				echo "E: data inválida."
			fi
		;;
		s)
			option_s=true
			
			# verificar se $OPTARG (tamanho mínimo do ficheiro) é número inteiro positivo 
			if is_integer_positive "$OPTARG"; then
				size="$OPTARG"
			else
				echo "E: O número introduzido para size não é >= 0."
			fi
		;;
		r)
			option_r=true
			sort="-n" # a funcionar
		;;
		a)
			option_a=true
			sort="-k 2" # -k serve para ordenar alfabeticamente, o 2 significa a segunda coluna, onde estão os nomes
		;;
		l)
			option_l=true
			
			# verificar se $OPTARG (n de linhas) é número inteiro positivo E maior que 0 
			if is_integer_positive "$OPTARG" && [ "$OPTARG" -gt 0 ]; then
				limit="$OPTARG"
			else
				echo "E: O número introduzido tem de ser > 0"
			fi
		;;
	esac
done		

print_head $@

# Identificar os argumentos que são passados como diretórios
for option in "$@"; do
	if is_dir "$option"; then
		directories+=("$option")
	fi
done

if [ "$option_r" = true ] && [ "$option_a" = true ]; then
	sort="-k 2r" # ordernar alfabeticamente na ordem inversa, usando o r (reverse)
fi


# para cada diretório, listar os tamanhos
# é implementado um if para o caso do user introduzir um número de linhas a limitar
# caso option_l seja true é necessário agregar o comando head passando como argumento o número de linhas pretendido a limitar ($limit)
for dir in "${directories[@]}"; do

	if [ "$option_l" = true ]; then
		output=$(du -b "$dir" | sort $sort | awk -v min_size="$size" '$1 >= min_size' | head -n "$limit")
	else
		output=$(du -b "$dir" | sort $sort | awk -v min_size="$size" '$1 >= min_size')
	fi
	
	echo "$output" 						# "sort $sort" Para dar sort de acordo com aquilo que o user quiser
done								# head -n "$limit" limita o número de linhas
								# awk -v min_size="$size" para definir o tamanho mínimo





# find "$dir" -type d | xargs du -b | ......
# este comando substitui o que temos em cima























#----------------#
# As linhas seguintes servem para testar se os argumentos foram armazenados
# !! tirar posteriormente !!
echo ""
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



