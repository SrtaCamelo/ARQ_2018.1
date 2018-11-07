#Leitor e comparador de Strings
#Raissa Camelo =)

.data
buffer_file: .space 1024
string_out: .space 1024
maior_palavra: .space 1024
menor_palavra: .space 1024
palavra_atual: .space 1024
tamanho_maior: .byte 0
tamanho_menor: .byte 101
tamanho_atual: .byte 0
ponteiro_maior: .byte 0
ponteiro_menor: .byte 0
spaco: .byte ' '
barra_r: .byte '\r'
barra_n: .byte '\n'
arquivo: .asciiz "string.in"  #Salva o ponteiro do arquivo
arquivo_out: .asciiz "string.out" #Arquivo de saida

.text
#Open o file
li $v0, 13
la $a0, arquivo #Registrador a0 recebe o ponteiro do arquivo
li $a1, 0
li $a2, 0
syscall #Abra cadabra
move $s0, $v0 #descritor

#Read o file
li $v0, 14
move $a0, $s0
la $a1, buffer_file
addi $a2, $zero,1024
syscall

#Fechar o file
li $v0, 16
move $a0, $s0
syscall

#Print test
#la $a1, -label here- 
#li $v0, 4
#la $a0, ($a1)
#syscall

#Reservar Registradores
	#S0 -> posicao do buffer
	move $s0, $zero 
	lb $s1, tamanho_maior
	lb $s2, tamanho_atual
	lb $s3, tamanho_menor
	#carregar /n, /r e espaco em registradores
	lb $s4, barra_r
	lb $s5, spaco
	lb $t6, barra_n
	#carregar os ponteiros da palavra_menor e da palavra_maior
	lb $s6, ponteiro_maior
	lb $s7, ponteiro_menor
	# O temporario $t7 esta reservado para identificar o EOF, nao usar
	#O temporario $t5 esta reservado para identificar a primeira palavra
	
#Ler Palavras
	LP: #Ler palavras do buffer
	lb $t7, buffer_file($s0)  #pega o caracter do buffer
	beq $t7, $s4, checar_tamanho        #Se a caractere for /r
	beq $t7, $zero, checar_tamanho        #Se o caractere for /0
	sb $t7, palavra_atual($s2) #coloca na palavra atual   
	addi $s0, $s0,1  #Incrementa o contador do buffer
	addi $s2, $s2,1  #Incrementa o contador do tamanho da palavra sendo lida 
	j LP

#Resetador
	resetador:
	beq  $t7, $zero, final
	move $s2, $zero  #Reseta o tamanho da palavra atualmente lida
	addi $s0, $s0,2  #Sai do /r e do /n
	j LP
#Primeira Palavra
	first_word:  #Colocar a primeira palavra como maior e menor
	addi $s6, $s6,-1
	addi $s7, $s7,-1
	jal igual_maior
	jal igual_menor
	addi $t5, $t5,1
	move $s1, $s2  # size(maior) =  size(first_word)
	move $s3, $s2  # size(menor) =  size(first_word)
	j resetador
			
#Checar tamanho da palavra lida atualmente
	checar_tamanho:
		beq  $t5, $zero, first_word
		sb   $zero, palavra_atual($s2)
		bgt  $s2, $s1, maior       #Se o tamanho da palavra atual for maior que o da maior palavra
		blt  $s2, $s3, menor  	   #Se o tamanho da palavra atual for menor que o da menor palavra
		beq  $s2, $s1, igual_maior  #Se o tamanho da palavra atual for igual ao da maior palavra
		unitaria: #Teste se a palavra maior e menor sao identicas (arquivo composto de 10 palavras iguais)
		beq  $s2, $s3, igual_menor   #Se o tamanho da palavra atual for igual ao da menor palavra
		j resetador  

#Se a palavra for maior
	maior:
		move $s1, $zero            #O tamanho da maior eh zerado
		move $t1, $zero            #limpa t1 para usar na funcao (jal) abaixo
		move $s6, $zero		   #Limpa o ponteiro da posição no vetor maior_palavra
		
