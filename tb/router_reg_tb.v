module router_reg_tb();
 reg clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
 reg [7:0]data_in;

 wire err,parity_done,low_pkt_valid;
 wire [7:0]dout;

 integer i;

 router_reg DUT(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_pkt_valid,dout);

initial begin
  clock = 1'b0;
 end
always #5 clock =~clock;


task reset;
begin
   resetn = 1'b0;
   #10;
   @(negedge clock);
   resetn = 1'b1;
end
endtask 

// Correct parity
task pkt1;
reg [5:0]payload_len;
reg [7:0]parity;
reg [1:0]addr;
begin
   detect_add = 1'b1;
   fifo_full = 1'b0;
   full_state = 1'b0;
   pkt_valid = 1'b1;
   lfd_state = 1'b1;
   payload_len = 6'd5;
   addr = 2'b01;
   data_in = {payload_len,addr};
   parity = 0 ^ data_in;
   repeat(2)
      @(negedge clock);
   detect_add = 1'b0;
   ld_state = 1'b1;
   lfd_state = 1'b0;
   for( i=0 ; i<payload_len ; i=i+1) begin
          data_in = $urandom%256;
          parity = parity ^ data_in;
          @(negedge clock);
   end
   full_state = 1'b1;
   data_in = parity;
   pkt_valid = 1'b0;
   @(negedge clock);
   ld_state = 1'b0;
   
end
endtask

// Internal parity mismatch
task pkt2;
reg [5:0]payload_len;
reg [7:0]parity;
reg [1:0]addr;
begin
   detect_add = 1'b1;
   fifo_full = 1'b0;
   full_state = 1'b0;
   pkt_valid = 1'b1;
   lfd_state = 1'b1;
   payload_len = 6'd5;
   addr = 2'b01;
   data_in = {payload_len,addr};
   parity = 0 ^ data_in;
   repeat(2)
      @(negedge clock);
   detect_add = 1'b0;
   ld_state = 1'b1;
   lfd_state = 1'b0;
   for( i=0 ; i<payload_len ; i=i+1) begin
          data_in = $urandom%256;
          parity = parity ^ data_in;
          @(negedge clock);
   end
 
   full_state = 1'b1;
   data_in = ! parity; // parity internally calculated is "parity"
   pkt_valid = 1'b0; 
  
   @(negedge clock);
   ld_state = 1'b0;          
         
end
endtask

//Driving stimulus
initial begin
   reset();
   repeat(2)
   @(negedge clock);
   pkt1();
   #30;
   pkt2();
end


initial #500 $finish;
  endmodule
