module router_fifo_tb();
  reg clock,resetn,soft_reset;
  reg write_enb,read_enb,lfd_state;
  reg [7:0]data_in;

  wire [7:0]data_out;
  wire full,empty;
  integer i;

  router_fifo DUT(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,full,empty,data_out);


  initial begin
     clock = 1'b0;
      forever #5 clock=~clock;
  end

  task input_reset();
  begin
      resetn =1'b0;
      {soft_reset,write_enb,read_enb,lfd_state} = 4'b0000;
  end
  endtask

  task write;
    reg [7:0]payload_data,parity,header;
    reg [5:0]payload_len;
    reg [1:0]addr;
      begin
        @(negedge clock);
          write_enb = 1'b1;
          payload_len = 6'd14;
          addr = 2'b01;
          header = {payload_len,addr};
          data_in = header;
          lfd_state = 1'b1;
          for(i=0;i<payload_len;i=i+1)
           begin
              @(negedge clock);
                 lfd_state =1'b0;
                 payload_data = ($random)%256;
                data_in = payload_data;
            end
        @(negedge clock)
            parity = ($random)%256;
            data_in = parity;
        end
    endtask

    initial begin
    input_reset();
       @(negedge clock)
        resetn = 1'b1;
       write();
   end

   initial begin
    #200
       @(negedge clock)
          read_enb = 1'b1;
          write_enb = 1'b0;
   end

  initial 
     #1000 $finish;
endmodule
