##################################
##Código Feito por Mayara Castro
##	Raissa Camelo
##################################

#Unit Width in Pixels: 2
#Unit Height in Pixels: 2
#Display Width in Pixels: 512
#Display Height in Pixels: 512
#Base address for display: 0x10010000 (static data)
#Movimentos : w,a,s,d

#funcao sleep para dar um slow down nas movimentacoes
.macro sleep(%tempo)
	li 	$v0, 32 		
	li 	$a0, %tempo
	syscall
.end_macro


              ############################################################
	#	MOVIMENTA		                #
	#	%vetor: o endereco do vetor a ser movimentado   #
	#	%tam: tamanho do array 
	#	%vezes : quantidade de vezes que anda
	###########################################################

.macro move_fantasma_direita(%vetor, %tam, %vezes)
	li	$a3, 0
vezes_andar_direita:
	addi	$a3, $a3, 1
	#sleep(16)
	
	move	$t5, $zero
direitaf_loop:
	add 	$t2, $t5, %vetor
	lw	$t4, ($t2)
	addi	$t4, $t4, 4
	sw	$t4, ($t2)
	addi	$t5, $t5, 4
	ble	$t5, %tam,direitaf_loop
	
	
	
	ble	$a3, %vezes, vezes_andar_direita
.end_macro

.macro move_fantasma_esquerda(%vetor, %tam, %vezes)
	li	$a3, 0
vezes_andar_esquerda:
	addi	$a3, $a3, 1
	#sleep(16)
	#jal	limpa_personagens
	move	$t5, $zero
esquerdaf_loop:
	add 	$t2, $t5, %vetor
	lw	$t4, ($t2)
	addi	$t4, $t4, -4
	sw	$t4, ($t2)
	addi	$t5, $t5, 4

	ble	$t5, %tam,esquerdaf_loop
	
	#la	$v0, pontos_mapa1
	#lw	$v1, tam_pontos_mapa1
	#pinta_ponto($v0, $v1)
	#jal	pinta_personagens
	ble	$a3, %vezes, vezes_andar_esquerda
.end_macro

.macro move_fantasma_cima(%vetor, %tam, %vezes) 
	li	$a3, 0
vezes_andar_cima:
	addi	$a3, $a3, 1
	#sleep(16)
	#jal 	limpa_personagens
	move	$t5, $zero
acimaf_loop:
	add	$t2, $t5, %vetor
	lw	$t4, ($t2)#pacman_dir($t5)
	addi	$t4, $t4, -1024 #decremenat a linha
	sw	$t4, ($t2)
	addi	$t5, $t5, 4

	ble	$t5, %tam,acimaf_loop
	
	#la	$v0, pontos_mapa1
	#lw	$v1, tam_pontos_mapa1
	#pinta_ponto($v0, $v1)
	#jal	pinta_personagens
	ble	$a3, %vezes, vezes_andar_cima
.end_macro	

.macro move_fantasma_baixo(%vetor, %tam, %vezes)
	li	$a3, 0
vezes_andar_baixo:
	addi	$a3, $a3, 1
	#sleep(16)
	#jal	 limpa_personagens
	move	$t5, $zero
baixof_loop:
	add 	$t2, $t5, %vetor
	lw	$t4, ($t2)#pacman_dir($t5)
	addi	$t4, $t4, 1024
	sw	$t4, ($t2)
	addi	$t5, $t5, 4
	ble	$t5, %tam,baixof_loop
	
	#la	$v0, pontos_mapa1
	#lw	$v1, tam_pontos_mapa1
	#pinta_ponto($v0, $v1)
	#jal	pinta_personagens
	ble	$a3, %vezes, vezes_andar_baixo
.end_macro

.macro pinta_ponto(%vetor, %tam)
	move	$t9, $zero
ler_array:
	add	$t8, %vetor, $t9
	addi	$t9, $t9, 4
	lw	$t3,($t8) 
	
	beqz	$t3, ler_array
	move	$t6, $t3
	addi	$t6, $t6, 8
	move	$t5, $t6
	addi	$t5, $t5, 2048 # 2*1024
	lw	$t1, cor_ponto
	jal 	pinta_retangulo
	
	blt	$t9, %tam, ler_array

.end_macro
.macro tirar_ponto(%vetor, %tam, %endereco)
	move	$t9, $zero
ler_array:
	add	$t8, %vetor, $t9
	addi	$t9, $t9, 4
	lw	$s5,($t8) 
	
	bge	$t9, %tam, sair_tirar_ponto
	bne	$s5,%endereco, ler_array
	
	sw	$zero,($t8) #se tiver o endereco do ponto ele poe zero
	
	blt	$t9, %tam, ler_array
sair_tirar_ponto:
.end_macro

.macro verifica_lateral(%topo, %baixo, %cor1, %cor2, %cor3, %cor4)
laterais:
##MODIFICAR
	bgt	%topo, %baixo, exit_lateral #verifica se já é o ultimo endereco
	lw 	$t4, (%topo) 
	addi 	%topo, %topo, 1024 #incrementa t3
	
	seq	$a3, $t4, %cor1 # se existe barreira entao a3 = 1, senao a3 = 0
	bnez	$a3, exit_lateral
	seq	$a3, $t4, %cor2
	bnez	$a3, exit_lateral
	seq	$a3, $t4, %cor3
	bnez	$a3, exit_lateral
	seq	$a3, $t4, %cor4
	bnez	$a3, exit_lateral
	j 	laterais
exit_lateral:

.end_macro
	
.macro verifica_topo(%esq, %dir, %cor1, %cor2, %cor3, %cor4)
topos:
	bgt	%esq, %dir, exit_topo #verifica se já é o ultimo endereco
	lw	$t4, (%esq) 
	addi	%esq, %esq, 4 #incrementa t3
	
	seq	$a3, $t4, %cor1 # se existe barreira entao a3 = 1, senao a3 = 0
	bnez	$a3, exit_topo
	seq	$a3, $t4, %cor2
	bnez	$a3, exit_topo
	seq	$a3, $t4, %cor3
	bnez	$a3, exit_topo
	seq	$a3, $t4, %cor4
	bnez	$a3, exit_topo
	j	topos
exit_topo:

.end_macro


.macro verifica_morte()
	##########################################################
	#	VERIFICA SE MORREU		 #
	##########################################################
	lw	$s1, cor_fantasma_vermelho
	lw	$s2, cor_fantasma_azul
	lw	$s3, cor_fantasma_laranja
	lw	$s4, cor_fantasma_rosa
	
	lw	$t3, pacman_dir
	addi	$t3, $t3,-16
	addi	$t5, $t3, 44
	verifica_topo($t3, $t5, $s1, $s2, $s3, $s4)
	bnez	$a3, exit_morte
	
	lw	$t3, pacman_dir
	addi	$t3, $t3,-16
	addi	$t3, $t3, 12288
	addi	$t5, $t3, 44
	verifica_topo($t3, $t5, $s1,$s2, $s3, $s4)
	bnez	$a3, exit_morte
	
	lw	$t3, pacman_dir
	addi	$t3, $t3,-16
	addi	$t5, $t3, 12288
	verifica_lateral($t3, $t5,$s1, $s2, $s3, $s4)
	bnez	$a3, exit_morte

	lw	$t3, pacman_dir
	addi	$t3, $t3,-16
	addi	$t3, $t3, 44
	addi	$t5, $t3, 12288
	verifica_lateral($t3, $t5,$s1, $s2, $s3, $s4)
	bnez	$a3, exit_morte
exit_morte:
	beqz	$a3, n_morreu
	lw	$t1, vidas
	addi	$t1, $t1, -1
	sw	$t1, vidas
	
	beqz	$t1, morreu #se a qtd de vi
n_morreu:			
.end_macro

.macro zera_arrazy_traversia()
	sw	$zero, array_travessia +0
	sw	$zero, array_travessia + 4
	sw	$zero, array_travessia +8
	sw	$zero, array_travessia +12
	
.end_macro
.kdata
pontuacao:		.word 0
bitmap_size:		.word 65536 # 256*256
bitmap_addr:		.word 0x10010000

cor_pacman:		.word 0x00FFFF00
cor_ponto:		.word 0x00e24638
cor_preto:		.word 0x00000000
cor_lab_parede:	.word 0x000000aa
cor_lab_branco:	.word 0x00FFFFFF

cor_fantasma_vermelho:	.word 0x00df0902
cor_fantasma_azul:	.word 0x0061fafc
cor_fantasma_laranja:	.word 0x00fc9711
cor_fantasma_rosa:	.word 0x00fa9893

direcao_fvermelho:	.word 0
direcao_flaranja:    	.word 0
direcao_fazul:    	.word 0
direcao_frosa:    	.word 3

direcao_pacman:	.word 0
direcao_pacman_prox:	.word 0
   
fantasma_tam: 	.word 628 #158*4  -4 
pacman_tam: 		.word 440 #111*4  - 4
tam_pontos_mapa1:	.word  396 #100*4  -4   
tam_pontos_mapa2:	.word  396 #100*4  -4

posicao_vermelho:	.word 0 # {0,1,2,3)

nivel:		.word 1
vidas:		.word 3

pacman_dir: 		.space  444 # 111*4 

fantasma_vermelho:	.space  632 # 111*4
fantasma_azul: 	.space  632 # 111*4
fantasma_laranja: 	.space  632 # 111*4
fantasma_rosa:	.space  632 # 111*4
array_travessia:	.space 16
pontos_mapa1:		.space 400 #100*4
pontos_mapa2:		.space 400 #100*4


.text 

.globl main

main:
	sw 	$zero, pontuacao #pontuacao do jogo inicial
	lw 	$t0, bitmap_addr
	
	li	$s7, 000
	sw	$s7, pontuacao
	#j venceu
	jal	desenha_vidas
	j	 fase1
	
	#############################
	#	FASE 1	#
	#############################
fase1:
	jal 	pinta_pontos_mapa1
reinicia_fase1:
	jal	pintar_tela
	jal 	escreve_titulo
	jal	escreve_fase1
	jal 	pinta_borda
	jal 	cria_personagens
	jal 	pinta_personagens
	jal 	obstaculos_fase1
	#jal 	pinta_pontos_mapa1
	jal 	mostra_placar
	
	la	$v0, pontos_mapa1
	lw	$v1, tam_pontos_mapa1
	pinta_ponto($v0, $v1)
	
	jal	desenha_vidas
	sw	$zero,direcao_pacman
	sw	$zero,direcao_pacman_prox
	sw	$zero, 0xFFFF0004
fase1_loop:
	
	jal 	obter_teclado
	
	jal 	limpa_personagens
	
	jal 	direita_prox # faz a moviemtação do pacman
	
	#faz a movimentação dos fantasmas
	jal	movimenta_fantasma_vermelho
	jal	movimenta_fantasma_laranja
	jal	movimenta_fantasma_azul
	jal	movimenta_fantasma_rosa
	
	la	$v0, pontos_mapa1
	lw	$v1, tam_pontos_mapa1
	pinta_ponto($v0, $v1)

	jal	pinta_personagens
	verifica_morte()
	bnez	$a3, reinicia_fase1
	
	sleep(16)
	jal 	verificar_ganho_fase1
	j	fase1_loop
	
	#############################
	#	FASE 2	#
	#############################
fase2:
	jal 	pinta_pontos_mapa2
