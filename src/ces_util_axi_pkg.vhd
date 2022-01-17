--=============================================================================
-- Module Name : ces_util_axi_pkg
-- Library     : ces_util_lib
-- Project     : CES Utility Library
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- * Description: Data types to abstract an AXI4 data bus. The AXi4, AXI4lite
-- and AXI4stream are included.
--
-- AXI4:
-- AXI4 Signals from master to slave are grouped in t_axi4_mosi record type
-- AXI4 Signals from slave to master are grouped in t_axi4_miso record type
--
-- AXI4lite:
-- AXI4lite Signals from master to slave are grouped in t_axi4lite_mosi record type
-- AXI4lite Signals from slave to master are grouped in t_axi4lite_miso record type
--
-- AXI4stream:
-- AXI4stream Signals from master to slave are grouped in t_axi4stream_mosi record type
-- AXI4stream Signals from slave to master are grouped in t_axi4stream_miso record type
--
-- Array of busses are implemented by
-- t_axi4lite_mosi_arr and t_axi4lite_miso_arr  arrays of records
--
-- A simple ready/ack v_interface is implemented in records
-- t_ipb_mosi/t_ipb_miso
-- If no acknowledge is required, i.e. write data are always accepted and read
-- data sent back in the next clock cycle, the
-- t_ipb_miso.wack and t_ipb_miso.rack signals can be tied to '1'.
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

