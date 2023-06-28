
`ifndef _I2C_SLAVE__SEQUENCER_SV_
`define _I2C_SLAVE__SEQUENCER_SV_

class i2c_slave_sequencer extends uvm_sequencer#(i2c_slave_tx_item);

    `uvm_component_utils(i2c_slave_sequencer)

    // Methods
    extern function new (string name="i2c_slave_sequencer", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);

endclass : i2c_slave_sequencer

//******************************************************************//
// Implementation
//******************************************************************//
//------------------------------------------------------------------------------
// Constructor
//******************************************************************//
function i2c_slave_sequencer::new(string name="i2c_slave_sequencer", uvm_component parent=null);
    super.new(name, parent);
endfunction : new

//*****************************************************************//
// Build
//*****************************************************************//
function void i2c_slave_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

`endif