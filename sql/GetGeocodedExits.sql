drop table if exists test.exitadds;
create table test.exitadds like `test`.`entrants_exits`;
alter table test.exitadds 
	add column (
		`exit_std_strtno` char(10),
		`exit_std_strt` char(32),       
		`exit_std_borocode` int);


drop table if exists test.exitids;
create table test.exitids  (
	`xid` int,
	`exit_std_strtno` char(10),
	`exit_std_strt` char(32),       
	`exit_std_borocode` int
);


drop table if exists test.exitll;
create table test.exitll  (
	`lid` int,
	`exit_spx` int(8),
	`exit_spy` int(8),
	`exit_lat` double,
	`exit_lon` double);
	

LOAD DATA LOCAL INFILE 'T:/tmp/ExitAdds2.csv'
IGNORE
INTO TABLE `test`.`exitadds`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';

LOAD DATA LOCAL INFILE 'T:/tmp/exitids.csv'
IGNORE
INTO TABLE `test`.`exitids`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'T:/tmp/ExitAddsWithLL.csv'
IGNORE
INTO TABLE `test`.`exitll`
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

create temporary table test.tmp as
	select id.*, ll.*
	from `test`.`exitids` id left join `test`.`exitll` ll
	on id.xid=ll.lid;

create index adds on `test`.`tmp` (`exit_std_strtno`, `exit_std_strt`, `exit_std_borocode`);
create index adds on `test`.`exitadds` (`exit_std_strtno`, `exit_std_strt`, `exit_std_borocode`);
drop table if exists exitadds;

create table exitadds as
	select a.*, `t`.`exit_spx`, `t`.`exit_spy`, `t`.`exit_lat`,
		`t`.`exit_lon`
	from `test`.`exitadds` a left join `test`.`tmp` t
	on `a`.`exit_std_strtno`=`t`.`exit_std_strtno`
		and `a`.`exit_std_strt`=`t`.`exit_std_strt`       
		and `a`.`exit_std_borocode`=`t`.`exit_std_borocode`
	limit 20000000;

	