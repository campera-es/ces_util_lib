--=============================================================================
-- Module Name : ces_util_debouncer
-- Library     : ces_util_lib
-- Project     : CES Utility Library
-- Company     : Campera Electronic Systems Srl
-- Author      : ACA
-------------------------------------------------------------------------------
-- Description  : general purpose debouncer circuit with configurable length
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

entity ces_util_debouncer is
  generic (
    -- debounce length in clock cycles
    g_debounce_length : natural;
    -- debounce level: 0: std_logic '0', 1: std_logic '1', 2: both ('0', and '1')
    g_debounce_lvl    : natural
    );
  port (
    clk_i   : in  std_logic;
    ce_i    : in  std_logic;
    rst_n_i : in  std_logic;
    din_i   : in  std_logic;
    dout_o  : out std_logic
    );
end ces_util_debouncer;

architecture a_rtl of ces_util_debouncer is

  signal s_din_d     : std_logic;
  signal s_din_d2    : std_logic;
  signal s_cnt       : unsigned(f_ceil_log2(g_debounce_length)-1 downto 0);
  signal s_diff      : std_logic;
  signal s_debounced : std_logic;

begin

  -- sanity checks
  assert g_debounce_lvl <= 2 report "only 0: '0', 1: '1' or 2: both debounce levels are supported" severity failure;

  proc_sample : process (clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      s_din_d  <= din_i;
      s_din_d2 <= s_din_d;
    end if;
  end process proc_sample;

  --xor 
  gen_debounce_both : if g_debounce_lvl = 2 generate
    s_diff <= s_din_d xor s_din_d2;

    -- this process assign the internal signal s_din_d2 (input sampled twice)
    -- to the output only if the debounce counter reached the debounce dength
    proc_debounce : process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (s_cnt = g_debounce_length - 1) then
          s_debounced <= s_din_d2;
        end if;
      end if;
    end process proc_debounce;

  end generate gen_debounce_both;

  -- low level debouncing: falling edge detected
  gen_debounce_low : if g_debounce_lvl = 0 generate
    s_diff <= not s_din_d and s_din_d2;

    -- this process assign the internal signal s_din_d2 (input sampled twice)
    -- to the output only if the debounce counter reached the debounce dength
    proc_debounce : process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (s_cnt = g_debounce_length - 1) then
          s_debounced <= s_din_d2;
        elsif s_din_d2 = '1' then
          s_debounced <= s_din_d2;
        end if;
      end if;
    end process proc_debounce;
  end generate gen_debounce_low;

  -- high level debouncing: rising edge detected
  gen_debounce_high : if g_debounce_lvl = 1 generate
    s_diff <= s_din_d and not s_din_d2;

    -- this process assign the internal signal s_din_d2 (input sampled twice)
    -- to the output only if the debounce counter reached the debounce dength
    proc_debounce : process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (s_cnt = g_debounce_length - 1) then
          s_debounced <= s_din_d2;
        elsif s_din_d2 = '0' then
          s_debounced <= s_din_d2;
        end if;
      end if;
    end process proc_debounce;
  end generate gen_debounce_high;

  -- this process implements a counter, the counter starts when a change is detected
  -- on the input signal (depending on g_debounce_lvl could be falling, rising or both edges)
  proc_counter : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0') then           --sync reset 
        s_cnt <= (others => '0');
      else
        --change detected or end of counter
        if (s_diff = '1' or s_cnt = g_debounce_length - 1) then
          s_cnt <= (others => '0');
        elsif ce_i = '1' then
          s_cnt <= s_cnt + 1;
        end if;
      end if;
    end if;
  end process proc_counter;



  -- output assignments
  dout_o <= s_debounced;

end a_rtl;
