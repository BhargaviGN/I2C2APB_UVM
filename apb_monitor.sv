typedef apb_agent;
class apb_monitor extends uvm_monitor;

  apb_seq_item      w_item;
  apb_seq_item      r_item;
  apb_config_obj config_obj;
  
  virtual apb_intf intf_m; //virtual interface for monitor

  uvm_analysis_port#(apb_seq_item) aport_m;

`uvm_component_utils(apb_monitor)

function new(string name="apb_monitor" ,uvm_component parent=null);
  super.new(name,parent);
  aport_m=new("aport_m",this);
endfunction:new

virtual function void build_phase(uvm_phase phase);
 //super.build_phase(phase);
  apb_agent agent;
  if ($cast(agent, get_parent()) && agent != null) begin
       intf_m = agent.vif;
     end
     else begin
       virtual apb_intf tmp;
       if (!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", tmp)) begin
         `uvm_fatal("APB/MON/NOVIF", "No virtual interface specified for this monitor instance")
       end
      intf_m= tmp;
     end

   if(!(uvm_config_db#(apb_config_obj)::get(this,"","apb_config_obj",config_obj))) begin //get apb configuration for virtual intf handle
    `uvm_fatal({get_full_name(),"::build_phase"},"CONFIG OBJ GET FAILED") 
   end

  intf_m = config_obj.v_intf;

endfunction:build_phase

virtual task run_phase(uvm_phase phase);

  
  forever begin
   @(negedge intf_m.pclk);
   // `uvm_info("@@@@@@MONITOR DEBUG@@@@","IN RUN PHASE",UVM_LOW)
    if((intf_m.psel) && (intf_m.penable) && (intf_m.pwrite) && (intf_m.pready)) begin
      w_item=apb_seq_item::type_id::create("w_item"); 
      export_write_tx();

      end
      
    else if((intf_m.psel) && (intf_m.penable) && (!intf_m.pwrite) && (intf_m.pready))begin
      r_item=apb_seq_item::type_id::create("r_item"); 
      //@(negedge intf_m.pclk);//should be removed.
      export_read_tx();

	 end
  end
endtask:run_phase
  
  virtual function void export_write_tx();
    
     //w_item=apb_seq_item::type_id::create("w_item");
     w_item.pwrite = intf_m.pwrite;
     $display("w_item.pwrite=%d",w_item.pwrite);    
      w_item.paddr  = intf_m.paddr;
     w_item.pwdata = intf_m.pwdata;
    `uvm_info({get_full_name(),"::export_write_tx"},$sformatf("\npwrite %h\n paddr %h\n pwdata %h exporting from monitor",w_item.pwrite,w_item.paddr,w_item.pwdata),UVM_LOW)    
     aport_m.write(w_item);
    
  endfunction:export_write_tx
  
  virtual function void export_read_tx();
    
     //r_item=apb_seq_item::type_id::create("r_item");
     r_item.pwrite = intf_m.pwrite;

    

     r_item.paddr  = intf_m.paddr;
     r_item.prdata = intf_m.prdata;
    `uvm_info({get_full_name(),"::export_read_tx"},$sformatf("\npwrite %h\n paddr %h\n prdata %h exporting from monitor",r_item.pwrite,r_item.paddr,r_item.prdata),UVM_LOW)    
     aport_m.write(r_item);
    
  endfunction:export_read_tx

endclass:apb_monitor
//*********************************************************************