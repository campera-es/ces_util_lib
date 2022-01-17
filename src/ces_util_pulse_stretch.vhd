--==============================================================================
-- Module Name : ces_io_pulse_stretch
-- Library     : ces_util_lib
-- Project     : CES
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
--------------------------------------------------------------------------------
-- Description: Stretch a pulse from an edge defining a fixed length or an overlength
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- User Library: CES Utility Library
library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

--pulse stretcher
entity ces_util_pulse_stretch is
  generic (
    --* 1: out pulse shall have fixed length specified by the g_pulse_length generic
    --* 0: out pulse shall be stretched of g_pulse_overlength clock cycles
    g_has_fixed_length : natural;
    g_pulse_length     : natural;
    g_pulse_overlength : natural;
    --* 0: do not include a 2-FFD resync stage on the input pulse
    --* 1: include a 2-FFD resync stage on the input pulse
    g_has_resync_stage : natural;
    g_out_level        : std_logic
    );
  port (
    clk_i   : in  std_logic;
    rst_n_i : in  std_logic;
    pulse_i : in  std_logic;
    pulse_o : out std_logic
    );
end ces_util_pulse_stretch;

architecture a_rtl of ces_util_pulse_stretch is
  constant C_MAX_LENGTH : integer := f_max(g_pulse_length, g_pulse_overlength);
  --
  signal s_pulse_d      : std_logic;
  signal s_pulse_d2     : std_logic;
  signal s_pulse_d3     : std_logic;
  signal s_cnt          : unsigned(f_ceil_log2(C_MAX_LENGTH)-1 downto 0);
  signal s_cnt_ena      : std_logic;

begin

  gen_resync_stage : if g_has_resync_stage = 1 generate
    --resample input async signal in the clock domain
    proc_buff : process (clk_i)
    begin
      if (rising_edge(clk_i)) then
        s_pulse_d  <= pulse_i;
        s_pulse_d2 <= s_pulse_d;
        s_pulse_d3 <= s_pulse_d2;
      end if;
    end process proc_buff;
  end generate gen_resync_stage;

  gen_input_stage : if g_has_resync_stage = 0 generate
    s_pulse_d2 <= pulse_i;
    --resample input async signal in the clock domain
    proc_buff : process (clk_i)
    begin
      if (rising_edge(clk_i)) then
        s_pulse_d3 <= pulse_i;
      end if;
    end process proc_buff;
  end generate gen_input_stage;

  -- generate fixed length
  gen_fixed_length : if g_has_fixed_length = 1 generate
    proc_cnt_ena : process (clk_i)
    begin
      if (rising_edge(clk_i)) then
        if (rst_n_i = '0') then
          s_cnt_ena <= '0';
        else
          --enable the counter on rising edge of input signal
          if (s_pulse_d2 = '1' and s_pulse_d3 = '0') then
            s_cnt_ena <= '1';
          elsif (s_cnt = g_pulse_length-1) then  --falling edge
            s_cnt_ena <= '0';
          end if;
        end if;
      end if;
    end process proc_cnt_ena;

    proc_stretch : process (clk_i)
    begin
      if (rising_edge(clk_i)) then
        if (rst_n_i = '0') then
          s_cnt   <= (others => '0');
          pulse_o <= not g_out_level;
        else
          if (s_cnt_ena = '1') then     -- counter enabled
            if (s_cnt < g_pulse_length-1) then  --count g_pulse_length* clk_i period          
              pulse_o <= g_out_level;
              s_cnt   <= s_cnt + 1;
            else
              s_cnt <= (others => '0');
            end if;
          else                          --se vengo da un undervoltage
            pulse_o <= not g_out_level;
            s_cnt   <= (others => '0');
          end if;
        end if;
      end if;
    end process proc_stretch;
  end generate gen_fixed_length;

  -- generate pulse stretch
  gen_stretched_pulse : if (g_has_fixed_length = 0 and g_pulse_overlength /= 0) generate
    signal s_pulse_rise_edge : std_logic;
  begin
    proc_cnt_ena : process (clk_i)
    begin
      if (rising_edge(clk_i)) then
        if (rst_n_i = '0') then
          s_cnt_ena <= '0';
        else
          if (s_pulse_d2 = '1' and s_pulse_d3 = '0') then  -- falling edge
            s_pulse_rise_edge <= '1';
          else
            s_pulse_rise_edge <= '0';
          end if;

          if (s_pulse_d2 = '0' and s_pulse_d3 = '1') then  -- falling edge
            s_cnt_ena <= '1';
          elsif (s_cnt = g_pulse_overlength-1) then        --extra length
            s_cnt_ena <= '0';
          end if;
        end if;
      end if;
    end process proc_cnt_ena;

    proc_counter : process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_n_i = '0') then
          s_cnt <= (others => '0');
        else
          if (s_cnt_ena = '1') then
            if (s_cnt < g_pulse_overlength-1) then
              s_cnt <= s_cnt + 1;
            else
              s_cnt <= (others => '0');
            end if;
          end if;
        end if;
      end if;
    end process proc_counter;

    proc_stretch : process (clk_i)
    begin
      if (rising_edge(clk_i)) then
        if (rst_n_i = '0') then
          pulse_o <= not g_out_level;
        else
          if s_pulse_rise_edge = '1' then
            pulse_o <= g_out_level;
          elsif (s_cnt = g_pulse_overlength-1) then
            pulse_o <= not g_out_level;
          end if;
        end if;
      end if;
    end process proc_stretch;
  end generate gen_stretched_pulse;

  gen_stretched_pulse_zero : if (g_has_fixed_length = 0 and g_pulse_overlength = 0) generate
    pulse_o <= pulse_i;
  end generate gen_stretched_pulse_zero;


end a_rtl;
