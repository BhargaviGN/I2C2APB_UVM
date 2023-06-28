          //  i2c slave transaction
//*******************************************************************//

`ifndef _I2C_SLAVE_TX_ITEM_ITEM_SV_
`define _I2C_SLAVE_TX_ITEM_ITEM_SV_

class i2c_slave_tx_item extends uvm_sequence_item;

    //------------------------------------------
    // Field automation
    //------------------------------------------
    `uvm_object_utils(i2c_slave_tx_item)

    //*********************************************//
    // Data Members
    //*********************************************//
       bit  [7:0] data_to_transmitt='0;
       bit [7:0]input_data='0;
       bit [7:0]address;
       bit [7:0]slave_address;
       bit [7:0]slave_address_monitor;
       bit [7:0]reg_address_monitor;
       bit [7:0]input_data_monitor;
       bit [7:0]data_monitor[int];
       bit   start;
       bit   stop;
       bit   write_ack;
       bit [31:0]i2c_data_monitor_queue[$];  
       bit     monitor_ack;
       bit [0:7]reg_address;     
       bit [0:7] input_dat;       

    //------------------------------------------
    // Methods
    //------------------------------------------
    extern function new(string name="i2c_slave_tx_item");
    extern function void   do_print (uvm_printer printer);
endclass : i2c_slave_tx_item

//**************************************************************//
// Implementation
//**************************************************************//

function i2c_slave_tx_item::new(string name="i2c_slave_tx_item");
    super.new(name);
endfunction : new

//****************************************************************//
       //do print method
//****************************************************************//

function void i2c_slave_tx_item::do_print(uvm_printer printer);
super.do_print(printer);
printer.print_field("slave_address_monitor",this.slave_address_monitor,8,UVM_BIN);
printer.print_field("reg_address_monitor",this.reg_address_monitor,8,UVM_BIN);
printer.print_field(" input_data_monitor",this.input_data_monitor,8,UVM_BIN);
printer.print_field(" stop",this.stop,1,UVM_BIN);


endfunction

`endif
//*************************************************************