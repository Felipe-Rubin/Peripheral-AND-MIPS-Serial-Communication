-- PT_BR
------------------------------------------------------------------------
-- Autores : Felipe Rubin e Ariel Ril
--
-- Email: felipe.rubin@acad.pucrs.br & ariel.ril@acad.pucrs.br
--
-- T1 Organizacao e Arquitetura de Computadores II PUCRS 2017/2
--
-- Arquivo : glueLogic.vhd
--
-- Descricao: Este arquivo representa o hardware da logica de cola que 
-- realiza operacoes sobre o periferico em comunicacao com a interface 
-- serial a partir de enderecos que nao sao utilizados pela memoria de 
-- dados ou pela memoria de instrucoes.
------------------------------------------------------------------------
-- EN_US
------------------------------------------------------------------------
-- Authors : Felipe Rubin & Ariel Ril
--
-- Email: felipe.rubin@acad.pucrs.br & ariel.ril@acad.pucrs.br
--
-- Assignment 1 Computer Organization and Design II PUCRS 2017/2
--
-- File : glueLogic.vhd
--
-- Description: This file represents the hardware of the glue logic
-- which is responsible for operations with the peripheral 
-- for which it will communicate with the serial interface
-- from addresses that are not beeing used in the memory address neither
-- in the data address.
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity glueLogic is
port(
	-- pt_br: Comum
	-- en_us: Common
	clock,reset : in std_logic;
	------------------------------------------------------------------------------------
	-- pt_br: Communicacao Interface Serial
	-- en_us: Communication Serial Interface

	-- pt_br: Dado que vem da interface serial
	-- en_us: Data that comes from the serial interface
	tx_data: in std_logic_vector (7 downto 0);
	-- pt_br: Aviso que existe dado em tx_data
	-- en_us: Warning that data is ready on tx_data
	tx_av: in std_logic;
	-- pt_br: Dado a ser mandado p/ interface serial
	-- en_us: Data that will be send to the serial interface
	rx_data: out std_logic_vector (7 downto 0);
	-- pt_br: Avisa que existe dado em rx_data
	-- en_us: Warning that data is ready on rx_data
	rx_start: out std_logic;
	-- pt_br: Avisa que a interface serial esta ocupada
	-- en_us: Warning that the serial interface is busy
	rx_busy: in std_logic;
	------------------------------------------------------------------------------------
	-- pt_br: Comunicacao com MIPS-S
	-- en_us: Communication with MIPS-S and its memory

	-- pt_br: Dado compartilhado com o MIPS e sua memoria
	-- en_us: Data shared with MIPS and its memory
	data: inout std_logic_vector(31 downto 0);
	-- pt_br: Operacao com memoria quando 1
	-- en_us: Operation with data memory when 1
	ce: in std_logic;
	-- pt_br: Operacao de Leitura 1 ou Escrita 0
	-- en_us: Read 1 or Write 0 operation
	rw: in std_logic;
	-- pt_br: Endereco compartilhado com o MIPS e sua Memoria
	-- en_us: Address shared with MIPS and its memory
	address: in std_logic_vector(31 downto 0)
	------------------------------------------------------------------------------------
	);
end glueLogic;

-- 5x pt_br: posicoes de memoria reservadas p/ periferico
--    en_us: positions in memory reserved for the peripheral
-- tx_data :
--	pt_br: contem o dado q vem do periferico
--	en_us: contains the data that the peripheral will send
--		POS: 0x10008000 Byte
-- tx_av :
-- pt_br: indica se existe dado disponivel no barramento tx_data
-- en_us: warns if there is data in the tx_data bus
--		POS: 0x10008001 Byte
-- rx_data : 
-- pt_br: contem dado a ser transmitido ao periferico
-- en_us: contains data to be send to the peripheral
--		POS: 0x10008002 Byte
-- rx_start : 
-- pt_br: indica se existe dado disponivel no barramento rx_data
-- en_us: warns that there is data in the rx_data bus
--		POS: 0x10008003 Byte
-- rx_busy :
-- pt_br: flag que fica em 1 enquanto envia ao periferico (do rx_start ao fim)
-- en_us: flag which stays in 1 while data is beeing send to the peripheral(from rx_start to the end)
--		POS: 0x10008004 Byte
---------------------------------------------------------------------------------
architecture glueLogic of glueLogic is
 	-- pt_br: Estados da FSM Sender
 	-- en_us: States of the FSM Sender
	type SendState is (SA,SB,SC);
	-- pt_br: Estados da FSM Receiver
	-- en_us: States of the FSM Receiver
	type ReceiveState is (RA,RB);
 	-- pt_br: Estado atual de Sender
 	-- en_us: Current state of the Sender
	signal send_state : SendState;
 	-- pt_br: Estado atual de Receiver
 	-- en_us: Current state of the Receiver
	signal receive_state : ReceiveState;
 	-- pt_br: Proximo estado de Sender
 	-- en_us: Next state of the Sender
	signal next_send_state : SendState;
 	-- pt_br: Proximo estado de Receiver
 	-- en_us: Next state of the Receiver
	signal next_receive_state : ReceiveState;
 	-- pt_br: proximo dado de sender
 	-- en_us: next data of sender
	signal next_data_send : std_logic_vector(31 downto 0) := (others => '0');
	-- pt_br: proximo dado de receiver
	-- en_us: next data of receiver
	signal next_data_receive : std_logic_vector(31 downto 0) := (others => '0');
 	-- pt_br: registrador que armazena dado a ser enviado p/ interface serial
 	-- en_us: register that holds the data which will be send to the serial interface
	signal rxReg : std_logic_vector(7 downto 0) := (others => '0');

	-- pt_br: registrador que armazena rx_start
	-- en_us: register which holds rx_start
	signal rxRegS : std_logic := '0';

	-- pt_br: registrador que armazena tx_av quando este recebe 1 
	-- en_us: register which holds tx_av when it receives 1 
	signal txRegAV : std_logic := '0';