reinicia_fase2:
	li 	$s7, 0x0001ff00 #muda a cor do labirinto
	sw 	$s7, cor_lab_parede
	
	li	$s1, 2
	sw	$s1, nivel
	
	li	$v0, 0	#deixa o pacman parado no inicio da fase
	sw	$v0,direcao_pacman
	sw	$v0,direcao_pacman_prox
	sw	$v0, 0xFFFF0004
	
	jal	transicao_estagio
	jal	pintar_tela
	jal 	escreve_titulo
	jal	escreve_fase2
	jal 	pinta_borda
	jal 	cria_personagens
	jal 	pinta_personagens
	jal 	obstaculos_fase2
	#jal 	pinta_pontos_mapa2
	jal 	mostra_placar
	
	jal	desenha_vidas
	la	$v0, pontos_mapa2
	lw	$v1, tam_pontos_mapa2
	pinta_ponto($v0, $v1)
fase2_loop:
	jal 	obter_teclado
	
	jal 	limpa_personagens
	jal 	direita_prox # faz a moviemtação do pacman
		
	#faz a movimentação dos fantasmas
	jal	movimenta_fantasma_vermelho
	jal	movimenta_fantasma_laranja
	jal	movimenta_fantasma_azul
	jal	movimenta_fantasma_rosa
	
	la	$v0, pontos_mapa2
	lw	$v1, tam_pontos_mapa2
	pinta_ponto($v0, $v1)
	jal	pinta_personagens
	verifica_morte()
	bnez	$a3, reinicia_fase2
	sleep(16)
	
	
	
	jal 	verificar_ganho_fase2
	j	fase2_loop
	
	
	###########################################
	#	MOVIMENTA FANTASMA VERMELHO	#
	###########################################
movimenta_fantasma_vermelho:
	move	$t7, $ra
    	zera_arrazy_traversia()
   	lw	$a2, direcao_fvermelho
	lw	$t5, fantasma_vermelho 
	  
	addi	$t5, $t5, -20 #pra por na posicao certa da verificacao do caminho
	addi	$t5, $t5, -2048
	jal	verifica_traversia
    	beq	$a3, 0, anda_vermelho # se não existe a traversia continua na mesma direcao
    	lw   $t1, posicao_vermelho
   
    	
add	$t2, $zero,$zero
mul	$t1,$t1,4
#Verifica o do 
loop_verificar_se_travessia_vermelho:
 	lw	$t6, array_travessia ($t1)
 	beq	$t6,1, mover_vermelho
 	beq	$t1, 16, resetar_travessia_vermelho
 	addi	$t1, $t1, 4
 	beqz	$t6,loop_verificar_se_travessia_vermelho
 	j	salvar_ponteiro_vermelho
resetar_travessia_vermelho:
	add	$t1, $zero, $zero
	j loop_verificar_se_travessia_vermelho
salvar_ponteiro_vermelho:
	
mover_vermelho:
	div	$t1,$t1,4
	addi	$t1, $t1, 1

	beq	$t1, 4, resetar_posicao
	sw	$t1, posicao_vermelho
	sw	$t1, direcao_fvermelho
	j	anda_vermelho

resetar_posicao:
	sw  	$zero,posicao_vermelho
	#Chamae mover macro aq

#ponteiro 0- direita, 1- esquerda, 2-cima, 3-baixo

anda_vermelho:
	lw	$a0, direcao_fvermelho
	la	$v0, direcao_fvermelho
	addi	$a0, $a0, -1
	
	
	beq	$a0, 0, vermelho_direita
	beq	$a0, 1, vermelho_esquerda
	beq	$a0, 2, vermelho_cima
	beq	$a0, 3, vermelho_baixo
	j	exit_vermelho
vermelho_direita:
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	la	$a2, fantasma_vermelho
	lw	$a1, fantasma_tam 
	beqz	$t1, direita_contrario
		move_fantasma_direita($a2, $a1, 1)
	j	exit_vermelho
vermelho_esquerda:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	la	$a2, fantasma_vermelho
	lw	$a1, fantasma_tam
	beqz	$t1, esquerda_contrario 
		move_fantasma_esquerda($a2, $a1,1)
	j	exit_vermelho
vermelho_cima:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	
	la	$a2, fantasma_vermelho
	lw	$a1, fantasma_tam 
	beqz	$t1, cima_contrario
		move_fantasma_cima($a2, $a1,1)
	j	exit_vermelho
vermelho_baixo:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	la	$a2, fantasma_vermelho
	lw	$a1, fantasma_tam 
	beqz	$t1, baixo_contrario
		move_fantasma_baixo($a2, $a1,1)
		
exit_vermelho:
	
	#Chamar funcao mover() para a posicao q ele ja tava andando antes 
	jr	$t7	

	###########################################
	#	MOVIMENTA FANTASMA LARANJA	#
	###########################################
movimenta_fantasma_laranja:
	move	$t7, $ra
	
	zera_arrazy_traversia()
    	lw	$a2, direcao_flaranja
	lw	$t5, fantasma_laranja 
	addi	$t5, $t5, -20 #pra por na posicao certa da verificacao do caminho
	addi	$t5, $t5, -2048
	jal	verifica_traversia
    	beq	$a3, 0, anda_laranja # se não existe a traversia continua na mesma direcao
    	
    	lw $t1, direcao_pacman
    	beqz $t1, exit_laranja
    	#0parad, 1- direira, 2- esq, 3- cima, 4- baixo
#Trocar posicao
	beq $t1, 1, trocar_esquerda
	beq $t1, 2, trocar_direita
	beq $t1, 3, trocar_baixo
	beq $t1, 4, trocar_cima
trocar_esquerda:
	addi $t1, $zero,2
	j verificar_laranja
trocar_direita:
	addi $t1, $zero,1
	j verificar_laranja
trocar_baixo:
	addi $t1, $zero,4
	j verificar_laranja
trocar_cima:
	addi $t1, $zero,3
	
verificar_laranja:	
add $t2, $zero,$zero
addi $t1, $t1, -1
mul $t1,$t1,4
 loop_verificar_se_travessia_laranja:
 	lw 	$t6, array_travessia ($t1)
 	beq 	$t6,1, mover_laranja
 	beq 	$t1, 16, resetar_travessia_laranja
 	addi 	$t1, $t1, 4
 	beq	$t6, 1,loop_verificar_se_travessia_laranja
 	j 	mover_laranja
resetar_travessia_laranja:
	add	$t1, $zero, $zero
	j	loop_verificar_se_travessia_laranja
mover_laranja:
	div 	$t1,$t1,4
	addi 	$t1,$t1,1
	sw $t1, direcao_flaranja
anda_laranja:
	lw	$a0, direcao_flaranja
	la	$v0,direcao_flaranja
	
	addi	$a0, $a0, -1
	
	beq	$a0, 0, laranja_direita
	beq	$a0, 1, laranja_esquerda
	beq	$a0, 2, laranja_cima
	beq	$a0, 3, laranja_baixo
	j	exit_laranja
laranja_direita:
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0)
	
	la	$a2, fantasma_laranja
	lw	$a1, fantasma_tam 
	beqz	$t1, direita_contrario
		move_fantasma_direita($a2, $a1, 1)
	j	exit_laranja
laranja_esquerda: 
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0)
  
	la	$a2, fantasma_laranja
	lw	$a1, fantasma_tam 
	beqz	$t1, esquerda_contrario
	
		move_fantasma_esquerda($a2, $a1,1)
	j	exit_laranja
laranja_cima:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0)

		la	$a2, fantasma_laranja
	lw	$a1, fantasma_tam 
	beqz	$t1, cima_contrario
	
		move_fantasma_cima($a2, $a1,1)
	j	exit_laranja
laranja_baixo:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 

	la	$a2, fantasma_laranja
	lw	$a1, fantasma_tam 
	beqz	$t1, baixo_contrario
		move_fantasma_baixo($a2, $a1,1)
exit_laranja:
	lw $t4, direcao_flaranja
	#Chamar funcao mover() para a posicao q ele ja tava andando antes 
	jr	$t7	
	
	###########################################
	#	MOVIMENTA FANTASMA ROSA	#
	###########################################
movimenta_fantasma_rosa:
	move	$t7, $ra
    	zera_arrazy_traversia()
	lw	$t5, fantasma_rosa  
	lw	$a2, direcao_frosa
	addi	$t5, $t5, -20 #pra por na posicao certa da verificacao do caminho
	addi	$t5, $t5, -2048
	jal	verifica_traversia
	beq	$a3, 0, anda_rosa # se não existe a traversia continua na mesma direcao
    
loop_random_rosa:   
	li	$v0, 42        #Syscall Random
	li	$a1, 3         # Valor max
	syscall           # Pegar em a0
    
	mul	$t5, $a0,4
	lw	$t2, array_travessia($t5)
	beqz	$t2, loop_random_rosa
	addi	$a0, $a0,1   #Ajeita pra ficar igual ao Array normal
 
 # para,direit, esq, cima, baixo
	sw	$a0, direcao_frosa
anda_rosa:
	lw	$a0, direcao_frosa
	la	$v0,direcao_frosa
	
	addi	$a0, $a0, -1
	
	beq	$a0, 0, rosa_direita
	beq	$a0, 1, rosa_esquerda
	beq	$a0, 2, rosa_cima
	beq	$a0, 3, rosa_baixo
	j	exit_rosa
rosa_direita:
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 

	
	la	$a2, fantasma_rosa
	lw	$a1, fantasma_tam 
	
	beqz	$t1, direita_contrario
		
		move_fantasma_direita($a2, $a1, 1)
	j	exit_rosa

rosa_esquerda:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 

	
	la	$a2, fantasma_rosa
	lw	$a1, fantasma_tam 
	
	beqz	$t1, esquerda_contrario
	
		move_fantasma_esquerda($a2, $a1,1)
	j	exit_rosa
rosa_cima:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 

	la	$a2, fantasma_rosa
	lw	$a1, fantasma_tam 
	
	beqz	$t1, cima_contrario
	
		move_fantasma_cima($a2, $a1,1)
	j	exit_rosa
rosa_baixo:  
	
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	la	$a2, fantasma_rosa
	lw	$a1, fantasma_tam 
	
	beqz	$t1, baixo_contrario
	
		move_fantasma_baixo($a2, $a1,1)
	
	j	exit_rosa
exit_rosa:

	jr	$t7

	###########################################
	#	MOVIMENTA FANTASMA AZUL	#
	###########################################
movimenta_fantasma_azul:
	lw	$v0, direcao_pacman
	move	$t7, $ra
    zera_arrazy_traversia()
   	lw	$a2, direcao_fazul
	lw	$t5, fantasma_azul  
	addi	$t5, $t5, -20 #pra por na posicao certa da verificacao do caminho
	addi	$t5, $t5, -2048
	jal	verifica_traversia
    	beq	$a3, 0, anda_azul # se não existe a traversia continua na mesma direcao
    	lw $t1, direcao_pacman
    	beqz $t1, exit_azul
    	
add	$t2, $zero,$zero
addi	$t1, $t1, -1
mul	$t1,$t1,4

loop_verificar_se_travessia_azul:
 	lw	$t6, array_travessia ($t1)
 	beq	$t6,1, mover_azul
 	
 	beq	$t1, 16, resetar_atravessia_azul
 	addi	$t1, $t1, 4
 	beqz	$t6,loop_verificar_se_travessia_azul
 	j 	mover_azul
resetar_atravessia_azul:
	#sw	$zero, array_travessia($t2)
	#addi	$t2, $t2, 4
	add	$t1, $zero, $zero
	j	loop_verificar_se_travessia_azul
