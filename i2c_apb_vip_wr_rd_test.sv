         //testcases
//************************************************************************//
   class i2c_apb_vip_wr_rd_test extends i2c_vip_test;
  `uvm_component_utils(i2c_apb_vip_wr_rd_test)
     
   wr_rd_seq apb_wr_rd;
   i2c_seq1  i2c_seq1_h;
   i2c_slave_tx_item item;
   virtual i2c_vip_intf v_intf; 

    extern function new(string name="i2c_apb_vip_wr_rd_test",uvm_component parent);
    extern task run_phase(uvm_phase phase);
    endclass
    
    function i2c_apb_vip_wr_rd_test::new(string name="i2c_apb_vip_wr_rd_test",uvm_component parent);
     super.new(name,parent);
      apb_wr_rd = wr_rd_seq::type_id::create("apb_wr_rd");
      i2c_seq1_h = i2c_seq1::type_id::create("i2c_seq1_h");
    endfunction

//**********************************************************************//
     //run_phase
//**********************************************************************//
     
task i2c_apb_vip_wr_rd_test::run_phase(uvm_phase phase);

phase.raise_objection(this);

  fork
    begin
  
      i2c_seq1_h.start(i2c_env.agent_i.i2c_slave_sequencer_h);
    $display($stime,"After dummy test");
    end
  join_none

//********************reset task**************************/
  begin
    assert(apb_wr_rd.randomize with {prstn==0;} );    
    apb_wr_rd.start(i2c_env.agent_a.seqr_a);
  end

  //*******************configuring  timeout_register************// 
  begin    
        assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd12;pwrite==1'b1;pwdata==12'hfff;} );  
    apb_wr_rd.start(i2c_env.agent_a.seqr_a);
  end 
   
 
  //*********************configuring i2c_register**************//

     begin
         assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd8;pwrite==1'b1;pwdata==32'h21;} );
          
       apb_wr_rd.start(i2c_env.agent_a.seqr_a);
     end

//*******************************************************************//
//writing data in to the registers
//writing in to tx fifo
//******************************************************************//

    begin    
       assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd0;pwrite==1'b1;pwdata==32'hb4_a5_a5_c2;});  
      apb_wr_rd.start(i2c_env.agent_a.seqr_a);
    end   
    begin    
       assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd0;pwrite==1'b1;pwdata==32'h12_30_50_12;});  
      apb_wr_rd.start(i2c_env.agent_a.seqr_a);
    end 

   begin    
       assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd0;pwrite==1'b1;pwdata==32'hffff_ff56;});  
     apb_wr_rd.start(i2c_env.agent_a.seqr_a);
   end 


    begin    
    assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd0;pwrite==1'b1;pwdata==32'haaaa_5a55;});  
      apb_wr_rd.start(i2c_env.agent_a.seqr_a);
   end 

   begin    
    assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd0;pwrite==1'b1;pwdata==32'h5555_5555;});  
     apb_wr_rd.start(i2c_env.agent_a.seqr_a);
   end 

                                              
   begin    
     assert(apb_wr_rd.randomize with {prstn==1;paddr==32'd0;pwrite==1'b1;pwdata==32'h3f56_fafe;});  
     apb_wr_rd.start(i2c_env.agent_a.seqr_a);
   end 
         

#10000000;

 phase.drop_objection(this);     
 endtask

