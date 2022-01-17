--=============================================================================
-- Module Name  : ces_util_ccd_sync_pulse 
-- Library      : ces_util_lib
-- Project      : CES UTIL Library
-- Company      : Campera Electronic Systems Srl
-- Author       : A.Campera
-------------------------------------------------------------------------------
-- Description: cross clock domain re-synchronizer circuit
--   The in_pulse is captured in the in_clk domain and then transfered to the
--   out_clk domain. The out_pulse is also only one cycle wide and transfered
--   back to the in_clk domain to serve as an acknowledge signal to ensure
--   that the in_pulse was recognized also in case the in_clk is faster than
--   the out_clk. The in_busy is active during the entire transfer. Hence the
--   rate of pulses that can be transfered is limited by g_delay_len and by
--   the out_clk rate.
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

--* @brief cross clock domain re-synchronizer circuit
--* The in_pulse is captured in the in_clk_i domain and then transfered to the
--* out_clk_i domain. The out_pulse_o is also only one cycle wide and transfered
--* back to the in_clk_i domain to serve as an acknowledge signal to ensure
--* that the in_pulse was recognized also in case the in_clk_i is faster than
--* the out_clk_i. The in_busy_o is active during the entire transfer. Hence the
--* rate of pulses that can be transfered is limited by g_delay_len and by
--* the out_clk_i rate.
--* @version 1.0.0
entity ces_util_ccd_sync_pulse is
  generic(
    --* number of resync stage to reduce metastability
    g_delay_len : natural
  );
  port(
    -- input clock
    in_clk_i : in std_logic;
    -- input reset
    in_rst_n_i : in std_logic;
    --* input pulse
    in_pulse_i : in std_logic;
    -- indicates whether the module is busy 
    in_busy_o : out std_logic;
    -- output reset
    out_rst_n_i : in std_logic;
    -- output clock
    out_clk_i : in std_logic;
    -- output clock enable
    out_ce_i : in std_logic;
    -- outpu pulse
    out_pulse_o : out std_logic
  );
end ces_util_ccd_sync_pulse;

architecture a_rtl of ces_util_ccd_sync_pulse is
  --`protect begin
  signal s_in_level       : std_logic;
  signal s_meta_level     : std_logic_vector(g_delay_len-1 downto 0);
  signal s_out_level      : std_logic;
  signal s_prev_out_level : std_logic;
  signal s_meta_ack       : std_logic_vector(g_delay_len-1 downto 0);
  signal s_pulse_ack      : std_logic;
  signal s_next_out_pulse : std_logic;

begin
  capture_in_pulse_inst : entity ces_util_lib.ces_util_ccd_switch
    generic map(
      g_priority_lo => true,
      g_or_high     => false,
      g_and_low     => false
    )
    port map(
      clk_i         => in_clk_i,
      rst_n_i       => in_rst_n_i,
      switch_high_i => in_pulse_i,
      switch_low_i  => s_pulse_ack,
      out_level_o   => s_in_level
    );

  in_busy_o <= s_in_level or s_pulse_ack;

  proc_out_clk : process(out_clk_i)
  begin
    if rising_edge(out_clk_i) then
      if (out_rst_n_i = '0') then
        s_meta_level     <= (others => '0');
        s_out_level      <= '0';
        s_prev_out_level <= '0';
        out_pulse_o      <= '0';
      elsif out_ce_i = '1' then
        s_meta_level     <= s_meta_level(s_meta_level'high-1 downto 0) & s_in_level;
        s_out_level      <= s_meta_level(s_meta_level'high);
        s_prev_out_level <= s_out_level;
        out_pulse_o      <= s_next_out_pulse;
      end if;
    end if;
  end process proc_out_clk;

  proc_in_clk : process(in_clk_i)
  begin
    if rising_edge(in_clk_i) then
      if (in_rst_n_i = '0') then
        s_meta_ack  <= (others => '0');
        s_pulse_ack <= '0';
      else
        s_meta_ack  <= s_meta_ack(s_meta_ack'high-1 downto 0) & s_out_level;
        s_pulse_ack <= s_meta_ack(s_meta_ack'high);
      end if;
    end if;
  end process proc_in_clk;

  s_next_out_pulse <= s_out_level and not s_prev_out_level;
--`protect end
end a_rtl;
