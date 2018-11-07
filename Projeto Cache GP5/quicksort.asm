 
.data 
A: .word 32,30,11,46,17,22,20,109,555,-10,44,43,42, 8, 88,42,1,2,3,4,5,6,89,116,711,1001,851,710,898,888,999,777,666,333,444,111,113,907,201,702,1029,3001,838,170,2280,1010,114,48,47,50
.text
addi $s0, $zero,0 # recebe 0 e sera o lado esquerdo da lista 
addi $s1, $zero,49 # recebe 3 e sera o lado direito da lisa   #POR O TAMANHO DO ARRAY -1 AQUI
la $s2, A # atribuindo o endere�o do vetor ao reg s2
jal quicksort #pule para quicksorte e guarde, link  o retorno 
j fim
################################################################
quicksort:
	addi $sp,$sp,-12#preparando a pilha para redeber 3 variaveis
	sw $ra,0($sp) # empilhando o endere�o de retorno
	sw $s0,4($sp)# empilhando o lado direito da lista
	sw $s1,8($sp)# empilhando o lado esquerdo da lista
	slt $t0, $s0,$s1 # se s0<s1 st recebe 1 se n�o recebe 0 
	beq  $t0,$zero, volta
	jal partition
	
	#------ primeira pilha recursiva do quicksorte------------#
	addi $sp,$sp,-8  #preparando a pilha para redeber 1 variaveis
	sw $v0,0($sp)    # empilhando o retorno da fun��o partition
	sw $s1,4($sp)    # empilhando o s1 que veio de partition para uso nas recur��es
	addi $s1,$v0,-1
	jal quicksort
	
	#ponto de retorno da primeira pilha de recur��o do quicksort
	lw $v0,0($sp)    # desmpilhando o retorrno de partition// $v0 recebe o seu valor original
	addi $sp,$sp, 4 # a pilha sobe 1 posi��o
	#addi $sp,$sp,8 # a pilha sobe 1 posi��o # teste
	lw $s1,0($sp)
	addi $sp,$sp, 4 # a pilha sobe 1 posi��o					 # teste
	#addi $sp,$sp,-8 # a pilha sobe 1 posi��o #teste	
	addi $s0,$v0,1
	jal quicksort
		
volta:
	lw $ra, 0($sp) # reg de retoro ra recebe o valor de cima da pilha
	addi $sp,$sp, 4 # a pilha sobe 1 posi��o
	lw $s0, 0($sp) # s0 recebe da pila seu valor orig.
	addi $sp,$sp, 4 # a pilha sobe 1 posi��o
	lw $s1,0($sp) # s1 recebe da pila seu valor orig.
	addi $sp,$sp, 4  # a pilha sobe 1 posi��o
	jr $ra
j fim


#################################################################
partition:
addi $sp,$sp,-12#preparando a pilha para redeber 3 variaveis
sw $ra,0($sp) # empilhando o endere�o de retorno
sw $s0,4($sp)# empilhando o lado direito da lista
sw $s1,8($sp)# empilhando o lado esquerdo da lista

#--------------------------------------------------extraindo o pivo:-----------------------------------------------------# 
#------------0($s2) nem sempre ser� o lado esq. da lista ja que o indice "anda" o correto � dizer --------#
#------------que o lado esquerdo da lista � $s0($s2), mais n�o � possivel usar regs como indicador----------#
#------------de indice nesta condi��o, por isso � necess�rio usar uma especie de jogo entre indice e endere�o de indice---#

sll $t0,$s0,2 # t0 recebe o valor da posi��o que o indice $s0 contem vezes 2^2 ou seja vezes 4
add $t0,$t0,$s2 # o valor do endere�o da lisa s2 esta sendo adicionada a t0 (que � um multiplo de 4) e o resultado colocado em t0  
		# veja que neste momento t0 tem o endere�o equivalente a A[$s0] e que $s0 nada mais � que o indece esquerdo da lista  
lw $t0,0($t0) # st0 agora tem o valo de A[$s0] e ser� o pivo da fun��o partitio  
addi $s1,$s1,1	# pela regua do quicsort o que ira ser manuseado ser dir+1 e por isso s1, que � a direita,
		#sera adicionado de 1,  mas n�o haver� problema pois no final o valor original de s1 sera resgatado da pilha 
