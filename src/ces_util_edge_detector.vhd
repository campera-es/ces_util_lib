--==============================================================================
-- Module Name : ces_util_edge_detector
-- Library     : ces_util_lib
-- Project     : CES_UTILITY
-- Company     : Campera Electronic Systems Srl
-- Author      : G. Dalle Mura
--------------------------------------------------------------------------------
-- Description  : the module detect the edge of a signal based on the generic
-- g_level_edge. If g_level_edge = C_CES_RISING the module detect the rising
-- edge of the signal. If g_level_edge = C_CES_FALLING the module detect the
-- falling edge of the signal. 
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
--==============================================================================

--------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
--* @brief the module detect the edge of a signal based on the generic
--* g_level_edge. If g_level_edge = C_CES_RISING the module detect the rising
--* edge of the signal. If g_level_edge = C_CES_FALLING the module detect the
--* falling edge of the signal.
--* @version 1.0.0
entity ces_util_edge_detector is
  generic(
    --* Rising or falling edge event to be detected
    --* g_event_edge can be C_RISING_EDGE or C_FALLING_EDGE
    g_event_edge : integer
    );
  port(
    --* input clcok
    clk_i   : in  std_logic;
    --* signal which edge has to be detected
    din_i   : in  std_logic;
    --* detected edge
    dout_o  : out std_logic
    );
end ces_util_edge_detector;

architecture a_rtl of ces_util_edge_detector is
  signal s_din_d  : std_logic;
  signal s_strobe : std_logic := '0';

begin

  --* process to register input signal. xor operation detect both rising and
  --* falling edge. the internal condition (din_i = g_event_edge) allows to select
  --* the desired edge event
  proc_reg : process(clk_i)
  begin
    if rising_edge(clk_i) then
      s_din_d <= din_i;
      --
      if din_i = f_int2sl(g_event_edge) then
        s_strobe <= din_i xor s_din_d;
      else
        s_strobe <= '0';
      end if;
    --
    end if;
  end process proc_reg;

  dout_o <= s_strobe;

end a_rtl;
