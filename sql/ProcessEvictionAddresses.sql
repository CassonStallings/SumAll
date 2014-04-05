# Fairly sure this is now done in python code.
# Correct borough names and add borough code for City geocoder


alter table evictions add column `prem-boro-code` int(4);
update evictions
	set 
	`prem-boro` = case `xref-cnty-code` 
		when '30' then 'MANHATTAN'
		when '62' then 'BRONX'
		when '23' then 'BROOKLYN'
		when '40' then 'QUEENS'
		when '42' then 'STATEN ISLAND'
	end,
	`prem-boro-code` = case `xref-cnty-code`
			when '30' then  1
			when '62' then 2
			when '23' then 3
			when '40' then 4 
			when '42' then 5 
			else 0
	end;

# Create and export the table of unique addresses for evictions

drop table if exists uniqueadds;

set @aid := 0;
create temporary table uniqueadds0 as
	select distinct `prem-strt-no`, `prem-strt`, `prem-boro-code`
	from evictions;

create table uniqueadds as
	select @aid:=@aid+1 as aid, u.*
	from uniqueadds0 u;

select * from uniqueadds limit 100;

drop table if exists uniqueadds0;

# Export table for use in geocoder
# It needs to be converted to Excel and
# the strt-no needs to be in text format

call test.export_csv_proc('evictions', 'uniqueadds', 't://tmp//uniqueids.csv');

# Import geocoder output tab as EvictionsAddsOut

# Combine initial output fields to output
# from the City geocoder

create table evictions_unique_adds as
	select u.*, o.*
	from uniqueadds u, evictionsaddsout o
	where u.aid=o.recnum
	order by aid;

create index uadd on evictions (
	`prem-boro-code`,`prem-strt`, `prem-strt-no`);

create index uadd on evictions_unique_adds (
	`prem-boro-code`,`prem-strt`, `prem-strt-no`);

drop table if exists evictions_with_adds;

create table evictions_with_adds as
	select e.*, a.aid, a.recnum, a.interior, a.vacant,
		a.bin, a.taxmapnum, a.spx, a.spy
	from evictions e inner join evictions_unique_adds a
	on e.`prem-boro-code`=a.`prem-boro-code`
		and e.`prem-strt`=a.`prem-strt`
		and e.`prem-strt-no`=a.`prem-strt-no`;

select *, count(*) from evictions limit 100;
select *, count(*) from evictions_unique_adds limit 100;

call test.export_csv_proc('evictions', 'evictions_with_adds', 't://tmp//evicwithadds.csv');

	