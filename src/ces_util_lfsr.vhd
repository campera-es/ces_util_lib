--=============================================================================
-- Module Name : ces_util_lfsr
-- Library     : ces_util_lib
-- Project     : CES UTILITY Library
-- Company     : Campera Electronic Systems Srl
-- Author      : A.Campera
-------------------------------------------------------------------------------
-- Description: random noise generator
-- The xorshift random number generator produces a sequence of 2^g_data_w -1
-- by making a xor of a computer word with a shifted version of itself.
-- Computing such xorshift opeations for various shifts and arguments provides
-- extremely fast and simple RNGs.
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

-------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
--* @brief random noise generator
--* The xorshift random number generator produces a sequence of 2^g_data_w -1
--* by making a xor of a computer word with a shifted version of itself.
--* Computing such xorshift opeations for various shifts and arguments provides
--* extremely fast and simple RNGs.
entity ces_util_lfsr is
  generic(
    --* data width
    g_data_w : integer := 32
    );
  port(
    clk_i   : in  std_logic;                                --* input clock
    rst_n_i : in  std_logic;                                --* input reset
    load_i  : in  std_logic;                                --* load
    seed_i  : in  std_logic_vector(g_data_w - 1 downto 0);  --* seed
    rng_o   : out std_logic_vector(g_data_w - 1 downto 0)   --* random output
    );
end ces_util_lfsr;

