
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_dma:7.1\
xilinx.com:hls:dataflow:1.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_include_mm2s {0} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_s2mm_burst_size {256} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
 ] $axi_dma_0

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
  set_property -dict [ list \
   CONFIG.c_include_mm2s {0} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_s2mm_burst_size {256} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
 ] $axi_dma_1

  # Create instance: dataflow_0, and set properties
  set dataflow_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:dataflow:1.0 dataflow_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_USE_S_AXI_HP0 {1} \
   CONFIG.PCW_USE_S_AXI_HP1 {1} \
   CONFIG.PCW_USE_S_AXI_HP2 {1} \
   CONFIG.PCW_USE_S_AXI_HP3 {1} \
 ] $processing_system7_0

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
 ] $ps7_0_axi_periph

  # Create instance: rst_ps7_0_50M, and set properties
  set rst_ps7_0_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_50M ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {4} \
   CONFIG.NUM_SI {7} \
 ] $smartconnect_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins smartconnect_0/S05_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_S2MM [get_bd_intf_pins axi_dma_1/M_AXI_S2MM] [get_bd_intf_pins smartconnect_0/S06_AXI]
  connect_bd_intf_net -intf_net dataflow_0_m_axi_AXI_M_0 [get_bd_intf_pins dataflow_0/m_axi_AXI_M_0] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net dataflow_0_m_axi_AXI_M_1 [get_bd_intf_pins dataflow_0/m_axi_AXI_M_1] [get_bd_intf_pins smartconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net dataflow_0_m_axi_AXI_M_2 [get_bd_intf_pins dataflow_0/m_axi_AXI_M_2] [get_bd_intf_pins smartconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net dataflow_0_m_axi_AXI_M_3 [get_bd_intf_pins dataflow_0/m_axi_AXI_M_3] [get_bd_intf_pins smartconnect_0/S03_AXI]
  connect_bd_intf_net -intf_net dataflow_0_m_axi_WEIGHT [get_bd_intf_pins dataflow_0/m_axi_WEIGHT] [get_bd_intf_pins smartconnect_0/S04_AXI]
  connect_bd_intf_net -intf_net dataflow_0_out_pixel0 [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM] [get_bd_intf_pins dataflow_0/out_pixel0]
  connect_bd_intf_net -intf_net dataflow_0_out_pixel1 [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins dataflow_0/out_pixel1]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins dataflow_0/s_axi_CTRL_BUS] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M01_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins ps7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M02_AXI [get_bd_intf_pins axi_dma_1/S_AXI_LITE] [get_bd_intf_pins ps7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins processing_system7_0/S_AXI_HP0] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins processing_system7_0/S_AXI_HP1] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins processing_system7_0/S_AXI_HP2] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins processing_system7_0/S_AXI_HP3] [get_bd_intf_pins smartconnect_0/M03_AXI]

  # Create port connections
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_dma_1/m_axi_s2mm_aclk] [get_bd_pins axi_dma_1/s_axi_lite_aclk] [get_bd_pins dataflow_0/ap_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP1_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP2_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP3_ACLK] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/M01_ACLK] [get_bd_pins ps7_0_axi_periph/M02_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK] [get_bd_pins rst_ps7_0_50M/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_50M/ext_reset_in]
  connect_bd_net -net rst_ps7_0_50M_interconnect_aresetn [get_bd_pins ps7_0_axi_periph/ARESETN] [get_bd_pins rst_ps7_0_50M/interconnect_aresetn]
  connect_bd_net -net rst_ps7_0_50M_peripheral_aresetn [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_dma_1/axi_resetn] [get_bd_pins dataflow_0/ap_rst_n] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/M01_ARESETN] [get_bd_pins ps7_0_axi_periph/M02_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_ps7_0_50M/peripheral_aresetn] [get_bd_pins smartconnect_0/aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_0] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_1] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_WEIGHT] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_2] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_3] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg

  # Exclude Address Segments
  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_axi_dma_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_dataflow_0_Reg]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_processing_system7_0_HP0_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_processing_system7_0_HP1_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_processing_system7_0_HP3_DDR_LOWOCM]

  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_1/Data_S2MM/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_1/Data_S2MM/SEG_axi_dma_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_1/Data_S2MM/SEG_dataflow_0_Reg]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_1/Data_S2MM/SEG_processing_system7_0_HP0_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_1/Data_S2MM/SEG_processing_system7_0_HP1_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_1/Data_S2MM/SEG_processing_system7_0_HP2_DDR_LOWOCM]

  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_0] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_0/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_0] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_0/SEG_axi_dma_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_0] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_0/SEG_dataflow_0_Reg]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_0] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_0/SEG_processing_system7_0_HP1_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_0] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_0/SEG_processing_system7_0_HP2_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_0] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_0/SEG_processing_system7_0_HP3_DDR_LOWOCM]

  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_1] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_1/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_1] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_1/SEG_axi_dma_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_1] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_1/SEG_dataflow_0_Reg]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_1] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_1/SEG_processing_system7_0_HP0_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_1] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_1/SEG_processing_system7_0_HP2_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_1] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_1/SEG_processing_system7_0_HP3_DDR_LOWOCM]

  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_2] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_2/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_2] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_2/SEG_axi_dma_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_2] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_2/SEG_dataflow_0_Reg]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_2] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_2/SEG_processing_system7_0_HP0_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_2] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_2/SEG_processing_system7_0_HP1_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_2] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_2/SEG_processing_system7_0_HP3_DDR_LOWOCM]

  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_3] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_3/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_3] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_3/SEG_axi_dma_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_3] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_3/SEG_dataflow_0_Reg]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_3] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_3/SEG_processing_system7_0_HP0_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_3] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_3/SEG_processing_system7_0_HP1_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_AXI_M_3] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_AXI_M_3/SEG_processing_system7_0_HP2_DDR_LOWOCM]

  create_bd_addr_seg -range 0x00010000 -offset 0x40400000 [get_bd_addr_spaces dataflow_0/Data_m_axi_WEIGHT] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_WEIGHT/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40410000 [get_bd_addr_spaces dataflow_0/Data_m_axi_WEIGHT] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_WEIGHT/SEG_axi_dma_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces dataflow_0/Data_m_axi_WEIGHT] [get_bd_addr_segs dataflow_0/s_axi_CTRL_BUS/Reg] SEG_dataflow_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_WEIGHT/SEG_dataflow_0_Reg]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_WEIGHT] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_WEIGHT/SEG_processing_system7_0_HP0_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_WEIGHT] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_WEIGHT/SEG_processing_system7_0_HP2_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces dataflow_0/Data_m_axi_WEIGHT] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs dataflow_0/Data_m_axi_WEIGHT/SEG_processing_system7_0_HP3_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs processing_system7_0/Data/SEG_processing_system7_0_HP0_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs processing_system7_0/Data/SEG_processing_system7_0_HP1_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs processing_system7_0/Data/SEG_processing_system7_0_HP2_DDR_LOWOCM]

  create_bd_addr_seg -range 0x10000000 -offset 0x50000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  exclude_bd_addr_seg [get_bd_addr_segs processing_system7_0/Data/SEG_processing_system7_0_HP3_DDR_LOWOCM]



  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

