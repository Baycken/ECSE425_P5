LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY fetch IS
	PORT (
		reset : in std_logic;
		clk : in std_logic;
	
		--execution stage communication
		ex_is_new_pc: in std_logic;
		ex_pc : in std_logic_vector(31 downto 0);

		--decode stage communication
		dc_pc : out std_logic_vector(31 downto 0);
		dc_instr : out std_logic_vector(31 downto 0);

		--instruction memory communication
		mem_read_data : in std_logic_vector (31 downto 0);
		mem_waitrequest : in std_logic;
		mem_write : out std_logic;
		mem_read : out std_logic;
		mem_addr : out integer RANGE 0 TO 8191;
		mem_write_data : out std_logic_vector (31 downto 0);

		--pipeline stall
		hazard_detect : in std_logic
	);
end fetch;

architecture fetch_arch of fetch is

type state_type is (req_read, instr_read);
signal state:state_type;
signal temp_pc : std_logic_vector(31 downto 0);

begin

mem_stage_process : process(clk,reset)
variable pc : integer := 0;
variable instruction: std_logic_vector(31 downto 0);

begin

if (reset = '1') then
	temp_pc<=x"00000000";
	state<=req_read;
elsif (rising_edge(clk)) then
	
	if (ex_is_new_pc = '1') then
		pc := to_integer(unsigned(ex_pc));
	end if;


	--read from isntruction memory
	case state is
		when req_read =>
			mem_read <= '1';
			mem_addr <= pc;
			if rising_edge(mem_waitrequest) then
				state<=instr_read;
			end if;
		when instr_read =>
			mem_read<='0';
			instruction := mem_read_data;
			state<=req_read;
			pc:=pc+1;
		when others =>
			state<=req_read;
		end case;

	if hazard_detect = '1' then--hazard
		dc_pc <=x"00000000";
		dc_instr <= x"00000000";
		pc:=pc-1;
	else--no hazard
		dc_pc <= std_logic_vector(to_unsigned(pc, dc_pc'length));
		dc_instr <= instruction;
	end if;			
		
end if;
end process;
end fetch_arch;
