--==============================================================================
-- Module Name : ces_util_tick_gen
-- Library     : ces_util_lib
-- Project     : CES UTILITY PROJECT
-- Company     : Campera Electronic Systems Srl
-- Author      : Andrea Campera
--------------------------------------------------------------------------------
-- Description: pulse generator, generate an output pulse for one clock cycle 
--              every g_clock_div clock pulses. Ideal to generate a clock enable
--              pulse
--------------------------------------------------------------------------------
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
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

-------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
--* @brief pulse generator, generate a pulse of one clock cycle every 
--* g_clock_div clock cycles
entity ces_util_tick_gen is
  generic(
    --* input clock frequency divider
    g_clock_div : integer
  );
  port(
    clk_i   : in  std_logic; --* input clock
    rst_n_i : in  std_logic; --* input reset, synchronous active low
    pulse_o : out std_logic  --* output pulse
  );
end ces_util_tick_gen;

architecture a_rtl of ces_util_tick_gen is
  signal s_count : unsigned(f_ceil_log2(g_clock_div) - 1 downto 0);
begin
  -----------------------------------------------------------------------------
  --* this process divides the input frequency to generate the
  --* desired output clock rate
  -----------------------------------------------------------------------------
  proc_m_counter : process(clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if (rst_n_i = '0') then
        s_count <= (others => '0');
        pulse_o <= '0';
      else
        if (s_count < g_clock_div - 1) then
          pulse_o <= '0';
          s_count <= s_count + 1;
        else
          pulse_o <= '1';
          s_count <= (others => '0');
        end if;
      end if;
    end if;
  end process proc_m_counter;

end a_rtl;
