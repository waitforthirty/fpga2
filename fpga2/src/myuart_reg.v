module myuart_reg
(
input pclk,
input presetn,
input psel,
input pwrite,
input penable,
input [ 5 : 0 ] paddr,
input [ 31 : 0 ] pwdata,
output reg[ 31 : 0 ] prdata,
output reg interrupt, //tell apb master to stop to send data
output reg pready,  //tell apb master to read data
output reg tx_shoot,
output reg[ 7 : 0 ] datatx,
output reg[ 2 : 0 ] Ctrl_reg=0,  //bit0: verify on;bit1:odd even verify  
input [ 7 : 0 ] datarx,
input  ready_rx,    //Check the data can be read
input busy_tx
);
reg[1:0] state,nstate;
reg[31:0] pwdata_reg;  
reg[7:0] Data_reg;  //store data of uart    address:0x08
reg rupt_reg;  //W1C clear all of reg

parameter IDLE = 0,
          SET  = 1,
          pWriteEN = 2,
          pReadEN = 3;

//reset
always @(posedge pclk) begin
  if (!presetn) begin
      state <= IDLE;
      nstate <= IDLE;
  end
  else begin
      state <= nstate;
  end
end
//reset
always @(posedge pclk) begin
  if (!presetn) begin
    datatx <= 0;
    tx_shoot <=0 ;
    pready <=0 ;
    prdata <= 0;
    interrupt<= 0;
    pready <= 0;
  end
end

// state machine
always @(*) begin
  case(state)  
    IDLE : begin
          if (psel) begin
            nstate = SET;
          end
          else begin
            nstate = IDLE;
          end
    end
    SET  :begin
          if (penable&&pwrite) begin
            nstate = pWriteEN;
          end
          else if (penable&&!pwrite)begin
            nstate = pReadEN;
          end
    end
    pWriteEN   :begin
          if(psel == 1)begin
            nstate = SET;
          end
          else begin
            nstate = IDLE;
          end
    end
    pReadEN :begin
          if(psel == 1)begin
            nstate = SET;
          end
          else begin
            nstate = IDLE;
          end          
    end
    default:nstate = IDLE;
  endcase    
end

//write and read transfer
always @(posedge pclk ) begin
  case(nstate)
    IDLE  :begin  
          tx_shoot <= 0;
          if (ready_rx) begin
            pready <= 1;
          end
          else begin
            pready <= 0;
          end  
    end
    SET   :begin
          if (pwrite) begin
              Data_reg <= pwdata[7:0]; //latch write data
          end  
          else begin
              Data_reg <= datarx;
          end
    end
    pWriteEN    :begin
            if (paddr == 6'h4) begin
              Ctrl_reg <= Data_reg[3:0]; 
              tx_shoot <= 0; 
            end
            else if (paddr == 6'h08) begin
              datatx <= Data_reg ;
              tx_shoot <= 1;
            end
            else if (paddr == 6'hC)begin
              rupt_reg <= Data_reg[0];
              tx_shoot <= 0;
            end              

        end 
    pReadEN    :begin
              if (paddr == 6'h04) begin
                  prdata[3:0] <= Ctrl_reg;
              end
              else if (paddr == 6'h08) begin
                  prdata[7:0] <= Data_reg;
              end 
    end     
  endcase
end
//tell the master send data
always @(posedge pclk ) begin
if (busy_tx == 1) begin
  interrupt <= 1;
end
else begin
  interrupt <= 0;
end
end

//clear reg
always @(posedge pclk ) begin
  if (rupt_reg ==1) begin
    Data_reg <= 0;
    Ctrl_reg <= 0;
    rupt_reg <= 0;
  end
end

endmodule