mover_azul:
	div	$t1,$t1,4
	addi	$t1, $t1, 1
	#Chamae mover macro aq
#pacman_dir:  0 - parado, 1- direita, 2- esquerda, 3- cima, 4-baixo
#array_travessia 0- direita, 1- esquerda, 2-cima, 3-baixo

	sw $t1, direcao_fazul
anda_azul:
	lw	$a0, direcao_fazul
	la	$v0, direcao_fazul
	addi	$a0, $a0, -1
	
	
	beq	$a0, 0, azul_direita
	beq	$a0, 1, azul_esquerda
	beq	$a0, 2, azul_cima
	beq	$a0, 3, azul_baixo
	j	exit_azul
azul_direita:
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	la	$a2, fantasma_azul
	lw	$a1, fantasma_tam 
	beqz	$t1, direita_contrario
		move_fantasma_direita($a2, $a1, 1)
	j	exit_azul
azul_esquerda:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	la	$a2, fantasma_azul
	lw	$a1, fantasma_tam
	beqz	$t1, esquerda_contrario 
		move_fantasma_esquerda($a2, $a1,1)
	j	exit_azul
azul_cima:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	
	la	$a2, fantasma_azul
	lw	$a1, fantasma_tam 
	beqz	$t1, cima_contrario
		move_fantasma_cima($a2, $a1,1)
	j	exit_azul
azul_baixo:  
	mul	$a0,$a0,4
	lw	$t1,array_travessia ($a0) 
	
	la	$a2, fantasma_azul
	lw	$a1, fantasma_tam 
	beqz	$t1, baixo_contrario
		move_fantasma_baixo($a2, $a1,1)
		
exit_azul:
	
	#Chamar funcao mover() para a posicao q ele ja tava andando antes 
	jr	$t7	
cima_contrario:
	move_fantasma_baixo($a2, $a1,1)
	li	$a0, 4
	sw	$a0, ($v0)
	jr	$t7	
baixo_contrario:
	move_fantasma_cima($a2, $a1,1)
	li	$a0, 3
	sw	$a0, ($v0)
	jr	$t7	
direita_contrario:
	move_fantasma_esquerda($a2, $a1,1)
	li	$a0, 2
	sw	$a0, ($v0)
	jr	$t7	
esquerda_contrario:
	move_fantasma_direita($a2, $a1,1)
	li	$a0, 1
	sw	$a0, ($v0)
	jr	$t7		
    	########################################################
    	#    VERIFICA SE O FANTASMA TA EM UMA TRAVERSIA        #
    	#     	0 : DIREITA	(tem valor 1)              #
    	#     	1 : ESQUERDA   (tem valor 2 )            #
	#	2 : CIMA        (tem valor 3)            #
	#	3 : BAIXO        (tem valor 4)           #
   	 #######################################################
verifica_traversia:
	li	$t9, 0
	move	$t8, $ra
verifica_traversia_direita:
    
	addi	$t3, $t5,60
	addi	$t3, $t3,2048
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal	verifica_laterais 
	beq	$a3, 1, verifica_traversia_esquerda
    
	li	$t2, 1 #quando é possível ir para a direita
	sw	$t2,array_travessia($t9)
    
    
verifica_traversia_esquerda:
	addi	$t9, $t9, 4
	
    	move	$t3, $t5
    	addi	$t3, $t3,-8
    	addi	$t3, $t3,2048
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal 	verifica_laterais
	beq	$a3, 1, verifica_traversia_cima
    
	li	$t2, 1 #quando é possível ir para a esquerda
	sw	$t2,array_travessia($t9)


verifica_traversia_cima:
	addi	$t9, $t9, 4
    
	addi	$t3, $t5,0
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal	verifica_topos
	beq	$a3, 1, verifica_traversia_baixo
    
	li	$t2, 1 #quando é possível ir para a cima
	sw	$t2,array_travessia($t9)
    
    
verifica_traversia_baixo:
	addi	$t9, $t9, 4

	addi	$t3, $t5,15360
	addi	$t3, $t3,3072
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal	verifica_topos
	beq	$a3, 1, verifica_traversia_exit
    
	li	$t2, 1 #quando é possível ir para a baixo
	sw	$t2,array_travessia($t9)
    
verifica_traversia_exit:
	jal	verifica_valor_no_array
	jr	$t8
        
        ########################################################
        #    VERIFICA SE A DIRECAO QUE O FANTASMA ESTÁ INDO 
        #    ESTÁ EM UMA POSICAO DE TRAVERSIA DADO OS VALORES
        #    DO ARRAY
        #    a3 -> 0 se nao existe traversia
        #    a3 -> 1 se existe traversia
        #########################################################
verifica_valor_no_array:

	beq	$a2, 0, tem_traversia
	beq	$a2, 1, verifica_array_topos
	beq	$a2, 2, verifica_array_topos
	beq	$a2, 3, verifica_array_laterais
	beq	$a2, 4, verifica_array_laterais
verifica_array_topos:
	lw	$t2, array_travessia + 12
	beq	$t2, 1, tem_traversia
        
	lw	$t2, array_travessia + 8
	beq	$t2, 1, tem_traversia
	j	n_tem_traversia
        
verifica_array_laterais:
	lw	$t2, array_travessia + 0
	beq	$t2, 1, tem_traversia
        
	lw	$t2, array_travessia + 4
	beq	$t2, 1, tem_traversia
	j	n_tem_traversia
n_tem_traversia:
	li	$a3, 0
	jr	$ra
tem_traversia:
	li	$a3, 1
	jr	$ra
 

	###########################################
	#	TRANSICAO DE ESTAGIO	#
	###########################################
transicao_estagio:
	move	$t7, $ra
	li	$t8, 0
	li	$t9, 261120
transicao_loop:
	sleep(10)
	beq	$t9, 130048, transicao_exit
	move	$t3, $t8 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 1020 #canto topo direito do retangulo 36
	addi	$t5, $t6, 0 #canto inferior direito do retangulo
	lw	$t1, cor_preto
	jal	pinta_retangulo
	
	move	$t3, $t9 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 1020 #canto topo direito do retangulo 36
	addi	$t5, $t6, 0 #canto inferior direito do retangulo
	lw	$t1, cor_preto
	jal	pinta_retangulo
	
	addi 	$t9, $t9, -1024
	addi	$t8, $t8, 1024
	j	transicao_loop
	
transicao_exit:
	sleep(1000)
	jr	$t7

	#########################################
	#	PINTA A TELA TODA DE PRETO	#
	#########################################
pintar_tela:
	lw $t0, bitmap_addr
	lw $t1, cor_preto
	lw $t2, bitmap_size
	move $t3, $zero #contador de pixels
	
	
bitmap_loop:
	beq $t3, $t2, bitmap_exit #verifica se já é o ultimo endereco
	sll $t4, $t3, 2  #multiplica por 4
	add $t4, $t4, $t0 # pega a posicao certa do endereco
	sw $t1, 0($t4) #armazena a cor no endereco
	addi $t3, $t3, 1 #incrementa t3
	j bitmap_loop #retorna ao loop
	
bitmap_exit:
	jr	$ra
	####################################################################3
	#	VERIFICA SE TODOS OS PONTOS DO MAPA FORAM COMIDOS
	####################################################################
verificar_ganho_fase1:
	lw	$s7, pontuacao
	beq	$s7, 100, fase2 #trocar pra fase2
	jr	$ra
verificar_ganho_fase2:
	lw	$s7, pontuacao
	beq	$s7, 209, venceu
	jr	$ra
	
	#########################################################
	#	MOSTRA PLACAR DE PONTUACAO DO JOGO	#
	#########################################################
mostra_placar:
	move 	$t7, $ra
	
	lw 	$t9, pontuacao # pega a pontuacao atual
	
	# pega o digito da terceira casa e salva em a2 
	li 	$a1, 3	# posicao da casa
	div	$a2, $t9, 100 #pega o digito da centena só	
	mul 	$t1, $a2, 100 #tranforma em centena novamente
	sub 	$t9, $t9, $t1 # subtrai do valor total 			
	jal 	digito_placar

	# pega o digita da segunda casa e salva em a2
	li	$a1, 2	# posicao da casa
	div	$a2, $t9, 10	# pega o digito da dezena
	mul	$t1, $a2, 10	# transforma em dezena novamente
	sub 	$t9, $t9, $t1	# subtrai do valor total para sobrar apenas a unidade			#
	jal	 digito_placar
	
	# pega o digito da primeira casa e armazena em a2
	li	$a1, 1 	#posicao da casa
	move	$a2, $t9		
	jal	digito_placar
	
	jr	$t7
	
	#######################################################################
	#	DESENHA NA TELA UM DIGITO DO PLACAR DADO A SUA POSICAO	#
	#	a2 -> digito				#
	#	a1 -> posicao da casa do digito (1:unidade, 2:dezena, 3:centena)
	#######################################################################
digito_placar:
	move	$t8,$ra
casa1:
	bne	$a1, 1, casa2
	li	$s1, 49696 #endereco onde comeca a primeira casa
	j	pintar_digito
casa2:
	bne	$a1, 2, casa3
	li	$s1, 49648 #endereco onde comeca a segunda casa
	j	pintar_digito
casa3:
	li	$s1, 49600 #endereco onde comeca a terceira casa
pintar_digito:
	
digito_0:
	bne	$a2, 0, digito_1
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,16	#canto topo direito do retangulo
	addi	$t5,$t6, 8192 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_1:
	bne	$a2, 1, digito_2
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,12	#canto topo direito do retangulo
	addi	$t5,$t6, 8192 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,28	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,4	#canto topo direito do retangulo
	addi	$t5,$t6, 10240 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_2:
	bne	$a2, 2, digito_3
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_3:
	bne	$a2, 3, digito_4
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,5120	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,4	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_4:
	bne	$a2, 4, digito_5
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,16	#canto topo direito do retangulo
	addi	$t5,$t6, 4096 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 4096 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo	
	
	j	digito_placar_exit
digito_5:
	bne	$a2, 5, digito_6
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_6:
	bne	$a2, 6, digito_7
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,16	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_7:
	bne	$a2, 7, digito_8
	
	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 10240 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_8:
	bne	$a2, 8, digito_9

	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,16	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,16	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
digito_9:

	addi 	$t3, $s1,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_lab_branco # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,8
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,16	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s1,0
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	j	digito_placar_exit
	
digito_placar_exit:
	jr	$t8
	
	###########################################
	#	PINTA OS PONTOS NO MAPA	#
	###########################################
pinta_pontos_mapa1:
	
	#pontos retangulo esquerdo topo
	move 	$t7, $ra
	
	la	$t8, pontos_mapa1
	move	$v0, $zero
	
	li 	$t3, 74928 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 74928 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	

	li 	$t3, 109744 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 75208 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	
	#pontos no obstaculo U
	li 	$t3, 126408 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	

	li 	$t3, 138748 #canto topo esquerdo do retangulo
	li	$s2, 1
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 110076 #canto topo esquerdo do retangulo
	li	$s2, 1
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 126512 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	
	#pontos retangulo direito topo

	li 	$t3, 75312 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 75312 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	

	li 	$t3, 110128 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 75592 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	#pontos retangulo direito inferior

	li 	$t3, 206384 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 206384 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	

	li 	$t3, 241200 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 206664 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	#pontos retangulo esquerdo inferior 
	li 	$t3, 206000 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 206000 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	

	li 	$t3, 240816 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 206280 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	# pontos dos corredores
	li 	$t3, 123220 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 179540 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 124580 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 180900 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 167492 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_horizontal

	li 	$t3, 166284 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_horizontal
	
	sw	$v0, tam_pontos_mapa1
			
	jr $t7
	
