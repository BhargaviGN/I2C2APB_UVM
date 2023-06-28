  class i2c_vip_env  extends uvm_env;
  virtual i2c_vip_intf  vif;
  virtual apb_intf  vif1;
  `uvm_component_utils(i2c_vip_env);
   i2c_slave_agent agent_i;
   apb_agent agent_a;
   i2c_vip_scoreboard scoreboard;
    // apb_scoreboard scoreboard;
   //ENV class will have agent as its sub component
  // apb_agent  agt;
   //virtual interface for APB interface
  

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   //Build phase - Construct agent and get virtual interface handle from test  and pass it down to agent
   function void build_phase(uvm_phase phase);
     `uvm_info("environment","build phase started",UVM_LOW);
     if ($cast(agent_i, get_parent()) && agent_i != null) begin
       vif = agent_i.vif;
     end
     agent_i = i2c_slave_agent::type_id::create("agent_i", this);
     agent_a = apb_agent::type_id::create("agent_a", this);
     scoreboard =i2c_vip_scoreboard::type_id::create("scoreboard",this);    
     if (!uvm_config_db#(virtual i2c_vip_intf)::get(this, "", "v_intf", vif)) begin
     `uvm_fatal("I2C/AGT/NOVIF", "No virtual interface specified for this i2c env instance")
     end
     uvm_config_db#(virtual i2c_vip_intf)::set( this, "agent_i", "vif", vif);
     `uvm_info("environment","build phase ended",UVM_LOW);
     
       //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//     
       //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$//
     
     if ($cast(agent_a, get_parent()) && agent_a != null) begin
       vif1 = agent_a.vif;
     end
     
     if (!uvm_config_db#(virtual apb_intf)::get(this, "", "vif", vif1)) begin
       `uvm_fatal("APB/AGT/NOVIF", "No virtual interface specified for this apb env instance")
     end
     uvm_config_db#(virtual apb_intf)::set( this, "agent_a", "vif1", vif1);
     `uvm_info("environment","build phase ended",UVM_LOW);
   endfunction: build_phase
  
   
  function void connect_phase(uvm_phase phase);
   //agent.drv.drv_to_sb.connect(scoreboard.input_fifo.analysis_export);
   // `uvm_info("environment","driver connected scoreboard",UVM_LOW);    
    agent_i.i2c_slave_monitor_h.i2c_slave_ap.connect(scoreboard.i2c_analysis_export);
   `uvm_info("environment","monitor connected to scoreboard",UVM_LOW);
     agent_a.monitor_a.aport_m.connect(scoreboard.apb_analysis_export);
    `uvm_info("environment","apb monitor connected to scoreboard",UVM_LOW);
  endfunction  
  
endclass : i2c_vip_env
////////////////////////////////////////////////////////////////////////////
