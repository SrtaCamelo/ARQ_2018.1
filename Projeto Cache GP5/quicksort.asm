 
.data 
A: .word 32,30,11,46,17,22,20,109,555,-10,44,43,42, 8, 88,42,1,2,3,4,5,6,89,116,711,1001,851,710,898,888,999,777,666,333,444,111,113,907,201,702,1029,3001,838,170,2280,1010,114,48,47,50
.text
addi $s0, $zero,0 # recebe 0 e sera o lado esquerdo da lista 
addi $s1, $zero,49 # recebe 3 e sera o lado direito da lisa   #POR O TAMANHO DO ARRAY -1 AQUI
la $s2, A # atribuindo o endereço do vetor ao reg s2
jal quicksort #pule para quicksorte e guarde, link  o retorno 
j fim
################################################################
quicksort:
	addi $sp,$sp,-12#preparando a pilha para redeber 3 variaveis
	sw $ra,0($sp) # empilhando o endereço de retorno
	sw $s0,4($sp)# empilhando o lado direito da lista
	sw $s1,8($sp)# empilhando o lado esquerdo da lista
	slt $t0, $s0,$s1 # se s0<s1 st recebe 1 se não recebe 0 
	beq  $t0,$zero, volta
	jal partition
	
	#------ primeira pilha recursiva do quicksorte------------#
	addi $sp,$sp,-8  #preparando a pilha para redeber 1 variaveis
	sw $v0,0($sp)    # empilhando o retorno da função partition
	sw $s1,4($sp)    # empilhando o s1 que veio de partition para uso nas recurções
	addi $s1,$v0,-1
	jal quicksort
	
	#ponto de retorno da primeira pilha de recurção do quicksort
	lw $v0,0($sp)    # desmpilhando o retorrno de partition// $v0 recebe o seu valor original
	addi $sp,$sp, 4 # a pilha sobe 1 posição
	#addi $sp,$sp,8 # a pilha sobe 1 posição # teste
	lw $s1,0($sp)
	addi $sp,$sp, 4 # a pilha sobe 1 posição					 # teste
	#addi $sp,$sp,-8 # a pilha sobe 1 posição #teste	
	addi $s0,$v0,1
	jal quicksort
		
volta:
	lw $ra, 0($sp) # reg de retoro ra recebe o valor de cima da pilha
	addi $sp,$sp, 4 # a pilha sobe 1 posição
	lw $s0, 0($sp) # s0 recebe da pila seu valor orig.
	addi $sp,$sp, 4 # a pilha sobe 1 posição
	lw $s1,0($sp) # s1 recebe da pila seu valor orig.
	addi $sp,$sp, 4  # a pilha sobe 1 posição
	jr $ra
j fim


#################################################################
partition:
addi $sp,$sp,-12#preparando a pilha para redeber 3 variaveis
sw $ra,0($sp) # empilhando o endereço de retorno
sw $s0,4($sp)# empilhando o lado direito da lista
sw $s1,8($sp)# empilhando o lado esquerdo da lista

#--------------------------------------------------extraindo o pivo:-----------------------------------------------------# 
#------------0($s2) nem sempre será o lado esq. da lista ja que o indice "anda" o correto é dizer --------#
#------------que o lado esquerdo da lista é $s0($s2), mais não é possivel usar regs como indicador----------#
#------------de indice nesta condição, por isso é necessário usar uma especie de jogo entre indice e endereço de indice---#

sll $t0,$s0,2 # t0 recebe o valor da posição que o indice $s0 contem vezes 2^2 ou seja vezes 4
add $t0,$t0,$s2 # o valor do endereço da lisa s2 esta sendo adicionada a t0 (que é um multiplo de 4) e o resultado colocado em t0  
		# veja que neste momento t0 tem o endereço equivalente a A[$s0] e que $s0 nada mais é que o indece esquerdo da lista  
lw $t0,0($t0) # st0 agora tem o valo de A[$s0] e será o pivo da função partitio  
addi $s1,$s1,1	# pela regua do quicsort o que ira ser manuseado ser dir+1 e por isso s1, que é a direita,
		#sera adicionado de 1,  mas não haverá problema pois no final o valor original de s1 sera resgatado da pilha 
