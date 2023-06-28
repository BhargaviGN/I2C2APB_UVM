  //*******************//
class i2c_vip_test extends uvm_test;

`uvm_component_utils(i2c_vip_test)

i2c_vip_env i2c_env;
//  apb_env env;
i2c_env_config env_cfg;

virtual i2c_vip_intf v_intf;

apb_config_obj apb_cfg;
i2c_slave_config i2c_cfg;


//******************************************************************//
         // extern methods
//******************************************************************//

extern function new(string name="i2c_vip_test",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void config_i2c();


endclass

//**********************************************************//
//////////////constructor/////////////////////////
//**********************************************************//
function i2c_vip_test::new(string name="i2c_vip_test",uvm_component parent);
super.new(name,parent);
 endfunction

//*************************************************************//
//////////build_phase///////
//*************************************************************//

function void i2c_vip_test::build_phase(uvm_phase phase);

env_cfg=i2c_env_config::type_id::create("env_cfg");
config_i2c();
super.build_phase(phase);
uvm_config_db #(i2c_env_config)::set(this,"*","i2c_env_config",env_cfg);
  i2c_env=i2c_vip_env::type_id::create("i2c_env",this);

endfunction

//************************************************************//
   //config_i2c task
//************************************************************//

function void  i2c_vip_test::config_i2c();

apb_cfg=apb_config_obj::type_id::create("apb_cfg");
if(!uvm_config_db#(virtual apb_intf)::get(this,"","vif",apb_cfg.v_intf))
`uvm_fatal("tb config","cannot get vif from config db")
apb_cfg.is_agent=UVM_ACTIVE;
env_cfg.apb_master_cfg=apb_cfg;



i2c_cfg=i2c_slave_config::type_id::create("i2c_cfg");
if(!uvm_config_db#(virtual i2c_vip_intf)::get(this," ","v_intf",i2c_cfg.v_intf))
`uvm_fatal("tb config","cannot get vif from config db")

i2c_cfg.is_active=UVM_ACTIVE;
env_cfg.i2c_agent_cfg=i2c_cfg;

endfunction

//**********