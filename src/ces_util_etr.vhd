--=============================================================================
-- Module Name : ces_util_etr
-- Library     : ces_util_lib
-- Project     : CES UTILITY
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: Elapsed Time Recorder. 
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
use ieee. numeric_std.all;
library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;
--use ces_util_lib.ces_util_physical.all; 

--* @brief Clock an asynchronous din_i into the clk_i clock domain.
--* The delay line combats the potential meta-stability of clocked in data. 
--* @version 1.0.0
entity ces_util_etr is
  generic (
    --* select input clock frequency
    g_clk_freq       : natural;  --unit: Hz
    --* update rate in Non Volatile Memory
    g_update_rate    : natural;        --unit: milli seconds
    --* ETR resolution
    g_etr_resolution : natural;         --unit: milli seconds
    --* ETR counter max resolution (is resolution in seconds then with 32 bits
    --* the maximu ETR value would be more than 136 years)
    g_counter_width  : natural
    );
  port (
    --* input clock
    clk_i        : in  std_logic;
    --* input reset
    rst_n_i      : in  std_logic;
    --* enable ETR, active high. Provide starting time prior to enable the module
    ena_i        : in  std_logic;
    --* starting time
    start_time_i : in  std_logic_vector(g_counter_width-1 downto 0);
    --* update ETR value
    update_etr_o : out std_logic;
    --* ETR updated value
    etr_dout_o   : out std_logic_vector(g_counter_width-1 downto 0)
    );
end ces_util_etr;


architecture a_rtl of ces_util_etr is

  constant C_TICK_DIVIDER : natural := 10000000;  --g_etr_resolution*(g_clk_freq/1000);
  constant C_UPDATE_VALUE : natural := 60;  --g_update_rate/g_etr_resolution;
  -- resolution tick, 1 clock cycle
  signal s_tick           : std_logic;
  -- rising edge on enable input
  signal s_load_cnt       : std_logic;
  -- delay on input enable, for edge detection
  signal s_ena_d          : std_logic;
  -- ETR main counter
  signal s_etr_cnt : unsigned(g_counter_width-1 downto 0) := (others => '0');

begin

  assert g_update_rate > g_etr_resolution
    report "update rate shall be greater than ETR resolution"
    severity error;

  -- generate resolution tick for the counter
  inst_tick_gen : entity ces_util_lib.ces_util_tick_gen
    generic map(
      g_clock_div => C_TICK_DIVIDER
      )
    port map(
      clk_i   => clk_i,
      rst_n_i => rst_n_i,
      pulse_o => s_tick
      );

  -- capture rising edge on ena input signal to load the counter,
  -- wait the ce to release it
  proc_load : process(clk_i)
  begin
    if rising_edge(clk_i) then
      s_ena_d <= ena_i;
      if ena_i = '1' and s_ena_d = '0' then
        s_load_cnt <= '1';
      elsif s_tick = '1' and s_load_cnt = '1' then
        s_load_cnt <= '0';
      end if;
    end if;
  end process proc_load;


  inst_counter : entity ces_util_lib.ces_util_counter
    generic map(
      g_data_w   => g_counter_width,
      g_wd_timer => 0,
      g_dir      => 1                   -- UP
      )
    port map(
      clk_i      => clk_i,
      rst_n_i    => rst_n_i,
      ce_i       => s_tick,
      load_i     => s_load_cnt,
      load_dat_i => start_time_i,
      cnt_o      => etr_dout_o,
      timer_o    => open
      );

  inst_updater : entity ces_util_lib.ces_util_counter
    generic map(
      g_data_w   => f_ceil_log2(C_UPDATE_VALUE),
      g_wd_timer => C_UPDATE_VALUE,
      g_dir      => 1                   -- UP
      )
    port map(
      clk_i      => clk_i,
      rst_n_i    => rst_n_i,
      ce_i       => s_tick,
      load_i     => '0',
      load_dat_i => (others => '0'),
      cnt_o      => open,
      timer_o    => update_etr_o
      );


end a_rtl;
