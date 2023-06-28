
// Description   :: This sequence is dedicated for writing/reading data to/from any register

// Sequence name :: wr_rd_seq
// Created on    :: 14-june-2017

class wr_rd_seq extends apb_sequence;
 
`uvm_object_utils(wr_rd_seq)
  
  
  apb_seq_item req_item;
  apb_seq_item rsp_item;
function new(string name = "wr_rd_seq");
super.new(name);
  
  endfunction
 
   bit  [31:0] pwdata  ;
   bit prstn;
   bit [31:0] paddr;
   bit [31:0] prdata;
   bit pwrite;
  bit pslverr;
  bit no_rst_cyc;

virtual task body();
   //pwrite        = 1'b0 ; //default value
  // no_rst_cyc    =4;
  
  
   //bit pslverr;
   

   //super.body();
   req_item = apb_seq_item::type_id::create("req_item");
 if(pwrite) begin   
    start_item(req_item);

   assert(req_item.randomize);

    `uvm_info({get_type_name(),"::task body"},"seq item start",UVM_LOW)

    req_item.pwrite  =this.pwrite;
    req_item.prstn   = this.prstn;
    req_item.paddr   = this.paddr;
    req_item.pwdata  = this.pwdata;
    req_item.prstn  = this.prstn;
    req_item.no_rst_cyc  =this.no_rst_cyc;

    `uvm_info({get_type_name(),"::task body"},$sformatf("\npresetn %h\n pwrite %h\npaddr %h\npwdata %h\n",req_item.prstn,req_item.pwrite,req_item.paddr,req_item.pwdata),UVM_LOW)

    finish_item(req_item);

    get_response(rsp_item);

   this.pslverr = rsp_item.pslverr ;
    
    `uvm_info({get_type_name(),"::task body"},"seq item finished",UVM_LOW)
end

 else begin

    start_item(req_item);

    `uvm_info({get_type_name(),"::task body"},"seq item  start",UVM_LOW)

  

    req_item.pwrite  = this.pwrite;
    req_item.prstn   = this.prstn;
    req_item.paddr   = this.paddr;
    req_item.prstn  = this.prstn;
    req_item.no_rst_cyc  = this.no_rst_cyc;
    `uvm_info({get_type_name(),"::task body"},$sformatf("\npresetn %h\n pwrite %h\npaddr %h\n",req_item.prstn,req_item.pwrite,req_item.paddr),UVM_LOW)

    finish_item(req_item);

    get_response(rsp_item);

   this. pslverr = rsp_item.pslverr ;
   this.prdata  = rsp_item.prdata  ;
    
    `uvm_info({get_type_name(),"::task body"},"seq item finished",UVM_LOW)
  end
 

endtask:body
endclass:wr_rd_seq


