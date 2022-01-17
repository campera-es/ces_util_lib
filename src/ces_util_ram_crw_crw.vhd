--=============================================================================
-- Module Name : ces_util_ram_crw_crw
-- Library     : ces_util_lib
-- Project     : CES Utility
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: this module is the core of the ram memory entities. It is a
-- general purpose core that can be configured as sindle or
-- true dual port memory, with differetn aspect ratio. The
-- memory content at power on can be configured via a file
-- the target device and synthesizer are important as memory inference can be 
-- device and synthesizer dependent. The default C_VENDOR, C_FAMILY and
-- C_SYNTH_TOOL are defined in the ces_util_pkg and can be defined on a 
-- per-project basis.  
-- g_simulation is disabled by default, and the initialization file is not
-- used by default. All others generics must be defined byt the user when this
-- module is instantiated, this is a safety intended feature
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
use std.textio.all;
use ieee.std_logic_textio.all;
library ces_util_lib;
use ces_util_lib.ces_util_pkg.all;

--* @brief this module is the core of the ram memory entities. It is a
--* general purpose core that can be configured as single or
--* true dual port memory, with different aspect ratio. The
--* memory content at power on can be configured via a file
--* @version 1.0.0
entity ces_util_ram_crw_crw is
  generic(
    --* PORT A latency 1: LOW performance, 2: HIGH PERFORMANCE
    g_ram_a_latency : integer;
    --* PORT A: data width
    g_ram_a_data_w  : integer;
    --* PORT A: depth
    g_ram_a_depth   : integer;
    --* PORT B latency 1: LOW performance, 2: HIGH PERFORMANCE
    g_ram_b_latency : integer;
    --* PORT B: data width
    g_ram_b_data_w  : integer;
    ----* PORT B: depth
    --g_ram_b_depth   : integer   := 256;
    --* initialization file
    g_init_file     : string    := "";
    --* simulation: 1 enabled, 0 disabled (certain models are synthesizable but 
    --  do not work in simulation, e.g. VIVADO with different aspect ratio)
    g_simulation    : integer   := 0;
    --* (vendor, family, synthesizer)
    g_vendor        : integer   := C_VENDOR;
    g_family        : integer   := C_FAMILY;
    g_synth_tool    : integer   := C_SYNTH_TOOL
    );
  port(
    --* input clock, port A
    clk_a_i     : in  std_logic;
    --* enable, port A
    ena_i       : in  std_logic := '1';
    --* input clock, port B
    clk_b_i     : in  std_logic;
    --* enable, port B
    enb_i       : in  std_logic := '1';
    --* write enable port A
    wen_a_i     : in  std_logic;
    --* write enable port B
    wen_b_i     : in  std_logic;
    --* input data on port A
    data_wr_a_i : in  std_logic_vector(g_ram_a_data_w - 1 downto 0);
    --* input data on port B
    data_wr_b_i : in  std_logic_vector(g_ram_b_data_w - 1 downto 0);
    --* address on port A
    addr_a_i    : in  std_logic_vector(f_ceil_log2(g_ram_a_depth) - 1 downto 0);
    --* address on port B
    addr_b_i    : in  std_logic_vector(f_ceil_log2(g_ram_a_depth*g_ram_a_data_w/g_ram_b_data_w) - 1 downto 0);
    --* output data on port A
    data_rd_a_o : out std_logic_vector(g_ram_a_data_w - 1 downto 0);
    --* output data on port B
    data_rd_b_o : out std_logic_vector(g_ram_b_data_w - 1 downto 0)
    );
end ces_util_ram_crw_crw;

