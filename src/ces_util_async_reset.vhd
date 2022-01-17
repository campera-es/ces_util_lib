--=============================================================================
-- Module Name : ces_util_async_reset
-- Library     : ces_util_lib
-- Project     : CES UTILITY
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: Immediately apply reset and synchronously release it at rising clk_i
--              The first reason for recommending synchronous resets is for big 
--              blocks like DSPs and block RAMs which by architecture support only 
--              synchronous resets. The inference of DSPs and block RAMs is possible 
--              if synchronous resets are used. Use of asynchronous resets might 
--              result in these structures getting inferred in the fabric which 
--              might hurt performance. In the DSP blocks, the pipeline registers 
--              only support synchronous resets. In block RAMs, the output 
--              registers support only synchronous resets and using output 
--              registers is an advantage as it reduces the clock-to-out (Tco).
--              The rule of thumb with reset is to use synchronous reset inside 
--              the FPGA, as it is automaticcally timed and need no special
--              constraint
--              The input asynchronous reset is activeon g_rst_lvl, the output
--              is active low
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
library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

--* @brief Immediately apply reset and synchronously release it at an edge of 
--* clk_i. 
--* @version 1.0.0
entity ces_util_async_reset is
  generic(
    --* select level of edge transition: 1 rising, 0 falling
    g_rising_edge : integer;
    --* number of resync stage to reduce metastability
    g_delay_len   : integer;
    --* asynchronous reset level
    g_rst_lvl : std_logic
    );
  port(
    --* input reset, asynchronous, active state at generic g_rst_lvl
    arst_i  : in std_logic;
    --* input clock
    clk_i   : in std_logic;
    --* output resynced reset, active low
    rst_n_o : out std_logic
    );
end ces_util_async_reset;

architecture a_rtl of ces_util_async_reset is
  -- active low output reset
  constant C_OUT_RESET_LEVEL :std_logic := '0';
  -- shift register
  type t_meta_regs is array (1 downto 0) of std_logic;
  signal s_resync_reg                 : t_meta_regs := (others => '0');
begin

  --* When rst_n_i becomes '0' then rst_n_o follows immediately (asynchronous reset apply).
  --* When rst_n_i becomes '1' then rst_n_o follows after g_delay_len cycles (synchronous reset release).
  --* This block can also synchronise other signals than reset
  proc_resync : process(clk_i, arst_i)
  begin
    if arst_i = g_rst_lvl then
      s_resync_reg(0) <= C_OUT_RESET_LEVEL;
      s_resync_reg(1) <= C_OUT_RESET_LEVEL;
    else
      if rising_edge(clk_i) then
        s_resync_reg(0) <= not C_OUT_RESET_LEVEL;
        s_resync_reg(1) <= s_resync_reg(0);
      end if;
    end if;
  end process proc_resync;

  rst_n_o <= s_resync_reg(1);

end a_rtl;