pinta_pontos_mapa2:
	
	#pontos retangulo esquerdo topo
	move 	$t7, $ra
	la	$t8, pontos_mapa2
	move	$v0, $zero
	
	li 	$t3, 74928 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 85168 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 85332 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical

	li 	$t3, 109744 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 75208 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	
	#pontos no obstaculo U
	li 	$t3, 126408 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 110076 #canto topo esquerdo do retangulo
	li	$s2, 1
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 126512 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	
	#pontos retangulo direito topo

	li 	$t3, 75312 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 85552 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 85672 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical

	li 	$t3, 110128 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 75592 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	#pontos retangulo direito inferior

	li 	$t3, 206384 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 216624 #canto topo esquerdo do retangulo +112
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 216736 #canto topo esquerdo do retangulo +112
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical

	li 	$t3, 241200 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 206664 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	#pontos retangulo esquerdo inferior 
	li 	$t3, 206000 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 216240 #canto topo esquerdo do retangulo+164
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 216404 #canto topo esquerdo do retangulo+164
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical

	li 	$t3, 240816 #canto topo esquerdo do retangulo
	li	$s2, 8
	move	$t9, $zero
	jal	pontos_horizontal
	
	li 	$t3, 206280 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	# pontos dos corredores
	li 	$t3, 123220 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 179540 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 124580 #canto topo esquerdo do retangulo
	li	$s2, 3
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 180900 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_vertical
	
	li 	$t3, 167492 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_horizontal

	li 	$t3, 166284 #canto topo esquerdo do retangulo
	li	$s2, 2
	move	$t9, $zero
	jal	pontos_horizontal
	
	sw	$v0, tam_pontos_mapa2
	jr $t7
	
pontos_horizontal:
	move $s3,$ra 
pontos_horizontal_loop:
	#3X3
	addi	$t9, $t9, 1 #incrementa contador
	bgt	$t9,$s2,pontos_exit
	
	add	$v1, $v0, $t8
	sw	$t3, ($v1) #salva a posição do ponto no array
	
	move	$t6, $t3
	addi	$t6, $t6, 8
	move	$t5, $t6
	addi	$t5, $t5, 2048 # 2*1024
	lw	$t1, cor_ponto
	jal 	pinta_retangulo
	
	addi	$v0,$v0,4
	addi	$t3, $t3, -2048 # seta pro topo direito do ponto
	addi	$t3, $t3, 28 #prox ponto em 28 pixeis
	j	pontos_horizontal_loop
pontos_vertical:
	move $s3, $ra
pontos_vertical_loop:
	addi	$t9, $t9, 1 #incrementa contador
	bgt	$t9,$s2,pontos_exit
	
	add	$v1, $v0, $t8
	sw	$t3, ($v1) #salva a posição do ponto no array
	
	move	$t6, $t3
	addi	$t6, $t6, 8
	move	$t5, $t6
	addi	$t5, $t5, 2048 # 2*1024
	lw	$t1, cor_ponto
	jal 	pinta_retangulo
	
	addi	$v0,$v0,4
	addi	$t3, $t3, -12 # seta pro topo direito do ponto
	addi	$t3, $t3, 10240#prox ponto em 28 pixeis
	j	pontos_vertical_loop
pontos_exit:
	jr 	$s3

	
	##########################################################
	#	VERIFICA SE PODE SE MOVER		 #
	##########################################################
#t3 - > pixel mais alto
#t6 - > pixel mais baixo
verifica_laterais:
##MODIFICAR
	bgt	$t3, $t6, verifica_exit #verifica se já é o ultimo endereco
	lw 	$t4, ($t3) 
	addi 	$t3, $t3, 1024 #incrementa t3
	lw	$t1, cor_lab_parede
	beq	$t4, $t1, verifica_exit
	j 	verifica_laterais
	
#t3 - > pixel mais a esquerda
#t6 - > pixel mais a direita
verifica_topos:
	bgt	$t3, $t6, verifica_exit #verifica se já é o ultimo endereco
	lw	$t4, ($t3) 
	addi	$t3, $t3, 4 #incrementa t3
	lw	$t1, cor_lab_parede
	beq	$t4, $t1, verifica_exit
	j	verifica_topos
verifica_exit:
	seq	$a3, $t4, $t1 # se existe barreira entao a3 = 1, senao a3 = 0
	jr	$ra
	

	#######################################################################
	#	VERIFICA SE COME PONTO	
	#	t9 -> se zero = não comeu ponto, 
	#	caso contrario ele contem o valor do endereço do pixel
	#	 mais alto ou mais a esquerda do ponto
	#######################################################################
come_ponto_topo:
	move 	$t9, $zero
#t3 - > pixel mais a esquerda
#t6 - > pixel mais a direita
come_ponto_topo_loop:
	bgt	$t3, $t6, come_ponto_exit #verifica se já é o ultimo endereco
	lw	$t4, ($t3) 
	lw	$t1, cor_ponto
	beq	$t4, $t1, comeu
	addi	$t3, $t3, 4 #incrementa t3
	j	come_ponto_topo_loop
come_ponto_lateral:
	move	$t9, $zero
#t3 - > pixel mais alto
#t6 - > pixel mais baixo
come_ponto_lateral_loop:
##MODIFICAR

	bgt	$t3, $t6, come_ponto_exit #verifica se já é o ultimo endereco
	lw 	$t4, ($t3) 
	lw	$t1, cor_ponto
	beq	$t4, $t1, comeu
	addi 	$t3, $t3, 1024 #incrementa t3
	j 	come_ponto_lateral_loop
	
comeu:
	move	$t9, $t3
come_ponto_exit:
	jr	$ra
	
	###########################################################
	#	MOVIMENTA		                #
	#	a2: o endereco do vetor a ser movimentado   #
	#	a1: tamanho do array                        #
	###########################################################
move_map1:
	move	$s1, $ra
	la	$v0, pontos_mapa1
	lw	$v1, tam_pontos_mapa1
	tirar_ponto($v0, $v1, $t3)
	jr	$s1
move_map2:
	move	$s4, $ra
	la	$v0, pontos_mapa2
	lw	$v1, tam_pontos_mapa2
	tirar_ponto($v0, $v1, $t3)
	jr	$s4
move_direita:
	move	$t5, $zero
	move 	$a3, $ra
	
	
	addi	$t3, $t3, -13312
	jal	come_ponto_lateral
	beqz	$t9, n_come_ponto_direita
come_ponto_direita: #apaga o ponto que comeu do mapa e incrementa a pontuacao
	
	lw	$s7, pontuacao #Incrementa a pontuacao
	addi	$s7, $s7, 1
	sw	$s7, pontuacao
	
		
	lw	$t0, bitmap_addr
	sub 	$t9, $t9, $t0 #sub pra nao add 2 vezes pois chama o pinta_labrinto que soma com t0
	addi	$t3, $t9, 0
	move	$t6, $t3
	addi	$t6, $t6, 8
	move	$t5, $t6
	addi	$t5, $t5, 2048 # 2*1024
	
	lw	$s6, nivel
	beq 	$s6, 1, move_map1dir
	beq 	$s6, 2, move_map2dir
move_map1dir:
	jal move_map1
	j despinta_dir
move_map2dir:
	jal move_map2
despinta_dir:
	lw	$t1, cor_preto
	jal 	pinta_retangulo
	
	move	$s6, $a1
	move	$s7, $a2
	move	$s5, $t7
	jal 	mostra_placar
	move	$a1,$s6
	move	$a2,$s7
	move	$t7,$s5

n_come_ponto_direita:
	#jal 	limpa_personagens
	move	$t5, $zero
direita_loop:
	add 	$t2, $t5, $a2
	lw	$t4, ($t2)
	addi	$t4, $t4, 4
	sw	$t4, ($t2)
	addi	$t5, $t5, 4
	bgt	$t5, $a1, move_exit
	#jal	pinta_personagens
	j	direita_loop
	#bgt	$t4, 0x10010000, acima_loop_ext
move_esquerda:
	move 	$a3, $ra
	
	addi	$t3, $t3, -13312
	jal	come_ponto_lateral
	beqz	$t9, n_come_ponto_esquerda
come_ponto_esquerda: #apaga o ponto que comeu do mapa e incrementa a pontuacao
	lw	$s7, pontuacao #Incrementa a pontuacao
	addi	$s7, $s7, 1
	sw	$s7, pontuacao

	
	lw	$t0, bitmap_addr
	sub 	$t9, $t9, $t0 #sub pra nao add 2 vezes pois chama o pinta_labrinto que soma com t0
	addi	$t3, $t9, -8
	move	$t6, $t3
	addi	$t6, $t6, 8
	move	$t5, $t6
	addi	$t5, $t5, 2048 # 2*1024
	
	lw	$s6, nivel
	beq 	$s6, 1, move_map1esq
	beq 	$s6, 2, move_map2esq
move_map1esq:
	jal move_map1
	j despinta_esq
move_map2esq:
	jal move_map2
despinta_esq:
	
	lw	$t1, cor_preto
	jal 	pinta_retangulo
	
	move	$s6, $a1
	move	$s7, $a2
	move	$s5, $t7
	jal 	mostra_placar
	move	$a1,$s6
	move	$a2,$s7
	move	$t7,$s5
n_come_ponto_esquerda:

	#jal	limpa_personagens
	move	$t5, $zero
esquerda_loop:
	add $t2, $t5, $a2
	lw	$t4, ($t2)#pacman_dir($t5)
	addi	$t4, $t4, -4
	sw	$t4, ($t2)
	addi	$t5, $t5, 4
	bgt	$t5, $a1, move_exit
	#jal	pinta_personagens
	j esquerda_loop
	#bgt	$t4, 0x10010000, acima_loop_ext

move_cima:
	move 	$a3, $ra
	addi	$t3, $t3, -52
	jal	come_ponto_topo
	beqz	$t9, n_come_ponto_cima
come_ponto_cima: #apaga o ponto que comeu do mapa e incrementa a pontuacao
	lw	$s7, pontuacao #Incrementa a pontuacao
	addi	$s7, $s7, 1
	sw	$s7, pontuacao

	
	lw	$t0, bitmap_addr
	sub 	$t9, $t9, $t0 #sub pra nao add 2 vezes pois chama o pinta_labrinto que soma com t0
	addi	$t3, $t9, -2048
	move	$t6, $t3
	addi	$t6, $t6, 8
	move	$t5, $t6
	addi	$t5, $t5, 2048 # 2*1024
	
	lw	$s6, nivel
	beq 	$s6, 1, move_map1cima
	beq 	$s6, 2, move_map2cima
move_map1cima:
	jal move_map1
	j despinta_cima
move_map2cima:
	jal move_map2
despinta_cima:
	
	lw	$t1, cor_preto
	jal 	pinta_retangulo
	
	move	$s6, $a1
	move	$s7, $a2
	move	$s5, $t7
	jal 	mostra_placar
	move	$a1,$s6
	move	$a2,$s7
	move	$t7,$s5
	
n_come_ponto_cima:
	#jal 	limpa_personagens
	move	$t5, $zero
