-------------------------------------------------------------------------------
-- Module Name   : ces_util_delay_var
-- Library                 : ces_util_lib
-- Project       : CES UTILITY
-- Company       : Campera Electronic Systems Srl
-- Author        : A.Campera
-------------------------------------------------------------------------------
-- Description: Variable delay for std_logic_vector signals. 
--              Shift register, memory or cimple counter (for pulses) implementation
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
--* @version 1.1.2
entity ces_util_delay_var is
  generic(
    --* Max delay can be different from a power of 2
    g_delay_max   : natural;
    --* Width of data to delay
    g_data_w      : natural;
    --* define the internal architecture: "srl" shift registers, "mem" memory,
    --* "pulse" specialized for pulse delay, with a counter. the delay should be
    --* lower than the pulses distances, since a pulse on input resets the count
    g_arch_type   : integer;
    --* input pulse active level, used only in "pulse" mode
    g_pulse_level : integer
    );
  port(
    --* input clock
    clk_i   : in  std_logic;
    --* input reset
    rst_n_i   : in  std_logic;
    --* input data valid
    dv_i    : in  std_logic;
    --* input data
    din_i   : in  std_logic_vector(g_data_w - 1 downto 0);
    --* variable delay input port
    delay_i : in  std_logic_vector(f_ceil_log2(g_delay_max) - 1 downto 0);
    --* output data valid
    dv_o    : out std_logic;
    --* output delayed data
    dout_o  : out std_logic_vector(g_data_w - 1 downto 0)
    );