package ces_util_axi_pkg is

  ------------------------------------------------------------------------------
  --COMMON FUNCTION
  ------------------------------------------------------------------------------
  -- F_RESIZE_AXI: performs vector resizing trimming or adding MSBs as zeros 
  --***************************************************************************
  function f_resize_axi(a : std_logic_vector; b : integer) return std_logic_vector;
  --***************************************************************************
  -- F_RESIZE_AXI: performs vector resizing trimming or adding MSBs as zeros 
  --***************************************************************************
  function f_resize_axi(a : integer; b : integer) return std_logic_vector;

  ------------------------------------------------------------------------------
  --AXI4 SECTION START
  ------------------------------------------------------------------------------
  constant C_AXI4_ADDR_W : natural := 32;
  constant C_AXI4_DATA_W : natural := 32;
  constant C_AXI4_STB_W  : natural := C_AXI4_DATA_W/8;
  constant C_AXI4_RESP_W : natural := 2;
  constant C_AXI4_PROT_W : natural := 2;

  type t_axi4_miso is record            -- master in, slave out
    -- write address stream
    awready : std_logic;
    -- write stream
    wready  : std_logic;
    -- write response
    bresp   : std_logic_vector(C_AXI4_RESP_W-1 downto 0);
    bvalid  : std_logic;
    bid     : std_logic_vector(5 downto 0);
    -- read address stream
    arready : std_logic;
    -- read response
    rresp   : std_logic_vector(C_AXI4_RESP_W-1 downto 0);
    rdata   : std_logic_vector(C_AXI4_DATA_W-1 downto 0);
    rlast   : std_logic;
    rvalid  : std_logic;
    rid     : std_logic_vector(5 downto 0);
  end record;

  type t_axi4_mosi is record            -- master out, slave in
    -- write address stream
    awaddr  : std_logic_vector(C_AXI4_ADDR_W-1 downto 0);
    awlen   : std_logic_vector(3 downto 0);
    awsize  : std_logic_vector(2 downto 0);
    awburst : std_logic_vector(1 downto 0);
    awcache : std_logic_vector(3 downto 0);
    awprot  : std_logic_vector(2 downto 0);
    awvalid : std_logic;
    awid    : std_logic_vector(5 downto 0);
    awlock  : std_logic_vector(1 downto 0);
    awqos   : std_logic_vector(3 downto 0);
    -- write data stream
    wdata   : std_logic_vector(C_AXI4_DATA_W-1 downto 0);
    wstrb   : std_logic_vector(C_AXI4_STB_W downto 0);
    wlast   : std_logic;
    wvalid  : std_logic;
    wid     : std_logic_vector(5 downto 0);
    -- write response
    bready  : std_logic_vector(5 downto 0);
    -- read address stream
    araddr  : std_logic_vector(C_AXI4_ADDR_W-1 downto 0);
    arlen   : std_logic_vector(3 downto 0);
    arsize  : std_logic_vector(2 downto 0);
    arburst : std_logic_vector(1 downto 0);
    arcache : std_logic_vector(3 downto 0);
    arprot  : std_logic_vector(2 downto 0);
    arvalid : std_logic;
    arid    : std_logic_vector(5 downto 0);
    arlock  : std_logic_vector(1 downto 0);
    arqos   : std_logic_vector(3 downto 0);
    -- read response
    rready  : std_logic;
  end record;
  ------------------------------------------------------------------------------
  --AXI4 SECTION END
  ------------------------------------------------------------------------------  

  ------------------------------------------------------------------------------
  --AXI4LITE SECTION START
  ------------------------------------------------------------------------------
  constant C_AXI4LITE_ADDR_W : natural := 32;
  constant C_AXI4LITE_DATA_W : natural := 32;
  constant C_AXI4LITE_STB_W  : natural := C_AXI4LITE_DATA_W/8;
  constant C_AXI4LITE_RESP_W : natural := 2;
  constant C_AXI4LITE_PROT_W : natural := 2;

  type t_axi4lite_miso is record        -- master in, slave out
    -- write address stream
    awready : std_logic;
    -- write stream
    wready  : std_logic;
    -- write response
    bresp   : std_logic_vector(C_AXI4LITE_RESP_W-1 downto 0);
    bvalid  : std_logic;
    -- read address stream
    arready : std_logic;
    -- read response
    rresp   : std_logic_vector(C_AXI4LITE_RESP_W-1 downto 0);
    rdata   : std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0);
    rvalid  : std_logic;
  end record;

  type t_axi4lite_mosi is record        -- master out, slave in
    -- write address stream
    awaddr  : std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
    awvalid : std_logic;
    -- write stream
    wdata   : std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0);
    wvalid  : std_logic;
    wstrb   : std_logic_vector(C_AXI4LITE_STB_W-1 downto 0);
    ---- write response
    --wready    : std_logic;
    -- read address stream
    araddr  : std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
    arvalid : std_logic;
    -- read response
    rready  : std_logic;
    bready  : std_logic;
  end record;

  -- multi port array for axi4 records
  type t_axi4lite_miso_arr is array (integer range <>) of t_axi4lite_miso;
  type t_axi4lite_mosi_arr is array (integer range <>) of t_axi4lite_mosi;

  -- blank records
  constant C_AXI4LITE_MISO_RST : t_axi4lite_miso :=
    ('0', '0', (others => '0'), '0', '0', (others => '0'), (others => '0'), '0');

  constant C_AXI4LITE_MOSI_RST : t_axi4lite_mosi :=
    ((others => '0'), '0', (others => '0'), '0', (others => '0'),
     (others => '0'), '0', '0', '0');

  -- response values
  constant C_AXI4LITE_RESP_OKAY   : std_logic_vector(C_AXI4LITE_RESP_W-1 downto 0) := "00";
  constant C_AXI4LITE_RESP_EXOKAY : std_logic_vector(C_AXI4LITE_RESP_W-1 downto 0) := "01";
  constant C_AXI4LITE_RESP_SLVERR : std_logic_vector(C_AXI4LITE_RESP_W-1 downto 0) := "10";
  constant C_AXI4LITE_RESP_DECERR : std_logic_vector(C_AXI4LITE_RESP_W-1 downto 0) := "11";

  type t_ipb_mosi is record
    addr : std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
    wdat : std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0);
    wreq : std_logic;
    rreq : std_logic;
  end record;

  type t_ipb_miso is record
    wack : std_logic;
    rdat : std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0);
    rack : std_logic;
  end record;

  procedure p_write_axi4lite(
    address         : in  std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
    data            : in  std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0);
    clk_period      : in  time;
    signal axi_mosi : out t_axi4lite_mosi
    );

  procedure p_read_axi4lite(
    address          : in  std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
    clk_period       : in  time;
    signal axi_miso  : in  t_axi4lite_miso;
    signal axi_mosi  : out t_axi4lite_mosi;
    signal data_read : out std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0)
    );

  ------------------------------------------------------------------------------
  --AXI4LITE SECTION END
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- AXI4STREAM SECTION START
  ------------------------------------------------------------------------------
  constant C_AXI4S_MAX_TDATA_NOF_BYTES : integer := 128;
  constant C_AXI4S_MAX_TID_WIDTH       : integer := 32;
  constant C_AXI4S_MAX_TUSER_WIDTH     : integer := 32;

  type t_axi4stream_mosi is record
    tdata  : std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES*8-1 downto 0);
    tid    : std_logic_vector(C_AXI4S_MAX_TID_WIDTH-1 downto 0);
    tuser  : std_logic_vector(C_AXI4S_MAX_TUSER_WIDTH-1 downto 0);
    tkeep  : std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES-1 downto 0);
    tlast  : std_logic;
    tvalid : std_logic;
  end record;

  type t_axi4stream_miso is record
    tready    : std_logic;
    prog_full : std_logic;
  end record;

  type t_axi4stream_mosi_arr is array (natural range<>) of t_axi4stream_mosi;
  type t_axi4stream_miso_arr is array (natural range<>) of t_axi4stream_miso;

  constant C_AXI4S_MOSI_DEFAULT : t_axi4stream_mosi := (tdata  => (others => '0'),
                                                        tid    => (others => '0'),
                                                        tuser  => (others => '0'),
                                                        tkeep  => (others => '0'),
                                                        tlast  => '0',
                                                        tvalid => '0');

  constant C_AXI4S_MISO_DEFAULT : t_axi4stream_miso := (tready    => '1',
                                                        prog_full => '0');

  --* @brief Group std_logic_vector to AXI4 stream mosi type
  --* @param std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES*8-1 downto 0)
  --*   std_logic_vector(C_AXI4S_MAX_TID_WIDTH-1 downto 0)
  --* std_logic_vector(C_AXI4S_MAX_TUSER_WIDTH-1 downto 0)
  --* std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES-1 downto 0)
  --* std_logic
  --* std_logic
  --* @v_return t_axi4stream_mosi                                                                                 
  procedure axi4s_mosi_pack_to_record(
    tdata             : in  std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES*8-1 downto 0);
    tid               : in  std_logic_vector(C_AXI4S_MAX_TID_WIDTH-1 downto 0);
    tuser             : in  std_logic_vector(C_AXI4S_MAX_TUSER_WIDTH-1 downto 0);
    tkeep             : in  std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES-1 downto 0);
    tlast             : in  std_logic;
    tvalid            : in  std_logic;
    signal axi4s_mosi : out t_axi4stream_mosi);

  --* @brief Split AXI4 stream mosi type to std_logic_vector(s)  
  --* @param axi4s_mosi
  --* @v_return std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES*8-1 downto 0)
  --*   std_logic_vector(C_AXI4S_MAX_TID_WIDTH-1 downto 0)
  --* std_logic_vector(C_AXI4S_MAX_TUSER_WIDTH-1 downto 0)
  --* std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES-1 downto 0)
  --* std_logic
  --* std_logic
  procedure axi4s_mosi_unpack_to_signals(
    signal tdata  : out std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES*8-1 downto 0);
    signal tid    : out std_logic_vector(C_AXI4S_MAX_TID_WIDTH-1 downto 0);
    signal tuser  : out std_logic_vector(C_AXI4S_MAX_TUSER_WIDTH-1 downto 0);
    signal tkeep  : out std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES-1 downto 0);
    signal tlast  : out std_logic;
    signal tvalid : out std_logic;
    axi4s_mosi    : in  t_axi4stream_mosi);

  --* @brief Group std_logic to AXI4 stream miso type
  --* @param tready and prog_full
  --* @v_return t_axi4stream_miso
  procedure axi4s_miso_pack_to_record(
    tready            : in  std_logic;
    prog_full         : in  std_logic;
    signal axi4s_miso : out t_axi4stream_miso);

  --* @brief Split AXI4 stream miso type to std_logic(s)  
  --* @param axi4s_miso
  --* @v_return std_logic
  --* std_logic 
  procedure axi4s_miso_unpack_to_signals(
    signal tready    : out std_logic;
    signal prog_full : out std_logic;
    axi4s_miso       : in  t_axi4stream_miso);

