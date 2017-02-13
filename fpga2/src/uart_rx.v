module uart_rx
#(
parameter VERIFY_ON = 1'b0 ,
parameter VERIFY_EVEN = 1'b0     
)
(
input clk_i ,
//input clk_en_i ,
input resetn_i ,
input uart_rx_i ,
output reg dataout_valid_o ,
output reg [ 7 : 0 ] dataout_o
) ;
reg[4:0] cstate,nstate;
reg[4:0] cnt16; 
reg[3:0] cnt8; // 发送数据位个数
reg[7:0] data_shiftBuff;
reg ParityBit=1;
integer j;
parameter RXD_Idle =6'b000_000,
          RXD_StartBit = 6'b000_001, 
          RXD_Receivedata = 6'b000_010,
          RXD_Parity_check= 6'b000_100,
          RXD_StopBit =6'b001_000,
          RXD_Done =6'b010_000;

always @ (negedge resetn_i or posedge clk_i)
	if(!resetn_i)begin
        nstate <= RXD_Idle; 
	    cstate <= RXD_Idle; 
        end 
	else 
	    cstate <= nstate;    

// idle -> startBit -> ReceiveData -> Parity check -> StopBit ->Done
always @ ( cstate or cnt8 or uart_rx_i or cnt16)
        	case (cstate)
        	    RXD_Idle: 
        	    	if(uart_rx_i==1'b0)
        	    		nstate = RXD_StartBit;     
        	    	else
        	    	    nstate = RXD_Idle;
                RXD_StartBit:
                    begin
                    if(cnt16<15)
                        begin
                            if(uart_rx_i==1'b0)
                                nstate=RXD_StartBit;
                            else
                                nstate=RXD_Idle;
                        end
                    else
                        nstate=RXD_Receivedata;
                    end
                RXD_Receivedata:
                    begin 
                        if(cnt8==4'd8&&cnt16==4'd15)begin  
                            if(VERIFY_ON == 1'b1)
                        	    nstate = RXD_Parity_check;
                            else
                                nstate = RXD_StopBit;
                        end        
                        else
		                    nstate = RXD_Receivedata;		                   
                    end
                RXD_Parity_check:
                    begin
                        if(cnt16==4'd15)
                            nstate=RXD_StopBit;
                        else
                            nstate=RXD_Parity_check;
                    end
                RXD_StopBit:
                    begin
                        if(cnt16==4'd15)
                            nstate=RXD_Done;
                        else
                            nstate=RXD_StopBit;
                    end
                RXD_Done:
                    begin
                        if(cnt16==4'd15)
                            nstate=RXD_Idle;
                        else
                            nstate=RXD_Done;
                    end
        		default :  nstate=6'b0;
        	endcase

always @(posedge clk_i or negedge resetn_i) 
	if(!resetn_i) 
	    begin
			cnt16 <=4'b0;
			cnt8  <=4'b0;
			dataout_valid_o <=1'b0;
        end
    else
        case (nstate)
            RXD_Idle: 
                begin
                 	cnt16 <=4'b0;
			        cnt8  <=4'b0;
			        dataout_valid_o <=1'b0;
                end
            RXD_StartBit:
                    cnt16<=cnt16+1'b1;
       
            RXD_Receivedata:
                begin
                    cnt16<=cnt16+1'b1;
                    if(cnt16==7)
                        begin
                            data_shiftBuff[cnt8]<=uart_rx_i;
                            cnt8<=cnt8+1'b1;                                        
                        end
                    else if(cnt16>=4'd15)
                            begin
                                cnt16<=4'b0;
                            end       
                end
            RXD_Parity_check:
                begin 
                    cnt16<=cnt16+1'b1;
                    if(cnt16==7)begin 
				    ParityBit <= uart_rx_i^data_shiftBuff[0]^data_shiftBuff[1]^data_shiftBuff[2]^data_shiftBuff[3]^data_shiftBuff[4]
                                 ^data_shiftBuff[5]^data_shiftBuff[6]^data_shiftBuff[7];
                    end
                    else if(cnt16>=4'd15)
                        cnt16<=4'b0;
				end     
            RXD_StopBit:
                begin
                    cnt8<=4'd0;
                    dataout_valid_o<=1'b0;
                    cnt16<=cnt16+1'b1;
                    if(cnt16>=4'd15)
                      cnt16<=4'b0;
                end            
            RXD_Done:
                begin  
                if(VERIFY_ON == 1'b1)
                    begin
                        if(ParityBit==VERIFY_EVEN)
                        begin
                            dataout_valid_o <= 1'b1;       
                            dataout_o<=data_shiftBuff;
                        end
                        else
                        begin  
                            dataout_valid_o <= 1'b0;          
                            dataout_o<=0;
                        end
                    end
                else 
                    begin
                        dataout_valid_o <= 1'b1;       
                        dataout_o<=data_shiftBuff;
                    end
                cnt16<=cnt16+1'b1;
                if(cnt16>=4'd15)
                    cnt16<=4'b0;   
                end
        endcase
endmodule

              