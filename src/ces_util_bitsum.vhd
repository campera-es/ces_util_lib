--=============================================================================
-- Module Name : ces_util_bitsum
-- Library     : ces_util_lib
-- Project     : CES Utility Library
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: Bit summation (or in other words counting the "1"s) module for
-- the new samples implemented as an adder tree.
-- At the first stage g_nof_first_stage_chunk wide chunks of the input are processed,
-- then the results are added together with a pipelined adder tree
-- Except the first stage, are two-input
-- Latency is configuration dependent
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

--* @brief Bit summation (or in other words counting the "1"s) module for
--* the new samples implemented as an adder tree.
--* At the first stage g_nof_first_stage_chunk wide chunks of the input are processed,
--* then the results are added together with a pipelined adder tree
--* Except the first stage, adders are two-input
--* Latency is configuration dependent 
entity ces_util_bitsum is
  generic(
    --* input data width
    g_din_w   : integer;
    --* g_nof_first_stage_chunk wide chunks of the input are processed at first stage
    g_nof_first_stage_chunk : integer
    );
  port(
    --* input clock
    clk_i    : in  std_logic;
    --* data valid in
    dv_i     : in  std_logic;
    --* input data
    din_i    : in  std_logic_vector(g_din_w-1 downto 0);
    --* data valid out
    dv_o     : out std_logic;
    --* output bitsum
    bitsum_o : out std_logic_vector(f_ceil_log2(g_din_w)-1 downto 0)
    );
end ces_util_bitsum;

architecture a_rtl of ces_util_bitsum is
  --`protect begin
  constant C_NOF_FIRST_STAGE_ADDERS : integer := f_max(2, f_div_ceil_2pwr(g_din_w, g_nof_first_stage_chunk));
  constant C_NOF_STAGES  : integer := f_get_bitsum_stages(g_din_w, g_nof_first_stage_chunk);
  
  type t_array_1stage is array (C_NOF_FIRST_STAGE_ADDERS-1 downto 0) of std_logic_vector(f_ceil_log2(g_din_w)-1 downto 0);
  type t_array_cnt_stages is array (C_NOF_STAGES-1 downto 0) of t_array_1stage;
  
  signal s_one_cnt : t_array_cnt_stages;
  
  signal s_dv      : std_logic_vector(0 to 1);
  
begin
  
  s_dv(0) <= dv_i;
  
  proc_dv : process(clk_i)
  begin
    if rising_edge(clk_i) then
      s_dv(1) <= s_dv(0);
      dv_o <= s_dv(1);--dv_o generated this way may be 1 delta-time early than the real output
    end if;
  end process proc_dv;
  
  
  
  
  -- bit sum for g_din_w wide input
  -- output is f_ceil_log2(g_din_w) bit wide
  -- at the first stage input is partitioned into ADDER_INS bit wide parts
  -- and these are summed.
  -- all other stages sum two outputs from the previous stage
  gen_1cnt_l0 : for k in 0 to C_NOF_STAGES-1 generate
    
    gen_1cnt_0 : if (k = 0) generate
      proc_count : process(clk_i)
        variable v_cntr_regs : t_array_1stage;
      begin
        if rising_edge(clk_i) then
          for IR in 0 to C_NOF_FIRST_STAGE_ADDERS-1 loop
            v_cntr_regs(IR) := (f_ceil_log2(g_din_w)-1 downto 0 => '0');
          end loop;
          for IB in 0 to g_din_w-1 loop
            v_cntr_regs(IB/g_nof_first_stage_chunk) := std_logic_vector(unsigned(v_cntr_regs(IB/g_nof_first_stage_chunk)) + f_sl2int(din_i(IB)));
          end loop;
          for IR in 0 to C_NOF_FIRST_STAGE_ADDERS-1 loop
            s_one_cnt(0)(IR) <= v_cntr_regs(IR);
          end loop;
        end if;
      end process proc_count;
    end generate gen_1cnt_0;
    
    gen_1cnt_last : if ((k = (C_NOF_STAGES-1)) and (k /= 0)) generate
      proc_last_sum : process(clk_i)
      begin
        if rising_edge(clk_i) then
          s_one_cnt(k)(0) <= std_logic_vector(unsigned(s_one_cnt(k-1)(0)) + unsigned(s_one_cnt(k-1)(1)));
        end if;
      end process proc_last_sum;
    end generate gen_1cnt_last;
    
    gen_1cnt_others : if ((k /= 0) and (k /= (C_NOF_STAGES-1))) generate
      proc_sum : process(clk_i)
      begin
        if rising_edge(clk_i) then
          for IR in 0 to f_div_ceil(C_NOF_FIRST_STAGE_ADDERS, (2**k))-1 loop
            s_one_cnt(k)(IR) <= std_logic_vector(unsigned(s_one_cnt(k-1)(2*IR)) + unsigned(s_one_cnt(k-1)(2*IR+1)));
          end loop;
        end if;
      end process proc_sum;
    end generate gen_1cnt_others;
    
  end generate;
  
  bitsum_o <= s_one_cnt(C_NOF_STAGES-1)(0);
  --`protect end
end a_rtl;
