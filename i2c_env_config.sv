//*****************************env config i2c****************************************//
 class i2c_env_config extends uvm_object;
`uvm_object_utils(i2c_env_config)

bit has_scoreboard=1;
bit has_magent=1;
bit has_sagent=1;

apb_config_obj apb_master_cfg;
i2c_slave_config i2c_agent_cfg;


//**************************************************//
     //methods
//**************************************************//
extern function new(string name="i2c_env_config");

endclass

//************************************************//
    //constructor//
//************************************************//

function i2c_env_config::new(string name="i2c_env_config");
super.new(name);
endfunction
//**************************************************************//