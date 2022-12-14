
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.keccak_types.all;

package testutil is

	procedure convertInput(input_line : inout line; res : out StateArray);

	function convertOutput(state : in StateArray) return string;

	function reverseByteOrder(input : std_logic_vector) return std_logic_vector;

end package testutil;

package body testutil is

	procedure convertInput(input_line : inout line; res : out StateArray) is
		variable good : boolean;
		variable hex : std_logic_vector(1599 downto 0);
	begin
		hread(input_line, hex, good);
		assert good severity FAILURE;
		res := to_StateArray(hex);
	end procedure convertInput;

	function convertOutput(state : in StateArray) return string is
		variable hex : std_logic_vector(1599 downto 0);
		variable str : line;
	begin
		hex := to_std_logic_vector(state);
		hwrite(str, hex);
		return str.all;
	end function convertOutput;

	function reverseByteOrder(input : std_logic_vector) return std_logic_vector is
		constant len : natural := input'length;
		variable output : std_logic_vector(len - 1 downto 0) := (others => '0');
	begin
		for i in 0 to (len / 8) - 1 loop
			output(i * 8 + 7 downto i * 8) := input(len - i * 8 - 1 downto len - i * 8 - 8);
		end loop;
		return output;
	end function reverseByteOrder;

end package body testutil;
