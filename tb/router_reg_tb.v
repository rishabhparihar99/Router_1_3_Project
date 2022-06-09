module router_reg_tb();
   reg clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
   reg [7:0]data_in;

   wire err,parity_done,low_pkt_valid;
   wire [7:0]dout;

   integer i;

   router_reg DUT(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_pkt_valid,dout);

   initial 
      clock = 1'b0;

      always #5 clock =~clock;

   task input_reset;
     begin
       {pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg} = 8'b0;
       {data_in} = 8'b0;
     end
     endtask

    task reset();
    begin
       @(negedge clock)
         resetn = 1'b0;
          #5;
        @(negedge clock)
           resetn = 1'b1;
      end
    endtask

    task parity_dne();
    begin
       @(negedge clock)
       {laf_state,ld_state,pkt_valid} = 3'b110;
       #10;
       @(negedge clock)
       {laf_state,ld_state,pkt_valid} = 3'b001;
    end
    endtask


    task loadfirstdata(input lfd1);
    begin
       lfd_state = lfd1;
       end
       endtask
    task fifofulll(input fifo);
    begin
        fifo_full = fifo;
     end
     endtask
     task loadstate(input ld1);
     begin
        ld_state = ld1;
       end
       endtask

     task loadafterdata(input laf1);
     begin
       laf_state = laf1;
       end
       endtask

        task detectaddress(input det1);
        begin
         detect_add = det1;
         end
          endtask

    task packet_valid(input pkt1);
      begin
         pkt_valid = pkt1;
      end
      endtask

     initial begin
        input_reset();
        reset();
        @(negedge clock)
        loadstate(1);
        @(negedge clock)
        detectaddress(1);
        @(negedge clock)
        detectaddress(0);
        #20;
        @(negedge clock)
        loadstate(0);
         #2;
         detectaddress(1);
          #5;
          detectaddress(0);
        parity_dne();
           #5;
           @(negedge clock)
             detectaddress(1);
             rst_int_reg = 1'b1;
           @(posedge clock)
             detectaddress(1);
           reset();
           input_reset();


         #10;
         @(negedge clock)
         pkt_gen1();
          #300;
         pkt_gen2();

    end

 task pkt_gen1;

			reg [7:0]header, payload_data, parity;
			reg [5:0]payload_len;
			begin
			    detectaddress(1);
			    packet_valid(1);
				payload_len=3;
				parity=0;
				header={payload_len,2'b10};
				data_in=header;
				parity=0^data_in;

				@(negedge clock);
				  detectaddress(0);
				  loadfirstdata(1);
		        @(negedge clock)
		           loadfirstdata(0);
		           loadstate(1);
				for(i=0;i<payload_len;i=i+1)	
					begin
				
	
					payload_data={$random}%256;
					data_in=payload_data;
					parity=parity^data_in;				
					
					@(negedge clock);	
					end

					fifofulll(1);
					repeat(2)
				
					  @(negedge clock);
					fifofulll(0);
					 packet_valid(0);
					 data_in = parity;
					 @(negedge clock)
					  loadstate(0);

					end
		endtask
		

task pkt_gen2;
      reg [7:0]header, payload_data, parity;
			reg [5:0]payload_len;
			 reg [1:0]addr;
			begin
			    detectaddress(1);
			    packet_valid(1);
				payload_len=3;
				addr = {$random}%3;
				header={payload_len,addr};
				data_in=header;
				parity=0^header;

				@(negedge clock);
				  detectaddress(0);
				  loadfirstdata(1);
		        @(negedge clock)
		           loadfirstdata(0);
		           loadstate(1);
				for(i=0;i<payload_len;i=i+1)	
					begin
				
	
					payload_data={$random}%256;
					data_in=payload_data;
					parity=parity^data_in;				
					
					@(negedge clock);	
					end

					fifofulll(1);
					repeat(2)
				
					  @(negedge clock);
					fifofulll(0);
					 packet_valid(0);
					 data_in = !parity;

					end
		endtask
initial begin
 #600
 $finish;
 end
 endmodule



