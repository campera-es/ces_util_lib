--=============================================================================
-- Module Name : ces_util_async
-- Library     : ces_util_lib
-- Project     : CES UTILITY
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: Clock an asynchronous din_i into the clk_i clock domain
--              The delay line combats the potential meta-stability of clocked 
--              in data.
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

--* @brief clock an asynchronous din_i into the clk_i clock domain.
--* The delay line combats potential meta-stability of clocked in data. 
--* @version 1.1.0
entity ces_util_async is
  generic (
    --* select level of edge transition: 1 rising, 0 falling
    g_rising_edge : integer;
    --* number of resync stages to reduce metastability
    g_delay_len   : integer
    );
  port (
    --* input clock
    clk_i  : in  std_logic;
    --* input reset
    rst_n_i  : in  std_logic;
    --* asynchronous input data
    din_i  : in  std_logic;
    --* synchronized output data
    dout_o : out std_logic
  );
end ces_util_async;


architecture a_rtl of ces_util_async is

  signal s_din_meta : std_logic_vector(0 to g_delay_len-1);

begin

  assert g_delay_len /= 0
    report "use ces_util_delay if g_delay_len=0 for wires only is also needed"
      severity error;

  -- generate rising edge detector
  gen_rising : if g_rising_edge = 1 generate
    ---------------------------------------------------------------------------
    -- This process synchronize the async reset in the clk_i domain
    ---------------------------------------------------------------------------  
    proc_resync : process (clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_n_i = '0') then
          s_din_meta <= (others => '0');
        else
          s_din_meta <= din_i & s_din_meta(0 to s_din_meta'high-1);
        end if;
      end if;
    end process proc_resync;
  end generate gen_rising;

  -- generate falling edge detector
  gen_falling : if g_rising_edge = 0 generate
    ---------------------------------------------------------------------------
    -- This process synchronize the async reset in the clk_i domain
    ---------------------------------------------------------------------------  
    proc_resync : process (clk_i)
    begin
      if falling_edge(clk_i) then
        if (rst_n_i = '0') then
          s_din_meta <= (others => '0');
        else
          s_din_meta <= din_i & s_din_meta(0 to s_din_meta'high-1);
        end if;
      end if;
    end process proc_resync;
  end generate gen_falling;

  dout_o <= s_din_meta(s_din_meta'high);

end a_rtl;
