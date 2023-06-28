//********************************************************************//
        //  i2c score board
//********************************************************************//

`uvm_analysis_imp_decl (_apb)
`uvm_analysis_imp_decl (_i2c)
class i2c_vip_scoreboard extends uvm_scoreboard;
`uvm_component_utils(i2c_vip_scoreboard)

apb_seq_item m_xtn;
i2c_slave_tx_item s_xtn;


  uvm_analysis_imp_apb #(apb_seq_item,i2c_vip_scoreboard) apb_analysis_export;
uvm_analysis_imp_i2c #(i2c_slave_tx_item,i2c_vip_scoreboard) i2c_analysis_export;

bit [31:0] apb_data;
bit [31:0] i2c_data;
bit [31:0] temp_apb_data;
bit [7:0]  temp_i2c_data;
bit temp=0;
int value=2;

bit [31:0]apb_monitor_queue[$];
i2c_env_config m_config;
extern function new  (string name="i2c_vip_scoreboard",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void write_apb(apb_seq_item m_apb_txn);
extern function void write_i2c(i2c_slave_tx_item s_i2c_txn);
extern function void comparision(); 
extern function void check_phase(uvm_phase phase);

endclass
//*******************************************************************************//
   //constructor
//*******************************************************************************//
 function  i2c_vip_scoreboard::new(string name="i2c_vip_scoreboard",uvm_component parent);
 super.new(name,parent);
 endfunction
//*****************************************************************************//
    //build_phase
//*****************************************************************************// 

 function  void i2c_vip_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db #(i2c_env_config)::get(this,"","i2c_env_config",m_config))
  `uvm_fatal("SB_CONFIG","cannot get the env config from the test have you set it?") 
   s_xtn = i2c_slave_tx_item::type_id::create("s_xtn");
   m_xtn =  apb_seq_item::type_id::create("m_xtn");
   apb_analysis_export=new("apb_analysis_export",this);
   i2c_analysis_export=new("i2c_analysis_export",this);

endfunction
//***************************************************************************//
      //apb write method
//**************************************************************************//
function  void i2c_vip_scoreboard::write_apb(apb_seq_item m_apb_txn);
  $display(".................write_apb............");
 begin
  m_xtn=m_apb_txn; 
  $display("pwrite=%h,paddr=%h",m_xtn.pwrite,m_xtn.paddr);
    $display("......apbaa.....");
 if(m_xtn.pwrite==1&&m_xtn.paddr==0)
 begin
  $display("pwrite>>>>>>>>>>>>>>>>>>>");
  apb_data=m_xtn.pwdata;
  apb_monitor_queue.push_front(apb_data);
  `uvm_info("master_sb","print from master sb",UVM_LOW)
    $display("pwrite=%h,paddr=%h,pwdata=%h",m_xtn.pwrite,m_xtn.paddr,m_xtn.pwdata);
    $display($stime,"apb_data =%h",apb_data);
    for (int i = 0; i<apb_monitor_queue.size; i++) begin
    $display("Value of Queue is %h",apb_monitor_queue[i]);
     end
   end
 end
endfunction

//*****************************************************************************//
      //i2c_write_method
//******************************************************************************//
function  void i2c_vip_scoreboard::write_i2c(i2c_slave_tx_item s_i2c_txn);
  $display(".....................i2c_write.............");
  begin
s_xtn= s_i2c_txn;

if(s_xtn.monitor_ack==1)
  begin
        `uvm_info("slave_sb","print from slave sb",UVM_LOW)
       for (int i = 0; i<s_xtn.i2c_data_monitor_queue.size; i++) begin
      $display($stime,"Value of scoreboard Queue is %h",s_xtn.i2c_data_monitor_queue[i]);
       end
end
  end
endfunction
 
//***************************************************************************//
    //comparision
//*****************************************************************************//


function void i2c_vip_scoreboard::comparision();
begin
   bit[1:0] case_value=2'b10;//for comparing the byte by byte  and case loop argument
    int l;
     for (int i = 0; i<apb_monitor_queue.size; i++) begin
      $display("Value of Queue is %h",apb_monitor_queue[i]);
       end

     for(int i=0;apb_monitor_queue.size()!=0;i++)
       begin

            $display("********************");
            if(temp==0)
             begin
                 value=2;
                temp=1;
             end
             else
                begin
                  value=4;
                end
                temp_apb_data=apb_monitor_queue.pop_back();
              for(int j=0;j<value;j++) 
                 begin
                    temp_i2c_data=s_xtn.i2c_data_monitor_queue.pop_back();
                case(case_value)
                  2'b00:  begin  l=0;
                               for(int k=0;k<=7;k++)
                               begin
                                   if(temp_apb_data[l]==temp_i2c_data[k])
                                    begin
                                   $display("data_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                      end
                                    else
                                    begin
                                   $display("data_mis_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                    end
                                    l++;
                                     end
                                    case_value=2'b01;
                          end

                   2'b01:  begin  l=8;
                                    for(int k=0;k<=7;k++)
                                    begin
                                      if(temp_apb_data[l]==temp_i2c_data[k])
                                        begin
                                        $display("data_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                        end
                                      else
                                       begin
                                         $display("data_mis_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                       end
                                    l++;
                                     end
                                    case_value=2'b10;
                             end

                       2'b10:  begin  l=16;
                               for(int k=0;k<=7;k++)
                               begin
                                   if(temp_apb_data[l]==temp_i2c_data[k])
                                    begin
                                   $display("data_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                      end
                                    else
                                    begin
                                   $display("data_mis_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                    end
                                    l++;
                                     end
                                    case_value=2'b11;
                                end
                        2'b11:  begin  l=24;
                               for(int k=0;k<=7;k++)
                               begin
                                   if(temp_apb_data[l]==temp_i2c_data[k])
                                    begin
                                   $display("data_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                      end
                                    else
                                    begin
                                   $display("data_mis_matched&&%h,%h",temp_apb_data[l],temp_i2c_data[k]);
                                    end
                                    l++;
                                     end
                                    case_value=2'b00;
                                end


                       endcase
                     end
                  end
     end
endfunction
//*****************************************************************//
     //check_phase
//*****************************************************************//

function void i2c_vip_scoreboard::check_phase(uvm_phase phase);
super.check_phase(phase);
comparision();
endfunction
