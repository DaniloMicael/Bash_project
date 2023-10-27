#!/bin/bash

#-------------------------------------------#
#  Trabalho realizado por:                  #
#                                           #
#  Danilo Micael Gregório Silva   n 113384  #
#  Tomás Santos Fernandos         n 112981  #
#-------------------------------------------#

# ---------------------------------------------------------------------------------------------------------------------------------------#
# NOTAS A RETIRAR NO FIM DO TRABALHO:

# Output:
# O output deve de ser com espaços e não tabs
# A ordem normal vem do menor para o maior
# NA: verificar se o diretório tem permissão de leitura
# Ordem: usar -r e -a ordena por ordem decrescente do nome
# Contabilizamos o tamanho das sub-pastas e dos ficheiros dentro da pasta (ver fotos)

# User Input:
# Podemos assumir que a pasta vem no final das opções, mas não podemos assumir que é só uma pasta
# Quando há um erro, um arg inválido, O VALOR RETORNO NÃO É ZERO, é diferente de zero, e não é obrigatório ter uma mensagem de erro

# Dicas:
# Para a função regex podemos usar =~ para a maior parte das coisas
# Não podemos assumir nada sobre a opção regular, ou seja, qualquer uma tem de ser validada 

# Notas:
# O script não deve de criar ficheiros!

# Relatório:
# No relatório: forma como organizámos a solução, não devemos colocar muito código, forma como validámos a solução, testesao código, etc

# ---------------------------------------------------------------------------------------------------------------------------------------#

: << 'END'

	INFO COMANDOS ESSENCIAIS:

    awk: O comando awk é uma linguagem de programação interpretada usada 
	principalmente para processar e manipular texto. Ele lê arquivos de 
	entrada linha por linha e permite que você aplique regras ou expressões 
	para extrair e formatar dados.

    bc: O bc é uma calculadora de precisão arbitrária no shell. Você pode 
	usá-lo para realizar cálculos matemáticos com uma precisão precisa, 
	manipular números decimais e até criar scripts simples para realizar 
	cálculos.

    cat: O comando cat é usado para concatenar e exibir o conteúdo de um 
	ou mais arquivos de texto. Ele é frequentemente usado para visualizar 
	o conteúdo de arquivos.

    cut: O comando cut é usado para cortar (extrair) partes específicas 
	de uma linha ou campo de texto em um arquivo. Ele é frequentemente 
	usado com arquivos delimitados por espaços, vírgulas ou outros caracteres.

    date: O comando date é usado para exibir a data e hora atual ou formatá-la 
	de acordo com as preferências do usuário. É útil para automatizar tarefas 
	relacionadas ao tempo.

    du: O comando du é usado para calcular o espaço em disco usado por 
	arquivos e diretórios. Ele exibe informações sobre o uso de espaço 
	em disco em um formato legível pelo usuário.

    find: O comando find é usado para buscar arquivos e diretórios em um 
	sistema de arquivos com base em critérios específicos, como nome, 
	data de modificação, tamanho, etc. É uma ferramenta poderosa para 
	localizar arquivos.

    getopts: Embora não seja um comando executável por conta própria, 
	getopts é usado em scripts shell para analisar opções e argumentos 
	passados para o script. Ele facilita o processamento de argumentos 
	de linha de comando em scripts Bash.

    grep: O comando grep é usado para procurar padrões de texto em arquivos. 
	Ele permite que você filtre e imprima linhas de texto que correspondam a 
	um padrão especificado.

    head: O comando head é usado para exibir as primeiras linhas de um 
	arquivo de texto. Por padrão, ele mostra as 10 primeiras linhas, mas 
	você pode especificar um número diferente de linhas a serem exibidas.

    ls: O comando ls é usado para listar os arquivos e diretórios em um 
	diretório. Ele fornece informações sobre os arquivos, como nomes, 
	permissões, tamanhos e datas de modificação.

    printf: O comando printf é usado para formatar e imprimir texto na saída 
	padrão. Ele permite criar saída formatada com base em especificações 
	de formato, como em linguagens de programação.

    sleep: O comando sleep é usado para pausar a execução de um script ou 
	processo por um período específico, especificado em segundos, minutos 
	ou outras unidades de tempo.

    sort: O comando sort é usado para ordenar as linhas de um arquivo de 
	texto. Você pode especificar diferentes critérios de ordenação, como 
	ordem alfabética, numérica e reversa.

    stat: O comando stat é usado para exibir informações detalhadas sobre 
	um arquivo, como tamanho, data de modificação, permissões e outros atributos.

