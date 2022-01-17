--=============================================================================
-- Module Name   : ces_util_delay_srl
-- Library       : ces_util_lib
-- Project       : CES UTIL Library
-- Company       : Campera Electronic Systems Srl
-- Author        : A.Campera
-------------------------------------------------------------------------------
-- Description: Fixed delay for std_logic_vector signals. 
--              Shift register with LUT, vendor and family from ces_util_pkg
--              check xapp465.pdf from Xilinx website for a reference
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

-------------------------------------------------------------------------------
-- LIBRARIES
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

--* @brief Variable delay for std_logic_vector signals
--* Input signal is delayed by a specific amount
--* The input is valid and is entered in the delay FIFO when ce_i is true
--* @version 1.1.1
entity ces_util_delay_srl is
  generic(
    --* actual delay can be different from a power of 2
    g_delay : natural;
    --* input data width
    g_data_w : natural
  );
  port(
    --* input clock
    clk_i : in std_logic;
    --* clock enable
    ce_i : in std_logic := '1';
    --* input data
    din_i : in std_logic_vector(g_data_w - 1 downto 0);
    --* output delayed data
    dout_o : out std_logic_vector(g_data_w - 1 downto 0)
  );
end ces_util_delay_srl;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture a_rtl of ces_util_delay_srl is
--`protect begin
begin

  gen_no_delay : if g_delay = 0 generate
    dout_o <= din_i;
  end generate gen_no_delay;

  -- in case of unitary delay a single register is instantiated
  gen_unit_delay : if g_delay = 1 generate
    proc_unit_delay : process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (ce_i = '1') then
          dout_o <= din_i;
        end if;
      end if;
    end process proc_unit_delay;
  end generate gen_unit_delay;

  -- delay greater than one
  gen_delay : if g_delay > 1 generate
    -- vendor and family from ces_util_pkg
    constant C_SRL_DEPTH : integer := f_get_srl_depth(C_VENDOR, C_FAMILY);
    constant C_NUM_SRL   : integer := f_div_ceil(g_delay, C_SRL_DEPTH);
    constant C_SRL_ADDR  : integer := g_delay mod C_SRL_DEPTH;

    -- SRL instantiation
    type t_array_srl_depth_by_width is array (C_SRL_DEPTH - 1 downto 0) of std_logic_vector(din_i'range);
    type t_array_numsrl_by_srl is array (C_NUM_SRL - 1 downto 0) of t_array_srl_depth_by_width;
    signal s_delay_line : t_array_numsrl_by_srl;
  begin
    -- generates WIDTH bit wide, NUM_SRL*SRL_DEPTH deep shift register array
    -- with one addressable output per SRL

    gen_srls : for i in 0 to C_NUM_SRL - 1 generate
      gen_stage_0 : if (i = 0) generate
        proc_srl_0 : process(clk_i)
        begin
          if rising_edge(clk_i) then
            if (ce_i = '1') then
              s_delay_line(i)(0) <= din_i;
              for j in 1 to C_SRL_DEPTH - 1 loop
                s_delay_line(i)(j) <= s_delay_line(i)(j - 1);
              end loop;
            end if;
          end if;
        end process proc_srl_0;
      end generate gen_stage_0;

      gen_stage_n : if (i /= 0) generate
        proc_srl : process(clk_i)
        begin
          if rising_edge(clk_i) then
            if (ce_i = '1') then
              s_delay_line(i)(0) <= s_delay_line(i - 1)(C_SRL_DEPTH - 1);
              for j in 1 to C_SRL_DEPTH - 1 loop
                s_delay_line(i)(j) <= s_delay_line(i)(j - 1);
              end loop;
            end if;
          end if;
        end process proc_srl;
      end generate gen_stage_n;
    end generate gen_srls;
    dout_o <= s_delay_line(C_NUM_SRL - 1)(C_SRL_ADDR - 1);


  end generate gen_delay;
--`protect end
end architecture a_rtl;
