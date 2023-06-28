class apb_wr_rd_test extends uvm_test;
  
  `uvm_component_utils(apb_wr_rd_test)
  
  apb_env env;
  apb_config_obj cfg;
  virtual  apb_intf vif;
  wr_rd_seq seq ;
  
  function new(string name="apb_wr_rd_test");
    super.new(name);
  endfunction
  
  function void build_phase(uvm_phase phase);
    //super.build(phase);
    cfg=apb_config_obj::type_id::create("cfg",this);
    env=apb_env::type_id::create("env",this);
    
    if (!uvm_config_db #(virtual apb_intf ) ::get (this,"","vif",vif)) begin
        
        `uvm_fatal("No such interface is created","APB/TEST")
        end
        
        uvm_config_db#(virtual apb_intf)::set( this, "env", "vif", vif);
  endfunction
        
        task body();
          
          seq=wr_rd_seq::type_id::create("seq",this);
          
          phase.raise_objection(this,"starting the sequence");
          $display("%t sequence has been started",$time);
          
          seq.start(env.agent.seqr_a);
           phase.drop_objection(this,"starting the sequence");
          $display("%t sequence has ended",$time);
        endtask
        endclass

          
  