END


# ---------------------------------------------------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#

# Funções a serem usadas no script:

# Função para imprimir o cabeçalho
function print_head() {
	#$(date --rfc-3339=date | cut -d "-" -f1)$(date --rfc-3339=date | cut -d "-" -f2)$(date --rfc-3339=date | cut -d "-" -f3)
	d1=$(date +%Y%m%d)
	# O pipe 'date --rfc-3339=date | cut -d "-" -fx' permite extrair a parte que 
	# interessa da data e dividi-la (cut) pelo delimitador "-". Depois ordena a data na forma YMD através de -f1, -f2, -f3

	cabecalho="SIZE NAME $d1$d2$d3"
	
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


######## VER ESTA FUNÇÃO, ESTÁ ERRADA!
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

: << 'END'

function calculate_output() {

	dir="$1"
	pattern="$2"

	# find para encontrar todos os diretórios e subdiretórios (subdir é cada diretório encontrado no find, pelo que entendi)
	find "$dir" -type d | while read -r subdir; do
		# segundo find para procurar os ficheiros com um certo pattern e de seguida é executado du retornando o size dos ficheiros e tentei fazer a soma com awk mas não funcionou (supostamente $1 é o tamanho de cada file e devia fazer a soma naquele subdiretório e printar no fim)
    		size=$(find "$subdir" | grep "$pattern" | xargs du -b  | cut -f1 | awk '{s+=$1} END {print s}')
    		# Imprima o tamanho e o subdiretório
    		echo "$size $subdir"
	done
}

END



#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#


# Passo 1: armazenar todos os argumentos passados ao executar o script


# Array associativo com os argumentos passados pelo utilizador para cada opção 
declare -A vals
vals["file_pattern"]=""
vals["date"]=""
vals["size"]="0"
vals["limit"]=""
vals["directories"]=()



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
		output=$(du -b "$dir" | sort $sort | awk -v min_size="$size" '	{
																			if ($1 >= min_size) 
																				print; 
																			else {
																				$1=0; 
																				print;
																			} 
																	   	}' | head -n "$limit")
																		# "sort $sort" Para dar sort de acordo com aquilo que o user quiser
																		# head -n "$limit" limita o número de linhas

	else
		output=$(du -b "$dir" | sort $sort | awk -v min_size="$size" '	{
																			if ($1 >= min_size) 
																				print; 
																			else {
																				$1=0; 
																				print;
																			} 
																	   	}' )
	# Nos comandos acima, usufruimos da liberdade que o comando 'awk' nos oferece para criar uma variável "min_size", cujo valor é o tamanho mínimo 	
	#que o utilizador deseja usar para listar os diretórios. Em seguida, abrimos "{" para criar um pequeno script que compara o $1 (valor presente na
	#1ª coluna de cada linha do tipo:"size	diretorio/diret/dir", ou seja, $1 contém o tamanho de cada diretório na lista de diretórios usada para este
	#ciclo for) com o valor da variável 'min_size'. Se for maior ou igual, então nada se altera e apenas dá print à linha normalmente, mas se for menor
	#do que o tamanho mínimo, então substitui a primeira coluna (size) por 0 e dá print à coluna.															
	fi
	
	echo "$output" 			
done						



: << 'END'

for dir in "${directories[@]}"; do
	if [ "$option_n" = true ]; then
		calculate_output "$dir" "$file_pattern"
	fi
done

END



# find "$dir" -type d | xargs du -b | ......
# este comando substitui o que temos em cima


# comando que nos dá o tamanho dos ficheiros (coluna 1):
# find sop | grep ".txt" | xargs du -b  | cut -f1













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