begin
	
-- pt_br: Processo que atualiza o estado da FSM
-- en_us: Process which updates the FSM state
process(clock,reset)  
begin
	if reset = '1' then
		send_state <= SA;
		receive_state <= RA;
	elsif clock = '1' and clock'event then
		receive_state <= next_receive_state;
		send_state <= next_send_state;
	end if;
end process;

-- pt_br: portas recebem os respectivos sinais
-- en_us: ports receive their respective signals
rx_data <= rxReg;
rx_start <= rxRegS;

process(ce,rw)
begin
	-- pt_br: operacao de leitura
	-- en_us: read operation
	if ce = '1' and rw = '1' 
		and (address = x"10008001" or address = x"10008000" or address = x"10008004") then
		-- pt_br: se for leitura do periferico
		-- en_us: if it reads from the peripheral
		if address = x"10008000" or address = x"10008001"  then 
			data <= next_data_receive;
		else
		 	-- pt_br: se for escrita do periferico
		 	-- en_us: if it writes to the peripheral
			data <= next_data_send;
		end if;
	else
	 	-- pt_br: Se nao for uma operacao reconhecida
	 	-- en_us: if it isn't a recognized operation
		data <= (others => 'Z');
	end if;
end process;

-- pt_br: Processo de Escrita
-- en_us: Write Process
Sender_FSM: process(send_state,ce,rw,data,rx_busy)
begin
	case send_state is
		when SA => 
			if address = x"10008004" and ce = '1' and rw = '1' then -- lbu rx_busy
				if rx_busy = '1' then
					next_send_state <= SA;
				else 
					-- pt_br: nao ta ocupada
					-- en_us: it isn't busy
					next_send_state <= SB;
				end if;
			end if;
			next_data_send <=  x"0000000" & "000" & rx_busy;
			rxRegS <= '0';
		when SB =>
			if address = x"10008002" and ce = '1' and rw = '0' then -- sb rx_data
				next_send_state <= SC;
				rxReg <= data(7 downto 0);
			end if;
		when SC =>
			if address = x"10008003" and ce = '1' and rw = '0' then -- sb rx_start
				if data(0) = '1' then
					rxRegS <= '1';
					next_send_state <= SA;
				else
					next_send_state <= SC;
				end if;
			end if;
	end case;
end process;

-- pt_br: tx_av fica em 1 clock = '1', depois ele fica 0, armazena em um reg
-- en_us: tx_av stays in 1 during only one clock, after that it goes back to zero, so we must hold it into a register
Tx_Observer : process(tx_av,receive_state)
begin
	if tx_av = '1' then
		txRegAV <= tx_av;
	elsif receive_state = RB then
		txRegAV <= '0';
	end if;
end process;

-- pt_br: Processo de Leitura
-- en_us: Read Process
Receiver_FSM: process(receive_state,ce,rw,txRegAV)
begin
	case receive_state is
		when RA =>
			if address = x"10008001" and ce ='1' and rw = '1' then -- lbu tx_av
				if txRegAV = '1' then
					next_receive_state <= RB;
				else
					next_receive_state <= RA;
				end if;
			end if;
			next_data_receive <=  x"0000000" & "000" & txRegAV;
		when RB =>
			if address = x"10008000" and ce = '1' and rw = '1' then -- lbu tx_data
				next_receive_state <= RA;
			end if;
			next_data_receive <= x"000000" & tx_data;	
	end case;
end process;


end glueLogic;