acima_loop:
	add $t2, $t5, $a2
	lw	$t4, ($t2)#pacman_dir($t5)
	addi	$t4, $t4, -1024 #decremenat a linha
	sw	$t4, ($t2)
	addi	$t5, $t5, 4
	bgt	$t5, $a1, move_exit
	#jal	pinta_personagens
	j acima_loop
	#bgt	$t4, 0x10010000, acima_loop_ext
	
move_baixo:
	move	 $a3, $ra
	
	addi	$t3, $t3, -52 
	jal	come_ponto_topo
	beqz	$t9, n_come_ponto_baixo
come_ponto_baixo: #apaga o ponto que comeu do mapa e incrementa a pontuacao
	lw	$s7, pontuacao #Incrementa a pontuacao
	addi	$s7, $s7, 1
	sw	$s7, pontuacao

	
	lw	$t0, bitmap_addr
	sub 	$t9, $t9, $t0 #sub pra nao add 2 vezes pois chama o pinta_labrinto que soma com t0
	addi	$t3, $t9, 0
	move	$t6, $t3
	addi	$t6, $t6, 8
	move	$t5, $t6
	addi	$t5, $t5, 2048 # 2*1024
	
	lw	$s6, nivel
	beq 	$s6, 1, move_map1baixo
	beq 	$s6, 2, move_map2baixo
move_map1baixo:
	jal move_map1
	j despinta_baixo
move_map2baixo:
	jal move_map2
despinta_baixo:
	
	lw	$t1, cor_preto
	jal 	pinta_retangulo
	
	move	$s6, $a1
	move	$s7, $a2
	move	$s5, $t7
	jal 	mostra_placar
	move	$a1,$s6
	move	$a2,$s7
	move	$t7,$s5
	
n_come_ponto_baixo:

	#jal	 limpa_personagens
	move	$t5, $zero
baixo_loop:
	add 	$t2, $t5, $a2
	lw	$t4, ($t2)#pacman_dir($t5)
	addi	$t4, $t4, 1024
	sw	$t4, ($t2)
	addi	$t5, $t5, 4
	bgt	$t5, $a1, move_exit
	#jal	pinta_personagens
	j	baixo_loop
	#bgt	$t4, 0x10010000, acima_loop_ext
move_exit:
	#jal	pinta_personagens

	jr	$a3
	
	########################################################
	#	VERIFICA QUAL A MOVIMENTACAO A SER FEITA #
	#	1 : DIREITA                              #
	#	2 : ESQUERDA		             #
	#	3 : CIMA                                 #
	#	4 : BAIXO                                #
	########################################################
	#VERIFICA SE PODE MOVER PARA A PROXIMA DIRECAO
direita_prox:
	move	$t7, $ra
#depois botar pra todos os lados do pacman
	lw	$v0, direcao_pacman
	lw	$v1, direcao_pacman_prox
	
	bne	$v1, 1, esquerda_prox
	
	lw 	$t3, pacman_dir + 16 #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -1004
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal 	verifica_laterais
	beq	$a3, 1, direita
	
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_direita
	
	li	$v1, 1
	sw	$v1, direcao_pacman
	
	jr	$t7
esquerda_prox:
	bne	$v1, 2, cima_prox
	
	lw 	$t3, pacman_dir #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -1052
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal 	verifica_laterais
	beq	$a3, 1, direita
		
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_esquerda
	
	li	$v1, 2
	sw	$v1, direcao_pacman
	
	jr	$t7
cima_prox:
	bne	$v1, 3, baixo_prox
	
	lw 	$t3, pacman_dir #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -2072
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal 	verifica_topos
	beq	$a3, 1, direita
	
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_cima
	
	li	$v1, 3
	sw	$v1, direcao_pacman
	jr	$t7
	#j	main_1
baixo_prox:
	bne	$v1, 4, direita
	
	lw 	$t3, pacman_dir + 428 #pega o canto da borda de cima do pacman
	addi	$t3, $t3, 2024
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal 	verifica_topos
	beq	$a3, 1, direita
	
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_baixo
	
	li	$v1, 4
	sw	$v1, direcao_pacman
	jr	$t7
	
	##CONTINUA MOVENDO NA DIRECAO ATUAL	
direita:
	#move $t7, $ra
#depois botar pra todos os lados do pacman
	bne	$v0, 1, esquerda
	
	lw 	$t3, pacman_dir + 16 #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -1004
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal 	verifica_laterais
	beq	$a3, 1, nenhum
	
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_direita
	jr	$t7
esquerda:
	bne	$v0, 2, cima
	
	lw 	$t3, pacman_dir #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -1052
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal 	verifica_laterais
	beq	$a3, 1, nenhum
		
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_esquerda
	jr	$t7
cima:
	bne	$v0, 3, baixo
	
	lw 	$t3, pacman_dir #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -2072
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal 	verifica_topos
	beq	$a3, 1, nenhum
	
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_cima
	jr	$t7
	#j	main_1
baixo:
	bne	$v0, 4, nenhum
	
	lw 	$t3, pacman_dir + 428 #pega o canto da borda de cima do pacman
	addi	$t3, $t3, 2024
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal 	verifica_topos
	beq	$a3, 1, nenhum
	
	la	$a2, pacman_dir
	lw 	$a1, pacman_tam
	jal	move_baixo
	jr	$t7
nenhum:
	jr	$t7
	
	#########################################################
	#	OBTEM TECLA PARA AS MOVIMENTACOES         #
	#	W,A,S,D                                   #
	#########################################################
obter_teclado:
##Salva qual a movimentacao é no v0
#salva a prox mocimentacao em v1
	move	$t7, $ra
	lw	$t0, 0xFFFF0004		
tecla_direita:
	bne 	$t0, 100, tecla_esquerda
	
	lw 	$t3, pacman_dir + 16 #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -1004
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal 	verifica_laterais
	li	$v1, 1
	sw	$v1, direcao_pacman_prox
	beq	$a3, 1, tecla_voltar
	
	li 	$v0,1
	sw	$v0, direcao_pacman
	j 	tecla_voltar
tecla_esquerda:
	bne	$t0, 97, tecla_cima
	
	lw 	$t3, pacman_dir #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -1052
	move	$t6, $t3
	addi	$t6, $t6, 13312
	jal 	verifica_laterais
	li	$v1, 2
	sw	$v1, direcao_pacman_prox
	beq	$a3, 1, tecla_voltar
	
	li 	$v0, 2
	sw	$v0, direcao_pacman
	j 	tecla_voltar
tecla_cima:
	bne	 $t0, 119, tecla_baixo
	
	lw 	$t3, pacman_dir #pega o canto da borda de cima do pacman
	addi	$t3, $t3, -2072
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal 	verifica_laterais
	li	$v1, 3
	sw	$v1, direcao_pacman_prox
	beq	$a3, 1, tecla_voltar
	
	li	 $v0, 3
	sw	$v0, direcao_pacman
	j	 tecla_voltar
tecla_baixo:
	bne	 $t0, 115, tecla_voltar
	
	lw 	$t3, pacman_dir + 428 #pega o canto da borda de cima do pacman
	addi	$t3, $t3, 2072
	move	$t6, $t3
	addi	$t6, $t6, 52
	jal 	verifica_laterais
	li	$v1, 4
	sw	$v1, direcao_pacman_prox
	beq	$a3, 1, tecla_voltar
	
	li	 $v0, 4
	sw	$v0,direcao_pacman
	#j tecla_voltar
tecla_voltar:
	#li $t0, 0xFFFF0004
	#sw $zero, ($t0)
	jr	$t7

	#########################################################
	#	POVOA COM OS ENDERECOS DOS PERSONAGENS	#
	#########################################################
cria_personagens:
	#$t3 -> enderco a esquerda da linha 
	#$t6 -> endereco a direita da linha
	#t5 -> endereco do ultimo pixel a adicionar
	#t8 -> endereco do array
	move	$t7, $ra
	
	#mapa1
personagens_mapa1:
	move	$t7, $ra
#pacman 
	la	$t8, pacman_dir
	li	$t2, 0
	
	li	$s6,237048 #endereco do pixel esquerdo do topo
	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,2048
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,3072
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,4096
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	jal	addr_retangulo
		
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,5120
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,6144
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,7168
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	jal	addr_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,8192
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,9216
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	jal	addr_retangulo
	

	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,10240
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,11264
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	jal	addr_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,12288
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	jal	addr_retangulo
	

#fantasma Vermelho
	la	$t8, fantasma_vermelho
	li	$t2, 0
	
	li	$s6,161276 #endereco do pixel esquerdo do topo
	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,12 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,28 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,36 
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,2048
	move	$t6, $t3
	addi	$t6, $t6,44 
	move	$t5, $t6
	addi	$t5, $t5, 2048
	jal	addr_retangulo  
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,5120
	move	$t6, $t3
	addi	$t6, $t6,52 
	move	$t5, $t6
	addi	$t5, $t5, 5120
	jal	addr_retangulo
	
	##calda
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,12
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	#calda linha 2
	move	$t3, $s6
	addi	$t3,$t3,4
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
###############	
#fantasma rosa#
###############
	la	$t8, fantasma_rosa
	li	$t2, 0
	
	li	$s6,179708 #endereco do pixel esquerdo do topo
	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,12 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,28 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,36 
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,2048
	move	$t6, $t3
	addi	$t6, $t6,44 
	move	$t5, $t6
	addi	$t5, $t5, 2048
	jal	addr_retangulo  
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,5120
	move	$t6, $t3
	addi	$t6, $t6,52 
	move	$t5, $t6
	addi	$t5, $t5, 5120
	jal	addr_retangulo
	
	##calda
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,12
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	#calda linha 2
	move	$t3, $s6
	addi	$t3,$t3,4
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
##################	
#fantasma laranja#
##################
	la	$t8, fantasma_laranja
	li	$t2, 0
	
	li	$s6,179780 #endereco do pixel esquerdo do topo
	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,12 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,28 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,36 
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,2048
	move	$t6, $t3
	addi	$t6, $t6,44 
	move	$t5, $t6
	addi	$t5, $t5, 2048
	jal	addr_retangulo  
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,5120
	move	$t6, $t3
	addi	$t6, $t6,52 
	move	$t5, $t6
	addi	$t5, $t5, 5120
	jal	addr_retangulo
	
	##calda
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,12
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	#calda linha 2
	move	$t3, $s6
	addi	$t3,$t3,4
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
###############
#fantasma azul#
###############
	la	$t8, fantasma_azul
	li	$t2, 0
	
	li	$s6,179636 #endereco do pixel esquerdo do topo
	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,12 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,28 
	move	$t5, $t6
	jal	addr_retangulo 
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	move	$s6, $t3
	move	$t6, $t3
	addi	$t6, $t6,36 
	move	$t5, $t6
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,2048
	move	$t6, $t3
	addi	$t6, $t6,44 
	move	$t5, $t6
	addi	$t5, $t5, 2048
	jal	addr_retangulo  
	
	move	$t3, $s6
	addi	$t3,$t3,-4
	addi	$t3,$t3,1024
	addi	$s6, $t3,5120
	move	$t6, $t3
	addi	$t6, $t6,52 
	move	$t5, $t6
	addi	$t5, $t5, 5120
	jal	addr_retangulo
	
	##calda
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,12
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,8 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	#calda linha 2
	move	$t3, $s6
	addi	$t3,$t3,4
	addi	$t3,$t3,1024
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-20
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,4 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	addi	$s6, $t3,0
	move	$t6, $t3
	addi	$t6, $t6,0 
	move	$t5, $t6
	addi	$t5, $t5, 0
	jal	addr_retangulo
	
	jr	$t7
	
	#mapa2
