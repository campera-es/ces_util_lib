--==============================================================================
-- Module Name : ces_util_clock_gen
-- Library     : ces_util_lib
-- Project     : CES UTILITY PROJECT
-- Company     : Campera Electronic Systems Srl
-- Author      : Andrea Campera
--------------------------------------------------------------------------------
-- Description: clock generator, generate an output clock with programmable duty cycle
--            only if g_clock_div is even. If odd the duty cycle is less than 
--            50% ( e.g. g_clock_div 7, high for 3 clock cycles and low for 4 )
--            the phase of the output clock can also be configured
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
--* @brief generate an output clock with 50 % duty cycle
--* only if g_clock_div is even. If odd the duty cycle is less than 
--* 50% ( e.g. g_clock_div 7, high for 3 clock cycles and low for 4
entity ces_util_clock_gen is
  generic(
    --* input clock frequency divider
    g_clock_div      : integer;
    --* output clock phase  
    g_clock_phase    : integer;
    --* positive output clock cycles 
    g_pos_duty_cycle : integer
    );
  port(
    clk_i   : in  std_logic;            --* input clock
    rst_n_i : in  std_logic;            --* input reset
    clk_o   : out std_logic             --* output pulse
    );
end ces_util_clock_gen;

architecture a_rtl of ces_util_clock_gen is
  signal s_count_delay : unsigned(f_ceil_log2(g_clock_div) - 1 downto 0);
  signal s_count       : unsigned(f_ceil_log2(g_clock_div) - 1 downto 0);
  -- internal divided clock, pre phase-adjustment
  signal s_clk_div     : std_logic;
  signal s_div_ena     : std_logic;
begin
  -- generate delay if phase is greater than 0
  gen_delay : if g_clock_phase > 0 generate
    -----------------------------------------------------------------------------
    --* delay on the output clock to adjust output phase
    -----------------------------------------------------------------------------
    proc_delay : process(clk_i)
    begin
      if (clk_i'event and clk_i = '1') then
        if (rst_n_i = '0') then
          s_count_delay <= (others => '0');
          s_div_ena     <= '0';
        else
          if (s_count_delay < g_clock_phase-1) and s_div_ena = '0' then
            s_count_delay <= s_count_delay + 1;
          elsif (s_count_delay = g_clock_phase-1) then
            s_div_ena <= '1';
          end if;
        end if;
      end if;
    end process proc_delay;
  end generate gen_delay;

  -- generate wire for 0 phase adjustment
  gen_wire : if g_clock_phase = 0 generate
    s_div_ena <= '1';
  end generate gen_wire;

  -----------------------------------------------------------------------------
  --* this process divides the input frequency to generate the
  --* desired output clock rate
  -----------------------------------------------------------------------------
  proc_m_counter : process(clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if (rst_n_i = '0') then
        s_count   <= (others => '0');
        s_clk_div <= '0';
      elsif s_div_ena = '1' then
        if (s_count < g_pos_duty_cycle) then
          s_clk_div <= '1';
          s_count   <= s_count + 1;
        elsif (s_count < g_clock_div - 1) then
          s_clk_div <= '0';
          s_count   <= s_count + 1;
        else
          s_clk_div <= '0';
          s_count   <= (others => '0');
        end if;
      end if;
    end if;
  end process proc_m_counter;

  clk_o <= s_clk_div;

end a_rtl;
