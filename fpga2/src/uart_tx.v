module uart_tx 
(
input clk_i ,
input resetn_i ,
input clk_en_i ,
input [ 2 : 0 ] Ctrl,
input [ 7 : 0 ] datain_i ,
output reg uart_tx_o = 1'b1 ,
output reg uart_busy_o
) ;
parameter       TXIdle=6'b00_0000,        // 空闲状态
                TXLoad=6'b00_0001,        // 装载字符状态
                TXStartBit=6'b00_0010,    //开始位状态
                TXDataBit=6'b00_0100,     //数据位状态
                TXParity_check_EVEN=6'b00_1000,//偶校验位状态
                TXParity_check_ODD =6'b00_1001,//奇校验
                TXStopBit=6'b01_0000,     //停止位状态
                TXDone=6'b10_0000;        //结束标志
reg[5:0] cState,nState;    //cstate当前状态，nstate次态
reg[7:0] TxdBufTmp;
reg[3:0] BitCnt;
reg VERIFY_ON,VERIFY_EVEN;
reg parity=1; //奇偶校验
integer i ;
always @(Ctrl) begin
     if (Ctrl == 3'b001)begin
          VERIFY_ON = 1'b1 ;
          VERIFY_EVEN = 1'b0;
      end  
    else if(Ctrl == 3'b011)begin
          VERIFY_ON = 1'b1 ;
          VERIFY_EVEN = 1'b1;
      end  
    else 
        begin
        VERIFY_ON = 1'b0 ;
        VERIFY_EVEN = 1'b0;
     end
end
always @ (negedge resetn_i or posedge clk_i)
        if(!resetn_i)begin
                nState<=TXIdle;
                cState<=TXIdle;         //复位
            end
        else
                cState<=nState;

always @(clk_en_i ) begin
  if(clk_en_i == 1)
    nState = TXLoad;
end

always @ (cState or  BitCnt)
        case(cState)
            TXLoad:     nState=TXStartBit;
            TXStartBit: nState=TXDataBit;
            TXDataBit:
                        if(BitCnt>=8)begin
                        	if(VERIFY_ON==1'b1)begin
                                for (i= 0; i < 8; i = i + 1)begin
                                    parity =  ^TxdBufTmp[i];                                             end
                               if(VERIFY_EVEN == 1'b0)
                                  nState = TXParity_check_EVEN;
                               else
                                  nState = TXParity_check_ODD;
                            end
                            else  
                                nState = TXStopBit;
                        end
                        else
                            nState=TXDataBit;

            TXParity_check_EVEN:    nState=TXStopBit;
            TXParity_check_ODD:     nState=TXStopBit;
            TXStopBit:         nState=TXDone;
            TXDone,TXIdle:     nState=TXIdle;
            default:           nState=6'b0;
        endcase

		  
always @(posedge clk_i or negedge resetn_i)
            if(!resetn_i)
            begin
                    uart_tx_o<=1'b1;
                    uart_busy_o<=1'b0;  //清除busy位
                    BitCnt<=4'b0000;
            end
            else
                    case(nState)
                            TXLoad:
                                    begin
                                    TxdBufTmp<=datain_i; //要发送的数据放入数据寄存器
                                    uart_busy_o<=1'b1;  //开始发送时，设置busy标志位
                                    end
                            TXStartBit:
                                    uart_tx_o<=1'b0;
                            TXDataBit:
                                    begin
                                        uart_tx_o<=TxdBufTmp[BitCnt];
                                        BitCnt<=BitCnt+1'b1;                
                                    end
                            TXParity_check_EVEN: 
                                    if(parity==1) 
                                        uart_tx_o <= parity;   
                                    else
                                        uart_tx_o <= parity;   
                                    
                            TXParity_check_ODD:
                                    if(parity==1) 
                                        uart_tx_o <= ~parity;   
                                    else
                                        uart_tx_o <= ~parity;   

                            TXStopBit:
                                    uart_tx_o<=1'b1;
                            TXDone:
                                    uart_busy_o<=1'b0; //发送结束，清除busy位
                            TXIdle: BitCnt<=4'b0000;                                       
                    endcase
endmodule