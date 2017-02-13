vlib work
vmap work work
vlog -novopt -incr -work work "../src/uart_rx.v"
vlog -novopt -incr -work work "../src/uart_tx.v"
vlog -novopt -incr -work work "../src/myuart_reg.v"
vlog -novopt -incr -work work "../tb/myuart_tb.v"
vsim -novopt work.myuart_tb
add  wave -noupdate /myuart_tb/pclk
add  wave -noupdate /myuart_tb/clk_TX
add  wave -noupdate /myuart_tb/clk_RX
add  wave -noupdate /myuart_tb/presetn
add  wave -noupdate /myuart_tb/pwrite
add  wave -noupdate /myuart_tb/psel
add  wave -noupdate /myuart_tb/penable
add  wave -noupdate /myuart_tb/paddr
add  wave -noupdate /myuart_tb/pwdata
add  wave -noupdate /myuart_tb/data_tx
add  wave -noupdate /myuart_tb/data_tx_o
add  wave -noupdate /myuart_tb/data_rx
add  wave -noupdate /myuart_tb/prdata_1

run -all