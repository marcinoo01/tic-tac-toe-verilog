#Project name                                 -- EDIT
set project tic_tac_toe_game
# Top module name                             -- EDIT
set top_module vga_example
# FPGA device
set target xc7a35tcpg236-1
# Bitstream location
set bitstream_file build/${project}.runs/impl_1/${top_module}.bit

# Print how to use the script
proc usage {} {
puts "===========================================================================\n
usage: vivado -mode tcl -source [info script] -tclargs \[open/rebuild/sim/bit/prog\]\n
\topen    - open project and start gui\n
\trebuild - clear build directory and create the project again from sources, then open gui\n
\tsim     - run simulation\n
\tbit     - generate bitstream\n
\tprog    - load bitstream to FPGA\n
If a project is already created in the build directory, run.tcl opens it. Otherwise, creates a new one.
==========================================================================="
}

# Create project
proc create_new_project {project target top_module} {
    file mkdir build
    create_project ${project} build -part ${target} -force
    
    # Specify .xdc files location             -- EDIT
    read_xdc {
        ../src/constraints/clk_wiz_0.xdc
		../src/constraints/clk_wiz_0_board.xdc
		../src/constraints/clk_wiz_0_late.xdc
		../src/constraints/clk_wiz_0_ooc.xdc
		../src/constraints/vga_constraints.xdc
    }

    # Specify verilog design files location   -- EDIT
    read_verilog {
		../src/rtl/clk_wiz_0.v
		../src/rtl/clk_wiz_0_clk_wiz.v
		../src/rtl/draw_background.v
		../src/rtl/draw_rect.v
		../src/rtl/ff_delay.v
		../src/rtl/reset_delay.v
		../src/rtl/vga_example.v
		../src/rtl/vga_timing.v
		../src/rtl/ff_synchronizer.v
		../src/rtl/char_rom.v
		../src/rtl/control_unit.v
		../src/rtl/draw_rect_char.v
		../src/rtl/draw_square1.v
		../src/rtl/draw_square2.v
		../src/rtl/draw_square3.v
		../src/rtl/draw_square4.v
		../src/rtl/draw_square5.v
		../src/rtl/draw_square6.v
		../src/rtl/draw_square7.v
		../src/rtl/draw_square8.v
		../src/rtl/draw_square9.v
		../src/rtl/font_rom.v
		../src/rtl/fifo.v
		../src/rtl/mod_m_counter.v
		../src/rtl/square_ctl.v
		../src/rtl/UART.v
		../src/rtl/uart_rx.v
		../src/rtl/uart_tx.v
		../src/rtl/uart_unit.v
		../src/rtl/winner_check.v
    }
    
    # Specify vhdl design files location      -- EDIT
    read_vhdl {
        ../src/rtl/MouseCtl.vhd    
        ../src/rtl/MouseDisplay.vhd
		../src/rtl/Ps2Interface.vhd
    }
    
    # Specify files for memory initialization -- EDIT
    #read_mem {
        #rtl/image_rom.data
    #}

    # Specify simulation files location       -- EDIT
    #add_files -fileset sim_1 {
		#sim/draw_rect_ctl_tb.v
		#sim/draw_rect_ctl_test.v
    #}

    set_property top ${top_module} [current_fileset]
    update_compile_order -fileset sources_1
    update_compile_order -fileset sim_1
}

# Open existing project
proc open_existing_project {project} {
    open_project build/$project.xpr
    update_compile_order -fileset sources_1
    update_compile_order -fileset sim_1
}

# If project already exists, open it. Otherwise, create it.
proc open_or_create_project {project target top_module} {
    if {[file exists build/$project.xpr] == 1} {
        open_existing_project $project 
    } else {
        create_new_project $project $target $top_module
    }
}


# Load bitstream to FPGA
proc program_fpga {bitstream_file} {
    if {[file exists $bitstream_file] == 0} {
        puts "ERROR: No bitstream found"
    } else {
        open_hw
        connect_hw_server
        current_hw_target [get_hw_targets *]
        open_hw_target
        current_hw_device [lindex [get_hw_devices] 0]
        refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

        set_property PROBES.FILE {} [lindex [get_hw_devices] 0]
        set_property FULL_PROBES.FILE {} [lindex [get_hw_devices] 0]
        set_property PROGRAM.FILE ${bitstream_file} [lindex [get_hw_devices] 0]

        program_hw_devices [lindex [get_hw_devices] 0]
        refresh_hw_device [lindex [get_hw_devices] 0]
    }
}

# Simulation
proc simulation {} {
    launch_simulation
    # run all
}

# Generate bitstream
proc bitstream {} {
    # Run synthesis
    reset_run synth_1
    launch_runs synth_1 -jobs 8
    wait_on_run synth_1
    
    # Run implemenatation up to bitstream generation
    launch_runs impl_1 -to_step write_bitstream -jobs 8
    wait_on_run impl_1
}

## MAIN
if {$argc == 1} {
    switch $argv {
        open {
            open_or_create_project $project $target $top_module    
            start_gui
        }
        rebuild {
            create_new_project $project $target $top_module    
            start_gui
        }
        sim {
            open_or_create_project $project $target $top_module    
            simulation
            start_gui
        }
        bit {
            open_or_create_project $project $target $top_module    
            bitstream
            exit
        }
        prog {
            program_fpga $bitstream_file
            exit
        }
        default {
            usage
            exit 1
        }
    }
} else {
    usage
    exit 1
}