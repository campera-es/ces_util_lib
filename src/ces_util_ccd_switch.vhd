--=============================================================================
-- Module Name  : ces_util_ccd_switch
-- Library      : ces_util_lib
-- Project      : CES UTIL Library
-- Company      : Campera Electronic Systems Srl
-- Author       : A.Campera
-------------------------------------------------------------------------------
-- Description:
-- The output goes high when switch_high_i='1' and low when
--    switch_low_i='1'.
--    If g_or_high is true then the output follows the switch_high_i immediately,
--    else it goes high in the next clk cycle.
--    If g_and_low is true then the output follows the switch_low_i immediately,
--    else it goes low in the next clk cycle.
--    The g_priority_lo defines which input has priority when switch_high_i and
--    switch_low_i are active simultaneously.
--
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

library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

-------------------------------------------------------------------------------
-- ENTITY
------------------------------------------------------------------------------- 
--* @brief The output goes high when switch_high_i='1' and low when
--* switch_low_i='1'.
--* If g_or_high is true then the output follows the switch_high_i immediately,
--* else it goes high in the next clk cycle.
--* If g_and_low is true then the output follows the switch_low_i immediately,
--* else it goes low in the next clk cycle.
--* The g_priority_lo defines which input has priority when switch_high_i and
--* switch_low_i are active simultaneously.
--* @version 1.0.0
entity ces_util_ccd_switch is
  generic(
    --* When TRUE then input switch_low_i has priority, else switch_high_i.
    --* Don't care when switch_high_i and switch_low_i are pulses that do not occur
    --* simultaneously.
    g_priority_lo : boolean;
    --* When TRUE and priority hi then the registered switch_level is OR-ed with the
    --* input switch_high_i to get out_level_o, else out_level_o is the registered
    --* switch_level
    g_or_high     : boolean;
    --* When TRUE and priority lo then the registered switch_level is AND-ed with the
    --* input switch_low_i to get out_level_o, else out_level_o is the registered
    --* switch_level
    g_and_low     : boolean
    );
  port(
    --* input clock
    clk_i         : in  std_logic;
    --* input reset
    rst_n_i       : in  std_logic;
    --* A pulse on switch_high_i makes the out_level go high
    switch_high_i : in  std_logic;
    --* A pulse on switch_low_i makes the out_level go low
    switch_low_i  : in  std_logic;
    --* output data
    out_level_o   : out std_logic
    );
end ces_util_ccd_switch;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture a_rtl of ces_util_ccd_switch is
  --`protect begin
  signal s_switch_level      : std_logic;
  signal s_next_switch_level : std_logic;

begin
  wire_gen : if g_or_high = false and g_and_low = false generate
    out_level_o <= s_switch_level;
  end generate wire_gen;

  or_gen : if g_or_high = true and g_and_low = false generate
    out_level_o <= s_switch_level or switch_high_i;
  end generate or_gen;

  and_gen : if g_or_high = false and g_and_low = true generate
    out_level_o <= s_switch_level and (not switch_low_i);
  end generate and_gen;

  or_and_gen : if g_or_high = true and g_and_low = true generate
    out_level_o <= (s_switch_level or switch_high_i) and (not switch_low_i);
  end generate or_and_gen;

  proc_reg : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0') then
        s_switch_level <= '0';
      else
        s_switch_level <= s_next_switch_level;
      end if;
    end if;
  end process proc_reg;

  proc_switch_level : process(s_switch_level, switch_low_i, switch_high_i)
  begin
    s_next_switch_level <= s_switch_level;
    if g_priority_lo = true then
      if switch_low_i = '1' then
        s_next_switch_level <= '0';
      elsif switch_high_i = '1' then
        s_next_switch_level <= '1';
      end if;
    else
      if switch_high_i = '1' then
        s_next_switch_level <= '1';
      elsif switch_low_i = '1' then
        s_next_switch_level <= '0';
      end if;
    end if;
  end process proc_switch_level;
--`protect end
end a_rtl;
