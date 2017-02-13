`timescale 1ns/1ns
module myuart_tb;

wire data_tx_o;
wire uart_tx_busy_o;
reg pclk;
reg clk_TX;
reg clk_RX;
reg presetn;
reg psel;
reg pwrite;
reg penable;
wire [2 : 0]ctrl_reg;
reg  [ 5 : 0]paddr;
reg  [ 31 : 0 ] pwdata ;
wire [31:0] prdata_1 ;
wire pready;
wire interrupt;
wire tx_shoot_1;
wire [ 7 : 0 ] data_tx;
wire [ 7 : 0 ] data_rx;
wire data_out_rx_valid;
initial
fork
pclk = 1;
presetn = 0;
psel = 0;
penable = 0;
pwrite = 0;
pwdata = 0;
paddr = 6'h4;

#500 presetn = 1;
#1000 psel = 1;
#1020 psel = 0;
#1010 penable =1;
#1020 penable = 0;
#1000 pwrite = 1;
#1020 pwrite = 0;
#1000 pwdata = 32'b11;
#1020 pwdata = 0;

#1500 paddr = 6'h8;
#2000 psel = 1;
#2020 psel = 0;
#2010 penable =1;
#2020 penable = 0;
#2000 pwrite = 1;
#2020 pwrite = 0;
#2000 pwdata = 32'h55;
#2020 pwdata = 0;

forever
begin
#5 pclk = ~ pclk; 
end
join

always@(pready)
begin
  if(pready==1)
  begin
    psel=1;
    pwrite=0;
    paddr=6'h8;
#10 penable = 1;
#10 psel = 0;
    penable = 0;
  end  
end
parameter DIVISOR_TX = 10'd868;
reg [9:0] clk_dividor_TX= 0 ;
// clk divider
always @ ( posedge pclk or negedge presetn ) 
begin
	if ( !presetn) 
	begin

//Beginning of auto reset for uninitialized flops
    clk_dividor_TX <= 10'b0;
    clk_TX <= 1'b0;
// End of auto matics
    end 
        else 
        begin
            if ( clk_dividor_TX <= DIVISOR_TX/2 ) 
                begin
				clk_dividor_TX <= clk_dividor_TX + 1'b1;
				clk_TX <= 1'b0;
			    end 
		    else if( clk_dividor_TX < DIVISOR_TX ) begin
                clk_dividor_TX <= clk_dividor_TX + 1'b1;
                clk_TX <= 1'b1;
              end
            else 
                clk_dividor_TX <= 10'b0 ; 

        end     
end

parameter DIVISOR_RX = 10'd54;
reg [9:0] clk_dividor_RX= 0 ;
// clk divider
always @ ( posedge pclk or negedge presetn ) 
begin
  if ( !presetn) 
  begin

//Beginning of auto reset for uninitialized flops
    clk_dividor_RX <= 10'b0;
    clk_RX <= 1'b0;
// End of auto matics
    end 
        else 
        begin
            if ( clk_dividor_RX <= DIVISOR_RX/2 ) 
                begin
        clk_dividor_RX <= clk_dividor_RX + 1'b1;
        clk_RX <= 1'b0;
          end 
        else if( clk_dividor_RX < DIVISOR_RX ) begin
                clk_dividor_RX <= clk_dividor_RX + 1'b1;
                clk_RX <= 1'b1;
              end
            else 
                clk_dividor_RX <= 10'b0 ; 

        end     
end


uart_tx
uart_tx_1
(
 .clk_i(clk_TX),
 .resetn_i(presetn),
 .Ctrl(ctrl_reg),
 .clk_en_i(tx_shoot_1),
 .datain_i(data_tx),
 .uart_tx_o(data_tx_o),
 .uart_busy_o(uart_tx_busy_o)
);

uart_rx
#(.VERIFY_ON(1'b1),.VERIFY_EVEN(1'b1))
uart_rx_1
(
 .clk_i(clk_RX),
 .resetn_i(presetn),
 .uart_rx_i(data_tx_o),
 .dataout_valid_o(data_out_rx_valid),
 .dataout_o(data_rx)
);

myuart_reg myuart_1
(
  .pclk(pclk),
  .presetn(presetn),
  .psel(psel),
  .pwrite(pwrite),
  .penable(penable),
  .paddr(paddr),
  .pwdata(pwdata),
  .prdata(prdata_1),
  .pready(pready),
  .interrupt(interrupt),
  .tx_shoot(tx_shoot_1),
  .datatx(data_tx),
  .datarx(data_rx),
  .busy_tx(uart_tx_busy_o),
  .Ctrl_reg(ctrl_reg),
  .ready_rx(data_out_rx_valid)
);
endmodule