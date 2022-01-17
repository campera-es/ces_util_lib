--=============================================================================
-- Module Name   : ces_util_delay
-- Library       : ces_util_lib
-- Project       : CES UTIL Library
-- Company       : Campera Electronic Systems Srl
-- Author        : A.Campera
-------------------------------------------------------------------------------
-- Description: Fixed delay for std_logic_vector signals. 
--              Shift register implementation
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
entity ces_util_delay is
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
end ces_util_delay;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture a_rtl of ces_util_delay is
--`protect begin
begin
  -- Check that the delay is non-negative
  assert (g_delay > 0) report "Delay must greater than 0" severity error;

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
      -- srl architecture signals
      type t_mem_srl is array (0 to g_delay - 1) of std_logic_vector(din_i'range);
      signal s_mem_ary_srl : t_mem_srl := (others => (others => '0'));

    begin
        ------------------------------------------------------------------------------
        -- Comments: srl delay architecture
        -------------------------------------------------------------------------------
        proc_srl_delay : process(clk_i)
        begin
          if rising_edge(clk_i) then
            if ce_i = '1' then
              s_mem_ary_srl(0) <= din_i;
              for i in 1 to g_delay - 1 loop
                s_mem_ary_srl(i) <= s_mem_ary_srl(i - 1);
              end loop;
            end if;
          end if;
        end process proc_srl_delay;
        dout_o <= s_mem_ary_srl(g_delay - 1);

  end generate gen_delay;
--`protect end
end architecture a_rtl;
