# ces_util_lib
The UTILITY LIBRARY is a collection of modules that are used in almost every FPGA design, it is the Swiss Army Knife of every FPGA designer. All the modules are vendor independent high quality VHDL code.
In the UTILITY LIBRARY you will find a full set of memory modules (single port,
dual port, true dual port), synchronous and asynchronous FIFOs, Encoders and Decoders and a lot of other essential modules.

Benefits of libraries

VHDL libraries are a powerful mechanism the language offers to collect common modules together for reuse.
Reuse is a key to success with FPGA design, it helps to design faster, easier and with verified and validated
modules. Designing and testing a general purpose library is often considered as a time consuming effort and
most often there is no time for FPGA designers to build a complete general purpose library.
Using our library allow designers to focus on highlevel design without wasting time to develop building blocks.

Key Features

vendor independent "off the shelf" VHDL cores for FPGAs (Xilinx, Altera,
Achronix, Lattice and Microsemi)
VHDL modules are written in pure VHDL-93 standard (2008 is not fully supported by all vendors and synthesizers), 
completely vendor independent optimized in terms of speed, power and resource usage


Key benefits 

No cost for hardware/tool version update/upgrade
No time to re-generate the cores for different targets and/or tools
Considerably faster simulations compared to vendor pre-synthesized IP Cores
More than 150 useful functions in the ces_util package
More than 13.000 lines of VHDL source code and 7000 lines of comments
Campera-ES internal VHDL coding standard to help you quickly understand the source code
The ces_util_lib is the swiss army knife of every FPGA designer and is ideal for expert designers as well as beginners


CES UTILITY LIBRARY MODULES
Module name 					Description
ces_util_async					Clock an asynchronous data into the internal clock domain
ces_util_async_reset			Immediately apply reset and synchronously release it at rising clock
ces_util_axi_pkg				Data types to abstract an AXI4 data bus. The AXi4, AXI4lite and AXI4stream are included.
ces_util_bitsum					Bit summation (or in other words counting the "1"s) module implemented as an adder tree
ces_util_ccd_resync				re-synchronizer circuit, used in cross clock domain for std_logic signals
ces_util_ccd_switch 			Cross clock domain switch
ces_util_ccd_sync_pulse			cross clock domain pulse re-synchronizer circuit
ces_util_clock_gen				clock generator, generate an output clock with programmable duty cycle
ces_util_counter 				General purpose configurable counter. Can be used also as Watchdog timer
ces_util_debouncer				general purpose debouncer circuit with configurable length
ces_util_delay					Fixed delay for std_logic_vector signals, SRL, memory or pulse optimized implementation
ces_util_delay_var 				Variable delay module with SRL, memory or pulse architecture
ces_util_edge_detector			the module detect the edge of a signal based on a generic
ces_util_encoder 				General purpose encoder
ces_util_etr					Elapsed Time Recorder
ces_util_fifo					generic FIFO: sync/async, FTFW, configurable length and depth on both ports
ces_util_lfsr					Linear feedback shift register
ces_util_mux					general purpose multiplexer
ces_util_pulse_stretch			Stretch a pulse from an edge defining a fixed length or an overlength
ces_util_ram_crw_crw			Synthesizable ram modules, single, simple dual, true dual port. Wrappers available for simpler configurations
ces_util_pkg 					Utility package with more than 150 useful functions
ces_util_tick_gen 				pulse generator, generate an output pulse for one clock cycle every g_clock_div clock pulses

-- NAMING CONVENTIONS: 
-- _e one-CLK early sample
-- _d one-CLK delayed sample
-- _d2 two-CLKs delayed sample
-- _n active low signal
-- C_ constant
-- s_ signal
-- _i input port
-- _o output port
-- _io inout port
-- t_ type
-- _st FSM state

Reset Strategy
all the ces util librariy cores used active low synchronous reset, with the exception of the ces_util_async_reset that is used to synchronize an asynchronous reset.
keep in mind that you should only reset Finite State Machine and counters, the datapath should almost always doesnt need to use a reset signal, unless you have feedback i nyour datapath (again when you have "memory" of an old state you might need a reset)
the fanout on the reset signal should be kept as low as possible
