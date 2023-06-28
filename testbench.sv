package i2c_vip_package;

`include "uvm_macros.svh"

import uvm_pkg::*;



`include "apb_seq_item.sv"
`include "i2c_slave_tx_item.sv"


`include "apb_config_obj.sv"
`include "i2c_slave_config.sv"
`include "i2c_env_config.sv"

`include "apb_sequencer.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_agent.sv"
`include "apb_sequence.sv"
`include "wr_rd_seq.sv"
//`include "apb_env.sv"
//`include "apb_seq_item.sv"
//`include "apb_reset_seq.sv"


`include "i2c_slave_sequencer.sv"
`include "i2c_slave_driver.sv"
`include "i2c_slave_monitor.sv"
`include "i2c_slave_agent.sv"

`include "i2c_vip_scoreboard.sv"
`include "i2c_vip_env.sv"

`include "i2c_seq1.sv"




`include "i2c_vip_test.sv"
//`include "apb_wr_rd_test.sv"
//`include "i2c_apb_vip_reset_test.sv"
`include "i2c_apb_vip_wr_rd_test.sv"
endpackage 

///////////////////////////////////////
module i2c1;
import uvm_pkg::* ;  
import i2c_vip_package::* ;  
 
reg tb_clk;
reg apb_clk;
wire tb_sda_enable;
wire tb_scl_enable;
wire tb_sda_in;
wire tb_scl_in;
wire tb_slave_ack;
wire start;
wire stop;
logic sda;
reg sclk_count;

//***********************************************************//
 //Clock Generation
//***********************************************************//
 initial begin //{
      tb_clk=1'b0;
      forever begin //{
           #5ns tb_clk = ~tb_clk;  
      end //}
 end //}
 initial begin //{
      apb_clk=1'b0;
      forever begin //{
           #10ns apb_clk = ~apb_clk;  
      end //}
 end //}
 
//**************************************************************//
 //Interface declarations
//**************************************************************//
     i2c_vip_intf in1(tb_clk);
      apb_intf    in0(apb_clk);

//***********************************************************//
 //Configurations
//***********************************************************//

 initial begin //{
uvm_config_db#(virtual apb_intf)::set(null,"*","vif",in0);
uvm_config_db#(virtual i2c_vip_intf)::set(null,"*","v_intf",in1);



   run_test("i2c_vip_test");
 end //}

//****************************************************************//
 //Questa dump options
//****************************************************************//
 initial begin //{
    $dumpfile("dump.vcd");
   $dumpvars(0,i2c1);    
 end //}

//******************************************************************//
       //dut signals
//******************************************************************//

    i2c i2c_vip_dut_inst(.PCLK(in0.pclk), 
                         .PRESETn(in0.presetn), 
                         .PADDR(in0.paddr),
                         .PWDATA (in0.pwdata), 
                         .PWRITE(in0.pwrite),
                         .PSELx(in0.psel),
                         .PENABLE(in0.penable),
                         .PREADY(in0.pready),
                         .PSLVERR(in0.pslverr),
                         .INT_RX(INT_RX),
                         .INT_TX(INT_TX),
                         .PRDATA(in0.prdata) ,
                         .SDA_ENABLE(in1.TB_SDA_ENABLE),
                         .SCL_ENABLE(in1.TB_SCL_ENABLE),
                         .SDA(tb_sda_in),
                         .SCL(tb_scl_in));




                               
assign tb_sda_enable = in1.TB_SDA_ENABLE;
assign tb_scl_enable = in1.TB_SCL_ENABLE;
assign in1.TB_SDA =tb_sda_in;
assign tb_sda_in = in1.slave_ack ? in1.sda_out : 1'bz;//tristate buffer for driving ack to the mster
assign in1.TB_SCL=tb_scl_in;
assign tb_slave_ack=in1.slave_ack;


initial
begin
$monitor($stime,"in1.SDA = %d",in1.TB_SDA);
end


endmodule
