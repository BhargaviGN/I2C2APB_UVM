        
`ifndef I2C_MONITOR__SV
`define I2C_MONITOR__SV

typedef i2c_slave_agent;

class i2c_slave_monitor extends uvm_monitor;
   virtual i2c_vip_intf v_intf;
   uvm_analysis_port #(i2c_slave_tx_item) i2c_slave_ap;
   i2c_slave_config    m_config;
   i2c_slave_tx_item item;

//***********************************************************//
        //local variables
//***********************************************************//

   bit temp;  
   bit [7:0] temp_addr;
   bit  slave_register_ack;
   bit  slave_mon_addr_ack;
   bit  register_ack;
   bit  write_ack;
   bit [7:0]slave_address;
   bit [7:0]reg_address;
   int  num_of_access;
   bit  [2:0] count=0;
   bit count_signal;
  	
`uvm_component_utils(i2c_slave_monitor)

//***************************************************************//
                 // extern methods
//***************************************************************//
	
        extern function new(string name, uvm_component parent);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task          run_phase(uvm_phase phase);
        extern virtual function void connect_phase(uvm_phase phase);
        extern         task          collect_data();
        extern         task          start_condition();
        extern         task          stop_condition();
        extern         task          slave_address_1(i2c_slave_tx_item item);
        extern         task          register_address(i2c_slave_tx_item item);
        extern         task          write_data(i2c_slave_tx_item item);
        extern         task          start_stop_condition();
endclass: i2c_slave_monitor
	
//*******************************************************//            
// function: new
// constructor
//*******************************************************//

function i2c_slave_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
i2c_slave_ap=new("i2c_slave_ap",this);

endfunction: new

//***********************************************************//
// function: build_phase '
//***********************************************************//

function void i2c_slave_monitor::build_phase(uvm_phase phase);
 // super.build_phase(phase);
  i2c_slave_agent agent;
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
  
 if(!uvm_config_db #(i2c_slave_config)::get(this,"","i2c_slave_config",m_config)) begin
     `uvm_fatal("tb config","cannot get m_m_config from config db")
                          end  
 endfunction: build_phase

//****************************************************************************//
           //function:connect_phase
//**************************************************************************//

 function void  i2c_slave_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  v_intf=m_config.v_intf;
 endfunction


//**********************************************************************//
// task: run_phase
//**********************************************************************//

task i2c_slave_monitor::run_phase(uvm_phase phase);
   item=i2c_slave_tx_item::type_id::create("item");
   super.run_phase(phase);
   collect_data();
endtask: run_phase

//****************************************************************************//
     //collect_data
//****************************************************************************//

task i2c_slave_monitor::collect_data();
fork
  start_condition();
  slave_address_1(item);
  register_address(item);
  write_data(item);
  stop_condition();
  start_stop_condition();
 join
endtask


//***********************************************************************//
     //start_condition
//***********************************************************************//

task i2c_slave_monitor::start_condition();
forever 
  begin
      @(negedge v_intf.TB_SDA);
      $display(" sda neg edge received");
      if(v_intf.TB_SDA === 1'b0 && v_intf.TB_SCL === 1'b1) begin
      $display("start_condition");
      v_intf.start<=1;     
      end
  end
endtask

//*******************************************************************//
          //stop_condition
//*******************************************************************//

task i2c_slave_monitor::stop_condition();
  int i=0;
  forever begin
    @(posedge v_intf.TB_SDA);
    $display(" sda neg edge received");
      if(v_intf.TB_SDA === 1'b1 && v_intf.TB_SCL === 1'b1) begin
        $display($time,"stop_condition");
        v_intf.stop=1;       
        foreach(item.data_monitor[i])
        $display($stime,"slave monitor :: data_monitor[%h]= %h",i,item.data_monitor[i]); 
        for (int i = 0; i<item.i2c_data_monitor_queue.size; i++) begin
        $display("Value of Queue is %h",item.i2c_data_monitor_queue[i]);
        end
        item.monitor_ack=1;     
      end
  end
endtask

//*****************************************************************//
       //slave_address_1 task
//*****************************************************************//


