    //i2c slave config
//*************************************************************//
class i2c_slave_config extends uvm_object;
`uvm_object_utils(i2c_slave_config)

virtual  i2c_vip_intf v_intf;
uvm_active_passive_enum is_active=UVM_ACTIVE;

bit write_data_access=12;
bit start;
bit stop;

//********************************************************//
    //methods
//*******************************************************//

extern function new(string name="i2c_slave_config");
endclass

//**************************************************************//
////constructor/////////////////
//**************************************************************//

function i2c_slave_config::new(string name="i2c_slave_config");
super.new(name);
endfunction
//****************************************************************//