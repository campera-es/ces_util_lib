--=============================================================================
-- Module Name : ces_util_encoder
-- Library     : ces_util_lib
-- Project     : CES Utility Library
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: general purpose encoder
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

--* @brief general purpose encoder
--* @version 1.0.0
entity ces_util_encoder is
  generic(
    --* input data width
    g_data_w : integer
    );
  port(
    --* input clock
    clk_i   : in  std_logic;
    --* input data valid
    dv_i    : in  std_logic;
    --* input data
    din_i   : in  std_logic_vector(g_data_w - 1 downto 0);
    --* output data valid
    dv_o    : out std_logic;
    --* output encoded data
    dout_o  : out std_logic_vector(f_ceil_log2(g_data_w) - 1 downto 0)
    );
end entity ces_util_encoder;

architecture a_rtl of ces_util_encoder is
--`protect begin
begin
  proc_enc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      dv_o <= dv_i;
      if dv_i = '1' then
        for k in 0 to g_data_w - 1 loop
          if din_i(k) = '1' then
            dout_o <= std_logic_vector(to_unsigned(k, f_ceil_log2(g_data_w)));
          end if;
        end loop;
      end if;
    end if;
  end process proc_enc;
--`protect end
end a_rtl;