personagens_mapa2:

	jr	$t7
	
	#######################################################################
	#	POVOA O ARRAY COM ENDERECOS BASEADO NO MAPA	#
	#######################################################################
addr_retangulo:
	subu	$t2, $t6, $t3 #pega a quantidade de posições entre uma ponta e outra
	
addr_largura:

	bgt	$t3, $t6, addr_altura #verifica se já é o ultimo endereco
	move	$t4, $t3 #multiplica por 4
	add	$t4, $t4, $t0 # pega a posicao certa do endereco 
	sw	$t4,0($t8) #escreve no array a palavra em t4
	addi	$t3, $t3, 4 #incrementa t3
	addi	$t8, $t8, 4 #incrementa t8
	j	addr_largura #retorna ao loop
addr_altura:
	bgt	$t3, $t5, exit_addr
	addi	$t6, $t6, 1024 #pula a linha
	subu	$t3, $t6, $t2 # nova posição do canto esquerdo, baseado na distancia de t6 e t3
	j	addr_largura
exit_addr:
	jr	$ra
	
	#########################################################
	#	PINTA E LIMPA OS PERSONAGENS	#
	#########################################################		
pinta_personagens:
	move	$s7, $ra
#pacman
	lw	$t1, cor_pacman
	move	$t2, $zero
	la	$t8, pacman_dir
	lw	$t4, pacman_tam
	jal	pinta_personagens_loop
	
#fantasma vermelho
	lw	$t1, cor_fantasma_vermelho
	move	$t2, $zero
	la	$t8, fantasma_vermelho
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop
	
#fantasma laranja
	lw	$t1, cor_fantasma_laranja
	move	$t2, $zero
	la	$t8, fantasma_laranja
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop

#fantasma azul
	lw	$t1, cor_fantasma_azul
	move	$t2, $zero
	la	$t8, fantasma_azul
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop
	
#fantasma rosa
	lw	$t1, cor_fantasma_rosa
	move	$t2, $zero
	la	$t8, fantasma_rosa
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop
	
	jr	$s7
limpa_personagens:
	move	$s7, $ra
	lw	$t1, cor_preto
	
	move	$t2, $zero
	la	$t8, pacman_dir
	lw	$t4, pacman_tam
	jal	pinta_personagens_loop
#fantasma rosa
	move	$t2, $zero
	la	$t8, fantasma_rosa
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop
#fantasma azul
	move	$t2, $zero
	la	$t8, fantasma_azul
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop
	
#fantasma laranja
	move	$t2, $zero
	la	$t8, fantasma_laranja
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop

#fantasma vermelho
	move	$t2, $zero
	la	$t8, fantasma_vermelho
	lw	$t4, fantasma_tam
	jal	pinta_personagens_loop
	
	jr	$s7
pinta_personagens_loop:

	add 	$t9, $t2, $t8
	lw	$t3, ($t9)
	sw	$t1, ($t3)
	addi	$t2, $t2, 4
	bgt	$t2, $t4, pinta_personagens_exit
	j	pinta_personagens_loop
	
pinta_personagens_exit:
	jr	$ra
	
	#########################################################
	#	PINTA OS OBSTACULOS NO MAPA		#
	#########################################################	
###############
# MAPA FASE 1 #
###############
obstaculos_fase1:
	move	$t7, $ra
	
	li	$t3, 69104 #canto topo esquerdo do retangulo
	li	$t6, 69140 #canto topo direito do retangulo
	li	$t5, 101908 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 84180 #canto topo esquerdo do retangulo
	li	$t6, 84392 #canto topo direito do retangulo
	li	$t5, 101800 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo  #retangulo topo esquerdo
	
	li	$t3, 84568 #canto topo esquerdo do retangulo
	li	$t6, 84780 #canto topo direito do retangulo
	li	$t5, 102188 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo #retangulo topo direito
	
	li	$t3, 215252 #canto topo esquerdo do retangulo
	li	$t6, 215468 #canto topo direito do retangulo
	li	$t5, 233900 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo #retangulo inferior esquerdo
	
	li	$t3, 215636 #canto topo esquerdo do retangulo
	li	$t6, 215852 #canto topo direito do retangulo
	li	$t5, 234284 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo #retangulo inferior direito
	
	#obstaculos centrais
	li	$t3, 118256 #canto topo esquerdo do retangulo
	li	$t6, 118292 #canto topo direito do retangulo
	li	$t5, 130580 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	#obstaculo U
	li	$t3, 118140 #canto topo esquerdo do retangulo
	li	$t6, 118184 #canto topo direito do retangulo
	li	$t5, 159144 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 149932 #canto topo esquerdo do retangulo
	li	$t6, 150104 #canto topo direito do retangulo
	li	$t5, 159320 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 118364 #canto topo esquerdo do retangulo
	li	$t6, 118408 #canto topo direito do retangulo
	li	$t5, 159368 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	#Caixa dos fantasmas
	li	$t3, 176508 #canto topo esquerdo do retangulo
	li	$t6, 176532 #canto topo direito do retangulo
	li	$t5, 199060 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 194968 #canto topo esquerdo do retangulo
	li	$t6, 195184 #canto topo direito do retangulo
	li	$t5, 199280 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 176752 #canto topo esquerdo do retangulo
	li	$t6, 176776 #canto topo direito do retangulo
	li	$t5, 199304 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	#
	li	$t3, 176680 #canto topo esquerdo do retangulo
	li	$t6, 176748 #canto topo direito do retangulo
	li	$t5, 177772 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 176604 #canto topo esquerdo do retangulo
	li	$t6, 176676 #canto topo direito do retangulo
	li	$t5, 177692 #canto inferior direito do retangulo
	lw	$t1, cor_lab_branco
	jal	pinta_retangulo #porta 
	
	li	$t3, 176520 #canto topo esquerdo do retangulo
	li	$t6, 176600 #canto topo direito do retangulo
	li	$t5, 177620 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	#Retangulo emaixo da caixa
	li	$t3, 200176 #canto topo esquerdo do retangulo
	li	$t6, 200212 #canto topo direito do retangulo
	li	$t5, 235028 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	jr	$t7
##################
# MAPA DA FASE 2 #
##################
obstaculos_fase2:
	move	$t7, $ra
	
	li	$t3, 69104 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 36 #canto topo direito do retangulo 36
	addi	$t5, $t6, 31744 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	#RETANGULO ESQUERDO TOPO 1
	li	$t3, 84180 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 96 #canto topo direito do retangulo 212
	addi	$t5, $t6, 17408 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo  #retangulo topo esquerdo
	
	#RETANGULO ESQUERDO TOPO 2
	li	$t3, 84340 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 52 #canto topo direito do retangulo 212
	addi	$t5, $t6, 17408 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo  #retangulo topo esquerdo
	
	#RETANGULO DIREITO TOPO 1
	li	$t3, 84560 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 56 #canto topo direito do retangulo 212
	addi	$t5, $t6, 16384 #canto inferior direito do retangulo
	#li	$t6, 84780 #canto topo direito do retangulo
	#li	$t5, 102188 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo #retangulo topo direito
	
	#RETANGULO DIREITO TOPO 2
	li	$t3, 84676 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 100 #canto topo direito do retangulo 212
	addi	$t5, $t6, 16384 #canto inferior direito do retangulo
	#li	$t6, 84780 #canto topo direito do retangulo
	#li	$t5, 102188 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo #retangulo topo direito

	
	#RETANGULO ESQUERDO INFERIOR 1
	li	$t3, 215252 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 96 #canto topo direito do retangulo 212
	addi	$t5, $t6, 17408 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo  #retangulo topo esquerdo
	
	#RETANGULO ESQUERDO INFERIOR 2
	li	$t3, 215412 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 52 #canto topo direito do retangulo 212
	addi	$t5, $t6, 17408 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo  #retangulo topo esquerdo
	
	#RETANGULO DIREITO INFERIOR 1
	li	$t3, 215636 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 52 #canto topo direito do retangulo 212
	addi	$t5, $t6, 17408 #canto inferior direito do retangulo
	#li	$t6, 84780 #canto topo direito do retangulo
	#li	$t5, 102188 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo #retangulo topo direito
	
	#RETANGULO DIREITO INFERIOR 2
	li	$t3, 215752 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 100 #canto topo direito do retangulo 212
	addi	$t5, $t6, 17408 #canto inferior direito do retangulo
	#li	$t6, 84780 #canto topo direito do retangulo
	#li	$t5, 102188 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo #retangulo topo direito
	#obstaculos centrais
		#CENTRO
	li	$t3, 118256 #canto topo esquerdo do retangulo
	addi	$t6, $t3, 36 #canto topo direito do retangulo 212
	addi	$t5, $t6, 40960 #canto inferior direito do retangulo
	#li	$t6, 118292 #canto topo direito do retangulo
	#li	$t5, 130580 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
		#obstaculo ESQUERDA
	li	$t3, 118132 #canto topo esquerdo do retangulo
	li	$t6, 118188 #canto topo direito do retangulo
	li	$t5, 159148 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo

		#OBSTACULO DIREITA
	li	$t3, 118352 #canto topo esquerdo do retangulo
	li	$t6, 118408 #canto topo direito do retangulo
	li	$t5, 159368 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	#Caixa dos fantasmas
	li	$t3, 176500 #canto topo esquerdo do retangulo
	li	$t6, 176532 #canto topo direito do retangulo
	li	$t5, 199060 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 194968 #canto topo esquerdo do retangulo
	li	$t6, 195184 #canto topo direito do retangulo
	li	$t5, 199280 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 176752 #canto topo esquerdo do retangulo
	li	$t6, 176776 #canto topo direito do retangulo
	li	$t5, 199304 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 176680 #canto topo esquerdo do retangulo
	li	$t6, 176748 #canto topo direito do retangulo
	li	$t5, 177772 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	li	$t3, 176604 #canto topo esquerdo do retangulo
	li	$t6, 176676 #canto topo direito do retangulo
	li	$t5, 177692 #canto inferior direito do retangulo
	lw	$t1, cor_lab_branco
	jal	pinta_retangulo #porta 
	
	li	$t3, 176520 #canto topo esquerdo do retangulo
	li	$t6, 176600 #canto topo direito do retangulo
	li	$t5, 177620 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	
	#Retangulo emaixo da caixa
	li	$t3, 200176 #canto topo esquerdo do retangulo
	li	$t6, 200212 #canto topo direito do retangulo
	li	$t5, 235028 #canto inferior direito do retangulo
	lw	$t1, cor_lab_parede
	jal	pinta_retangulo
	jr	$t7
	
	###########################################
	#	PINTA A BORDA DO MAPA	#
	###########################################	
