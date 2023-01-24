library IEEE;
use IEEE.std_logic_1164.all;
use work.state.all;


package slice_buffer is

    type buffer_data_t is array(natural range 0 to 1) of slice_t;

    subtype buffer_t is natural range 0 to 255;

    subtype transmission_word_t is std_logic_vector(31 downto 0);

    procedure init_buffer(iterator : inout buffer_t);

    procedure sync(
        iterator : inout buffer_t;
        state : inout block_t;
        atom_index : in atom_index_t;
        input : in lane_t;
        results : in buffer_data_t;
        output : out lane_t;
        data : out buffer_data_t;
        -- control signals
        ready : out std_logic;
        finished : out std_logic;
        isFirst : out std_logic;
        isLast : out std_logic;
        current_slice : out slice_index_t
    );

end package;

package body slice_buffer is

    procedure init_buffer(iterator : inout buffer_t) is
    begin
        iterator := 0;
    end procedure;

    procedure sync(
        iterator : inout buffer_t;
        state : inout block_t;
        atom_index : in atom_index_t;
        input : in lane_t;
        results : in buffer_data_t;
        output : out lane_t;
        data : out buffer_data_t;
        -- control signals
        ready : out std_logic;
        finished : out std_logic;
        isFirst : out std_logic;
        isLast : out std_logic;
        current_slice : out slice_index_t
    ) is

        constant zero : transmission_word_t := (others => '0');

        variable outgoing_state_transmission : transmission_word_t;
        variable outgoing_result_transmission : transmission_word_t;

        variable incoming_state_transmission : transmission_word_t;
        variable incoming_result_transmission : transmission_word_t;

    begin
        incoming_state_transmission := input(31 downto 0);
        incoming_result_transmission := input(63 downto 32);

        -- transmit own state
        if iterator <= 7 then
            if atom_index = 1 then
                outgoing_state_transmission := x"0" & get_slice_tile(state, 2 * iterator + 1)(12 downto 1)
                                            &  x"0" & get_slice_tile(state, 2 * iterator    )(12 downto 1);
            else
                outgoing_state_transmission := x"0" & get_slice_tile(state, 2 * iterator + 17)(11 downto 0)
                                            &  x"0" & get_slice_tile(state, 2 * iterator + 16)(11 downto 0);
            end if;
        else
            outgoing_state_transmission := zero;
        end if;
        
        -- transmit own results
        if iterator >= 3 and iterator <= 10 then
            if atom_index = 1 then
                outgoing_result_transmission := "000" & results(1)(12 downto 0)
                                             &  "000" & results(0)(12 downto 0);
            else
                outgoing_result_transmission := "000" & results(1)(24 downto 12)
                                             &  "000" & results(0)(24 downto 12);
            end if;
        else
            outgoing_result_transmission := zero;
        end if;

        --finalize own results
        if iterator >= 3 and iterator <= 9 then
            if atom_index = 1 then
                set_slice_tile(state, results(1)(24 downto 12), iterator * 2 + 13);
                set_slice_tile(state, results(0)(24 downto 12), iterator * 2 + 12);
            else
                set_slice_tile(state, results(1)(12 downto 0), iterator * 2 - 3);
                set_slice_tile(state, results(0)(12 downto 0), iterator * 2 - 4);
            end if;
        end if;
        if iterator = 10 then
            if atom_index = 1 then
                set_slice_tile(state, results(1)(24 downto 12), 17);
                set_slice_tile(state, results(0)(24 downto 12), 16);
            else
                set_slice_tile(state, results(1)(12 downto 0), 1);
                set_slice_tile(state, results(0)(12 downto 0), 0);
            end if;
        end if;

        -- merge received slices with own block
        if iterator >= 1 and iterator <= 8 then
            if atom_index = 1 then
                data(1) := get_slice_tile(state, iterator * 2 + 15) & incoming_state_transmission(27 downto 16);
                data(0) := get_slice_tile(state, iterator * 2 + 14) & incoming_state_transmission(11 downto  0);
                current_slice := iterator * 2 + 14;
            else
                data(1) := incoming_state_transmission(27 downto 16) & get_slice_tile(state, iterator * 2 - 1);
                data(0) := incoming_state_transmission(11 downto  0) & get_slice_tile(state, iterator * 2 - 2);
                current_slice := iterator * 2 - 2;
            end if;
            if iterator = 1 then
                isFirst := '1';
            else
                isFirst := '0';
            end if;
            if iterator = 8 then
                isLast := '1';
            else
                isLast := '0';
            end if;
            ready := '1';
        else
            data(0) := (others => '0');
            data(1) := (others => '1');
            isFirst := '0';
            isLast := '0';
            ready := '0';
            current_slice := 0;
        end if;

        -- finalize incoming result transmission
        if iterator >= 4 and iterator <= 10 then
            if atom_index = 1 then
                set_slice_tile(state, incoming_result_transmission(28 downto 16), iterator * 2 + 11);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), iterator * 2 + 10);
            else
                set_slice_tile(state, incoming_result_transmission(28 downto 16), iterator * 2 - 5);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), iterator * 2 - 6);
            end if;
        end if;
        if iterator = 11 then
            if atom_index = 1 then
                set_slice_tile(state, incoming_result_transmission(28 downto 16), 1);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), 0);
            else
                set_slice_tile(state, incoming_result_transmission(28 downto 16), 17);
                set_slice_tile(state, incoming_result_transmission(12 downto  0), 16);
            end if;
        end if;

        if iterator >= 11 then
            finished := '1';
        else
            finished := '0';
        end if;

        output := outgoing_result_transmission & outgoing_state_transmission;
        iterator := iterator + 1;
    end procedure;

end package body;