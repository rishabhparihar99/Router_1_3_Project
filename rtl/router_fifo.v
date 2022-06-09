
module router_fifo(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,full,empty,data_out);

input clock,resetn,soft_reset;
input write_enb,read_enb,lfd_state;
input [7:0]data_in;
  
output reg [7:0] data_out;
output full,empty;
  


reg [8:0]fifo[15:0];

reg lfd_state_t;
reg [4:0]rd_ptr,wr_ptr;
reg [6:0]count;
integer i;


// LFD_STATE
always@(posedge clock) begin
      if(!resetn)
        lfd_state_t <= 0;
      else
        lfd_state_t <= lfd_state;
end 

// WRITE OPERATION
always@(posedge clock) begin
      if(!resetn || soft_reset)
              begin
                  for(i=0;i<16;i=i+1)
                        fifo[i]<=0;
              end
      else if(write_enb&&(~full))   
              begin
                      if(lfd_state_t)
	                      begin
                                 fifo[wr_ptr[3:0]][8]<=1'b1;
                                 fifo[wr_ptr[3:0]][7:0]<=data_in;
	                      end
                       else
	                      begin
                                   fifo[wr_ptr[3:0]][8]<=1'b0;
                                   fifo[wr_ptr[3:0]][7:0]<=data_in;
			      end
              end
     end

//READ
always@(posedge clock) begin
    if(!resetn)
        data_out <= 8'b0;
      else if(soft_reset) 
          data_out <= 8'bz;
      else if((read_enb) && (!empty))
            data_out <= fifo[rd_ptr[3:0]][7:0];
      else if(count == 0)
              data_out <= 8'bz;
end    

// POINTERS
always@(posedge clock) begin
if(!resetn) begin
     wr_ptr <= 0;
     rd_ptr <= 0; end
else begin
    if(write_enb && !full)
       wr_ptr <= wr_ptr + 1'b1;
    else
      wr_ptr <= wr_ptr;
    if(read_enb && !empty)
        rd_ptr <= rd_ptr + 1'b1;
    else
        rd_ptr<= rd_ptr ;end
end

// READ COUNTER BLOCK
always@(posedge clock) begin
 if(read_enb && !empty) begin
      if( (fifo[rd_ptr[3:0]][8]) == 1)
             count <=  fifo[rd_ptr[3:0]][7:2] + 1'b1 ;
      else if(count != 0)
            count <= count - 1'b1;
       end
end

//FULL & EMPTY CONDITION
  assign full  = (wr_ptr ==({~rd_ptr[4],rd_ptr[3:0]}))?1:0;
  assign empty = (rd_ptr == wr_ptr)?1:0;

endmodule


