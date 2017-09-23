.text
.globl main
# tx_data : contem o dado q vem do periferico
#		POS: 0x10008000
# tx_av : indica se existe dado disponivel no barramento tx_data
#		POS: 0x10008001
# rx_data : contem dado a ser transmitido ao periferico
#		POS: 0x10008002
# rx_start : indica se existe dado disponivel no barramento rx_data
#		POS: 0x10008003
# rx_busy : flag que fica em 1 enquanto envia ao periferico (do rx_start ao fim)
#		POS: 0x10008004


main: #Aguarda Inicio do Periferico

#testes:
#	li $t0, 0x10008001
#	li $t1, 1
#	sb $t1, 0 ($t0)
#	li $t0, 0x10008000
#	li $t1, 0xA
#	sb $t1, 0 ($t0)

	addiu $t0, $zero, 542
init_p:
	beq $t0, $zero, application #Se acabou, entao o periferico foi iniciado (Ja mandou 0x55)
	addiu $t0, $t0, -1 # i-- 
	sll $zero, $zero, 0 # nop
	j init_p
	
application:	
	la $s0, A  # Carrega endereco de memoria do vetor de dados
	lbu $a0, 0 ($s0) #Carrega primeiro elemento de A Vai ser 1o argumento q vai mandar
	jal send_data #Manda o primeiro dado p/ periferico
	addiu $s0, $s0, 1 #Vai p/ proxima posicao
	lbu $a0, 0 ($s0) #Carrega segundo elemento de A
	jal send_data #Manda o seugndo dado p/ periferico
	jal read_data #Le a resposta do periferico q deve ser A[0] + A[1]
	la $s1, B #Carrega pos memoria em que deve salvar A[0]+ A[1]
	sb $v0, 0 ($s1) #Salva a soma retornada pela funcao read_data do periferico
	j fim #Termina o programa
	
	
################################################################################################
# MANDA DADOS AO PERIFERICO
################################################################################################
send_data:
	li $t0, 0x10008004 #Carrega rx_busy p/ saber se pode mandar
wait_busy:
	lbu $t1, 0 ($t0)# carrega rx_busy
	bne $t1, $zero, wait_busy # Se rx_busy = 1, tenta novamente, se rx_busy = 0, pode mandar
	li $t0, 0x10008002 # carrega endereco p/ mandar dado ao periferico
	sb  $a0, 0 ($t0) # Salva dado em rx_data
	li $t1, 0x10008003 # Carrega endereco de aviso que existe um dado disponivel
	addiu $t0, $zero, 1 #Carrega valor 1 p/ ativar rx_start
	sb  $t0, 0 ($t1) #Salva rx_start = 1
	jr $ra
################################################################################################
# LE DADOS DO PERIFERICO
################################################################################################
read_data:
	li $t0, 0x10008001 # Carrega pos mem tx_av
wait_av:
	lbu $t1, 0 ($t0) #Carrega valor de tx_av
	beq $t1, $zero, wait_av # Se tx_av = 0, tenta novamente, se tx_av = 1, pode ler
	li $t0, 0x10008000 #Carrega pos mem tx_data
	lbu  $v0, 0 ($t0) #carrega valor de tx_data
	jr $ra #Retorna valor

################################################################################################
# FIM DO PROGRAMA
################################################################################################
fim: #Fica sempre em loop
	j fim

.data
# Dados para mandar
A: .byte  0x5 0x4 #Dados que quer somar
B: .byte 0x0 #Dados que quer
