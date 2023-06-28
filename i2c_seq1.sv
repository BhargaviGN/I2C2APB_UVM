class i2c_seq1 extends uvm_sequence #(i2c_slave_tx_item);
  i2c_slave_tx_item r_trans;
  `uvm_object_utils(i2c_seq1)
  function new(string name="i2c_seq1");
    super.new(name);
  endfunction
  
  task body();
    
    r_trans = i2c_slave_tx_item::type_id::create("r_trans");
     begin
     start_item(r_trans);
      assert (r_trans.randomize());
     // assert(r_trans.randomize() with {apb_cmd == 1'b1;});
      finish_item(r_trans);       
     end
  endtask
  
endclass
    
