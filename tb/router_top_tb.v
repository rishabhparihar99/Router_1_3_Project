module router_top_tb();

   reg clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid;
   reg [7:0]datain;

   wire [7:0]data_out_0, data_out_1, data_out_2;
   wire vld_out_0, vld_out_1, vld_out_2, err, busy;
   integer i;

  router_top DUT(.clock(clk),.resetn(resetn),.read_enb_0(read_enb_0), .read_enb_1(read_enb_1), .read_enb_2(read_enb_2), .pkt_valid(packet_valid),  .data_in(datain), .data_out_0(data_out_0),  .data_out_1(data_out_1), .data_out_2(data_out_2), .valid_out_0(vld_out_0),    .valid_out_1(vld_out_1),   .valid_out_2(vld_out_2),.error(err),  .busy(busy) );        
     

initial begin
    clk = 1'b0;
end
  always #5 clk = ~clk;
  
task reset;
 begin
   resetn=1'b0;
   {read_enb_0, read_enb_1, read_enb_2, packet_valid, datain}=0;
   #10;
   @(negedge clk)
   resetn=1'b1;
 end
endtask

task pkt_len_25;
reg [5:0]payload_len;
reg [7:0]payload_data,parity;
reg [1:0]addr;
begin
    @(negedge clk);
     wait(!busy)

     packet_valid = 1'b1;
     payload_len = 6'd25;
     addr = 2'b01;
     datain = {payload_len,addr};
     parity = 0 ^ datain;

     @(negedge clk);
     wait(!busy)

     for(i=0; i<payload_len; i=i+1)
        begin
          @(negedge clk)
          wait(!busy)
              payload_data = {$urandom}%256;
              datain = payload_data;
              parity = parity ^ datain;
        end
     @(negedge clk)
     wait(!busy)
     packet_valid = 1'b0;
     datain = parity;
      
end 
endtask
    
task pkt_len_5;
reg [5:0]payload_len;
reg [7:0]payload_data,parity;
reg [1:0]addr;
begin
    @(negedge clk);
     wait(!busy)

     packet_valid = 1'b1;
     payload_len = 6'd5;
     addr = 2'b10;
     datain = {payload_len,addr};
     parity = 0 ^ datain;

     @(negedge clk);
     wait(!busy)

     for(i=0; i<payload_len; i=i+1)
        begin
          @(negedge clk)
          wait(!busy)
              payload_data = {$urandom}%256;
              datain = payload_data;
              parity = parity ^ datain;
        end
     @(negedge clk)
     wait(!busy)
     packet_valid = 1'b0;
     datain = parity;
      
end 
endtask
  
  


  
initial begin
   reset();
   pkt_len_25();
   repeat(8)
      @(negedge clk);
   read_enb_1 = 1'b1;
   read_enb_2 = 1'b1; 
   repeat(16)
      @(negedge clk);
    reset();
    pkt_len_5();
    repeat(2)
       @(negedge clk);
    read_enb_2 = 1'b1;
   #1000 $finish;
end
    
    
endmodule