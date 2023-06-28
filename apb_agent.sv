class apb_agent extends uvm_agent;

  apb_driver       driver_a  ;
  apb_monitor      monitor_a ;
 // uvm_sequencer #(apb_seq_item) seqr_a;
  apb_sequencer    seqr_a    ;
  apb_config_obj   config_obj;
  virtual apb_intf vif;
  uvm_analysis_port#(apb_seq_item) aport_a;

`uvm_component_utils(apb_agent)

  function new(string name="apb_agent",uvm_component parent=null);  
  
    super.new(name,parent);
    aport_a=new("aport_a",this);

  endfunction:new

  virtual function void build_phase(uvm_phase phase);
    
  super.build_phase(phase);
     if (!uvm_config_db#(virtual apb_intf)::get(this, "", "vif", vif)) begin
       `uvm_fatal("APB/AGT/NOVIF", "No virtual interface specified for this apb env instance")
     end
   // uvm_config_db#(virtual apb_intf)::set( this, "", "vif", vif);
     //`uvm_info("environment","build phase ended",UVM_LOW);
    
    if(!(uvm_config_db#(apb_config_obj)::get(this,"","apb_config_obj",config_obj))) begin
    `uvm_fatal({get_full_name(),"::build_phase"},"CONFIG OBJ GET FAILED")
    end

    if(config_obj.is_agent==UVM_ACTIVE) begin    
    driver_a = apb_driver::type_id::create("driver_a",this) ;
    seqr_a   = apb_sequencer::type_id::create("seqr_a",this);
    end
    
  monitor_a=apb_monitor::type_id::create("monitor_a",this);
    
  endfunction:build_phase

  virtual function void connect_phase(uvm_phase phase);
    
    if(config_obj.is_agent==UVM_ACTIVE) begin
    driver_a.seq_item_port.connect(seqr_a.seq_item_export);
    end

    monitor_a.aport_m.connect(aport_a);
  
  endfunction:connect_phase

endclass:apb_agent