pinta_borda:
	#t3 -> topo esquerdo
	#t6 -> topo direito
	#t5 -> inferior direito
	#t1 -> cor
	
	move	$t7, $ra
	##BORDA DO LABIRINTO
	##LADO ESQUERDO DO LABIRINTO
	
	li $t3, 68736 #canto topo esquerdo do retangulo
	li $t6, 68752 #canto topo direito do retangulo
	li $t5, 128144 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo #canto esquerdo topo
	
	li $t3, 118932 #canto topo esquerdo do retangulo
	li $t6, 119052 #canto topo direito do retangulo
	li $t5, 128268 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo #canto esquerdo 
	
	li $t3, 119056 #canto topo esquerdo do retangulo
	li $t6, 119096 #canto topo direito do retangulo
	li $t5, 152888 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 143488 #canto topo esquerdo do retangulo
	li $t6, 143628 #canto topo direito do retangulo
	li $t5, 152840 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 153728 #canto topo esquerdo do retangulo
	li $t6, 153732 #canto topo direito do retangulo
	li $t5, 169092 #canto inferior direito do retangulo
	#lw $t1, cor_lab_branco
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 170112 #canto topo esquerdo do retangulo
	li $t6, 170244 #canto topo direito do retangulo
	li $t5, 179460 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo

	li $t3, 170248 #canto topo esquerdo do retangulo
	li $t6, 170296 #canto topo direito do retangulo
	li $t5, 198952 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 190592 #canto topo esquerdo do retangulo
	li $t6, 190724 #canto topo direito do retangulo
	li $t5, 198916 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo	
	
	li $t3, 199808 #canto topo esquerdo do retangulo
	li $t6, 199824 #canto topo direito do retangulo
	li $t5, 255120 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 251028 #canto topo esquerdo do retangulo
	li $t6, 251776 #canto topo direito do retangulo
	li $t5, 255872 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	##LADO DIREITO DO LABIRINTO
	
	li $t3, 190320 #canto topo esquerdo do retangulo
	li $t6, 190336 #canto topo direito do retangulo
	li $t5, 250752 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 190192 #canto topo esquerdo do retangulo
	li $t6, 190316 #canto topo direito do retangulo
	li $t5, 199532 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 169672 #canto topo esquerdo do retangulo
	li $t6, 169708 #canto topo direito do retangulo
	li $t5, 199404 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 169712 #canto topo esquerdo do retangulo
	li $t6, 169852 #canto topo direito do retangulo
	li $t5, 179468 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 153464 #canto topo esquerdo do retangulo
	li $t6, 153468 #canto topo direito do retangulo
	li $t5, 168688 #canto inferior direito do retangulo
	#lw $t1, cor_lab_branco
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 143088 #canto topo esquerdo do retangulo
	li $t6, 143228 #canto topo direito do retangulo
	li $t5, 152444 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 118472 #canto topo esquerdo do retangulo
	li $t6, 118508 #canto topo direito do retangulo
	li $t5, 152300 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 118512 #canto topo esquerdo do retangulo
	li $t6, 118656 #canto topo direito do retangulo
	li $t5, 127872 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 69488 #canto topo esquerdo do retangulo
	li $t6, 69504 #canto topo direito do retangulo
	li $t5, 117632 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	li $t3, 63616 #canto topo esquerdo do retangulo
	li $t6, 64384 #canto topo direito do retangulo
	li $t5, 68480 #canto inferior direito do retangulo
	lw $t1, cor_lab_parede
	jal pinta_retangulo
	
	
	
	jr $t7
	
	#######################################################################
	#	PINTA RETANGULOS	
	#	t3 -> endereco do topo esquerdo do retangulo
	#	t6 -> endereco do topo direito
	#	t5 -> endereco do canto inferior direito do retangulo
	#	t1 -> cor 
	#######################################################################

pinta_retangulo:
	subu	$t2, $t6, $t3 #pega a quantidade de posições entre uma ponta e outra
	lw $t0, bitmap_addr
pinta_largura:

	bgt	$t3, $t6, pinta_altura #verifica se já é o ultimo endereco
	move	$t4, $t3
	add	$t4, $t4, $t0 # pega a posicao certa do endereco
	sw	$t1, 0($t4) #armazena a cor no endereco
	addi	$t3, $t3, 4 #incrementa t3
	j	pinta_largura #retorna ao loop
pinta_altura:
	bgt	$t3, $t5, exit_retangulo
	addi	$t6, $t6, 1024 #pula a linha
	subu	$t3, $t6, $t2 # nova posição do canto esquerdo, baseado na distancia de t6 e t3
	j	pinta_largura
exit_retangulo:
	jr	$ra

	###########################################
	#	TITULO DO JOGO 	#
	###########################################
escreve_titulo:
	move	$t7, $ra
	#P
	li 	$t3, 6380 #canto topo esquerdo do retangulo
	li 	$t6, 6452 #canto topo direito do retangulo
	li	 $t5, 30004 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 11528 #canto topo esquerdo do retangulo
	li 	$t6, 11540 #canto topo direito do retangulo
	li	 $t5, 13588 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	li 	$t3, 20748 #canto topo esquerdo do retangulo
	li 	$t6, 20788 #canto topo direito do retangulo
	li	 $t5, 30004 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	###LETRA A#
	li 	$t3, 7484 #canto topo esquerdo do retangulo
	li 	$t6, 7564 #canto topo direito do retangulo
	li	 $t5, 30092 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 15704 #canto topo esquerdo do retangulo
	li 	$t6, 15728 #canto topo direito do retangulo
	li	 $t5, 17776 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	li 	$t3, 24924 #canto topo esquerdo do retangulo
	li 	$t6, 24940 #canto topo direito do retangulo
	li	 $t5, 30060 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#PACMAN
	#parte superior
	li 	$t3, 7616 #canto topo esquerdo do retangulo
	li 	$t6, 7628 #canto topo direito do retangulo
	li	 $t5, 16844 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 17856 #canto topo esquerdo do retangulo
	li 	$t6, 17856 #canto topo direito do retangulo
	li	 $t5, 18880 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 7632 #canto topo esquerdo do retangulo
	li 	$t6, 7632 #canto topo direito do retangulo
	li	 $t5, 14804 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 8660 #canto topo esquerdo do retangulo
	li 	$t6, 8668 #canto topo direito do retangulo
	li	 $t5, 14816 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 8672 #canto topo esquerdo do retangulo
	li 	$t6, 8672 #canto topo direito do retangulo
	li	 $t5, 13792 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 10724 #canto topo esquerdo do retangulo
	li 	$t6, 10732 #canto topo direito do retangulo
	li	 $t5, 13804 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 11760 #canto topo esquerdo do retangulo
	li 	$t6, 11760 #canto topo direito do retangulo
	li	 $t5, 13808 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	#jal 	pinta_retangulo
	
	#PARTE INFERIOR
	
	li 	$t3, 19904 #canto topo esquerdo do retangulo
	li 	$t6, 19916 #canto topo direito do retangulo
	li	 $t5, 29132 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 21968 #canto topo esquerdo do retangulo
	li 	$t6, 21968 #canto topo direito do retangulo
	li	 $t5, 29136 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 21972 #canto topo esquerdo do retangulo
	li 	$t6, 21980 #canto topo direito do retangulo
	li	 $t5, 28124 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 23008 #canto topo esquerdo do retangulo
	li 	$t6, 23008 #canto topo direito do retangulo
	li	 $t5, 28128 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 23012 #canto topo esquerdo do retangulo
	li 	$t6, 23020 #canto topo direito do retangulo
	li	 $t5, 26092 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	## PARTE MEIO
	
	li 	$t3, 8624 #canto topo esquerdo do retangulo
	li 	$t6, 8636 #canto topo direito do retangulo
	li	 $t5, 28092 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 10660 #canto topo esquerdo do retangulo
	li 	$t6, 10668 #canto topo direito do retangulo
	li	 $t5, 26028 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 13724 #canto topo esquerdo do retangulo
	li 	$t6, 13728 #canto topo direito do retangulo
	li	 $t5, 23968 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 13724 #canto topo esquerdo do retangulo
	li 	$t6, 13728 #canto topo direito do retangulo
	li	 $t5, 23968 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	#terminar
	
	#IFEN
	li 	$t3, 17924 #canto topo esquerdo do retangulo
	li 	$t6, 17956 #canto topo direito do retangulo
	li	 $t5, 21028 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	#LETRA M
	li 	$t3, 6712 #canto topo esquerdo do retangulo
	li 	$t6, 6720 #canto topo direito do retangulo
	li	 $t5, 30272 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo	
	
	li 	$t3, 6724 #canto topo esquerdo do retangulo
	li 	$t6, 6728 #canto topo direito do retangulo
	li	 $t5, 20040 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo

	li 	$t3, 9804 #canto topo esquerdo do retangulo
	li 	$t6, 9812 #canto topo direito do retangulo
	li	 $t5, 23124 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo

	li 	$t3, 20056 #canto topo esquerdo do retangulo
	li 	$t6, 20064 #canto topo direito do retangulo
	li	 $t5, 23136 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 9828 #canto topo esquerdo do retangulo
	li 	$t6, 9836 #canto topo direito do retangulo
	li	 $t5, 23148 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo

	li 	$t3, 6768 #canto topo esquerdo do retangulo
	li 	$t6, 6768 #canto topo direito do retangulo
	li	 $t5, 20080 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 6772 #canto topo esquerdo do retangulo
	li 	$t6, 6784 #canto topo direito do retangulo
	li	$t5, 30336 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo

	#LETRA A
	li 	$t3, 9864 #canto topo esquerdo do retangulo
	li 	$t6, 9944 #canto topo direito do retangulo
	li	 $t5, 30424 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 16036 #canto topo esquerdo do retangulo
	li 	$t6, 16060 #canto topo direito do retangulo
	li	 $t5, 18108 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	li 	$t3, 25256 #canto topo esquerdo do retangulo
	li 	$t6, 25272 #canto topo direito do retangulo
	li	 $t5, 30392 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#LETRA N
	li 	$t3, 9952 #canto topo esquerdo do retangulo
	li 	$t6, 9968 #canto topo direito do retangulo
	li	 $t5, 30448 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 10996 #canto topo esquerdo do retangulo
	li 	$t6, 10996 #canto topo direito do retangulo
	li	 $t5, 22260 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 13048 #canto topo esquerdo do retangulo
	li 	$t6, 13056 #canto topo direito do retangulo
	li	 $t5, 22272 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 16132 #canto topo esquerdo do retangulo
	li 	$t6, 16136 #canto topo direito do retangulo
	li	 $t5, 25352 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 19212 #canto topo esquerdo do retangulo
	li 	$t6, 19216 #canto topo direito do retangulo
	li	 $t5, 25360 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 19220 #canto topo esquerdo do retangulo
	li 	$t6, 19228 #canto topo direito do retangulo
	li	 $t5, 28444 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	li 	$t3, 10016 #canto topo esquerdo do retangulo
	li 	$t6, 10036 #canto topo direito do retangulo
	li	 $t5, 30516 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
					
	jr $t7
	
	#############################
	#	STAGE ESCRITO	#
	#############################
escreve_fase:
	move	$t8, $ra
	
#LETRA S	
	addi 	$t3, $s6,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_fantasma_vermelho # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,8
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,0
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo 

#LETRA T
	addi	$s6, $s6, 48
	
	addi 	$t3, $s6,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,36	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_fantasma_vermelho # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,0
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,12	#canto topo direito do retangulo
	addi	$t5,$t6, 10240 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,24
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,12	#canto topo direito do retangulo
	addi	$t5,$t6, 10248 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo 
#LETRA A
	addi	$s6, $s6, 48
	
	addi 	$t3, $s6,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,36	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_fantasma_vermelho # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,16
	addi 	$t3, $t3,3072	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,12	#canto topo direito do retangulo
	addi	$t5,$t6, 3072 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,16
	addi 	$t3, $t3,9216	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,12	#canto topo direito do retangulo
	addi	$t5,$t6, 3072 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo 