loop1_2:	
	loop1:# a codição da continuação deste loop1 é que A[s0]<pivo e s0<s1 (indice esq. < indice dir.)
		addi $s0,$s0,1 #adicionando 1 ao indice esq.
		sll $t1, $s0, 2 #  $t1 rece a posição atual do indice x 4 
		add $t1,$t1,$s2 # $t1 recebe ele mesmo mais o endereço $s2 de A 
		lw $t1,0($t1) # $t1 agora tem o valor de A[$s0] para ser comparado ao pivô
		slt $t2,$t1,$t0 #  comparando A[$s0] com o pivô
		bnez $t2, comparaindice # se t2==0 então  A[$s0]<pivo, então vá para comparaindice, caso contrario ainda pode ser igualentão continue
		sub $t2,$t1,$t0 # subitraindo A[$s0] do pivo e jogando em $t2. se a subtração der 0 então t1 e t0 (pivo e A[$s0]) são iguais ou seja 
		bnez $t2, loop2 # se $t2 não for zero então A[$s0]!= pivo então   pule para loop2 se não continue
		comparaindice:
		slt $t2,$s0,$s1 # comparando es	q e dir
		bnez $t2,loop1 # se t2 !=0 então esq  é menor que dir volte então para o loop1, se não ainda pode ser igaul , continue 
		sub $t2,$s0,$s1# se a subtração der igual a zero, então os indices são iguais
		beqz $t2,loop1 	# se os indides são iguai voltar para loop1 se não continue e vá pata loop2
	loop2:
		addi $s1,$s1,-1 #adicionando 1 ao indice esq.
		sll  $t3,$s1,2 # agora estou jogando em t3 o indice $s2 x4
		add $t3,$t3,$s2 # $t3 recebe ele mesmo mais o endereço $s2 de A 
		lw $t3,0($t3) # $t3 agora tem o valor de A[$s1] para ser comparado ao pivô
		slt $t4,$t0,$t3 #  comparando A[$s2] com o pivô
		bnez $t4, loop2 # se A[$s0]<pivo vá para loop2		 
	
	#-----este é um break, é por esta condicional que o loop pode parar
	slt $t7,$s1,$s0 	#/ compare os indices esq e dir 	/#
	bnez $t7, finalPartitio	#/ se dir < esq pare o loop     	/#
	sub $t7,$s1,$s0			#/ e vá para o rotolo final partition   /#	
	beqz $t7, finalPartitio	
		# não faz mais sentido preservar os regs t pois serão sobreescritos em outros ciclos


	# neste momento $s0 e $s1 são respectivamente os indice esq. e dir. completamente
 	#adulterados pelas regras da função, como haverá uma troca, temos a intenção de salvar 
 	# e preservar temporariamente as posições de $s0 e $s1 e seus respectivos valores
		
	#----carregando o valor de A[$s0] para um reg temporario----#	
	sll $t1, $s0, 2 #  $t1 recebe a posição atual do indice x 4 
	add $t1,$t1,$s2 # $t1 recebe ele mesmo mais o endereço $s2 de A 
	lw $t2,0($t1) # $t2  recebe o valor de A[$s0]
	
	#----carregando o valor de A[$s1] para um reg temporario----#
	sll $t3, $s1, 2 #  $t3 rece a posição atual do indice x 4 
	add $t3,$t3,$s2 # $t3 recebe ele mesmo mais o endereço $s2 de A 
	lw $t4,0($t3) # $t4  recebe o valor de A[$s0]	
	#----primeira troca A[$s0] por A[$1] nas posiçoes que os indices pararam ----#
	sw $t4, 0($t1) #  colocando o valor de A[$s1] em A[$s0], indice dir. em indice esq  
	sw $t2,0($t3) #  colocando o valor de A[$s0] em A[$s1], indice esq. em indice dir 
	
	j loop1_2
	
	
finalPartitio:
	add $v0,$zero,$s1 # salvando em sv0 (reg de retorno) a variavel s1 de retorno da função partition
	#add $v1,$zero,$s0 # salvando em sv1 (reg de retorno) a variavel s0 para uso nas recursões
	#------------- desempilhamento dos indices originais e do ponto de retorno--------------#
	lw $ra, 0($sp) # reg de retoro ra recebe o valor de cima da pilha
	addi $sp,$sp, 4 # a pilha sobe 1 posição
	lw $s0, 0($sp) # s0 recebe da pila seu valor orig.
	addi $sp,$sp, 4 # a pilha sobe 1 posição
	lw $s1,0($sp) # s1 recebe da pila seu valor orig.
	addi $sp,$sp, 4 # a pilha sobe 1 posição		
	
	#-----------------segunda troca---------------#	
	sll $t1, $s0, 2 #  $t3 rece a posição atual do indice x 4 
	add $t1,$t1,$s2 # $t3 recebe ele mesmo mais o endereço $s2 de A 
	lw $t2,0($t1) # $t4  recebe o valor de A[$s0]	
		
	sll $t3, $v0, 2 #  $t3 rece a posição atual do indice x 4 
	add $t3,$t3,$s2 # $t3 recebe ele mesmo mais o endereço $s2 de A 
	lw $t4,0($t3) # $t4  recebe o valor de A[$s0]	

	sw $t4, 0($t1) #  colocando o valor de A[$s1] em A[$s0], indice dir. em indice esq  
	sw $t2,0($t3) #  colocando o valor de A[$s0] em A[$s1], indice esq. em indice dir
	
	

	jr $ra


fim:
