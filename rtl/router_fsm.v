module router_fsm(clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid
                  ,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in,
               busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input [1:0]data_in;
output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;

 parameter  DECODE_ADDRESS   =	4'b0001,
			WAIT_TILL_EMPTY = 4'b0010,
			LOAD_FIRST_DATA	= 4'b0011,
			LOAD_DATA = 4'b0100,
			LOAD_PARITY = 4'b0101,
			FIFO_FULL_STATE	= 4'b0110,
			LOAD_AFTER_FULL	 = 4'b0111,
			CHECK_PARITY_ERROR = 4'b1000;
reg [3:0]state,next_state;
 reg [1:0]addr;

// PRESENT STATE LOGIC
always@(posedge clock) begin
  if(!resetn)
       addr <= 2'd0;
    else if(detect_add)
       addr <= data_in;
  end


always @(posedge clock) begin
  if(!resetn)
      state <= DECODE_ADDRESS;
  else if(((soft_reset_0) && ( addr == 2'd0)) || ((soft_reset_1) && (addr == 2'd1)) || ((soft_reset_2) && ( addr == 2'd2)))
       state <= DECODE_ADDRESS;
  else
      state <= next_state;
end

//NEXT_STATE_LOGIC
always@(*) begin
  next_state = 4'b0;
  case(state)
      DECODE_ADDRESS: 
          begin
           if((pkt_valid && data_in[1:0] == 2'd0 && fifo_empty_0) || 
               (pkt_valid && (data_in[1:0] == 2'd1) && fifo_empty_1 ) ||
                (pkt_valid && (data_in[1:0] == 2'd2) && fifo_empty_2))
                    next_state = LOAD_FIRST_DATA;
           else if((pkt_valid && (data_in[1:0] == 2'd0) && !fifo_empty_0) ||
                    (pkt_valid && (data_in[1:0] == 2'd1) && !fifo_empty_1) ||
                     (pkt_valid && (data_in[1:0] == 2'd2) && !fifo_empty_2))
                     next_state = WAIT_TILL_EMPTY;
            else
                next_state = DECODE_ADDRESS;
          end

     LOAD_FIRST_DATA : next_state = LOAD_DATA;
  
     WAIT_TILL_EMPTY : begin
         if((fifo_empty_0 && (addr == 2'd0)) ||
              (fifo_empty_1 && (addr == 2'd1)) ||
                (fifo_empty_2 && (addr == 2'd2))) 
                        next_state = LOAD_FIRST_DATA;
         else
                next_state  = WAIT_TILL_EMPTY;
         end

    LOAD_DATA : begin
       if(fifo_full)
           next_state = FIFO_FULL_STATE;
       else if(!fifo_full && !pkt_valid)
            next_state = LOAD_PARITY;
       else
            next_state = LOAD_DATA;
      end

   FIFO_FULL_STATE: begin
       if(fifo_full)
          next_state = FIFO_FULL_STATE;
      else 
          next_state = LOAD_AFTER_FULL;
    end
   
   LOAD_AFTER_FULL:begin
     if(parity_done)
         next_state = DECODE_ADDRESS;
     else begin
        if(low_pkt_valid)
            next_state = LOAD_PARITY;
        else
            next_state = LOAD_DATA;
           end
    end
  
    LOAD_PARITY: next_state = CHECK_PARITY_ERROR;
    
    CHECK_PARITY_ERROR:
             if(fifo_full)
                      next_state = FIFO_FULL_STATE;
             else 
                      next_state = DECODE_ADDRESS;
     
  endcase
end

//OUTPUT LOGIC
assign detect_add = (state==DECODE_ADDRESS)?1:0;
assign lfd_state = (state == LOAD_FIRST_DATA)?1:0;
assign busy = ((state==LOAD_FIRST_DATA)||(state==LOAD_PARITY)||(state==FIFO_FULL_STATE)||(state==LOAD_AFTER_FULL)||(state==WAIT_TILL_EMPTY)||(state==CHECK_PARITY_ERROR))?1:0;
assign ld_state = (state  == LOAD_DATA)?1:0;
assign write_enb_reg = ((state==LOAD_DATA)||(state==LOAD_AFTER_FULL)||(state==LOAD_PARITY))?1:0;
assign laf_state = (state == LOAD_AFTER_FULL)?1:0;
assign full_state = (state == FIFO_FULL_STATE)?1:0;
assign rst_int_reg = (state == CHECK_PARITY_ERROR)?1:0;


endmodule
   
  
              

  
     
  
 





