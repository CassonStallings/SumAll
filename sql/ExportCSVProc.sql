-- create procedure to export entire table to CSV with header for Excel pivot tables
-- - input: schema and table for export, file path for CSV file
#--------------------------------------------------------------------------------
delimiter $$

drop procedure if exists test.export_csv_proc
$$

create procedure test.export_csv_proc(IN vSchema varchar(200), IN vTable varchar(200), IN vFilePath varchar(2000))

begin

	#------------------------------------------------------------------------ declare variables

	declare vColumn varchar(200); -- field name
	declare vDataType char(20); -- field data type
	declare vOrdinalPosition smallint unsigned default 0; -- counter based on information_schema data
	declare vMaxFields smallint unsigned default 0; -- number of fields in export table
	declare vHeaderSQL text default ''; -- hold text for header export SQL
	declare vDataSQL text default ''; -- hold text for data export SQL
	declare vOutputSQL text default ''; -- combine all SQL into final code for exporting table
	#--------------------------------------------------------------------------------
	-- create cursor to get list of columns for export

	declare cur_header cursor for
	select distinct
	c.column_name,
	c.data_type,
	c.ordinal_position
	from information_schema.columns as c
	where c.table_schema = vSchema
	and c.table_name = vTable
	order by
	c.ordinal_position
	;
	
	-- how many columns are in the export table

	set @pSQL = concat("
	select @vFields:= max(c.ordinal_position)
	from information_schema.columns as c
	where c.table_schema = '", vSchema,
	"' and c.table_name = '", vTable, "'"
	);

	prepare stmt from @pSQL;
	execute stmt;
	deallocate prepare stmt;

	set vMaxFields = @vFields;

	-- create SQL export text
	-- - add double quote enclosure only for character fields
	-- - format date fields for Excel import (DD/MM/YYYY)
	-- - add comma after all but last field

	open cur_header;

	repeat
		fetch cur_header into vColumn, vDataType, vOrdinalPosition;

		set vHeaderSQL = concat(vHeaderSQL, '\'"\',', '\'', vColumn, '\'', ',\'"\'');

		case
			when vDataType in ('char','varchar') then set vDataSQL = concat(vDataSQL, '\'"\',ifnull(`', vColumn, '`,\'\'),\'"\'');
			when vDataType in ('date','datetime','timestamp') then set vDataSQL = concat(vDataSQL, 'ifnull(date_format(`', vColumn, '`,\'%d/%m/%Y %T\'),\'\')');
			else set vDataSQL = concat(vDataSQL, 'ifnull(`', vColumn, '`,\'\')');
		end case;

		if vOrdinalPosition < vMaxFields
			then set vHeaderSQL = concat(vHeaderSQL, ',', '",", '),
				vDataSQL = concat(vDataSQL, ',', '",", ');
		end if;

		until vOrdinalPosition = vMaxFields
	end repeat;

	close cur_header;
	#--------------------------------------------------------------------------------
	-- create CSV SQL text

	set vOutputSQL = concat(
	'select concat (',
	vHeaderSQL,
	') UNION select concat (',
	vDataSQL,
	') from ', vSchema, '.', vTable,
	' into outfile "', vFilePath,
	'" lines terminated by "\\r\\n"'
	);
	#--------------------------------------------------------------------------------
	-- execute created statement

	set @pSQL = vOutputSQL;

	prepare stmt from @pSQL;
	execute stmt;
	deallocate prepare stmt;
	#--------------------------------------------------------------------------------
end
$$

delimiter ;
#--------------------------------------------------------------------------------
call test.export_csv_proc('evictions', 'headers', 't://tmp//headers.csv');
call test.export_csv_proc('evictions', 'first', 't://tmp//first.csv');
call test.export_csv_proc('evictions', 'second', 't://tmp//second.csv');