--  -- type description
--  type t_axi4s_descr is record
--      tdata_nof_bytes : positive;
--      tid_width       : positive;
--      tuser_width     : positive;
--      has_tlast       : integer range 0 to 1;
--      has_tkeep       : integer range 0 to 1;
--      has_tid         : integer range 0 to 1;
--      has_tuser       : integer range 0 to 1;
--   end record;
--   
--   type t_axi4s_descr_arr is array (natural range<>) of t_axi4s_descr;  

  ------------------------------------------------------------------------------
  -- AXI4STREAM SECTION END
  ------------------------------------------------------------------------------                                                                                  

end ces_util_axi_pkg;

package body ces_util_axi_pkg is

  --***************************************************************************
  -- F_RESIZE_AXI
  --***************************************************************************   
  function f_resize_axi (a : std_logic_vector; b : integer) return std_logic_vector is
    variable v_ret : std_logic_vector(b-1 downto 0);
    variable v_int : std_logic_vector(a'length-1 downto 0) := a;
  begin
    if b <= v_int'length then
      v_ret := v_int(b-1 downto 0);
    else
      v_ret(v_int'length-1 downto 0) := v_int;
      v_ret(b-1 downto v_int'length) := (others => '0');
    end if;
    return v_ret;
  end function;
  --***************************************************************************
  -- F_RESIZE_AXI
  --***************************************************************************   
  function f_resize_axi (a : integer; b : integer) return std_logic_vector is
    variable v_ret : std_logic_vector(b-1 downto 0);
  begin
    v_ret := std_logic_vector(to_unsigned(a, b));
    return v_ret;
  end function;
  --***************************************************************************

  ------------------------------------------------------------------------------
  --AXI4 SECTION START
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  --AXI4 SECTION END
  ------------------------------------------------------------------------------ 

  ------------------------------------------------------------------------------
  --AXI4LITE SECTION START
  ------------------------------------------------------------------------------
  procedure p_write_axi4lite(
    address         : in  std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
    data            : in  std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0);
    clk_period      : in  time;
    signal axi_mosi : out t_axi4lite_mosi
    ) is
  begin
    -- start of write
    axi_mosi.bready  <= '1';
    axi_mosi.wdata   <= data;
    axi_mosi.wvalid  <= '1';  --(wrtsb)         The Master assert valid (data is valid)  (2)
    axi_mosi.awaddr  <= address;        --send write address through axi bus
    axi_mosi.awvalid <= '1';
    axi_mosi.wstrb   <= "1111";
    wait for clk_period;                --wait for processing
    axi_mosi.wvalid  <= '0';
    axi_mosi.awvalid <= '0';
    axi_mosi.wstrb   <= "0000";
  end p_write_axi4lite;


  procedure p_read_axi4lite(
    address          : in  std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
    clk_period       : in  time;
    signal axi_miso  : in  t_axi4lite_miso;
    signal axi_mosi  : out t_axi4lite_mosi;
    signal data_read : out std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0)
    ) is
  begin
    -- start of read
    axi_mosi.arvalid <= '1';
    axi_mosi.rready  <= '1';
    axi_mosi.araddr  <= address;         --send read address through axi bus
    wait until axi_miso.arready = '1';
    wait for clk_period;
    axi_mosi.arvalid <= '0' after 1 ps;
    wait until axi_miso.rvalid = '1';    --arready
    data_read        <= axi_miso.rdata;  --retrieve read data
  end p_read_axi4lite;

  --  procedure p_read_axi4lite(
  --    address          : in  std_logic_vector(C_AXI4LITE_ADDR_W-1 downto 0);
  --    clk_period       : in  time;
  --    signal data_out  : out std_logic_vector(C_AXI4LITE_DATA_W-1 downto 0);
  --    axoi             : in  t_axi4lite_miso;
  --    signal axio      : out t_axi4lite_mosi
  --    ) is
  --  begin
  --    -- start of read
  --    axio.arvalid <= '1';
  --    axio.rready  <= '1';
  --    axio.araddr  <= address;
  --    wait for clk_period;
  --    axio.arvalid <= '0';
  --    if axoi.rvalid = '1' then
  --      data_out <= axoi.rdata;
  --    end if;
  --  end p_read_axi4lite;
  ------------------------------------------------------------------------------
  --AXI4LITE SECTION END
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- AXI4STREAM SECTION START
  ------------------------------------------------------------------------------  
  procedure axi4s_mosi_pack_to_record(
    tdata             : in  std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES*8-1 downto 0);
    tid               : in  std_logic_vector(C_AXI4S_MAX_TID_WIDTH-1 downto 0);
    tuser             : in  std_logic_vector(C_AXI4S_MAX_TUSER_WIDTH-1 downto 0);
    tkeep             : in  std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES-1 downto 0);
    tlast             : in  std_logic;
    tvalid            : in  std_logic;
    signal axi4s_mosi : out t_axi4stream_mosi) is
  begin
    axi4s_mosi.tdata  <= tdata;
    axi4s_mosi.tid    <= tid;
    axi4s_mosi.tuser  <= tuser;
    axi4s_mosi.tkeep  <= tkeep;
    axi4s_mosi.tlast  <= tlast;
    axi4s_mosi.tvalid <= tvalid;
  end procedure;

  procedure axi4s_mosi_unpack_to_signals(
    signal tdata  : out std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES*8-1 downto 0);
    signal tid    : out std_logic_vector(C_AXI4S_MAX_TID_WIDTH-1 downto 0);
    signal tuser  : out std_logic_vector(C_AXI4S_MAX_TUSER_WIDTH-1 downto 0);
    signal tkeep  : out std_logic_vector(C_AXI4S_MAX_TDATA_NOF_BYTES-1 downto 0);
    signal tlast  : out std_logic;
    signal tvalid : out std_logic;
    axi4s_mosi    : in  t_axi4stream_mosi) is
  begin
    tdata  <= f_resize_axi(axi4s_mosi.tdata, tdata'length);
    tid    <= f_resize_axi(axi4s_mosi.tid, tid'length);
    tuser  <= f_resize_axi(axi4s_mosi.tuser, tuser'length);
    tkeep  <= f_resize_axi(axi4s_mosi.tkeep, tkeep'length);
    tlast  <= axi4s_mosi.tlast;
    tvalid <= axi4s_mosi.tvalid;
  end procedure;

  procedure axi4s_miso_pack_to_record(
    tready            : in  std_logic;
    prog_full         : in  std_logic;
    signal axi4s_miso : out t_axi4stream_miso) is
  begin
    axi4s_miso.tready    <= tready;
    axi4s_miso.prog_full <= prog_full;
  end procedure;

  procedure axi4s_miso_unpack_to_signals(
    signal tready    : out std_logic;
    signal prog_full : out std_logic;
    axi4s_miso       : in  t_axi4stream_miso) is
  begin
    tready    <= axi4s_miso.tready;
    prog_full <= axi4s_miso.prog_full;
  end procedure;
------------------------------------------------------------------------------
-- AXI4STREAM SECTION START
------------------------------------------------------------------------------        
end package body;
