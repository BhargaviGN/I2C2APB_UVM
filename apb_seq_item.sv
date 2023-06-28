class apb_seq_item extends uvm_sequence_item;
 
    
  rand bit   [31:0] paddr;     
  rand logic [31:0] data; 
  rand logic [31:0] pwdata;
  rand logic  [31:0] prdata;
  rand logic  pwrite;
  rand logic pslverr;
  rand bit no_rst_cyc;
  rand bit  apb_cmd ;
  rand bit prstn;//r/w  
    
    reg pdata; 

    //Register with factory for dynamic creation
  `uvm_object_utils(apb_seq_item)
  
   
  function new (string name = "apb_seq_item");
      super.new(name);
   endfunction

   function string convert2string();
     return $psprintf("addr=%0h  data=%0h apb_cmd=%b",paddr,pwdata,apb_cmd);
   endfunction

endclass :apb_seq_item