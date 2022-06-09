module router_fsm_tb();
 reg clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
 reg [1:0]data_in;
 wire busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;


 router_fsm DUT(clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid
                  ,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in,
               busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);


initial 
  clock = 1'b0;
  always  #5 clock = ~clock;

task reset;
begin
 resetn = 1'b0;
 @(posedge clock)
 resetn = 1'b1; 
end
endtask

//DA-LFD-LD-LP-CPE-DA
task task1;
 begin

   pkt_valid = 1'b1;
   data_in = 2'b01;
   fifo_empty_1 = 1'b1;
   fifo_full = 1'b0;
   low_pkt_valid = 1'b0;
   @(posedge clock)
   pkt_valid = 1'b0;
end

endtask

//DA-LFD-LD-FFS-LAF-LP-CPE-DA
task task2;
 begin
   pkt_valid = 1'b1;
   fifo_full = 1'b1;
   low_pkt_valid = 1'b1;
   parity_done = 1'b0;
    repeat(4)
       @(posedge clock);
   fifo_full = 1'b0;
   pkt_valid = 1'b0;
end
endtask

//DA-LFD-LD-FFS-LAF-LD-LP-CPE-DA
task task3;
  begin
     pkt_valid = 1'b1;
     fifo_full = 1'b1;
     low_pkt_valid = 1'b0;
      repeat(4)
         @(posedge clock);
      fifo_full = 1'b0;
      pkt_valid = 1'b0;
   end
endtask
 

//DA-LFD-LD-LP-CPE-FFS-LAF-DA
task task4;
 begin
    pkt_valid = 1'b1;
    fifo_full = 1'b0;
    parity_done = 1'b1;
    repeat(3)
      @(posedge clock);
    pkt_valid = 1'b0;
    repeat(2)
      @(posedge clock);
    fifo_full = 1'b1;
    @(posedge clock)
       fifo_full = 1'b0;
end
endtask
     
initial begin
  reset();
  task1;
  #60;
  task2;
  #60;
  task3;
  #70;
  task4;
end

initial begin
  #400 $finish;
end
endmodule