architecture a_rtl of ces_util_ram_crw_crw is
  --`protect begin
  constant C_MINWIDTH : integer := f_min(g_ram_a_data_w, g_ram_b_data_w);
  constant C_MAXWIDTH : integer := f_max(g_ram_a_data_w, g_ram_b_data_w);
  constant C_MAXSIZE  : integer := f_max(g_ram_a_depth, g_ram_a_depth*g_ram_a_data_w/g_ram_b_data_w);
  constant C_RATIO    : integer := C_MAXWIDTH / C_MINWIDTH;
  type t_mem is array (0 to C_MAXSIZE - 1) of std_logic_vector(C_MINWIDTH - 1 downto 0);
  --   Function to initialize memory from an external file

  --    impure function f_init_ram_from_file(ram_file_name : in string) return t_mem is
  --      file my_init_file : text open read_mode is ram_file_name;
  --      variable v_ram_file_line : line;
  --      variable v_temp_ram      : std_logic_vector(C_MINWIDTH - 1 downto 0);
  --      variable v_ram           : t_mem;
  --    begin
  --      if ram_file_name /= "unused" then
  --        for i in v_ram'range loop             -- read one line every coef step
  --          readline(my_init_file, v_ram_file_line);
  --          read(v_ram_file_line, v_temp_ram);
  --          v_ram(i) := v_temp_ram;
  --        end loop;
  --        file_close(my_init_file);
  --      else
  --        v_ram := (others => (others => '0'));
  --      end if;
  --      return v_ram;
  --    end function;

  -- The folowing code either initializes the memory values to a specified file or to all zeros to match hardware

  function f_init_ram_from_file(ramfilename : in string) return t_mem is
    file ramfile           : text open read_mode is ramfilename;
    variable v_ramfileline : line;
    variable v_ram_name    : t_mem;
    variable v_bitvec      : bit_vector(C_MINWIDTH - 1 downto 0);
  begin

    readline(ramfile, v_ramfileline);

    for i in 0 to t_mem'high loop
      readline(ramfile, v_ramfileline);
      read(v_ramfileline, v_bitvec);
      v_ram_name(i) := to_stdlogicvector(v_bitvec);
      readline(ramfile, v_ramfileline);
    end loop;

    file_close(ramfile);

    return v_ram_name;
  end function;

  function f_init_from_file_or_zeroes(ramfile : string) return t_mem is
  begin
    if ramfile = g_init_file and ramfile /= "" then
      return f_init_ram_from_file(g_init_file);
    else
      return (others => (others => '0'));
    end if;
  end;

  -- Define RAM
  --signal s_mem : t_mem := f_init_from_file_or_zeroes(g_init_file);


  shared variable v_mem : t_mem := (others => (others => '0'));  --f_init_from_file_or_zeroes(g_init_file); --(others => (others => '0')); --
  signal s_mem_xil_viv  : t_mem := (others => (others => '0'));  -- := f_init_ram_from_file(g_init_file);

  --  signal s_mem : t_mem := (others => (others => '0'));

  --

  signal s_data_rd_a   : std_logic_vector(g_ram_a_data_w - 1 downto 0);
  signal s_data_rd_b   : std_logic_vector(g_ram_b_data_w - 1 downto 0);
  signal s_data_rd_a_p : std_logic_vector(g_ram_a_data_w - 1 downto 0);
  signal s_data_rd_b_p : std_logic_vector(g_ram_b_data_w - 1 downto 0);


  --Signal for Altera
  -- Use a multidimensional array to model mixed-width
  type t_word is array(C_RATIO - 1 downto 0) of std_logic_vector(C_MINWIDTH - 1 downto 0);
  type t_ram is array (0 to C_MAXSIZE - 1) of t_word;

  -- declare the RAM
  signal s_ram : t_ram;

  signal s_w1_local   : t_word;
  signal s_q1_local   : t_word;

  signal s_clk_b  : std_logic;
  signal s_clk_a  : std_logic;
  signal s_wen_a  : std_logic;
  signal s_wen_b  : std_logic;
  signal s_addr_a : std_logic_vector(addr_a_i'length-1 downto 0);
  signal s_addr_b : std_logic_vector(addr_b_i'length-1 downto 0);
  signal s_data_a : std_logic_vector(data_wr_a_i'length-1 downto 0);
  signal s_data_b : std_logic_vector(data_wr_b_i'length-1 downto 0);

begin
  --   -- check memory dimensions
  --   assert addr_a_i'length = addr_b_i'length
  --   report "common_ram_cr_cw: memory dimensions be the same on both ports"
  --   severity error;
  --   -- check memory data
  --   assert data_a_i'length = data_b_o'length
  --   report "common_ram_cr_cw: memory data sizes should be the same on both ports"
  --   severity error;

  assert g_ram_a_latency = 1 or g_ram_a_latency = 2
    report "ces_util_ram_crw_crw: latency on port A shall be only 1 or 2"
    severity failure;

  assert g_ram_b_latency = 1 or g_ram_b_latency = 2
    report "ces_util_ram_crw_crw: latency on port B shall be only 1 or 2"
    severity failure;


  gen_simulation_model : if g_simulation = 1 generate
    gen_different_ratio_a_gt_b : if (C_RATIO > 1 and g_ram_a_data_w > g_ram_b_data_w) generate  -- READ FIRST
      -- write port
      proc_port_a : process(clk_a_i)
      begin
        if rising_edge(clk_a_i) then
          if (ena_i = '1') then
            for i in 0 to C_RATIO - 1 loop
              s_data_rd_a((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= v_mem(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
            end loop;

            if wen_a_i = '1' then
              for i in 0 to C_RATIO - 1 loop
                v_mem(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) := data_wr_a_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
              end loop;
            end if;
          end if;
        end if;
      end process proc_port_a;

      -- read port
      proc_port_b : process(clk_b_i)
      begin
        if rising_edge(clk_b_i) then
          if (enb_i = '1') then
            s_data_rd_b <= v_mem(to_integer(unsigned(addr_b_i)));
            if wen_b_i = '1' then
              v_mem(to_integer(unsigned(addr_b_i))) := data_wr_b_i;
            end if;
          end if;
        end if;
      end process proc_port_b;

    end generate gen_different_ratio_a_gt_b;

    gen_different_ratio_b_gt_a : if (C_RATIO > 1 and g_ram_b_data_w > g_ram_a_data_w) generate
      -- write port
      proc_port_a : process(clk_a_i)
      begin
        if rising_edge(clk_a_i) then
          if (ena_i = '1') then
            s_data_rd_a <= v_mem(to_integer(unsigned(addr_a_i)));
            if wen_a_i = '1' then
              v_mem(to_integer(unsigned(addr_a_i))) := data_wr_a_i;
            end if;
          end if;
        end if;
      end process proc_port_a;

      -- read port
      proc_port_b : process(clk_b_i)
      begin
        if rising_edge(clk_b_i) then
          if (enb_i = '1') then
            for i in 0 to C_RATIO - 1 loop
              s_data_rd_b((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= v_mem(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
            end loop;
            if wen_b_i = '1' then
              for i in 0 to C_RATIO - 1 loop
                v_mem(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) := data_wr_b_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
              end loop;
            end if;
          end if;
        end if;
      end process proc_port_b;

    end generate gen_different_ratio_b_gt_a;

    gen_equal_ratio : if C_RATIO = 1 generate
      -- write port
      proc_port_a : process(clk_a_i)
      begin
        if rising_edge(clk_a_i) then
          if ena_i = '1' then
            s_data_rd_a <= v_mem(to_integer(unsigned(addr_a_i)));
            if wen_a_i = '1' then
              v_mem(to_integer(unsigned(addr_a_i))) := data_wr_a_i;
            end if;
          end if;
        end if;
      end process proc_port_a;

      -- read port
      proc_port_b : process(clk_b_i)
      begin
        if rising_edge(clk_b_i) then
          if (enb_i = '1') then
            s_data_rd_b <= v_mem(to_integer(unsigned(addr_b_i)));
            if wen_b_i = '1' then
              v_mem(to_integer(unsigned(addr_b_i))) := data_wr_b_i;
            end if;
          end if;
        end if;
      end process proc_port_b;

    end generate gen_equal_ratio;
  end generate gen_simulation_model;


  gen_synthesis : if g_simulation = 0 generate
    --###########################################################################
    -- ISE
    --###########################################################################
    gen_xilinx_ise : if g_vendor = C_XILINX and g_synth_tool = C_ISE generate
      gen_different_ratio_a_gt_b : if (C_RATIO > 1 and g_ram_a_data_w > g_ram_b_data_w) generate  -- READ FIRST
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if (ena_i = '1') then
              for i in 0 to C_RATIO - 1 loop
                s_data_rd_a((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= v_mem(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
              end loop;

              if wen_a_i = '1' then
                for i in 0 to C_RATIO - 1 loop
                  v_mem(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) := data_wr_a_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
                end loop;
              end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if (enb_i = '1') then
              s_data_rd_b <= v_mem(to_integer(unsigned(addr_b_i)));
              if wen_b_i = '1' then
                v_mem(to_integer(unsigned(addr_b_i))) := data_wr_b_i;
              end if;
            end if;
          end if;
        end process proc_port_b;

      end generate gen_different_ratio_a_gt_b;

      gen_different_ratio_b_gt_a : if (C_RATIO > 1 and g_ram_b_data_w > g_ram_a_data_w) generate
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if (ena_i = '1') then
              s_data_rd_a <= v_mem(to_integer(unsigned(addr_a_i)));
              if wen_a_i = '1' then
                v_mem(to_integer(unsigned(addr_a_i))) := data_wr_a_i;
              end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if (enb_i = '1') then
              for i in 0 to C_RATIO - 1 loop
                s_data_rd_b((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= v_mem(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
              end loop;
              if wen_b_i = '1' then
                for i in 0 to C_RATIO - 1 loop
                  v_mem(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) := data_wr_b_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
                end loop;
              end if;
            end if;
          end if;
        end process proc_port_b;

      end generate gen_different_ratio_b_gt_a;

      gen_equal_ratio : if C_RATIO = 1 generate
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if ena_i = '1' then
              s_data_rd_a <= v_mem(to_integer(unsigned(addr_a_i)));
              if wen_a_i = '1' then
                v_mem(to_integer(unsigned(addr_a_i))) := data_wr_a_i;
              end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if (enb_i = '1') then
              s_data_rd_b <= v_mem(to_integer(unsigned(addr_b_i)));
              if wen_b_i = '1' then
                v_mem(to_integer(unsigned(addr_b_i))) := data_wr_b_i;
              end if;
            end if;
          end if;
        end process proc_port_b;

      end generate gen_equal_ratio;
    end generate gen_xilinx_ise;

    --###########################################################################
    -- VIVADO
    --###########################################################################
    gen_xilinx_vivado : if g_vendor = C_XILINX and g_synth_tool = C_VIVADO generate
      gen_different_ratio_a_gt_b : if (C_RATIO > 1 and g_ram_a_data_w > g_ram_b_data_w) generate  -- READ FIRST

        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if (ena_i = '1') then
              for i in 0 to C_RATIO - 1 loop
                s_data_rd_a((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= s_mem_xil_viv(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
              end loop;

              if wen_a_i = '1' then
                for i in 0 to C_RATIO - 1 loop
                  s_mem_xil_viv(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) <= data_wr_a_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
                end loop;
              end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if (enb_i = '1') then
              s_data_rd_b <= s_mem_xil_viv(to_integer(unsigned(addr_b_i)));
              if wen_b_i = '1' then
                s_mem_xil_viv(to_integer(unsigned(addr_b_i))) <= data_wr_b_i;
              end if;
            end if;
          end if;
        end process proc_port_b;

      end generate gen_different_ratio_a_gt_b;

      gen_different_ratio_b_gt_a : if (C_RATIO > 1 and g_ram_b_data_w > g_ram_a_data_w) generate
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if (ena_i = '1') then
              s_data_rd_a <= s_mem_xil_viv(to_integer(unsigned(addr_a_i)));
              if wen_a_i = '1' then
                s_mem_xil_viv(to_integer(unsigned(addr_a_i))) <= data_wr_a_i;
              end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if (enb_i = '1') then
              for i in 0 to C_RATIO - 1 loop
                s_data_rd_b((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= s_mem_xil_viv(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
              end loop;
              if wen_b_i = '1' then
                for i in 0 to C_RATIO - 1 loop
                  s_mem_xil_viv(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) <= data_wr_b_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
                end loop;
              end if;
            end if;
          end if;
        end process proc_port_b;

      end generate gen_different_ratio_b_gt_a;

      gen_equal_ratio : if C_RATIO = 1 generate
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if ena_i = '1' then
              s_data_rd_a <= v_mem(to_integer(unsigned(addr_a_i)));
              if wen_a_i = '1' then
                v_mem(to_integer(unsigned(addr_a_i))) := data_wr_a_i;
              end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if (enb_i = '1') then
              s_data_rd_b <= v_mem(to_integer(unsigned(addr_b_i)));
              if wen_b_i = '1' then
                v_mem(to_integer(unsigned(addr_b_i))) := data_wr_b_i;
              end if;
            end if;
          end if;
        end process proc_port_b;

      end generate gen_equal_ratio;
    end generate gen_xilinx_vivado;
    --###########################################################################
    -- ALTERA
    --###########################################################################
    gen_altera : if g_vendor = C_ALTERA generate
      gen_different_ratio_a_gt_b : if (C_RATIO > 1 and g_ram_a_data_w > g_ram_b_data_w) generate
        -- Re-organize the write data to match the RAM word type
        unpack : for i in 0 to C_RATIO - 1 generate
          s_w1_local(i) <= data_wr_a_i(g_ram_b_data_w*(i+1) - 1 downto g_ram_b_data_w*i);
        end generate unpack;

        -- Port A
        process(clk_a_i)
        begin
          if (rising_edge(clk_a_i)) then
            if (wen_a_i = '1') then
              s_ram(to_integer(unsigned(addr_a_i))) <= s_w1_local;
            end if;
          end if;
        end process;

        port_b_out_reg : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            s_data_rd_b <= s_ram(to_integer(unsigned(addr_b_i)) / C_RATIO)(to_integer(unsigned(addr_b_i)) mod C_RATIO);
          end if;
        end process;  -- port_b_out_reg

      end generate gen_different_ratio_a_gt_b;


      gen_different_ratio_b_gt_a : if (C_RATIO > 1 and g_ram_b_data_w > g_ram_a_data_w) generate
        -- Re-organize the write data to match the RAM word type
        unpack : for i in 0 to C_RATIO - 1 generate
          s_data_rd_b(g_ram_a_data_w*(i+1) - 1 downto g_ram_a_data_w*i) <= s_q1_local(i);
        end generate unpack;

        --port A
        process(clk_a_i)
        begin
          if(rising_edge(clk_a_i)) then
            if(wen_a_i = '1') then
              s_ram(to_integer(unsigned(addr_a_i)) / C_RATIO)(to_integer(unsigned(addr_a_i)) mod C_RATIO) <= data_wr_a_i;
            end if;
          end if;
        end process;

        port_b_out_reg : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            s_q1_local <= s_ram(to_integer(unsigned(addr_b_i)));
          end if;
        end process;  -- port_b_out_reg

      end generate gen_different_ratio_b_gt_a;



      gen_equal_ratio : if C_RATIO = 1 generate

        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if ena_i = '1' then
              if wen_a_i = '1' then
                v_mem(to_integer(unsigned(addr_a_i))) := data_wr_a_i;
              end if;
            end if;
          end if;
        end process proc_port_a;

        proc_port_a_read : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            s_data_rd_a <= v_mem(to_integer(unsigned(addr_a_i)));
          end if;
        end process proc_port_a_read;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if (enb_i = '1') then
              if wen_b_i = '1' then
                v_mem(to_integer(unsigned(addr_b_i))) := data_wr_b_i;
              end if;
            end if;
          end if;
        end process proc_port_b;

        -- read port
        proc_port_b_read : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            s_data_rd_b <= v_mem(to_integer(unsigned(addr_b_i)));
          end if;
        end process proc_port_b_read;

      end generate gen_equal_ratio;
    end generate gen_altera;

    gen_microsemi : if g_vendor = C_MICROSEMI generate
      type t_mem_array is array(0 to C_MAXSIZE - 1) of std_logic_vector(C_MINWIDTH - 1 downto 0);
      signal s_mem_m      : t_mem_array;
      --    attribute syn_ramstyle : string;
      --    attribute syn_ramstyle of mem : signal is "no_rw_check" ;
      signal s_addr_a_reg : std_logic_vector(f_ceil_log2(g_ram_a_depth)-1 downto 0);
      signal s_addr_b_reg : std_logic_vector(f_ceil_log2(g_ram_a_depth*g_ram_a_data_w/g_ram_b_data_w)-1 downto 0);
    begin


      gen_different_ratio_a_gt_b : if (C_RATIO > 1 and g_ram_a_data_w > g_ram_b_data_w) generate
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if wen_a_i = '1' then
              for i in 0 to C_RATIO - 1 loop
                --              s_mem(to_integer(unsigned(addr_a_i & std_logic_vector(to_unsigned(i, ceil_log2(C_RATIO))))))
                s_mem_m(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) <= data_wr_a_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
              end loop;
            --                    end if;
            else
              --          elsif ren_a_i = '1' then
              for i in 0 to C_RATIO - 1 loop
                s_data_rd_a((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= s_mem_m(to_integer(unsigned(addr_a_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
              end loop;
            --          end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            -- if wen_b_i = '1' then
            -- s_mem_m(to_integer(unsigned(addr_b_i))) <= data_wr_b_i;

            -- else
            s_data_rd_b <= s_mem_m(to_integer(unsigned(addr_b_i)));

          --          end if;
          end if;
        end process proc_port_b;

      end generate gen_different_ratio_a_gt_b;

      gen_different_ratio_b_gt_a : if (C_RATIO > 1 and g_ram_b_data_w > g_ram_a_data_w) generate
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if wen_a_i = '1' then
              s_mem_m(to_integer(unsigned(addr_a_i))) <= data_wr_a_i;

            else
              s_data_rd_a <= s_mem_m(to_integer(unsigned(addr_a_i)));

            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            -- if wen_b_i = '1' then
            -- for i in 0 to C_RATIO - 1 loop
            -- s_mem_m(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO)))) <= data_wr_b_i((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH);
            -- end loop;
            -- --                 end if;
            -- else
            --          elsif ren_b_i = '1' then
            for i in 0 to C_RATIO - 1 loop
              s_data_rd_b((i + 1) * C_MINWIDTH - 1 downto i * C_MINWIDTH) <= s_mem_m(to_integer(unsigned(addr_b_i) & to_unsigned(i, f_ceil_log2(C_RATIO))));
            end loop;
          --          end if;
          -- end if;
          end if;
        end process proc_port_b;

      end generate gen_different_ratio_b_gt_a;

      gen_equal_ratio : if C_RATIO = 1 generate
        -- write port
        proc_port_a : process(clk_a_i)
        begin
          if rising_edge(clk_a_i) then
            if wen_a_i = '1' then
              s_mem_m(to_integer(unsigned(addr_a_i))) <= data_wr_a_i;
            --                    end if;
            else
              --          elsif ren_a_i = '1' then
              s_data_rd_a <= s_mem_m(to_integer(unsigned(addr_a_i)));
            --          end if;
            end if;
          end if;
        end process proc_port_a;

        -- read port
        proc_port_b : process(clk_b_i)
        begin
          if rising_edge(clk_b_i) then
            if wen_b_i = '1' then
              s_mem_m(to_integer(unsigned(addr_b_i))) <= data_wr_b_i;
            --                    end if;
            else
              --          elsif ren_b_i = '1' then
              s_data_rd_b <= s_mem_m(to_integer(unsigned(addr_b_i)));
            --          end if;
            end if;
          end if;
        end process proc_port_b;

      end generate gen_equal_ratio;
    end generate gen_microsemi;
  end generate gen_synthesis;

  -- output assignments
  gen_out_reg_a_ena : if g_ram_a_latency = 2 and g_synth_tool = C_VIVADO generate
    proc_out_reg_a : process(clk_a_i)
    begin
      if rising_edge(clk_a_i) then
        if ena_i = '1' then
          data_rd_a_o <= s_data_rd_a;
        end if;
      end if;
    end process proc_out_reg_a;
  end generate gen_out_reg_a_ena;
  
    gen_out_reg_a : if g_ram_a_latency = 2 and g_synth_tool /= C_VIVADO generate
    proc_out_reg_a : process(clk_a_i)
    begin
      if rising_edge(clk_a_i) then
        data_rd_a_o <= s_data_rd_a;
      end if;
    end process proc_out_reg_a;
  end generate gen_out_reg_a;
  
  gen_out_wire_a : if g_ram_a_latency /= 2 generate
    data_rd_a_o <= s_data_rd_a;
  end generate gen_out_wire_a;

  gen_out_reg_b_ena : if g_ram_b_latency = 2 and g_synth_tool = C_VIVADO generate
    proc_out_reg_b : process(clk_b_i)
    begin
      if rising_edge(clk_b_i) then
        if enb_i = '1' then
          data_rd_b_o <= s_data_rd_b;
        end if;
      end if;
    end process proc_out_reg_b;
  end generate gen_out_reg_b_ena;
  
  gen_out_reg_b : if g_ram_b_latency = 2 and g_synth_tool /= C_VIVADO generate
    proc_out_reg_b : process(clk_b_i)
    begin
      if rising_edge(clk_b_i) then
        data_rd_b_o <= s_data_rd_b;
      end if;
    end process proc_out_reg_b;
  end generate gen_out_reg_b;
  gen_out_wire_b : if g_ram_b_latency /= 2 generate
    data_rd_b_o <= s_data_rd_b;
  end generate gen_out_wire_b;
--`protect end
end architecture a_rtl;
