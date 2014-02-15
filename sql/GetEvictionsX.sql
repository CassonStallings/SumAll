/* 
GetEvictionsX - Define the xrefs table and read 
the data from a fixed format text file.
*/

create database if not exists evictions;
drop table if exists evictions.xrefs;

# Table definition

create table if not exists evictions.xrefs (
	`xid` int(8) auto_increment primary key,
	`xref-type` char(1),
	`xref-cnty-code` char(2),
	`xref-indx-year` char(4),
	`xref-indx-numb` char(7),	
	`xref-seq-num` char(3),
	`xref-id` char(16),
	`petn-lsn` char(20),
	`petn-ftn` char(15),
	`petn-mi` char(1),
	`prem-strt-no` char(6),
	`prem-strt` char(25),
	`prem-apn` char(6),
	`prem-boro` char(20),
	`prem-state` char(2),
	`prem-zip` char(9),
	`resp-lsn` char(20),
	`resp-ftn` char(15),
	`resp-mi` char(1),
	`resp-strt-no` char(6),
	`resp-strt` char(25),
	`resp-apn` char(6),
	`resp-city` char(20),
	`resp-state` char(2),
	`resp-zip` char(9),
	`resp-tel-area` char(3),
	`resp-tel-exch` char(3),
	`resp-tel-num` char(4));
	#`filler` char(48));

# Read data from fixed field text file;

-- Test on subset of data 'T:/Uncom/dhs13.cnty62'
LOAD DATA LOCAL INFILE 'T:/Uncom/dhs_evictions_data.txt'
IGNORE
INTO TABLE `evictions`.`xrefs`
LINES TERMINATED BY '\r\n'
(@l)
 set
	`xref-type` = SUBSTR(@l,1,1),
	`xref-cnty-code` = SUBSTR(@l,2,2),
	`xref-indx-year` = SUBSTR(@l,4,4),
	`xref-indx-numb` = SUBSTR(@l,8,7),
	`xref-seq-num` = SUBSTR(@l,15,3),
	`xref-id` = SUBSTR(@l,2,16),
	`petn-lsn` = SUBSTR(@l,18,20),
	`petn-ftn` = SUBSTR(@l,38,15),
	`petn-mi` = SUBSTR(@l,53,1),
	`prem-strt-no` = SUBSTR(@l,54,6),
	`prem-strt` = SUBSTR(@l,60,25),
	`prem-apn` = SUBSTR(@l,85,6),
	`prem-boro` = SUBSTR(@l,91,20),
	`prem-state` = SUBSTR(@l,111,2),
	`prem-zip` = SUBSTR(@l,113,9),
	`resp-lsn` = SUBSTR(@l,122,20),
	`resp-ftn` = SUBSTR(@l,142,15),
	`resp-mi` = SUBSTR(@l,157,1),
	`resp-strt-no` = SUBSTR(@l,158,6),
	`resp-strt` = SUBSTR(@l,164,25),
	`resp-apn` = SUBSTR(@l,189,6),
	`resp-city` = SUBSTR(@l,195,20),
	`resp-state` = SUBSTR(@l,215,2),
	`resp-zip` = SUBSTR(@l,217,9) ,
	`resp-tel-area` = SUBSTR(@l,226,3),
	`resp-tel-exch` = SUBSTR(@l,224,3),
	`resp-tel-num` = SUBSTR(@l,227,4);
	#`filler` = SUBSTR(@l,231,48);

# Clean out any records that are not Xref type

delete from evictions.xrefs where `xref-type` != 'X';

# Original table contains 5 duplicate records
# Remove them

drop table if exists evictions.dupids;

create table evictions.dupids as
	select distinct `xref-id`, count(*) as cnt, max(xid) as maxid
	from  evictions.xrefs
	group by `xref-id`
	having count(*) > 1
	order by cnt desc;

select * from evictions.dupids;

delete from evictions.xrefs 
	where xid in 
		(select distinct maxid from evictions.dupids);

drop table if exists evictions.dupids;

# Clean up xref table 

alter table evictions.xrefs  
	drop `resp-tel-area`, drop `resp-tel-exch`, 
	drop `resp-tel-num`;
create unique index xrefs on evictions.xrefs (`xref-cnty-code`,	
	`xref-indx-year`, `xref-indx-numb`,	`xref-seq-num`);
create unique index xrefsid on evictions.xrefs (`xref-id`);



select * from xrefs limit 100;