LIBRARY IEEE;

use IEEE.std_logic_1164.all;
use work.state.all;

package util is

    subtype round_index_t is natural range 0 to 23;

    function to_lane(vec : std_ulogic_vector) return lane_t;

    function full_lane_index(x : natural range 0 to 4; y : natural range 0 to 4) return full_lane_index_t;

    function mergeSlice(f : tile_slice_t; r : remote_slice_t; atom_index : atom_index_t) return slice_t;

    function asBit(condition : boolean) return std_logic;

end package;

package body util is

    function to_lane(vec : std_ulogic_vector) return lane_t is
    begin
        return lane_t(vec);
    end function;

    function full_lane_index(x : natural range 0 to 4; y : natural range 0 to 4) return full_lane_index_t is
    begin
        return y * 5 + x;
    end function;

    function mergeSlice(f : tile_slice_t; r : remote_slice_t; atom_index : atom_index_t) return slice_t is
    begin
        if atom_index = 0 then
            return r & f;
        else
            return f & r;
        end if;
    end function;

    function asBit(condition : boolean) return std_logic is
    begin
        if condition then
            return '1';
        else
            return '0';
        end if;
    end function;
    

end package body;