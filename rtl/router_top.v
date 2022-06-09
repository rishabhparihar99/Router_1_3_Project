module router_top(clock,resetn,read_enb_0,read_enb_1,
                 read_enb_2, data_in ,pkt_valid, data_out_0, data_out_1, data_out_2,
                   valid_out_0, valid_out_1, valid_out_2, error, busy);


  input clock,resetn,read_enb_0,read_enb_1,read_enb_2;
  input [7:0]data_in;
  input pkt_valid;

  output [7:0]data_out_0,data_out_1,data_out_2;
  output valid_out_0, valid_out_1, valid_out_2, error, busy;
  
 /*FSM*/  wire  parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
         low_pkt_valid,detect_add,
            ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;

          /*Sync*/     wire  empty_0,empty_1,empty_2,full_0,full_1,full_2; 
                  wire [2:0]write_enb;

   /*reg*/  wire [7:0]dout;

  router_fsm FSM(.clock(clock),.resetn(resetn),.pkt_valid(pkt_valid),.parity_done(parity_done),
          .soft_reset_0(soft_reset_0),.soft_reset_1(soft_reset_1),.soft_reset_2(soft_reset_2),
                        .fifo_full(fifo_full),.low_pkt_valid(low_pkt_valid)
                  ,.fifo_empty_0(empty_0),.fifo_empty_1(empty_1),.fifo_empty_2(empty_2),.data_in(data_in[1:0]),
                  .busy(busy),.detect_add(detect_add),.ld_state(ld_state),.laf_state(laf_state),.full_state(full_state),.write_enb_reg(write_enb_reg),.rst_int_reg(rst_int_reg),.lfd_state(lfd_state));
  
 router_sync Synchronizer(.detect_add(detect_add), .write_enb_reg(write_enb_reg), .read_enb_0(read_enb_0), .read_enb_1(read_enb_1), .read_enb_2(read_enb_2),
           .empty_0(empty_0), .empty_1(empty_1), .empty_2(empty_2),
          .full_0(full_0), .full_1(full_1), .full_2(full_2), .clock(clock), .resetn(resetn),
         .data_in(data_in[1:0]),.soft_reset_0(soft_rest_0), .soft_reset_1(soft_reset_1) , 
             .soft_reset_2(soft_reset_2), .fifo_full(fifo_full),
             .vld_out_0(valid_out_0), .vld_out_1(valid_out_1), .vld_out_2(valid_out_2) ,.write_enb(write_enb));

  router_reg Register(.clock(clock),.resetn(resetn) ,.pkt_valid(pkt_valid),.data_in(data_in),.fifo_full(fifo_full),.detect_add(detect_add), .ld_state(ld_state),
                .laf_state(laf_state),.full_state(full_state),.lfd_state(lfd_state),.rst_int_reg(rst_int_reg),.err(error),.parity_done(parity_done),.low_pkt_valid(low_pkt_valid), .dout(dout));

  router_fifo FIFO_0( .clock(clock), .resetn(resetn), .soft_reset(soft_reset_0), .write_enb(write_enb[0]), .read_enb(read_enb_0) ,.lfd_state(lfd_state), .data_in(dout) ,.full(full_0), .empty(empty_0), .data_out(data_out_0));
  router_fifo FIFO_1( .clock(clock), .resetn(resetn), .soft_reset(soft_reset_1), .write_enb(write_enb[1]) ,.read_enb(read_enb_1) ,.lfd_state(lfd_state), .data_in(dout) ,.full(full_1), .empty(empty_1), .data_out(data_out_1));
  router_fifo FIFO_2( .clock(clock), .resetn(resetn), .soft_reset(soft_reset_2), .write_enb(write_enb[2]) ,.read_enb(read_enb_2) ,.lfd_state(lfd_state), .data_in(dout) ,.full(full_2), .empty(empty_2), .data_out(data_out_2));
  
endmodule