end ces_util_delay_var;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture a_rtl of ces_util_delay_var is
begin
  -- Check that the delay is non-negative
  assert (g_delay_max > 0) report "Max delay must be positive" severity error;
  
  -- in case of unitary delay a single register is instantiated
  gen_unit_delay : if g_delay_max = 1 generate
    proc_unit_delay : process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_n_i = '0') then
          dout_o <= (dout_o'range => '0');
        else
          if (dv_i = '1') then
            dout_o <= din_i;
          end if;
        end if;
      end if;
    end process proc_unit_delay;
  end generate gen_unit_delay;
  
  -- delay greater than one
  gen_delay : if g_delay_max > 1 generate
    -------------------------------------------------------------------------------
    -- Comments: memory delay architecture
    -------------------------------------------------------------------------------
    gen_mem_arch : if (g_arch_type = C_CES_MEM) generate
      constant C_LOG_DELAY : integer := f_ceil_log2(g_delay_max);
      constant C_DIN_WIDTH : natural := din_i'length;
      constant C_MEM_WIDTH : natural := din_i'length + 1;
     
      signal s_raddr   : unsigned(C_LOG_DELAY - 1 downto 0) := (others => '0');
      -- integer range 0 to delay-1;
      signal s_waddr   : unsigned(C_LOG_DELAY - 1 downto 0) := (others => '0');
      signal s_mem_in  : std_logic_vector(C_MEM_WIDTH - 1 downto 0);
      signal s_mem_out : std_logic_vector(C_MEM_WIDTH - 1 downto 0);
      signal s_delay   : natural range 0 to g_delay_max;
      begin
      
      -- Check that the delay is non-negative
      assert (g_delay_max > 0) report "Max delay must be positive" severity error;
      assert (s_delay <= g_delay_max) report "Delay in must smaller than max delay" severity error;
      
      s_mem_in <= dv_i & din_i;
      dv_o     <= s_mem_out(C_MEM_WIDTH - 1);
      dout_o   <= s_mem_out(C_DIN_WIDTH - 1 downto 0);
      
      inst_ces_util_ram_r_w : entity ces_util_lib.ces_util_ram_r_w
      generic map(
          g_ram_latency => 1,
          g_ram_data_w  => C_MEM_WIDTH,
          g_ram_depth   => g_delay_max
        )
      port map(
        clk_i     => clk_i,
        wen_i     => '1',
        wr_addr_i => std_logic_vector(s_waddr),
        wr_dat_i  => s_mem_in,
        rd_addr_i => std_logic_vector(s_raddr),
        rd_dat_o  => s_mem_out
        );
      
      proc_mem_delay : process(clk_i)
      begin
        if rising_edge(clk_i) then
          if dv_i = '1' then
            s_delay <= f_slv2int(delay_i);
            if (s_delay > 0) then
              if s_waddr = f_slv2int(delay_i) then
                s_waddr <= to_unsigned(0, C_LOG_DELAY);
                s_raddr <= to_unsigned(1, C_LOG_DELAY);
              else
                s_waddr <= s_waddr + 1;
                if s_waddr = f_slv2int(delay_i) - 1 then
                  s_raddr <= to_unsigned(0, C_LOG_DELAY);
                else
                  s_raddr <= s_waddr + C_TWO;
                end if;
              end if;
            end if;
          end if;
        end if;
      end process proc_mem_delay;
      
    end generate gen_mem_arch;
    
    ------------------------------------------------------------------------------
    -- Comments: srl delay architecture
    -------------------------------------------------------------------------------
    gen_srl_arch : if (g_arch_type = C_CES_SRL) generate
      
      -- srl architecture signals
      type t_mem_srl is array (0 to g_delay_max) of std_logic_vector(din_i'range);
      type t_dv_srl is array (0 to g_delay_max) of std_logic;
      signal s_mem_ary_srl : t_mem_srl;
      signal s_dv_ary_srl  : t_dv_srl := (others => '0');
      
      begin
      
      -- Check that the delay is non-negative
      assert (g_delay_max > 0) report "Max delay must be positive" severity error;
      assert (f_slv2int(delay_i) <= g_delay_max) report "Delay in must smaller than max delay" severity error;
      
      ------------------------------------------------------------------------------
      -- Comments: srl delay architecture
      -------------------------------------------------------------------------------
      
      --      gen_regs : if g_use_primitive = 0 generate
      proc_srl_delay : process(clk_i)
      begin
        if rising_edge(clk_i) then
          if (rst_n_i = '0') then
            s_mem_ary_srl <= (others => (s_mem_ary_srl(0)'range => '0'));
            s_dv_ary_srl  <= (others => '0');
          else
		  if dv_i = '1' then
            s_mem_ary_srl(0) <= din_i;
            s_dv_ary_srl(0)  <= dv_i;
            loop_reg : for i in 1 to g_delay_max loop
              s_mem_ary_srl(i) <= s_mem_ary_srl(i - 1);
              s_dv_ary_srl(i)  <= s_dv_ary_srl(i - 1);
            end loop loop_reg;
            if f_slv2int(delay_i) = 0 then
              dout_o <= (others => '0');
              dv_o   <= '0';
            elsif f_slv2int(delay_i) = 1 then
              dout_o <= din_i;
              dv_o   <= dv_i;
            elsif f_slv2int(delay_i) <= g_delay_max then
              dout_o <= s_mem_ary_srl(f_slv2int(delay_i) - 2);
              dv_o   <= s_dv_ary_srl(f_slv2int(delay_i) - 2);
            end if;
          end if;
        end if;
      end if;
      end process proc_srl_delay;
      
      --      end generate gen_regs;
      
      -- SRL instantiation
      --      gen_primitive : if g_use_primitive = 1 generate
      --        type t_array_srl_depth_by_width is array (C_SRL_DEPTH - 1 downto 0) of std_logic_vector(din_i'range);
      --        type t_array_numsrl_by_srl is array (C_NUM_SRL - 1 downto 0) of t_array_srl_depth_by_width;
      --        signal s_delay_line : t_array_numsrl_by_srl;
      --        begin
      --        -- generates WIDTH bit wide, NUM_SRL*SRL_DEPTH deep shift register array
      --        -- with one addressable output per SRL
      --        
      --        gen_srls : for i in 0 to C_NUM_SRL - 1 generate
      --          gen_stage_0 : if (i = 0) generate
      --            proc_srl_0 : process(clk_i)
      --            begin
      --              if rising_edge(clk_i) then
      --                if (ce_i = '1') then
      --                  s_delay_line(i)(0) <= din_i;
      --                  for j in 1 to C_SRL_DEPTH - 1 loop
      --                    s_delay_line(i)(j) <= s_delay_line(i)(j - 1);
      --                  end loop;
      --                end if;
      --              end if;
      --            end process proc_srl_0;
      --          end generate gen_stage_0;
      --          
      --          gen_stage_n : if (i /= 0) generate
      --            proc_srl : process(clk_i)
      --            begin
      --              if rising_edge(clk_i) then
      --                if (ce_i = '1') then
      --                  s_delay_line(i)(0) <= s_delay_line(i - 1)(C_SRL_DEPTH - 1);
      --                  for j in 1 to C_SRL_DEPTH - 1 loop
      --                    s_delay_line(i)(j) <= s_delay_line(i)(j - 1);
      --                  end loop;
      --                end if;
      --              end if;
      --            end process proc_srl;
      --          end generate gen_stage_n;
      --        end generate gen_srls; 
      --        
      --        dout_o <= s_delay_line(C_NUM_SRL - 1)(C_SRL_ADDR - 1);
      --        
      --      end generate gen_primitive;
      
    end generate gen_srl_arch;
    
    -------------------------------------------------------------------------------
    -- Comments: pulse delay architecture
    -------------------------------------------------------------------------------
    gen_pulse_arch : if (g_arch_type = C_CES_PULSE) generate
      constant C_LOG_DELAY : integer := f_ceil_log2(g_delay_max);
      
      -- pulse architecture signals
      signal s_pulse_cnt : unsigned(C_LOG_DELAY - 1 downto 0) := (others => '0');
      -- this signal force the cou nter to start after the first sof received
      signal s_cnt_ena   : std_logic;
      begin
      
      -- Check that the delay is non-negative
      assert (g_delay_max > 0) report "Max delay must be positive" severity error;
      assert (f_slv2int(delay_i) <= g_delay_max) report "Delay in must smaller than max delay" severity error;
      assert g_data_w = 1
      report "pulse delay makes sense only with std_logic signals"
      severity error;
      -------------------------------------------------------------------------------
      -- Comments: pulse delay architecture
      -------------------------------------------------------------------------------
      
      proc_cnt : process(clk_i)
      begin
        if rising_edge(clk_i) then
          if (rst_n_i = '0') then
            dout_o    <= (dout_o'range => '0');
            s_cnt_ena <= '0';
          else
            if dv_i = '1' then
              if din_i(0) = f_int2sl(g_pulse_level) then
                s_cnt_ena <= '1';
              end if;
              if din_i(0) = f_int2sl(g_pulse_level) then
                s_pulse_cnt <= to_unsigned(1, s_pulse_cnt'length);
              elsif s_pulse_cnt = f_slv2int(delay_i) - 1 then
                s_pulse_cnt <= to_unsigned(0, s_pulse_cnt'length);
                dout_o(0)   <= f_int2sl(g_pulse_level);
                s_cnt_ena   <= '0';
              elsif s_cnt_ena = '1' then
                s_pulse_cnt <= s_pulse_cnt + 1;
                dout_o(0)   <= not f_int2sl(g_pulse_level);
              else
                s_pulse_cnt <= s_pulse_cnt;
                dout_o(0)   <= not f_int2sl(g_pulse_level);
              end if;
            end if;
          end if;
        end if;
      end process proc_cnt;
      
    end generate gen_pulse_arch;
    
  end generate gen_delay;
  
end architecture a_rtl;
