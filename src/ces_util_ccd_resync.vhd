--=============================================================================
-- Module Name  : ces_util_ccd_resync
-- Library      : ces_util_lib
-- Project      : CES UTILITY Library, Cross-Clock-Domain
-- Company      : Campera Electronic Systems Srl
-- Author       : A.Campera
-------------------------------------------------------------------------------
-- Description: this module implements a re-synchronizer circuit, used in cross 
--              clock domain for std_logic signals. The circuit is done with
--              g_meta_levels (usually 2) registers in the destination clock 
--              domain.
--              Synthesis tools might infer SRL and not true registers, making
--              the clock domain crossing no implemented. To prevent this 
--              special attributes shall be used. One way to use those 
--              attributes is via HDL attribute keyword, another way would be to 
--              include the constraint in a specific contraint file. 
--              In both cases this process is vendor dependent 
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

-------------------------------------------------------------------------------
-- ENTITY
------------------------------------------------------------------------------- 
--* @brief this module implements a re-synchronizer circuit, used in cross 
--* clock domain for std_logic signals. The circuit is done with
--* g_meta_levels (usually 2) registers in the destination clock domain 
--* @version 1.0.0
entity ces_util_ccd_resync is
  generic(
    --* default nof flipflops (ff) in meta stability recovery delay line
    g_meta_levels : integer
    );
  port(
    --* input clock
    clk_i     : in  std_logic;
    --* input signal on the source clock domain
    ccd_din_i : in  std_logic;
    --* output signal on the destination clock domain
    ccd_din_o : out std_logic
    );
end ces_util_ccd_resync;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture a_rtl of ces_util_ccd_resync is

  signal s_din_meta : std_logic_vector(g_meta_levels-1 downto 0);

begin
  -- Safety check on input generic
  assert g_meta_levels >= 2
    report "ces_util_ccd_resync: g_meta_levels must be at least 2 to combat metastability"
    severity error;

  proc_resync : process (clk_i)
  begin
    if rising_edge(clk_i) then
      s_din_meta <= s_din_meta(s_din_meta'left-1 downto 0) & ccd_din_i;
    end if;
  end process proc_resync;
  
  ccd_din_o <= s_din_meta(g_meta_levels-1);

end a_rtl;
