
`ifndef _I2C_SLAVE_AGENT_SV_
`define _I2C_SLAVE_AGENT_SV_

//------------------------------------------------------------------------------
//
// CLASS: i2c_slave__agent
//
//------------------------------------------------------------------------------

class i2c_slave_agent extends uvm_agent;

    `uvm_component_utils(i2c_slave_agent)
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    i2c_slave_config m_config;
    virtual i2c_vip_intf vif;
    bit coverage_enable = 1;
    bit checks_enable = 1;


    //------------------------------------------
    // Component Members
    //------------------------------------------
    i2c_slave_sequencer                      i2c_slave_sequencer_h;
    i2c_slave_monitor                        i2c_slave_monitor_h;
    i2c_slave_driver                         i2c_slave_driver_h;

    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard Methods
    extern function new (string name = "i2c_slave_agent", uvm_component parent = null);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase (uvm_phase phase);

endclass: i2c_slave_agent

// Implementation
//*************************************************************//
// Constructor
//*************************************************************//

function i2c_slave_agent::new (string name = "i2c_slave_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction

//**************************************************************//
// Construct sub-components
// retrieve and set sub-component configuration
//**************************************************************//

function void i2c_slave_agent::build_phase (uvm_phase phase);
    super.build_phase(phase);
  
  if (!uvm_config_db#(virtual i2c_vip_intf)::get(this, "", "i2c_vip_intf",vif)) begin
    `uvm_fatal("I2C/AGENT/NOVIF", "No virtual interface specified for this i2c agent instance")
       end
    if(!uvm_config_db #(i2c_slave_config)::get(this,"", "i2c_slave_config", m_config))begin
        `uvm_error("MSGID","Failed to get agent's config object: i2c_slave_config")
    end
    // monitor is always present
    i2c_slave_monitor_h = i2c_slave_monitor::type_id::create("i2c_slave_monitor_h", this);
    // Only build the driver and sequencer if active
    if(m_config.is_active == UVM_ACTIVE)
    begin
        i2c_slave_sequencer_h = i2c_slave_sequencer::type_id::create("i2c_slave_sequencer_h", this);
        i2c_slave_driver_h    = i2c_slave_driver::type_id::create("i2c_slave_driver_h", this);
    end
endfunction: build_phase

//*********************************************************************//
// Connect sub-components
//**********************************************************************//

function void i2c_slave_agent::connect_phase (uvm_phase phase);
    // Only connect the driver and the sequencer if active
    if(m_config.is_active == UVM_ACTIVE)
    begin
        i2c_slave_driver_h.seq_item_port.connect(i2c_slave_sequencer_h.seq_item_export);
    end
endfunction: connect_phase

`endif