#LETRA G
	addi	$s6, $s6, 48
	
	addi 	$t3, $s6,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,44	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_fantasma_vermelho # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,16
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,28	#canto topo direito do retangulo
	addi	$t5,$t6, 3072 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,16
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,12	#canto topo direito do retangulo
	addi	$t5,$t6, 3072 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo 
	
	addi 	$t3, $s6,16
	addi 	$t3, $t3,4096	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,4	#canto topo direito do retangulo
	addi	$t5,$t6, 3072 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo 
#LETRA E	
	addi	$s6, $s6, 56
	
	addi 	$t3, $s6,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,36	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_fantasma_vermelho # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,16
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,28	#canto topo direito do retangulo
	addi	$t5,$t6, 3072 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,16
	addi 	$t3, $t3,7168	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,28	#canto topo direito do retangulo
	addi	$t5,$t6, 3072 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo 
	jr	$t8	
escreve_fase1:
	
	move	$t7, $ra
	li	$s6,34180 #endereco do pixel esquerdo do topo
	jal	escreve_fase
	
	addi	$s6, $s6, 60
	
	addi 	$t3, $s6,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_fantasma_vermelho # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,0
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,12	#canto topo direito do retangulo
	addi	$t5,$t6, 8192 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,28	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,4	#canto topo direito do retangulo
	addi	$t5,$t6, 10240 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	jr	$t7
escreve_fase2:	
	move	$t7, $ra
	li	$s6,34152 #endereco do pixel esquerdo do topo
	lw	$t1, cor_fantasma_vermelho
	jal	escreve_fase
	
	addi	$s6, $s6, 60
	
		
	addi 	$t3, $s6,0	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,32	#canto topo direito do retangulo
	addi	$t5,$t6, 12288 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_fantasma_vermelho # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,0
	addi 	$t3, $t3,2048	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	addi 	$t3, $s6,8
	addi 	$t3, $t3,8192	#canto topo esquerdo do retangulo
	addi 	$t6,$t3,24	#canto topo direito do retangulo
	addi	$t5,$t6, 2048 #canto inferior direito do retangulo (12*1024)
	lw 	$t1, cor_preto # cor
	jal 	pinta_retangulo
	
	jr	$t7
	
	###########################################
	#	DESENHA VIDAS 	#
	###########################################
desenha_vidas:
	move	$t7, $ra
	lw	$s1, vidas

vida1:
	li	$s6,66648 #endereco do pixel esquerdo do topo
	addi	$s6,$s6, 840
	blt	$s1, 1, pinta_preto_vida

	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,2048
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,3072
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,4096
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,5120
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,6144
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,7168
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,8192
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,9216
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	

	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,10240
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,11264
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,12288
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
vida2:
	addi	$s6,$s6, 20480 #endereco do pixel esquerdo do topo
	blt	$s1, 2, pinta_preto_vida
	

	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,2048
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,3072
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,4096
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,5120
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,6144
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,7168
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,8192
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,9216
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	

	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,10240
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,11264
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,12288
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo

vida3:
	addi	$s6,$s6, 20480 #endereco do pixel esquerdo do topo
	blt	$s1, 3, pinta_preto_vida
	

	
	move	$t3, $s6
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,1024
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,2048
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,3072
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,4096
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,5120
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,6144
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,7168
	move	$t6, $t3
	addi	$t6, $t6,24
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,8192
	move	$t6, $t3
	addi	$t6, $t6,36
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,9216
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	

	move	$t3, $s6
	addi	$t3,$t3,-12
	addi	$t3,$t3,10240
	move	$t6, $t3
	addi	$t6, $t6,40
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	move	$t3, $s6
	addi	$t3,$t3,-8
	addi	$t3,$t3,11264
	move	$t6, $t3
	addi	$t6, $t6,32
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
		
	move	$t3, $s6
	addi	$t3,$t3,0
	addi	$t3,$t3,12288
	move	$t6, $t3
	addi	$t6, $t6,16
	move	$t5, $t6
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	j	exit_pinta_vida	
pinta_preto_vida:
	move	$t3, $s6
	addi	$t3,$t3,-16
	addi	$t3,$t3,0
	move	$t6, $t3
	addi	$t6, $t6,44
	addi	$t5, $t6,12288
	lw 	$t1, cor_preto
	jal 	pinta_retangulo	
	
	j	exit_pinta_vida
	
exit_pinta_vida:
	jr	$t7
	
	###########################################
	#	ESCREVE "AZIZ PASSA NOS"	#
	###########################################
aziz_passa_nos:

	move	$t7, $ra
	
	li	$s6, 6460
	addi	$s6, $s6, 20480
	#LETRA A
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 28
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,24  #canto topo direito do retangulo
	addi	 $t5, $t6,3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 32 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 17408
	addi 	$t6, $t3, 16 #canto topo direito do retangulo
	addi	$t5,$t6 7168 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#LETRA Z
	addi 	$s6, $s6, 84 
	
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,84 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 0
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,8  #canto topo direito do retangulo
	addi	 $t5, $t6,11264 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 12 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 7168
	addi 	$t6, $t3, 16#canto topo direito do retangulo
	addi	$t5,$t6 7168 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 28 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 7168
	addi 	$t6, $t3, 16#canto topo direito do retangulo
	addi	$t5,$t6 3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo

	
	##
	addi	$t3, $s6, 76
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,12  #canto topo direito do retangulo
	addi	 $t5, $t6,11264 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 60 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 9216
	addi 	$t6, $t3, 20 #canto topo direito do retangulo
	addi	$t5,$t6 9216 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 48 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 12288
	addi 	$t6, $t3, 12#canto topo direito do retangulo
	addi	$t5,$t6 6144 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 36 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 15360
	addi 	$t6, $t3, 12#canto topo direito do retangulo
	addi	$t5,$t6 3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	##
	#LETRA I
	addi 	$s6, $s6, 96 #canto topo esquerdo do retangulo
	
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,25 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 0
	addi 	$t3,$t3, 5120 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,25  #canto topo direito do retangulo
	addi	 $t5, $t6,3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#LETRA Z
	addi 	$s6, $s6, 36 
	
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,84 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 0
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,8  #canto topo direito do retangulo
	addi	 $t5, $t6,11264 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 12 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 7168
	addi 	$t6, $t3, 16#canto topo direito do retangulo
	addi	$t5,$t6 7168 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 28 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 7168
	addi 	$t6, $t3, 16#canto topo direito do retangulo
	addi	$t5,$t6 3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo

	
	##
	addi	$t3, $s6, 76
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,12  #canto topo direito do retangulo
	addi	 $t5, $t6,11264 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 60 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 9216
	addi 	$t6, $t3, 20 #canto topo direito do retangulo
	addi	$t5,$t6 9216 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 48 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 12288
	addi 	$t6, $t3, 12#canto topo direito do retangulo
	addi	$t5,$t6 6144 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 36 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 15360
	addi 	$t6, $t3, 12#canto topo direito do retangulo
	addi	$t5,$t6 3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	##
	
	#li	$s6, 6380
	#LETRA P
	addi 	$s6, $s6, -216 #canto topo esquerdo do retangulo
	addi 	$s6, $s6, -52
	addi	$s6, $s6, 27648
	
	addi 	$t3, $s6, 0 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 28
	addi 	$t3,$t3, 5120 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,20  #canto topo direito do retangulo
	addi	 $t5, $t6,3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 32 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 14336
	addi 	$t6, $t3, 40 #canto topo direito do retangulo
	addi	$t5,$t6 10240 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	###LETRA A#
	addi	$s6, $s6, 84
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 28
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,24  #canto topo direito do retangulo
	addi	 $t5, $t6,3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 32 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 17408
	addi 	$t6, $t3, 16 #canto topo direito do retangulo
	addi	$t5,$t6 7168 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#LETRA S
	addi	$s6, $s6, 84
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 16
	addi 	$t3,$t3, 5120 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,60  #canto topo direito do retangulo
	addi	 $t5, $t6,4096 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 14336 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 0
	addi 	$t6, $t3, 40 #canto topo direito do retangulo
	addi	$t5,$t6 5120 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#LETRA S
	addi	$s6, $s6, 84
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 16
	addi 	$t3,$t3, 5120 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,60  #canto topo direito do retangulo
	addi	 $t5, $t6,4096 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 14336 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 0
	addi 	$t6, $t3, 48 #canto topo direito do retangulo
	addi	$t5,$t6 5120 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	###LETRA A#
	addi	$s6, $s6, 84
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 28
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,24  #canto topo direito do retangulo
	addi	 $t5, $t6,3072 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 32 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 17408
	addi 	$t6, $t3, 16 #canto topo direito do retangulo
	addi	$t5,$t6 7168 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#LETRA N
	addi	$s6, $s6, -336
	addi	$s6, $s6, 80
	addi	$s6, $s6, 27648
	
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,84 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 24
	addi 	$t3,$t3, 0 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,36  #canto topo direito do retangulo
	addi	 $t5, $t6,1024 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 36 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 2048
	addi 	$t6, $t3, 24#canto topo direito do retangulo
	addi	$t5,$t6 2048 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 44 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 5120
	addi 	$t6, $t3, 16#canto topo direito do retangulo
	addi	$t5,$t6 2048 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 52 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 6144
	addi 	$t6, $t3, 8#canto topo direito do retangulo
	addi	$t5,$t6 4096 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	##
	addi	$t3, $s6, 20
	addi 	$t3,$t3, 20480 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,40  #canto topo direito do retangulo
	addi	 $t5, $t6,4096 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 20 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 15360
	addi 	$t6, $t3, 28#canto topo direito do retangulo
	addi	$t5,$t6 4096 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 20 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 12288
	addi 	$t6, $t3, 20#canto topo direito do retangulo
	addi	$t5,$t6 2048 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	addi 	$t3, $s6, 20 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 9216
	addi 	$t6, $t3, 8#canto topo direito do retangulo
	addi	$t5,$t6 2048 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	##
	
	#LETRA 0
	addi	$s6, $s6, 96
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 28
	addi 	$t3,$t3, 7168 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,24  #canto topo direito do retangulo
	addi	 $t5, $t6,11264 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	#LETRA S
	addi	$s6, $s6, 84
	addi 	$t3, $s6, 1024 #canto topo esquerdo do retangulo
	addi 	$t6,$t3,72 #canto topo direito do retangulo
	addi	$t5,$t6, 23552 #canto inferior direito do retangulo
	lw 	$t1, cor_pacman
	jal 	pinta_retangulo
	
	addi	$t3, $s6, 16
	addi 	$t3,$t3, 5120 #canto topo esquerdo do retangulo
	addi 	$t6, $t3,60  #canto topo direito do retangulo
	addi	 $t5, $t6,4096 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	
	addi 	$t3, $s6, 14336 #canto topo esquerdo do retangulo
	addi	$t3, $t3, 0
	addi 	$t6, $t3, 48 #canto topo direito do retangulo
	addi	$t5,$t6 5120 #canto inferior direito do retangulo
	lw 	$t1, cor_preto
	jal 	pinta_retangulo
	
	jr	$t7	
	
	##################################################
	#	QUANDO O JOGADOR GANHA O JOGO
	#################################################
venceu:
	jal	pintar_tela
	jal	aziz_passa_nos

	j	exit
	
	##################################################
	#	QUANDO O JOGADOR morre 
	#################################################
morreu:
	#jal	pintar_tela
	jal	transicao_estagio
	jal	aziz_passa_nos
	jal desenha_vidas
	j	exit
	###########################################
	#	SAI DO JOGO		#
	###########################################
exit:
