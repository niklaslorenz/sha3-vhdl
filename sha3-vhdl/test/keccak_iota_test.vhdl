
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.all;
use work.keccak_types.all;
use work.testutil.all;

entity keccak_iota_test is
end entity keccak_iota_test;

architecture arch of keccak_iota_test is

	component keccak_iota is
		port(
			input : in StateArray;
			roundIndex : in natural;
			output : out StateArray
		);
	end component keccak_iota;

	file challenge_buf : text;
	file result_buf : text;
	
	signal input : StateArray;
	signal output : StateArray;
begin

	theta : keccak_iota port map(input => input, roundIndex => 0, output => output);

	verify : process
		variable challenge : line;
		variable result : line;
		variable result_state : StateArray;
		variable input_state : StateArray;
		begin
			file_open(challenge_buf, "../test_instances/raw_state_arrays.txt", read_mode);
			file_open(result_buf, "../test_solutions/iota.txt", read_mode);
			while not endfile(challenge_buf) loop
				assert not endfile(result_buf) report "Expected test result in result file" severity FAILURE;
				readline(challenge_buf, challenge);
				readline(result_buf, result);
				convertInput(challenge, input_state);
				convertInput(result, result_state);
				input <= input_state;
				wait for 10ns;
				assert output = result_state report "Failed keccak_iota Test: Expected: " & convertOutput(result_state) & " But got: " & convertOutput(output) severity ERROR;
			end loop;
			assert endfile(result_buf) report "Expected end of result file" severity FAILURE;
			wait;
	end process verify;
end architecture arch;