loop1_2:	
	loop1:# a codi��o da continua��o deste loop1 � que A[s0]<pivo e s0<s1 (indice esq. < indice dir.)
		addi $s0,$s0,1 #adicionando 1 ao indice esq.
		sll $t1, $s0, 2 #  $t1 rece a posi��o atual do indice x 4 
		add $t1,$t1,$s2 # $t1 recebe ele mesmo mais o endere�o $s2 de A 
		lw $t1,0($t1) # $t1 agora tem o valor de A[$s0] para ser comparado ao piv�
		slt $t2,$t1,$t0 #  comparando A[$s0] com o piv�
		bnez $t2, comparaindice # se t2==0 ent�o  A[$s0]<pivo, ent�o v� para comparaindice, caso contrario ainda pode ser igualent�o continue
		sub $t2,$t1,$t0 # subitraindo A[$s0] do pivo e jogando em $t2. se a subtra��o der 0 ent�o t1 e t0 (pivo e A[$s0]) s�o iguais ou seja 
		bnez $t2, loop2 # se $t2 n�o for zero ent�o A[$s0]!= pivo ent�o   pule para loop2 se n�o continue
		comparaindice:
		slt $t2,$s0,$s1 # comparando es	q e dir
		bnez $t2,loop1 # se t2 !=0 ent�o esq  � menor que dir volte ent�o para o loop1, se n�o ainda pode ser igaul , continue 
		sub $t2,$s0,$s1# se a subtra��o der igual a zero, ent�o os indices s�o iguais
		beqz $t2,loop1 	# se os indides s�o iguai voltar para loop1 se n�o continue e v� pata loop2
	loop2:
		addi $s1,$s1,-1 #adicionando 1 ao indice esq.
		sll  $t3,$s1,2 # agora estou jogando em t3 o indice $s2 x4
		add $t3,$t3,$s2 # $t3 recebe ele mesmo mais o endere�o $s2 de A 
		lw $t3,0($t3) # $t3 agora tem o valor de A[$s1] para ser comparado ao piv�
		slt $t4,$t0,$t3 #  comparando A[$s2] com o piv�
		bnez $t4, loop2 # se A[$s0]<pivo v� para loop2		 
	
	#-----este � um break, � por esta condicional que o loop pode parar
	slt $t7,$s1,$s0 	#/ compare os indices esq e dir 	/#
	bnez $t7, finalPartitio	#/ se dir < esq pare o loop     	/#
	sub $t7,$s1,$s0			#/ e v� para o rotolo final partition   /#	
	beqz $t7, finalPartitio	
		# n�o faz mais sentido preservar os regs t pois ser�o sobreescritos em outros ciclos


	# neste momento $s0 e $s1 s�o respectivamente os indice esq. e dir. completamente
 	#adulterados pelas regras da fun��o, como haver� uma troca, temos a inten��o de salvar 
 	# e preservar temporariamente as posi��es de $s0 e $s1 e seus respectivos valores
		
	#----carregando o valor de A[$s0] para um reg temporario----#	
	sll $t1, $s0, 2 #  $t1 recebe a posi��o atual do indice x 4 
	add $t1,$t1,$s2 # $t1 recebe ele mesmo mais o endere�o $s2 de A 
	lw $t2,0($t1) # $t2  recebe o valor de A[$s0]
	
	#----carregando o valor de A[$s1] para um reg temporario----#
	sll $t3, $s1, 2 #  $t3 rece a posi��o atual do indice x 4 
	add $t3,$t3,$s2 # $t3 recebe ele mesmo mais o endere�o $s2 de A 
	lw $t4,0($t3) # $t4  recebe o valor de A[$s0]	
	#----primeira troca A[$s0] por A[$1] nas posi�oes que os indices pararam ----#
	sw $t4, 0($t1) #  colocando o valor de A[$s1] em A[$s0], indice dir. em indice esq  
	sw $t2,0($t3) #  colocando o valor de A[$s0] em A[$s1], indice esq. em indice dir 
	
	j loop1_2
	
	
finalPartitio:
	add $v0,$zero,$s1 # salvando em sv0 (reg de retorno) a variavel s1 de retorno da fun��o partition
	#add $v1,$zero,$s0 # salvando em sv1 (reg de retorno) a variavel s0 para uso nas recurs�es
	#------------- desempilhamento dos indices originais e do ponto de retorno--------------#
	lw $ra, 0($sp) # reg de retoro ra recebe o valor de cima da pilha
	addi $sp,$sp, 4 # a pilha sobe 1 posi��o
	lw $s0, 0($sp) # s0 recebe da pila seu valor orig.
	addi $sp,$sp, 4 # a pilha sobe 1 posi��o
	lw $s1,0($sp) # s1 recebe da pila seu valor orig.
	addi $sp,$sp, 4 # a pilha sobe 1 posi��o		
	
	#-----------------segunda troca---------------#	
	sll $t1, $s0, 2 #  $t3 rece a posi��o atual do indice x 4 
	add $t1,$t1,$s2 # $t3 recebe ele mesmo mais o endere�o $s2 de A 
	lw $t2,0($t1) # $t4  recebe o valor de A[$s0]	
		
	sll $t3, $v0, 2 #  $t3 rece a posi��o atual do indice x 4 
	add $t3,$t3,$s2 # $t3 recebe ele mesmo mais o endere�o $s2 de A 
	lw $t4,0($t3) # $t4  recebe o valor de A[$s0]	

	sw $t4, 0($t1) #  colocando o valor de A[$s1] em A[$s0], indice dir. em indice esq  
	sw $t2,0($t3) #  colocando o valor de A[$s0] em A[$s1], indice esq. em indice dir
	
	

	jr $ra


fim:
