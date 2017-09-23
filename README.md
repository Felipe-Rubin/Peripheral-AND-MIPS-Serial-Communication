###### PT_BR

#### T1 Organizacao e Arquitetura de Computadores II PUCRS 2017/2

## Autores: 
Felipe Rubin e Ariel Ril

## Email:
felipe.rubin@acad.pucrs.br & ariel.ril@acad.pucrs.br

## Arquivos:

# ProjectFiles:
*glueLogic.vhd*: Implementação do hardware da Lógica de Cola

*MIPS-MC_SingleEdge*: Implementação do MIPS

*serialInterface.vhd*: Implementacao da Interface Serial

*softwareText.txt*: Arquivo que sera carregado pelo testbench e contem o Software(Aplicacao e Driver)

*mult_div.vhd*: Operações de Soma e Divisão

*System_tb.vhd*: Testbench do Sistema

# OlderTestbenches:
*MIPS-MC_SingleEdge_tb.vhd*: Testbench do MIPS

*serial_tb.vhd*: Testbench da Interface Serial

# Software:
*software.asm*: O Software

# Relatorio:
*relatorio.pdf*: O relatorio, escrito em português, explicando o sistema

## Execução utilizando GHDL e GTKWAVE:

*Passo 1*:
	ghdl -a --ieee=synopsys -fexplicit mult_div.vhd MIPS-MC_SingleEdge.vhd glueLogic.vhd serialinterface.vhd System_tb.vhd

*Passo 2*:
	ghdl -e --ieee=synopsys -fexplicit system_tb

*Passo 3*:
	ghdl -r --ieee=synopsys -fexplicit system_tb --stop-time=500us --wave=wave.ghw

*Passo 4*
	gtkwave wave.ghw

OBS: A execução do passo 3 pode ser feita gerando outro formato de onda, por exemplo vcd ( --vcd=wave.vcd ). Embora mais rápido, não apresenta sinais muito internos.

## Creditos:
Os arquivos relacionados à interface serial e ao MIPS foram criados pelos professores Ney Calazans *ney.calazans@pucrs.br* e Fernando Moraes *fernando.moraes@pucrs.br*

###### EN_US

#### Assignment 1 Computer Organization and Design II PUCRS 2017/2

## Authors:
Felipe Rubin & Ariel Ril

## Email:
felipe.rubin@acad.pucrs.br & ariel.ril@acad.pucrs.br

## Files:

# ProjectFiles:
*glueLogic.vhd*: Implementation of the Glue Logic Hardware

*MIPS-MC_SingleEdge*: MIPS Implementation

*serialInterface.vhd*: Serial Interface Implementation

*softwareText.txt*: File that will be loaded by the testbench and contains

the Software(Application and Driver)

*mult_div.vhd*: Multiplication and Sum operations

*System_tb.vhd*: System Testbench

# OlderTestbenches:
*MIPS-MC_SingleEdge_tb.vhd*: MIPS Testbench

*serial_tb.vhd*: Serial Interface Testbench

# Software:
*software.asm*: The software

# Relatorio:
*relatorio.pdf*: The assignment text,written in portuguese, explaining the system

# Execution using GHDL and GTKWAVE:

*Step 1*:
	ghdl -a --ieee=synopsys -fexplicit mult_div.vhd MIPS-MC_SingleEdge.vhd glueLogic.vhd serialinterface.vhd System_tb.vhd

*Step 2*:
	ghdl -e --ieee=synopsys -fexplicit system_tb

*Step 3*:
	ghdl -r --ieee=synopsys -fexplicit system_tb --stop-time=500us --wave=wave.ghw

*Step 4*:
	gtkwave wave.ghw

OBS: The execution in step 3 can be made using other wave format, for exemple
vcd (--vcd=wave.vcd ). While it is faster, it does not show too many internal signals.

# Credits:
The files related to the serial interface and MIPS where created by professor Ney Calazans *ney.calazans@pucrs.br* and professor Fernando Moraes *fernando.moraes@pucrs.br*
