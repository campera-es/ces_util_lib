--=============================================================================
-- Module Name   : ces_util_counter
-- Library       : ces_util_lib
-- Project       : CES UTILITY
-- Company       : Campera Electronic Systems Srl
-- Author        : A.Campera
-------------------------------------------------------------------------------
-- Description: general purpose counter
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

--* @brief general purpose counter
--* @version 1.0.0
entity ces_util_counter is
  generic(
    --* counter data width
    g_data_w   : integer;
    --* watchdog timer value:
    g_wd_timer : integer;
    --* counter direction, 1: up, 0 : down
    g_dir      : integer
    );
  port(
    --* input clock
    clk_i      : in  std_logic;
    --* input reset
    rst_n_i    : in  std_logic;
    --* clock enable
    ce_i       : in  std_logic;
    --* active high strobe for counter loading
    load_i     : in  std_logic;
    --* data to be loaded
    load_dat_i : in  std_logic_vector(g_data_w - 1 downto 0);
    --* output counter
    cnt_o      : out std_logic_vector(g_data_w - 1 downto 0);
    --* timer output
    timer_o    : out std_logic
    );
end entity ces_util_counter;

--`protect begin
architecture a_rtl of ces_util_counter is
  signal s_cnt   : unsigned(g_data_w - 1 downto 0);
  signal s_timer : std_logic;
begin

  -- check direction
  assert g_dir = 1 or g_dir = 0 report "direction should be an integer 1: up, 0:down" severity error;

  proc_count : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0') then
        s_cnt <= (others => '0');
      elsif (ce_i = '1') then
        if load_i = '1' then
          s_cnt <= unsigned(load_dat_i);
        elsif (s_cnt = to_unsigned(g_wd_timer-1, s_cnt'length)) then
          s_cnt <= (others => '0');
        elsif g_dir = 1 then
          s_cnt <= s_cnt + 1;
        else
          s_cnt <= s_cnt - 1;
        end if;
      end if;
    end if;
  end process proc_count;

  -- watchdog control process
  proc_timer : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0') then
        s_timer <= '0';
      elsif (ce_i = '1') then
        -- check the watchdog
        if s_cnt = to_unsigned(g_wd_timer-1, s_cnt'length) then
          s_timer <= '1';
        else
          s_timer <= '0';
        end if;
      end if;
    end if;
  end process proc_timer;

  -- output assignments
  cnt_o   <= std_logic_vector(s_cnt);
  timer_o <= s_timer;
--`protect end
end architecture a_rtl;