task i2c_slave_monitor::slave_address_1(i2c_slave_tx_item item);
forever
begin
   @(posedge v_intf.TB_SCL);
   if(v_intf.start===1'b1) begin
          v_intf.start<=0;
     for(int i = 0; i<=6; i++)begin
      item.slave_address_monitor[i] = v_intf.TB_SDA;
       @(posedge v_intf.TB_SCL);
     end
     item.slave_address_monitor[7] =v_intf.TB_SDA ;
     $display("slave_address_monitor=%h",item.slave_address_monitor);
      @(posedge v_intf.TB_SCL);
      slave_mon_addr_ack=v_intf.sda_out;
            if(slave_mon_addr_ack==0)
            begin
           slave_register_ack=1;
        end
     break;
   end
end
endtask
//**********************************************************************************//
    //register_address
//*********************************************************************************//
task i2c_slave_monitor::register_address(i2c_slave_tx_item item);
forever
begin
   @(posedge v_intf.TB_SCL);
   if(slave_register_ack==1'b1) begin
          for(int i = 0; i<=6; i++)begin
             @(posedge v_intf.TB_SCL);
         item.reg_address_monitor[i]=v_intf.TB_SDA;
         $display($stime,"reg_&&&&&&&&&&&&&&&&&&&&&&&&=%d",item.reg_address_monitor[i]);
           end
              @(posedge v_intf.TB_SCL);
         item.reg_address_monitor[7] =v_intf.TB_SDA ;
         $display($stime,"reg_&&&&&&&&&&&&&&&&&&&&&&&&=%d",item.reg_address_monitor[7]);   
         for(int i=0;i<=7;i++)
            begin
              item.reg_address[i]=item.reg_address_monitor[i];
            end
         $display("reg_address=%h",item.reg_address);
         $display("reg_address_monitor=%h",item.reg_address_monitor);
         @(negedge v_intf.TB_SCL);
         @(negedge v_intf.TB_SDA_ENABLE); 
         slave_mon_addr_ack=v_intf.sda_out;
           @(posedge v_intf.TB_SDA_ENABLE);
         if(slave_mon_addr_ack==0)
         begin
           register_ack=1;        
         end
    break;
   end
end
endtask

//************************************************************************************************//
   //start_stop_condition
//***********************************************************************************************//
task i2c_slave_monitor::start_stop_condition();
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
//******************************************************************************************************//
    //write_data to the scoreboard
//*****************************************************************************************************//    
task i2c_slave_monitor::write_data(i2c_slave_tx_item item);
 `uvm_info(get_type_name(),  $sformatf("Slave write"), UVM_LOW )
  forever
     begin    
      @(posedge v_intf.TB_SCL);               

           if((register_ack==1)||(v_intf.stop!=1'b1)) begin
               // if(count_signal==1)
               //  begin
                // $display($stime,"slave_monitor count signal");
                 //  @(posedge v_intf.TB_SCL);
                 //   count_signal=0;
                // end
                for(int i=0;i<=6;i++)
                begin
                  item.input_data_monitor[i]=v_intf.TB_SDA;
                  $display($stime,"data*_&&&&&&&&&&&&&&&&&&&&&&&&=%b",item.input_data_monitor[i]);
                  if(v_intf.start===1&&v_intf.stop===1)
                      begin
                          i=0; 
                        item.input_data_monitor[0]=v_intf.TB_SDA;
                        v_intf.stop=0;                       
                         v_intf.start=0;                                                 
                  end
                  @(posedge v_intf.TB_SCL);
                end
                                        
                item.input_data_monitor[7]=v_intf.TB_SDA;
         $display($stime,"data^_&&&&&&&&&&&&&&&&&&&&&&&&=%h",item.input_data_monitor[7]);
                item.data_monitor[item.reg_address_monitor]=item.input_data_monitor;               
                  for(int i=7;i<=0;i--)
                   begin
                      item.input_dat[i]=item.input_data_monitor[i];
                   end
      
                $display("register_address_monit=%h",item.reg_address_monitor);
                $display("input_data_monitor=%b",item.input_data_monitor);
                @(negedge v_intf.TB_SCL);
                @(negedge v_intf.TB_SDA_ENABLE);
                write_ack=v_intf.sda_out;                       
                register_ack=1;
                item.i2c_data_monitor_queue.push_front(item.input_data_monitor);
                item.write_ack=1;                            
                i2c_slave_ap.write(item);
                @(posedge v_intf.TB_SDA_ENABLE);
                item.reg_address_monitor++;                                         
               end
 end
endtask
`endif