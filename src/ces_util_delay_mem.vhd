--=============================================================================
-- Module Name   : ces_util_delay_mem
-- Library       : ces_util_lib
-- Project       : CES UTIL Library
-- Company       : Campera Electronic Systems Srl
-- Author        : A.Campera
-------------------------------------------------------------------------------
-- Description: Fixed delay for std_logic_vector signals. 
--              memory implementation
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
entity ces_util_delay_mem is
  generic(
    --* actual delay can be different from a power of 2
    g_delay  : natural;
    --* input data width
    g_data_w : natural
    );
  port(
    --* input clock
    clk_i  : in  std_logic;
    --* clock enable
    ce_i   : in  std_logic := '1';
    --* input data
    din_i  : in  std_logic_vector(g_data_w - 1 downto 0);
    --* output delayed data
    dout_o : out std_logic_vector(g_data_w - 1 downto 0)
    );
end ces_util_delay_mem;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture a_rtl of ces_util_delay_mem is
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
    -- Comments: memory delay architecture
    -------------------------------------------------------------------------------
    constant C_LOG_DELAY : integer := f_ceil_log2(g_delay);

    signal s_raddr : unsigned(C_LOG_DELAY - 1 downto 0) := (others => '0');
    -- integer range 0 to delay-1;
    signal s_waddr : unsigned(C_LOG_DELAY - 1 downto 0) := (others => '0');
  -- integer range 0 to delay-1;
  begin

    ces_util_ram_r_w_inst : entity ces_util_lib.ces_util_ram_r_w
      generic map(
        g_ram_latency => 1,
        g_ram_data_w  => g_data_w,
        g_ram_depth   => g_delay
        )
      port map(
        clk_i     => clk_i,
        wen_i     => '1',
        wr_addr_i => std_logic_vector(s_waddr),
        wr_dat_i  => din_i,
        rd_addr_i => std_logic_vector(s_raddr),
        rd_dat_o  => dout_o
        );

    proc_mem_delay : process(clk_i)
    begin
      if rising_edge(clk_i) then
        if ce_i = '1' then
          if s_waddr = g_delay - 1 then
            s_waddr <= to_unsigned(0, C_LOG_DELAY);
            s_raddr <= to_unsigned(1, C_LOG_DELAY);
          else
            s_waddr <= s_waddr + 1;
            if s_waddr = g_delay - 2 then
              s_raddr <= to_unsigned(0, C_LOG_DELAY);
            else
              s_raddr <= s_waddr + 2;
            end if;  -- case g_delay -2
          end if;  -- case g_delay -1
        end if;
      end if;
    end process proc_mem_delay;

  end generate gen_delay;
--`protect end
end architecture a_rtl;
