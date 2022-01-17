--=============================================================================
-- Module Name   : ces_util_delay
-- Library       : ces_util_lib
-- Project       : CES UTIL Library
-- Company       : Campera Electronic Systems Srl
-- Author        : A.Campera
-------------------------------------------------------------------------------
-- Description: Fixed delay for std_logic_vector signals. 
--              simple counter (for pulses) implementation
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
entity ces_util_delay_pulse is
  generic(
    --* actual delay can be different from a power of 2
    g_delay       : natural;
    --* input data width
    g_data_w      : natural;
    --* input pulse active level, used only in "pulse" mode
    g_pulse_level : std_logic
    );
  port(
    --* input clock
    clk_i   : in  std_logic;
    --* input reset
    rst_n_i : in  std_logic;
    --* clock enable
    ce_i    : in  std_logic := '1';
    --* input data
    din_i   : in  std_logic_vector(g_data_w - 1 downto 0);
    --* output delayed data
    dout_o  : out std_logic_vector(g_data_w - 1 downto 0)
    );
end ces_util_delay_pulse;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture a_rtl of ces_util_delay_pulse is
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
    -------------------------------------------------------------------------------
    -- Comments: pulse delay architecture
    -------------------------------------------------------------------------------
    constant C_LOG_DELAY : integer := f_ceil_log2(g_delay);

    -- pulse architecture signals
    signal s_pulse_cnt : unsigned(C_LOG_DELAY - 1 downto 0) := (others => '0');
    -- this signal force the cou nter to start after the first sof received
    signal s_cnt_ena   : std_logic;

  begin


    assert g_data_w = 1
      report "pulse delay makes sense only with std_logic signals"
      severity error;

    proc_cnt : process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_n_i = '0') then
          dout_o    <= (dout_o'range => '0');
          s_cnt_ena <= '0';
        elsif ce_i = '1' then
          if din_i(0) = g_pulse_level then
            s_cnt_ena <= '1';
          end if;
          if din_i(0) = g_pulse_level then
            s_pulse_cnt <= to_unsigned(1, s_pulse_cnt'length);
          elsif s_pulse_cnt = (g_delay - 1) then
            s_pulse_cnt <= to_unsigned(0, s_pulse_cnt'length);
            dout_o(0)   <= g_pulse_level;
            s_cnt_ena   <= '0';
          elsif s_cnt_ena = '1' then
            s_pulse_cnt <= s_pulse_cnt + 1;
            dout_o(0)   <= not g_pulse_level;
          else
            s_pulse_cnt <= s_pulse_cnt;
            dout_o(0)   <= not g_pulse_level;
          end if;
        end if;
      end if;
    end process proc_cnt;

  end generate gen_delay;
--`protect end
end architecture a_rtl;
