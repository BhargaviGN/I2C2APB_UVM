class apb_sequence extends uvm_sequence#(apb_seq_item);

  `uvm_object_utils(apb_sequence)
       apb_seq_item rw_trans;
  
  function new(string name ="");
    super.new(name);
  endfunction


  //Main Body method that gets executed once sequence is started
  task body();
     
     //Create 10 random APB read/write transaction and send to driver
    rw_trans = apb_seq_item::type_id::create("rw_trans");
      //apb_rw::type_id::create(.name("rw_trans"),.contxt(get_full_name()));
    for(int i=0;i<5;i++) begin
       start_item(rw_trans);
      // assert (rw_trans.randomize());
      assert(rw_trans.randomize() with { paddr==32'h6002_3000;pwdata == 32'h20020002;apb_cmd == 1'b0;pwrite==1;});
       finish_item(rw_trans);
      
       start_item(rw_trans);
      // assert (rw_trans.randomize());
      assert(rw_trans.randomize() with { paddr==32'h7002_3000;pwdata == 32'h30020002;apb_cmd == 1'b0;pwrite==1;});
       finish_item(rw_trans);
      
      
     start_item(rw_trans);
      // assert (rw_trans.randomize());
      assert(rw_trans.randomize() with { paddr==32'h6032_0000;apb_cmd == 1'b1;pwrite==0;});
      finish_item(rw_trans); 
      
             
     end
  endtask
  
endclass