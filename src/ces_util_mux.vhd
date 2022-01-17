--=============================================================================
-- Module Name  : ces_util_mux
-- Library      : ces_util_lib
-- Project      : CES UTIL Library
-- Company      : Campera Electronic Systems Srl
-- Author       : A.Campera
-------------------------------------------------------------------------------
-- Description : general purpose multiplexer
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
-- SOFTWARE.                                  ed to define the reset level.
--
--=============================================================================
library ieee;
use ieee.std_logic_1164.all;

library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

--* @brief general purpose multiplexer
--* @version 1.0.0
entity ces_util_mux is
  generic(
    --* input data width
    g_data_w     : integer;
    --* implementation type, C_CES_COMB: combinatorial mux, C_CES_SYNC: synchronuous mux
    g_arch_type  : integer;
    --* number of inputs
    g_nof_inputs : integer
    );
  port(
    --* input clock
    clk_i  : in  std_logic;
    --* mux select control input
    sel_i  : in  std_logic_vector(f_ceil_log2(g_nof_inputs) - 1 downto 0);
    --* mux input data as concatenation of g_nof_inputs inputs of data width g_data_w
    din_i  : in  std_logic_vector(g_nof_inputs * g_data_w - 1 downto 0);
    -- output selected data
    dout_o : out std_logic_vector(g_data_w - 1 downto 0)
    );
end entity ces_util_mux;

architecture a_rtl of ces_util_mux is
  --`protect begin
  type t_mux_array is array (natural range 0 to g_nof_inputs - 1) of std_logic_vector(g_data_w - 1 downto 0);
  signal s_array_val : t_mux_array;

begin
  assert g_arch_type = C_CES_COMB or g_arch_type = C_CES_SYNC
    report "ces_util_mux: architecture could only be 0:comb or 1: sync"
    severity failure;

  gen_comb : if g_arch_type = C_CES_COMB generate
    gen_mux : for i in s_array_val'range generate
      s_array_val(i) <= din_i(dout_o'left + (i * g_data_w) downto i * g_data_w);
    end generate;

    dout_o <= s_array_val(f_slv2nat(sel_i));
  end generate gen_comb;

  gen_sync : if g_arch_type = C_CES_SYNC generate
    gen_mux : for i in s_array_val'range generate
      proc_mux : process(clk_i)
      begin
        if rising_edge(clk_i) then
          s_array_val(i) <= din_i(dout_o'left + (i * g_data_w) downto i * g_data_w);
        end if;
      end process proc_mux;
    end generate;

    dout_o <= s_array_val(f_slv2nat(sel_i));
  end generate gen_sync;
--`protect end
end architecture a_rtl;