#Limpador do buffer da maior palavra
	limpa_bmaior:
		sw $zero, maior_palavra($t1)
		addi $t1, $t1, 4
		lw $t0, maior_palavra($t1)	#t0 = palavra_maior[t1]
		bne $t0, $zero, limpa_bmaior
	loop:
		lb $t1, palavra_atual($s1)
		sb $t1, maior_palavra($s1)
		addi $s1, $s1, 1
		bne $t1, $zero, loop
		addi $s1, $s1,-1
		sb  $s5, maior_palavra($s1) #Por espaco no fim da palavra
		move $s6, $s1		    #Ponteiro da maior palavra atualizado (concatenar depois)
		j resetador
				
#Se a palavra for menor
	menor:
		move $s3, $zero		#O tamanho da menor eh zerado
		move $t1, $zero
		move $s7, $zero		#Limpa o ponteiro da posição no vetor menor_palavra
#Limpador do buffer da menor palavra
	limpa_bmenor:
		sw $zero, menor_palavra($t1)
		addi $t1, $t1, 4
		lw $t0, menor_palavra($t1)	#t0 = palavra_menor[t1]
		bne $t0, $zero, limpa_bmenor

	loop2:
		lb $t1, palavra_atual($s3)
		sb $t1, menor_palavra($s3)
		addi $s3, $s3, 1
		bne $t1, $zero, loop2
		addi $s3, $s3, -1
		sb  $s5, menor_palavra($s3) #Por espaco no fim da palavra
		move $s7, $s3               #Ponteiro da menor palavra atualizado (concatenar depois)
		j resetador	
		
#Se a palavra for de tamanho igual a maior
	igual_maior:
		move $t0, $zero      #Zera o registrador pra usar como contador
		move $t1, $zero	     #Zera o resgistrador pra usar como leitor temporario
	loop3:
		addi $s6, $s6,1
		lb $t1, palavra_atual($t0)
		beq $t1, $zero, ajeita
		sb $t1, maior_palavra($s6)
		addi $t0, $t0,1
		j loop3
	ajeita:
		sb $s5, maior_palavra($s6) #Por espaco no fim da palavra
		addi $t0, $s6,1
		sb $zero, maior_palavra($t0)
		bne $t5, $zero, unitaria
		jr $ra     
	
	
#Se a palavra for de tamanho igual a menor
	igual_menor:
		move $t0, $zero      #Zera o registrador pra usar como contador
		move $t1, $zero	     #Zera o resgistrador pra usar como leitor temporario
	loop4:
		addi $s7, $s7,1
		lb $t1, palavra_atual($t0)
		beq $t1, $zero, ajeita1
		sb $t1, menor_palavra($s7)
		addi $t0, $t0,1
		j loop4
	ajeita1:
		sb $s5, menor_palavra($s7) #Por espaco no fim da palavra
		addi $t0, $s7,1
		sb $zero, menor_palavra($t0)
		bne $t5, $zero, resetador
		jr $ra
#Final (terminou de ler o arquivo)
final:
#Print das duas string separadas pra test
#sb $t6, menor_palavra($s7)
#la $a1, menor_palavra #Printa menor
#li $v0, 4
#la $a0, ($a1)
#syscall


#la $a1, maior_palavra 
#li $v0, 4
#la $a0, ($a1)
#syscall

move $t0, $zero #Limpar t0 e t1 pra usar embaixo
move $t1, $zero
#Concatenar as duas strings para escrever no arquivo
string_out1:
	lb $t1,menor_palavra($t0)
	sb $t1, string_out($t0)
	addi $t0, $t0, 1
	bne $t1, $zero, string_out1
	addi $t0, $t0, -1	  #volta o ponteiro
	sb $s4, string_out($t0)   #Poe /r
	addi $t0, $t0,1
	sb $t6, string_out($t0)   #Poe /n
	addi $t0, $t0,1
string_out2:
	lb $t1, maior_palavra($t8)
	sb $t1, string_out($t0)
	addi $t0, $t0, 1
	addi $t8, $t8, 1
	bne $t1, $zero, string_out2
#Print das duas strings concatenadas para teste	
la $a1, string_out
li $v0, 4
la $a0, ($a1)
syscall
	
#Open o file
li $v0, 13
la $a0, arquivo_out #Registrador a0 recebe o ponteiro do arquivo
li $a1, 1
li $a2, 1
syscall #Abra cadabra
move $s0, $v0 #descritor salvo

#write no file
move $a0,$zero
li $v0, 15
move $a0, $s0
la $a1, string_out
addi $a2, $zero,1024
syscall

#Fechar o file
li $v0, 16
move $a0, $s0
syscall