architecture a_rtl of ces_util_lfsr is

  --function for Linear Feedbakc Shift Register.

  function f_lfsr(random : std_logic_vector) return std_logic is
    variable v_xor_out : std_logic                                  := '0';
    variable v_rand    : std_logic_vector(random'length-1 downto 0) := random;
  begin
    if(v_rand'length = 3) then          --3
      v_xor_out := v_rand(2) xor v_rand(1);
    elsif(v_rand'length = 4) then       --4
      v_xor_out := v_rand(3) xor v_rand(2);
    elsif(v_rand'length = 5) then       --5
      v_xor_out := v_rand(4) xor v_rand(2);
    elsif(v_rand'length = 6) then       --6
      v_xor_out := v_rand(5) xor v_rand(4);
    elsif(v_rand'length = 7) then       --7
      v_xor_out := v_rand(6) xor v_rand(5);
    elsif(v_rand'length = 8) then       --8
      v_xor_out := v_rand(7) xor v_rand(5) xor v_rand(4) xor v_rand(3);
    elsif(v_rand'length = 9) then       --9
      v_xor_out := v_rand(8) xor v_rand(4);
    elsif(v_rand'length = 10)then       --10
      v_xor_out := v_rand(9) xor v_rand(6);
    elsif(v_rand'length = 11) then      --11
      v_xor_out := v_rand(10) xor v_rand(8);
    elsif(v_rand'length = 12) then      --12
      v_xor_out := v_rand(11) xor v_rand(5) xor v_rand(3) xor v_rand(0);
    elsif(v_rand'length = 13) then      --13
      v_xor_out := v_rand(12) xor v_rand(3) xor v_rand(2) xor v_rand(0);
    elsif(v_rand'length = 14) then      --14
      v_xor_out := v_rand(13) xor v_rand(4) xor v_rand(2) xor v_rand(0);
    elsif(v_rand'length = 15) then      --15
      v_xor_out := v_rand(14) xor v_rand(13);
    elsif(v_rand'length = 16) then      --16
      v_xor_out := v_rand(15) xor v_rand(14) xor v_rand(12) xor v_rand(3);
    elsif(v_rand'length = 17) then      --17
      v_xor_out := v_rand(16) xor v_rand(13);
    elsif(v_rand'length = 18) then      --18
      v_xor_out := v_rand(17) xor v_rand(10);
    elsif(v_rand'length = 19) then      --19
      v_xor_out := v_rand(18) xor v_rand(5) xor v_rand(1) xor v_rand(0);
    elsif(v_rand'length = 20) then      --20
      v_xor_out := v_rand(19) xor v_rand(16);
    elsif(v_rand'length = 21) then      --21
      v_xor_out := v_rand(20) xor v_rand(18);
    elsif(v_rand'length = 22) then      --22
      v_xor_out := v_rand(21) xor v_rand(20);
    elsif(v_rand'length = 23) then      --23
      v_xor_out := v_rand(22) xor v_rand(17);
    elsif(v_rand'length = 24) then      --24
      v_xor_out := v_rand(23) xor v_rand(22) xor v_rand(21) xor v_rand(16);
    elsif(v_rand'length = 25) then      --25
      v_xor_out := v_rand(24) xor v_rand(21);
    elsif(v_rand'length = 26) then      --26
      v_xor_out := v_rand(25) xor v_rand(5) xor v_rand(1) xor v_rand(0);
    elsif(v_rand'length = 27) then      --27
      v_xor_out := v_rand(26) xor v_rand(4) xor v_rand(1) xor v_rand(0);
    elsif(v_rand'length = 28) then      --28
      v_xor_out := v_rand(27) xor v_rand(24);
    elsif(v_rand'length = 29) then      --29
      v_xor_out := v_rand(28) xor v_rand(26);
    elsif(v_rand'length = 30) then      --30
      v_xor_out := v_rand(29) xor v_rand(5) xor v_rand(3) xor v_rand(0);
    elsif(v_rand'length = 31) then      --31
      v_xor_out := v_rand(30) xor v_rand(27);
    elsif(v_rand'length = 32) then      --32
      v_xor_out := v_rand(31) xor v_rand(21) xor v_rand(1) xor v_rand(0);
    elsif(v_rand'length = 33) then      --33
      v_xor_out := v_rand(32) xor v_rand(19);
    elsif(v_rand'length = 34) then      --34
      v_xor_out := v_rand(33) xor v_rand(26) xor v_rand(1) xor v_rand(0);
    elsif(v_rand'length = 35) then      --35
      v_xor_out := v_rand(34) xor v_rand(32);
    elsif(v_rand'length = 36) then      --36
      v_xor_out := v_rand(35) xor v_rand(24);
    elsif(v_rand'length = 37) then      --37
      v_xor_out := v_rand(36) xor v_rand(4) xor v_rand(3) xor v_rand(2) xor v_rand(1) xor v_rand(0);
    elsif(v_rand'length = 38) then      --38
      v_xor_out := v_rand(37) xor v_rand(5) xor v_rand(4) xor v_rand(0);
    elsif(v_rand'length = 39) then      --39
      v_xor_out := v_rand(38) xor v_rand(34);
    elsif(v_rand'length = 40) then      --40
      v_xor_out := v_rand(39) xor v_rand(37) xor v_rand(20) xor v_rand(18);
    elsif(v_rand'length = 41) then      --41
      v_xor_out := v_rand(40) xor v_rand(37);
    elsif(v_rand'length = 42) then      --42
      v_xor_out := v_rand(41) xor v_rand(40) xor v_rand(19) xor v_rand(18);
    elsif(v_rand'length = 43) then      --43
      v_xor_out := v_rand(42) xor v_rand(41) xor v_rand(37) xor v_rand(36);
    elsif(v_rand'length = 44) then      --44
      v_xor_out := v_rand(43) xor v_rand(42) xor v_rand(17) xor v_rand(16);
    elsif(v_rand'length = 45) then      --45
      v_xor_out := v_rand(44) xor v_rand(43) xor v_rand(41) xor v_rand(40);
    elsif(v_rand'length = 46) then      --46
      v_xor_out := v_rand(45) xor v_rand(44) xor v_rand(25) xor v_rand(24);
    elsif(v_rand'length = 47) then      --47
      v_xor_out := v_rand(46) xor v_rand(41);
    elsif(v_rand'length = 48) then      --48
      v_xor_out := v_rand(47) xor v_rand(46) xor v_rand(20) xor v_rand(19);
    elsif(v_rand'length = 49) then      --49
      v_xor_out := v_rand(48) xor v_rand(39);
    elsif(v_rand'length = 50) then      --50
      v_xor_out := v_rand(49) xor v_rand(48) xor v_rand(23) xor v_rand(22);
    elsif(v_rand'length = 51) then      --51
      v_xor_out := v_rand(50) xor v_rand(49) xor v_rand(35) xor v_rand(34);
    elsif(v_rand'length = 52) then      --52
      v_xor_out := v_rand(51) xor v_rand(48);
    elsif(v_rand'length = 53) then      --53
      v_xor_out := v_rand(52) xor v_rand(51) xor v_rand(37) xor v_rand(36);
    elsif(v_rand'length = 54) then      --54
      v_xor_out := v_rand(53) xor v_rand(52) xor v_rand(17) xor v_rand(16);
    elsif(v_rand'length = 55) then      --55
      v_xor_out := v_rand(54) xor v_rand(30);
    elsif(v_rand'length = 56) then      --56
      v_xor_out := v_rand(55) xor v_rand(54) xor v_rand(34) xor v_rand(33);
    elsif(v_rand'length = 57) then      --57
      v_xor_out := v_rand(56) xor v_rand(49);
    elsif(v_rand'length = 58) then      --58
      v_xor_out := v_rand(57) xor v_rand(38);
    elsif(v_rand'length = 59) then      --59
      v_xor_out := v_rand(58) xor v_rand(57) xor v_rand(37) xor v_rand(36);
    elsif(v_rand'length = 60) then      --60
      v_xor_out := v_rand(59) xor v_rand(58);
    elsif(v_rand'length = 61) then      --61
      v_xor_out := v_rand(60) xor v_rand(59) xor v_rand(45) xor v_rand(44);
    elsif(v_rand'length = 62) then      --62
      v_xor_out := v_rand(61) xor v_rand(60) xor v_rand(5) xor v_rand(4);
    elsif(v_rand'length = 63) then      --63
      v_xor_out := v_rand(62) xor v_rand(61);
    elsif(v_rand'length = 64) then      --64
      v_xor_out := v_rand(63) xor v_rand(62) xor v_rand(60) xor v_rand(59);
    elsif(v_rand'length = 65) then      --65
      v_xor_out := v_rand(64) xor v_rand(46);
    elsif(v_rand'length = 66) then      --66
      v_xor_out := v_rand(65) xor v_rand(64) xor v_rand(56) xor v_rand(55);
    elsif(v_rand'length = 67) then      --67
      v_xor_out := v_rand(66) xor v_rand(65) xor v_rand(57) xor v_rand(56);
    elsif(v_rand'length = 68) then      --68
      v_xor_out := v_rand(67) xor v_rand(58);
    elsif(v_rand'length = 69) then      --69
      v_xor_out := v_rand(68) xor v_rand(66) xor v_rand(41) xor v_rand(39);
    elsif(v_rand'length = 70) then      --70
      v_xor_out := v_rand(69) xor v_rand(68) xor v_rand(54) xor v_rand(53);
    elsif(v_rand'length = 71) then      --71
      v_xor_out := v_rand(70) xor v_rand(64);
    elsif(v_rand'length = 72) then      --72
      v_xor_out := v_rand(71) xor v_rand(65) xor v_rand(24) xor v_rand(18);
    elsif(v_rand'length = 73) then      --73
      v_xor_out := v_rand(72) xor v_rand(47);
    elsif(v_rand'length = 74) then      --74
      v_xor_out := v_rand(73) xor v_rand(72) xor v_rand(58) xor v_rand(57);
    elsif(v_rand'length = 75) then      --75
      v_xor_out := v_rand(74) xor v_rand(73) xor v_rand(64) xor v_rand(63);
    elsif(v_rand'length = 76) then      --76
      v_xor_out := v_rand(75) xor v_rand(74) xor v_rand(40) xor v_rand(39);
    elsif(v_rand'length = 77) then      --77
      v_xor_out := v_rand(76) xor v_rand(75) xor v_rand(46) xor v_rand(45);
    elsif(v_rand'length = 78) then      --78
      v_xor_out := v_rand(77) xor v_rand(76) xor v_rand(58) xor v_rand(57);
    elsif(v_rand'length = 79) then      --79
      v_xor_out := v_rand(78) xor v_rand(69);
    elsif(v_rand'length = 80) then      --80
      v_xor_out := v_rand(79) xor v_rand(78) xor v_rand(42) xor v_rand(41);
    elsif(v_rand'length = 81) then      --81
      v_xor_out := v_rand(80) xor v_rand(76);
    elsif(v_rand'length = 82) then      --82
      v_xor_out := v_rand(81) xor v_rand(78) xor v_rand(46) xor v_rand(43);
    elsif(v_rand'length = 83) then      --83
      v_xor_out := v_rand(82) xor v_rand(81) xor v_rand(37) xor v_rand(36);
    elsif(v_rand'length = 84) then      --84
      v_xor_out := v_rand(83) xor v_rand(70);
    elsif(v_rand'length = 85) then      --85
      v_xor_out := v_rand(84) xor v_rand(83) xor v_rand(57) xor v_rand(56);
    elsif(v_rand'length = 86) then      --86
      v_xor_out := v_rand(85) xor v_rand(84) xor v_rand(73) xor v_rand(72);
    elsif(v_rand'length = 87) then      --87
      v_xor_out := v_rand(86) xor v_rand(73);
    elsif(v_rand'length = 88) then      --88
      v_xor_out := v_rand(87) xor v_rand(86) xor v_rand(16) xor v_rand(15);
    elsif(v_rand'length = 89) then      --89
      v_xor_out := v_rand(88) xor v_rand(50);
    elsif(v_rand'length = 90) then      --90
      v_xor_out := v_rand(89) xor v_rand(88) xor v_rand(71) xor v_rand(70);
    elsif(v_rand'length = 91) then      --91
      v_xor_out := v_rand(90) xor v_rand(89) xor v_rand(7) xor v_rand(6);
    elsif(v_rand'length = 92) then      --92
      v_xor_out := v_rand(91) xor v_rand(90) xor v_rand(79) xor v_rand(78);
    elsif(v_rand'length = 93) then      --93
      v_xor_out := v_rand(92) xor v_rand(90);
    elsif(v_rand'length = 94) then      --94
      v_xor_out := v_rand(93) xor v_rand(72);
    elsif(v_rand'length = 95) then      --95
      v_xor_out := v_rand(94) xor v_rand(83);
    elsif(v_rand'length = 96) then      --96
      v_xor_out := v_rand(95) xor v_rand(93) xor v_rand(48) xor v_rand(46);
    elsif(v_rand'length = 97) then      --97
      v_xor_out := v_rand(96) xor v_rand(90);
    elsif(v_rand'length = 98) then      --98
      v_xor_out := v_rand(97) xor v_rand(86);
    elsif(v_rand'length = 99) then      --99
      v_xor_out := v_rand(98) xor v_rand(96) xor v_rand(53) xor v_rand(51);
    elsif(v_rand'length = 100) then     --100
      v_xor_out := v_rand(99) xor v_rand(62);
    elsif(v_rand'length = 101) then     --101
      v_xor_out := v_rand(100) xor v_rand(99) xor v_rand(94) xor v_rand(93);
    elsif(v_rand'length = 102) then     --102
      v_xor_out := v_rand(101) xor v_rand(100) xor v_rand(35) xor v_rand(34);
    elsif(v_rand'length = 103) then     --103
      v_xor_out := v_rand(102) xor v_rand(93);
    elsif(v_rand'length = 104) then     --104
      v_xor_out := v_rand(103) xor v_rand(102) xor v_rand(93) xor v_rand(92);
    elsif(v_rand'length = 105) then     --105
      v_xor_out := v_rand(104) xor v_rand(88);
    elsif(v_rand'length = 106) then     --106
      v_xor_out := v_rand(105) xor v_rand(90);
    elsif(v_rand'length = 107) then     --107
      v_xor_out := v_rand(106) xor v_rand(104) xor v_rand(43) xor v_rand(41);
    elsif(v_rand'length = 108) then     --108
      v_xor_out := v_rand(107) xor v_rand(76);
    elsif(v_rand'length = 109) then     --109
      v_xor_out := v_rand(108) xor v_rand(107) xor v_rand(102) xor v_rand(101);
    elsif(v_rand'length = 110)then      --110
      v_xor_out := v_rand(109) xor v_rand(108) xor v_rand(97) xor v_rand(96);
    elsif(v_rand'length = 111) then     --111
      v_xor_out := v_rand(110) xor v_rand(100);
    elsif(v_rand'length = 112) then     --112
      v_xor_out := v_rand(111) xor v_rand(109) xor v_rand(68) xor v_rand(66);
    elsif(v_rand'length = 113) then     --113
      v_xor_out := v_rand(112) xor v_rand(103);
    elsif(v_rand'length = 114) then     --114
      v_xor_out := v_rand(113) xor v_rand(112) xor v_rand(32) xor v_rand(31);
    elsif(v_rand'length = 115) then     --115
      v_xor_out := v_rand(114) xor v_rand(113) xor v_rand(100) xor v_rand(99);
    elsif(v_rand'length = 116) then     --116
      v_xor_out := v_rand(115) xor v_rand(114) xor v_rand(45) xor v_rand(44);
    elsif(v_rand'length = 117) then     --117
      v_xor_out := v_rand(116) xor v_rand(114) xor v_rand(98) xor v_rand(96);
    elsif(v_rand'length = 118) then     --118
      v_xor_out := v_rand(117) xor v_rand(84);
    elsif(v_rand'length = 119) then     --119
      v_xor_out := v_rand(118) xor v_rand(110);
    elsif(v_rand'length = 120) then     --120
      v_xor_out := v_rand(119) xor v_rand(112) xor v_rand(8) xor v_rand(1);
    elsif(v_rand'length = 121) then     --121
      v_xor_out := v_rand(120) xor v_rand(102);
    elsif(v_rand'length = 122) then     --122
      v_xor_out := v_rand(121) xor v_rand(120) xor v_rand(62) xor v_rand(61);
    elsif(v_rand'length = 123) then     --123
      v_xor_out := v_rand(122) xor v_rand(120);
    elsif(v_rand'length = 124) then     --124
      v_xor_out := v_rand(123) xor v_rand(86);
    elsif(v_rand'length = 125) then     --125
      v_xor_out := v_rand(124) xor v_rand(123) xor v_rand(17) xor v_rand(16);
    elsif(v_rand'length = 126) then     --126
      v_xor_out := v_rand(125) xor v_rand(124) xor v_rand(89) xor v_rand(88);
    elsif(v_rand'length = 127) then     --127
      v_xor_out := v_rand(126) xor v_rand(125);
    elsif(v_rand'length = 128) then     --128
      v_xor_out := v_rand(127) xor v_rand(125) xor v_rand(100) xor v_rand(98);
    elsif(v_rand'length = 129) then     --129
      v_xor_out := v_rand(128) xor v_rand(123);
    elsif(v_rand'length = 130) then     --130
      v_xor_out := v_rand(129) xor v_rand(126);
    elsif(v_rand'length = 131) then     --131
      v_xor_out := v_rand(130) xor v_rand(129) xor v_rand(83) xor v_rand(82);
    elsif(v_rand'length = 132) then     --132
      v_xor_out := v_rand(131) xor v_rand(102);
    elsif(v_rand'length = 133) then     --133
      v_xor_out := v_rand(132) xor v_rand(131) xor v_rand(81) xor v_rand(80);
    elsif(v_rand'length = 134) then     --134
      v_xor_out := v_rand(133) xor v_rand(76);
    elsif(v_rand'length = 135) then     --135
      v_xor_out := v_rand(134) xor v_rand(123);
    elsif(v_rand'length = 136) then     --136
      v_xor_out := v_rand(135) xor v_rand(134) xor v_rand(10) xor v_rand(9);
    elsif(v_rand'length = 137) then     --137
      v_xor_out := v_rand(136) xor v_rand(115);
    elsif(v_rand'length = 138) then     --138
      v_xor_out := v_rand(137) xor v_rand(136) xor v_rand(130) xor v_rand(129);
    elsif(v_rand'length = 139) then     --139
      v_xor_out := v_rand(138) xor v_rand(135) xor v_rand(133) xor v_rand(130);
    elsif(v_rand'length = 140) then     --140
      v_xor_out := v_rand(139) xor v_rand(110);
    elsif(v_rand'length = 141) then     --141
      v_xor_out := v_rand(140) xor v_rand(139) xor v_rand(109) xor v_rand(108);
    elsif(v_rand'length = 142) then     --142
      v_xor_out := v_rand(141) xor v_rand(120);
    elsif(v_rand'length = 143) then     --143
      v_xor_out := v_rand(142) xor v_rand(141) xor v_rand(122) xor v_rand(121);
    elsif(v_rand'length = 144) then     --144
      v_xor_out := v_rand(143) xor v_rand(142) xor v_rand(74) xor v_rand(73);
    elsif(v_rand'length = 145) then     --145
      v_xor_out := v_rand(144) xor v_rand(92);
    elsif(v_rand'length = 146) then     --146
      v_xor_out := v_rand(145) xor v_rand(144) xor v_rand(86) xor v_rand(85);
    elsif(v_rand'length = 147) then     --147
      v_xor_out := v_rand(146) xor v_rand(145) xor v_rand(109) xor v_rand(108);
    elsif(v_rand'length = 148) then     --148
      v_xor_out := v_rand(147) xor v_rand(120);
    elsif(v_rand'length = 149) then     --149
      v_xor_out := v_rand(148) xor v_rand(147) xor v_rand(39) xor v_rand(38);
    elsif(v_rand'length = 150) then     --150
      v_xor_out := v_rand(149) xor v_rand(96);
    elsif(v_rand'length = 151) then     --151
      v_xor_out := v_rand(150) xor v_rand(147);
    elsif(v_rand'length = 152) then     --152
      v_xor_out := v_rand(151) xor v_rand(150) xor v_rand(86) xor v_rand(85);
    elsif(v_rand'length = 153) then     --153
      v_xor_out := v_rand(152) xor v_rand(151);
    elsif(v_rand'length = 154) then     --154
      v_xor_out := v_rand(153) xor v_rand(151) xor v_rand(26) xor v_rand(24);
    elsif(v_rand'length = 155) then     --155
      v_xor_out := v_rand(154) xor v_rand(153) xor v_rand(123) xor v_rand(122);
    elsif(v_rand'length = 156) then     --156
      v_xor_out := v_rand(155) xor v_rand(154) xor v_rand(40) xor v_rand(39);
    elsif(v_rand'length = 157) then     --157
      v_xor_out := v_rand(156) xor v_rand(155) xor v_rand(130) xor v_rand(129);
    elsif(v_rand'length = 158) then     --158
      v_xor_out := v_rand(157) xor v_rand(156) xor v_rand(131) xor v_rand(130);
    elsif(v_rand'length = 159) then     --159
      v_xor_out := v_rand(158) xor v_rand(127);
    elsif(v_rand'length = 160) then     --160
      v_xor_out := v_rand(159) xor v_rand(158) xor v_rand(141) xor v_rand(140);
    elsif(v_rand'length = 161) then     --161
      v_xor_out := v_rand(160) xor v_rand(142);
    elsif(v_rand'length = 162) then     --162
      v_xor_out := v_rand(161) xor v_rand(160) xor v_rand(74) xor v_rand(73);
    elsif(v_rand'length = 163) then     --163
      v_xor_out := v_rand(162) xor v_rand(161) xor v_rand(103) xor v_rand(102);
    elsif(v_rand'length = 164) then     --164
      v_xor_out := v_rand(163) xor v_rand(162) xor v_rand(150) xor v_rand(149);
    elsif(v_rand'length = 165) then     --165
      v_xor_out := v_rand(164) xor v_rand(163) xor v_rand(134) xor v_rand(133);
    elsif(v_rand'length = 166) then     --166
      v_xor_out := v_rand(165) xor v_rand(164) xor v_rand(127) xor v_rand(126);
    elsif(v_rand'length = 167) then     --167
      v_xor_out := v_rand(166) xor v_rand(160);
    elsif(v_rand'length = 168) then     --168
      v_xor_out := v_rand(167) xor v_rand(165) xor v_rand(152) xor v_rand(150);
    end if;

    return v_xor_out;
  end f_lfsr;
--END function for Linear Feedback Shift Register.

  signal s_rng_reg : std_logic_vector(g_data_w - 1 downto 0) := std_logic_vector(to_unsigned(1, g_data_w));

begin
  proc_rng : process(clk_i)
    variable v_rand_tmp : std_logic_vector(g_data_w - 1 downto 0);
    variable v_lfsr     : std_logic;
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0') then
        s_rng_reg   <= f_int2slv(4327, rng_o'length);
        v_rand_tmp  := seed_i;
      else
        if load_i = '1' then
          v_rand_tmp := seed_i;
        else
          v_lfsr                          := f_lfsr(v_rand_tmp);
          v_rand_tmp(g_data_w-1 downto 1) := v_rand_tmp(g_data_w-2 downto 0);
          v_rand_tmp(0)                   := v_lfsr;
        end if;

        s_rng_reg <= v_rand_tmp;

      end if;
    end if;
  end process proc_rng;

  rng_o <= std_logic_vector(s_rng_reg);

end a_rtl;
