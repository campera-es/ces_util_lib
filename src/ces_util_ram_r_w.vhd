--=============================================================================
-- Module Name : ces_util_ram_r_w
-- Library     : ces_util_lib
-- Project     : CES Utility
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: this module implements a dual port ram, with common clock, one
-- read port and one write port
--
-------------------------------------------------------------------------------
-- Copyright (c) 2020 Campera Electronic Systems Srl
 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--=============================================================================

library ieee;
use ieee.std_logic_1164.all;
library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

--* @brief this module implements a dual port ram, with common clock, one
--* read port and one write port 
--* @version 1.0.0
entity ces_util_ram_r_w is
  generic(
    --* latency 1: LOW performance, 2: HIGH PERFORMANCE
    g_ram_latency : integer;
    --* data width
    g_ram_data_w : integer;
    --* depth
    g_ram_depth : integer;
    --* initialization file
    g_init_file : string := "";
    --* simulation: 1 enabled, 0 disabled (certain models are synthesizable but 
    --  do not work in simulation, e.g. VIVADO with different aspect ratio
    g_simulation : integer := 0

  );
  port(
    --* input clock
    clk_i : in std_logic;
    --* PORT A enable
    ena_i : in std_logic := '1';
    --* write enable
    wen_i : in std_logic;
    --* write address
    wr_addr_i : in std_logic_vector(f_ceil_log2(g_ram_depth) - 1 downto 0);
    --* write data
    wr_dat_i : in std_logic_vector(g_ram_data_w - 1 downto 0);
    --* PORT B enable
    enb_i : in std_logic := '1';
    --* read address
    rd_addr_i : in std_logic_vector(f_ceil_log2(g_ram_depth) - 1 downto 0);
    --* read data
    rd_dat_o : out std_logic_vector(g_ram_data_w - 1 downto 0)
  );
end ces_util_ram_r_w;

architecture a_str of ces_util_ram_r_w is
  --`protect begin

  --constant C_ZERO : std_logic_vector(g_ram.data_w - 1 downto 0) := (others => '0');

begin


  -- Use port a only for write
  -- Use port b only for read

  inst_mem : entity ces_util_lib.ces_util_ram_crw_crw
    generic map(
      g_ram_a_latency => g_ram_latency,
      g_ram_a_data_w  => g_ram_data_w,
      g_ram_a_depth   => g_ram_depth,
      g_ram_b_latency => g_ram_latency,
      g_ram_b_data_w  => g_ram_data_w,
      g_init_file     => g_init_file,
      g_simulation    => g_simulation
    )
    port map(
      clk_a_i     => clk_i,
      clk_b_i     => clk_i,
      wen_a_i     => wen_i,
      wen_b_i     => '0',
      ena_i       => ena_i,
      enb_i       => enb_i,
      data_wr_a_i => wr_dat_i,
      data_wr_b_i => (others => '0'),
      addr_a_i    => wr_addr_i,
      addr_b_i    => rd_addr_i,
      data_rd_a_o => open,
      data_rd_b_o => rd_dat_o
    );
--`protect end
end a_str;
