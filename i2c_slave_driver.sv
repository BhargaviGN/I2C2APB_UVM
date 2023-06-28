   //i2c slave driver
//************************************************************************//
typedef i2c_slave_agent;
   class i2c_slave_driver extends uvm_driver #(i2c_slave_tx_item);

   virtual i2c_vip_intf v_intf;
   i2c_slave_config m_config;
   i2c_slave_tx_item item;


//************************************************************//
     //local variables
//************************************************************//
  
  bit                slave_reg_ack;
  bit                register_ack=0;
  bit                start=0;
  bit                stop=0;
  bit                register_read_ack=0;
  logic [7:0]        input_data;
  bit   [7:0]        reg_address;
  bit   [7:0]        data[int];
  bit   [2:0]         count=0;
  bit                count_signal;
  
  `uvm_component_utils(i2c_slave_driver)

//****************************************************************//
            //extern methods
//****************************************************************//
  
  extern function       new(string name, uvm_component parent);
  extern function void  build_phase(uvm_phase phase);
  extern virtual  task  run_phase(uvm_phase phase);
  extern function void  connect_phase(uvm_phase phase);
  extern virtual task   slave_address_1(i2c_slave_tx_item item);
  extern virtual task   drive_item(i2c_slave_tx_item item);
  extern virtual task   write_req();
  extern virtual task   slave_read_write();
  extern virtual task   read_req();
  extern virtual task   wait_for_ack_from_master(output bit ack);
  extern         task   register_address();
  extern         task   start_condition( );
  extern         task   stop_condition();
  extern         task   start_stop_condition();
  endclass: i2c_slave_driver
  
//****************************************************************************//
// Function: new
// constructor
//****************************************************************************//

function i2c_slave_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction: new

//****************************************************************************//
      //build_phase
//****************************************************************************//

function void i2c_slave_driver::build_phase(uvm_phase phase);
//  super.build_phase(phase);
    i2c_slave_agent agent;
  item= i2c_slave_tx_item::type_id::create("item");
 
  if ($cast(agent, get_parent()) && agent != null) begin
       v_intf = agent.vif;
     end
     else begin
       virtual i2c_vip_intf tmp;
       if (!uvm_config_db#(virtual i2c_vip_intf)::get(this, "", "i2c_vip_intf1", tmp)) begin
         `uvm_fatal("APB/MON/NOVIF", "No virtual interface specified for this monitor instance")
       end
       v_intf = tmp;
     end
  if(!uvm_config_db#(i2c_slave_config)::get(this,"","i2c_slave_config",m_config)) begin
  `uvm_fatal("tb config","cannot get m_cfg from config db")
    end  
endfunction: build_phase

//*****************************************************************************//
         //connect_phase
//*****************************************************************************//

function void i2c_slave_driver::connect_phase(uvm_phase phase);
 v_intf=m_config.v_intf;
endfunction


//**************************************************************************//
// task: run_phase
// run phase is called by UVM flow. Driver is active during this phase.
//**************************************************************************//

task i2c_slave_driver::run_phase(uvm_phase phase);
  super.run_phase(phase); 
  forever
  begin
    $display("this is driver run_phase");
    seq_item_port.get_next_item(item);
    $display("this is get next_item");
    drive_item(item);
    $display("this is drive_item"); 
    seq_item_port.item_done();
    $display($stime,"AFTR ITEM_DONE"); 
  end
endtask: run_phase



//**********************************************************************//
    //start_condition_task
//**********************************************************************//

task i2c_slave_driver::start_condition();
  forever begin
    @(negedge v_intf.TB_SDA);
    $display(" sda neg edge received");
    if(v_intf.TB_SDA === 1'b0 && v_intf.TB_SCL === 1'b1) begin
    $display("start_condition");
    v_intf.start=1;
    item.start=v_intf.start;
    if(slave_reg_ack==1'b1)
      begin
         v_intf.start<=0;
      end
    end
  end
endtask
//*******************************************************************//
     //stop_condition_task
//*******************************************************************//

task i2c_slave_driver::stop_condition();
   forever begin
   @(posedge v_intf.TB_SDA);
   $display(" sda neg edge received");
   if(v_intf.TB_SDA === 1'b1 && v_intf.TB_SCL === 1'b1) begin
   $display("stop_condition");
   v_intf.stop=1;
   item.stop=1;
  end
 end
endtask
//********************************************************************//
    //drive_item task
//********************************************************************//

task i2c_slave_driver::drive_item(i2c_slave_tx_item item);
 $display($stime,"inside drive");
  fork
   start_condition();
   slave_address_1(item);
   register_address();
   write_req();
   stop_condition();
   start_stop_condition();
 join
endtask
//****************************************************************************//
     //slave_address
//****************************************************************************//
task i2c_slave_driver::slave_address_1(i2c_slave_tx_item item );
forever
begin//{
   @(posedge v_intf.TB_SCL);
   if(v_intf.start===1'b1) begin//{
         v_intf.start=0;
     for(int i = 0; i<=6; i++)begin
      item.slave_address[i] =v_intf.TB_SDA ;
       @(posedge v_intf.TB_SCL);
     end
       item.slave_address[7] =v_intf.TB_SDA ;
       $display("slave_address=%h",item.slave_address);
       @(negedge v_intf.TB_SCL);
       @(negedge v_intf.TB_SDA_ENABLE);
       v_intf.slave_ack =1'b1;
       v_intf.sda_out=1'b0;
       slave_reg_ack=1'b1;
       $display("ack is driven by slave");
       @(posedge v_intf.TB_SDA_ENABLE);
       v_intf.slave_ack =1'b0;
      break;
   end//}  
 
end//}
endtask

//*************************************************************************//
    //register_address task
//*************************************************************************//

task i2c_slave_driver::register_address();
forever
    begin
       @(posedge v_intf.TB_SCL);
       if(slave_reg_ack==1) begin//{
         slave_reg_ack=0;
       for(int i=0;i<=6;i++)
       begin
         @(posedge v_intf.TB_SCL);
         reg_address[i]=v_intf.TB_SDA;
       end
         @(posedge v_intf.TB_SCL);
         reg_address[7]=v_intf.TB_SDA;
         $display("register_address=%h",reg_address);
         @(negedge v_intf.TB_SCL);
         @(negedge v_intf.TB_SDA_ENABLE);
         v_intf.slave_ack =1'b1;
         v_intf.sda_out=1'b0;
         register_ack=1'b1;
         $display("ack is driven by slave");
         @(posedge v_intf.TB_SDA_ENABLE);
         v_intf.slave_ack <=1'b0;
       break;
     end//}
   end
endtask


//*************************************************************************//
      //slave_read_write_task
//*************************************************************************//

task i2c_slave_driver::slave_read_write(); 

forever
   begin
   if(register_ack==1'b1)
      begin
    if(item.slave_address[7]==1'b0)
      begin
       $display("write_req");
       write_req();
      end
  else
      begin
      //read_req();
      $display("read_req");
      end 
  end
end 
endtask


//****************************************************************//
   //START_STOP_CONDITION
//***************************************************************//

task i2c_slave_driver::start_stop_condition();
begin
forever
  begin
   @(negedge v_intf.TB_SDA_ENABLE);
    count=count+1;
     if(count==4)
       begin
          count_signal=1'b1;
          count=0;
       end
  end
end
endtask

//*************************************************************************//
      //write_req_from_master
//************************************************************************//

task i2c_slave_driver::write_req();
 `uvm_info(get_type_name(),  $sformatf("Slave write"), UVM_LOW )
    forever
       begin
           @(posedge v_intf.TB_SCL);
       if((register_ack==1)||(v_intf.stop!=1'b1)) begin
             if(count_signal==1)
                 begin
                 $display($stime,"slave_driver count_signal");
                   @(posedge v_intf.TB_SCL);
                    count_signal=0;
                 end  
           for(int i=0;i<=6;i++)
             begin
               input_data[i]=v_intf.TB_SDA;
               @(posedge v_intf.TB_SCL);
             end
             input_data[7]=v_intf.TB_SDA;
             data[reg_address]=input_data;
             $display("data=%h",data[reg_address]);
             $display("input_data=%h",input_data);
             @(negedge v_intf.TB_SCL);
             @(negedge v_intf.TB_SDA_ENABLE);
             v_intf.slave_ack =1'b1;
             v_intf.sda_out=1'b0;
             register_ack=1'b1;
             $display("ack is driven by slave");
             @(posedge v_intf.TB_SDA_ENABLE);
             v_intf.slave_ack <=1'b0;
             reg_address++;                  
              end
         end
endtask


//*******************************************************************************//
       //read_request from the master
//*******************************************************************************//

task i2c_slave_driver::read_req();
  int       current_address   = this.reg_address;
  bit [7:0] data_to_transmit  = '0;
  bit       ack_from_master   = '0;
      `uvm_info(get_type_name(),  $sformatf("Slave read"), UVM_LOW )
      $display("read=%d",item.slave_address[7]);
   if(item.slave_address[7]==1'b1&&register_read_ack==1'b1 )
   begin
           $display("read_ack");
           register_read_ack=1'b0;
     do begin
        if (!data.exists(current_address)) begin
          data[current_address] = 8'b0;
          `uvm_info(get_type_name(),  $sformatf("Created a random value %0h for address %0h", data[current_address], current_address), UVM_LOW)
    end
    
        data_to_transmit = data[current_address];
        `uvm_info(get_type_name(),  $sformatf("transmitting read request data %0h", data_to_transmit), UVM_LOW )
    
        //TX to master the data requested by the read request
        for (int i = 8; i; i--) begin
           @(negedge v_intf.TB_SCL);
          v_intf.sda_out<= data_to_transmit[i - 1];
         end
          v_intf.sda_out<= 1'b1;     
          current_address++;
          wait_for_ack_from_master( .ack(ack_from_master) );
  end 
  while(ack_from_master==1'b0);
  end 
endtask


//*****************************************************************************************************//
             //wait_for ack from master task
//****************************************************************************************************//

task i2c_slave_driver::wait_for_ack_from_master(output bit ack);
  @(posedge v_intf.TB_SCL);
  ack =  (v_intf.TB_SDA);
  `uvm_info(get_type_name(),  $sformatf("received ACK from master %0h", v_intf.TB_SDA), UVM_LOW )
  
endtask