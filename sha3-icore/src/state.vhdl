library IEEE;

use IEEE.std_logic_1164.all;

package state is

    subtype lane_t is std_logic_vector(63 downto 0);
    type block_t is array(natural range 0 to 12) of lane_t;
    subtype tile_slice_t is std_logic_vector(12 downto 0);
    subtype remote_slice_t is std_logic_vector(11 downto 0);
    subtype slice_t is std_logic_vector(24 downto 0);
    subtype transmission_word_t is std_logic_vector(31 downto 0);

    type tile_computation_data_t is array(natural range 1 downto 0) of tile_slice_t;
    type computation_data_t is array(natural range 1 downto 0) of slice_t;

    subtype atom_index_t is natural range 0 to 1;
    subtype lane_index_t is natural range 0 to 12;
    subtype full_lane_index_t is natural range 0 to 24;
    subtype slice_index_t is natural range 0 to 63;
    subtype computation_data_index_t is natural range 0 to 31;

    procedure set_lane(state: inout block_t; data : in lane_t; index : in lane_index_t);
    function get_lane(state: block_t; index : lane_index_t) return lane_t;

    procedure set_slice_tile(state : inout block_t; data : in tile_slice_t; index : in slice_index_t);
    function get_slice_tile(state : block_t; index : slice_index_t) return tile_slice_t;

    procedure set_computation_data(state : inout block_t; data : in tile_computation_data_t; index : in computation_data_index_t);
    function get_computation_data(state : block_t; index : computation_data_index_t) return tile_computation_data_t;

    procedure reset(state : inout block_t);

    function isValid(state : block_t) return boolean;

end package;

package body state is

    procedure set_lane(state: inout block_t; data : in lane_t; index : lane_index_t) is
    begin
        state(index) := data;
    end procedure;

    function get_lane(state: block_t; index : lane_index_t) return lane_t is
    begin
        return state(index);
    end function;

    procedure set_slice_tile(state : inout block_t; data : in tile_slice_t; index : slice_index_t) is
    begin
        for i in 0 to 12 loop
            state(i)(index) := data(i);
        end loop;
    end procedure;

    function get_slice_tile(state : block_t; index : slice_index_t) return tile_slice_t is
        variable data : tile_slice_t;
    begin
        for i in 0 to 12 loop
            data(i) := state(i)(index);
        end loop;
        return data;
    end function;

    procedure set_computation_data(state : inout block_t; data : in tile_computation_data_t; index : in computation_data_index_t) is
    begin
        for i in 0 to 12 loop
            state(i)(index * 2 + 1 downto index * 2) := data(1)(i) & data(0)(i);
        end loop;
    end procedure;

    function get_computation_data(state : block_t; index : computation_data_index_t) return tile_computation_data_t is
        variable data : tile_computation_data_t;
    begin
        for i in 0 to 12 loop
            data(0)(i) := state(i)(2 * index);
            data(1)(i) := state(i)(2 * index + 1);
        end loop;
        return data;
    end function;

    procedure reset(state : inout block_t) is
        constant ZERO : lane_t := (others => '0');
    begin
        for i in 0 to 12 loop
            set_lane(state, ZERO, i);
        end loop;
    end procedure;

    function isValid(state : block_t) return boolean is
    begin
        for l in 0 to 12 loop
            for i in 0 to 63 loop
                if state(l)(i) /= '1' and state(l)(i) /= '0' then
                    return false;
                end if;
            end loop;
        end loop;
        return true;
    end function;

end package body;
