
class apb_config_obj extends uvm_object;
  
  `uvm_object_utils( apb_config_obj)
  
  uvm_active_passive_enum is_agent=UVM_ACTIVE;
  virtual apb_intf v_intf;
  
  function new(string name="apb_config_obj");
    super.new(name);
  endfunction

   task wait_for_reset();
    @(negedge v_intf.presetn); //reset asserted
    @(posedge v_intf.presetn); //reset deasserted
  endtask
  
  task wait_for_clocks(bit[3:0] n=1); //provides one clock cycle delay default
    repeat(n) begin                   //16 clock cycles max delay
      @(posedge v_intf.pclk);
    end
  endtask:wait_for_clocks
  
 // task wait_for_IRQ();
 //   @(posedge vintf.fsk_int);
 // endtask:wait_for_IRQ
  
endclass:apb_config_obj