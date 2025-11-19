-- Project Reti Logiche

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity of the component
entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

-- Architecture of the component
architecture Behavioral of project_reti_logiche is

    -- Enumerated type declaration of the states
    type state_type is (SR, S1, S2, S3, S4);
    -- Current state signal declaration
    signal state : state_type := SR;
    -- Register that samples the bits that identify the output channel
    signal output_channel : std_logic_vector(1 downto 0) := (others => '0');
    -- Register that samples the bits of the memory address from which to extract the data
    signal memory_address : std_logic_vector(15 downto 0) := (others => '0');
    -- Registers that track outputs
    signal z0_register, z1_register, z2_register, z3_register : std_logic_vector(7 downto 0) := (others => '0');
    
    begin
        -- Process that manages the reset or the input
        lambda_delta : process(i_rst, i_clk)
        begin
            if i_rst = '1' then
                -- Setting all the registers to default values in case of reset
                output_channel <= (others => '0');
                memory_address  <= (others => '0');
                z0_register <= (others => '0');
                z1_register <= (others => '0');
                z2_register <= (others => '0');
                z3_register <= (others => '0');
                state <= SR;
            elsif rising_edge(i_clk) then
                 case state is
                    when SR =>
                        if i_start = '1' then
                            -- Sampling the first bit of the output channel
                            output_channel(1) <= i_w;
                            state <= S1;
                        else
                            state <= SR;
                        end if;
                        o_z0 <= (others => '0');
                        o_z1 <= (others => '0');
                        o_z2 <= (others => '0');
                        o_z3 <= (others => '0');
                        o_done <= '0';
                        o_mem_addr <= memory_address;
                        o_mem_en <= '0';
                        o_mem_we <= '0';
                    when S1 =>
                        if i_start = '1' then
                            -- Sampling the second bit of the output channel
                            output_channel(0) <= i_w;
                            o_z0 <= (others => '0');
                            o_z1 <= (others => '0');
                            o_z2 <= (others => '0');
                            o_z3 <= (others => '0');
                            o_done <= '0';
                            o_mem_addr <= memory_address;
                            o_mem_en <= '1';
                            o_mem_we <= '0';
                            state <= S2;
                        end if;
                    when S2 =>
                        if i_start = '1' then
                            -- Shift of the memory address and insertion of the LSB, output propagation and saving to the register
                            o_mem_addr <= memory_address(14 downto 0) & i_w;
                            memory_address <= memory_address(14 downto 0) & i_w;
                            o_mem_en <= '1';
                            state <= S2;
                        else
                            o_mem_addr <= memory_address;
                            o_mem_en <= '0';
                            state <= S3;
                        end if;
                        o_z0 <= (others => '0');
                        o_z1 <= (others => '0');
                        o_z2 <= (others => '0');
                        o_z3 <= (others => '0');
                        o_done <= '0';
                        o_mem_we <= '0';
                    when S3 =>
                        if i_start = '0' then
                            -- Propagation of the data received on the appropriate output channel, saving in the register and loading of the other outputs from the registers
                            case output_channel is
                                when "00" =>
                                    o_z0 <= i_mem_data;
                                    z0_register <= i_mem_data;
                                    o_z1 <= z1_register;
                                    o_z2 <= z2_register;
                                    o_z3 <= z3_register;
                                when "01" =>
                                    o_z0 <= z0_register;
                                    o_z1 <= i_mem_data;
                                    z1_register <= i_mem_data;
                                    o_z2 <= z2_register;
                                    o_z3 <= z3_register;
                                when "10" =>
                                    o_z0 <= z0_register;
                                    o_z1 <= z1_register;
                                    o_z2 <= i_mem_data;
                                    z2_register <= i_mem_data;
                                    o_z3 <= z3_register;
                                when "11" =>
                                    o_z0 <= z0_register;
                                    o_z1 <= z1_register;
                                    o_z2 <= z2_register;
                                    o_z3 <= i_mem_data;
                                    z3_register <= i_mem_data;
                                when others =>
                            end case;
                            o_done <= '1';
                            o_mem_addr <= memory_address;
                            o_mem_en <= '0';
                            o_mem_we <= '0';
                            state <= S4;
                        end if;
                    when S4 =>
                        if i_start = '0' then
                            -- Setting output channel and memory address registers to default values to prepare the next sampling
                            output_channel <= (others => '0');
                            memory_address <= (others => '0');
                            o_z0 <= (others => '0');
                            o_z1 <= (others => '0');
                            o_z2 <= (others => '0');
                            o_z3 <= (others => '0');
                            o_done <= '0';
                            o_mem_addr <= (others => '0');
                            o_mem_en <= '0';
                            o_mem_we <= '0';
                            state <= SR;
                        end if;
                    when others =>  
                end case;
            end if; 
    end process lambda_delta;     
end Behavioral;