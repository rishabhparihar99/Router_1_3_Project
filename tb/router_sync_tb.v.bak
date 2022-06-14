module router_sync_tb();
 reg detect_add, write_enb_reg, read_enb_0, read_enb_1, read_enb_2, empty_0, empty_1, empty_2, full_0, full_1, full_2, clock, resetn; 
 reg [1:0]data_in;
 
 wire soft_reset_0, soft_reset_1, soft_reset_2, fifo_full;
 wire  vld_out_0, vld_out_1, vld_out_2;
 wire [2:0]write_enb;

router_sync DUT(detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,clock,resetn,data_in,soft_reset_0,soft_reset_1,soft_reset_2, fifo_full,vld_out_0,vld_out_1,vld_out_2,write_enb);
 
initial begin
    clock = 1'b0;
    forever #5 clock = ~clock;

end

task reset();
begin
 resetn = 1'b0;
   #15
   resetn = 1'b1;
end
endtask

task task0();
   begin
       detect_add = 1'b0;
       data_in = 2'b00;
       write_enb_reg = 1'b0;
        empty_0 = 1'b1;
       empty_1 = 1'b1;
       empty_0 = 1'b1;
       full_0 = 1'b0;
         full_1 = 1'b0;
          full_0 = 1'b0;
         read_enb_0 = 1'b0;
           read_enb_1 = 1'b0;
            read_enb_2 = 1'b0;
            reset;
           detect_add = 1'b1;
      end
endtask

task task1();
  begin
      @(negedge clock)
          data_in = 2'b10;
       @(negedge clock)
            write_enb_reg = 1'b1;
       repeat(2)
             @(negedge clock);
       empty_2 = 1'b0;
       @(negedge clock)
              full_2 = 1'b1;
              read_enb_0 = 1'b1;
               read_enb_1 = 1'b1;
   end
endtask

initial begin
     task0();
     task1();
      #500;
      $finish;
  end
endmodule