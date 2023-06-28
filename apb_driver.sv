typedef apb_agent;
class apb_driver extends uvm_driver#(apb_seq_item);

        apb_config_obj   config_obj;
virtual apb_intf         vintf_d   ;
        apb_seq_item     req_item  ;
        apb_seq_item     rsp_item  ;

  `uvm_component_utils(apb_driver)

  function new (string name, uvm_component parent = null);
  super.new(name,parent);
  endfunction

  
virtual function void build_phase(uvm_phase phase);
  //super.build_phase(phase);
   apb_agent agent;
  if ($cast(agent, get_parent()) && agent != null) begin
       vintf_d = agent.vif;
     end
     else begin
       virtual apb_intf tmp;
       if (!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", tmp)) begin
         `uvm_fatal("APB/MON/NOVIF", "No virtual interface specified for this monitor instance")
       end
      vintf_d= tmp;
     end


   if(!(uvm_config_db#(apb_config_obj)::get(this,"","apb_config_obj",config_obj))) begin //get apb configuration for virtual intf handle
    `uvm_fatal({get_full_name(),"::build_phase"},"CONFIG OBJ GET FAILED") 
   end

  vintf_d = config_obj.v_intf;

endfunction:build_phase
  
virtual task run_phase(uvm_phase phase);
  driver_initial_reset();
  //`uvm_info("apb_driver_reset","reset the interface",UVM_LOW)
  forever  
  begin

    seq_item_port.get_next_item(req_item);

    `uvm_info({get_full_name(),"::run_phase"},"seq item Arrived at driver",UVM_LOW)
    
    if(!req_item.prstn) begin
       reset_tx(req_item)  ;  //task to reset DUT intf 
      end    
      else  begin
       driver_tx(req_item) ; //task to drive DUT intf 
      end
     
     seq_item_port.item_done()      ;
        `uvm_info({get_full_name(),"::run_phase"},"before rsp item",UVM_LOW)
     rsp_item.set_id_info(req_item) ;
     seq_item_port.put(rsp_item)    ;
    
    `uvm_info({get_full_name(),"::run_phase"},"seq item sent to DUT from driver",UVM_LOW)

   end
    
endtask:run_phase
  
  task driver_initial_reset();
    
    vintf_d.presetn = 1;
   @(posedge vintf_d.pclk);
    vintf_d.presetn = 0;
    vintf_d.psel    = 0;
    vintf_d.pwrite  = 0;
    vintf_d.paddr   = 0;
    vintf_d.pwdata  = 0;
    vintf_d.penable = 0;      
   @(posedge vintf_d.pclk);  
    vintf_d.presetn = 1; 
    
  endtask:driver_initial_reset



 task reset_tx(apb_seq_item req_item);
   @(posedge vintf_d.pclk);
    `uvm_info({get_full_name(),"::run_phase"},"reset DUT",UVM_LOW)
    vintf_d.presetn = 0;
    repeat(req_item.no_rst_cyc) begin
	    $display("no_rst_cyc",req_item.no_rst_cyc);
	@(posedge vintf_d.pclk);
    end	
   vintf_d.presetn = 1;

   if(!($cast(rsp_item,req_item.clone()))) begin
    `uvm_fatal({get_full_name(),"::driver_tx"},"REQ AND RSP ITEM TYPE MISMATCH")
   end

    rsp_item.pwdata = vintf_d.pwdata  ;
    rsp_item.prdata = vintf_d.prdata  ;
    rsp_item.paddr  = vintf_d.paddr   ;
    rsp_item.pwrite = vintf_d.pwrite  ;
    rsp_item.pslverr = vintf_d.pslverr;
    `uvm_info({get_full_name(),"::driver_tx"},$sformatf("\npwrite %h\n paddr%h\n prdata %h\n pslverr %h\n",rsp_item.pwrite,rsp_item.paddr,rsp_item.prdata,rsp_item.pslverr),UVM_LOW)
 endtask:reset_tx 
    
  task driver_tx(apb_seq_item req_item); 
    
    @(posedge vintf_d.pclk);
    vintf_d.presetn = req_item.prstn ;
    vintf_d.psel    = 1              ;
    vintf_d.pwrite  = req_item.pwrite;
    vintf_d.paddr   = req_item.paddr ;
    
    if(req_item.pwrite) begin
    vintf_d.pwdata = req_item.pwdata;
      `uvm_info({get_full_name(),"::driver_tx"},$sformatf("\npwrite %h\n paddr%h\n pwdata %h\n",req_item.pwrite,req_item.paddr,req_item.pwdata),UVM_LOW)
    end 
        
    @(posedge vintf_d.pclk);    
    vintf_d.penable = 1; 
    
    while(! vintf_d.pready)
    begin 
    @(posedge vintf_d.pclk);     
      `uvm_info({get_full_name(),"::driver_tx"},"waiting for pready",UVM_LOW)
    end   
    
    if(!($cast(rsp_item,req_item.clone()))) begin
    `uvm_fatal({get_full_name(),"::driver_tx"},"REQ AND RSP ITEM TYPE MISMATCH")
    end
    @(negedge vintf_d.pclk);

    if(!req_item.pwrite) begin
    rsp_item.prdata = vintf_d.prdata  ;
    rsp_item.paddr  = vintf_d.paddr   ;
    rsp_item.pwrite = vintf_d.pwrite  ;
    rsp_item.pslverr = vintf_d.pslverr;
      //`uvm_info("DRIVER DEBUG MSG",$sformatf("\npwrite %h\n paddr%h\n prdata %h\n pslverr %h\n",vintf_d.pwrite,vintf_d.paddr,vintf_d.prdata,vintf_d.pslverr),UVM_LOW)
      `uvm_info({get_full_name(),"::driver_tx"},$sformatf("\npwrite %h\n paddr%h\n prdata %h\n pslverr %h\n",rsp_item.pwrite,rsp_item.paddr,rsp_item.prdata,rsp_item.pslverr),UVM_LOW)
    end
    else
    rsp_item.pslverr = vintf_d.pslverr;    
                       
    @(posedge vintf_d.pclk);  
    vintf_d.psel    = 0;
    vintf_d.penable = 0;    
    
  endtask:driver_tx

endclass:apb_driver
