create database if not exists evictions;

drop table if exists evictions.cases;

create table if not exists evictions.cases (
	`id` int(8) auto_increment primary key,
	`case-type` char(1),
	`case-cnty-code` char(2),
	`case-indx-year` char(4),
	`case-indx-numb` char(7),	
	`case-seq-num` char(3),
	`case-id` char(16),
	`indx-num-prfx` char(6),
	`case--status` char(1),
	`court-code` char(1),
	`case-type1` int(4),
	`case-type201` int(4),
	`case-type202` int(4),
	`case-type203` int(4),
	`case-type204` int(4),
	`case-type205` int(4),
	`case-type206` int(4),
	`case-type207` int(4),
	`case-type208` int(4),
	`case-type209` int(4),
	`case-type210` int(4),
	`case-type301` int(4),
	`case-type302` int(4),
	`case-type303` int(4),
	`case-type304` int(4),
	`case-type305` int(4),
	`case-type306` int(4),
	`case-type307` int(4),
	`case-type308` int(4),
	`case-type309` int(4),
	`filler1` char(12),
	`entry-dte` date,
	`entry-applid` char(8),
	`filler2` char(8),
	`filing-dte` date,
	`file-type` char(1),
	`petn-atty` int(8),
	`undr-tenent` char(36),
	`amt-demanded` int(9),
	`case-relief` int(4),
	`comm-rent` char(55),
	`total-fees` int(6),
	`legal-fees` int(6),
	`fees-subt` int(6),
	`mgr-agent` int(8),
	`case-serv-seq` int(3),
	`case-resp-seq` int(3),
	`case-appr-sourc` int(3),
	`case-appr-seq` int(3),
	`landlord-ind` char(1),
	`jury-demanded-by` char(1),
	`filler3` char(20),
	`case-filler` char(75));

#'T:/Uncom/dhs13.cnty62'##
LOAD DATA LOCAL INFILE 'T:/Uncom/dhs_evictions_data.txt'
IGNORE
INTO TABLE `evictions`.`cases`
LINES TERMINATED BY '\r\n'
(@l)
 set
	`case-type` = SUBSTR(@l,1,1),
	`case-cnty-code` = SUBSTR(@l,2,2),
	`case-indx-year` = SUBSTR(@l,4,4),
	`case-indx-numb` = SUBSTR(@l,8,7),
	`case-seq-num` = SUBSTR(@l,15,3),
	`case-id` = SUBSTR(@l,2,16),
	`indx-num-prfx` = SUBSTR(@l,18,6),
	`case--status` = SUBSTR(@l,24,1),
	`court-code` = SUBSTR(@l,25,1),
	`case-type1` = cast(SUBSTR(@l,26,4) as unsigned),
	`case-type201` = cast(SUBSTR(@l,30,4) as unsigned),
	`case-type202` = cast(SUBSTR(@l,34,4) as unsigned),
	`case-type203` = cast(SUBSTR(@l,38,4) as unsigned),
	`case-type204` = cast(SUBSTR(@l,42,4) as unsigned),
	`case-type205` = cast(SUBSTR(@l,46,4) as unsigned),
	`case-type206` = cast(SUBSTR(@l,50,4) as unsigned),
	`case-type207` = cast(SUBSTR(@l,54,4) as unsigned),
	`case-type208` = cast(SUBSTR(@l,58,4) as unsigned),
	`case-type209` = cast(SUBSTR(@l,62,4) as unsigned),
	`case-type210` = cast(SUBSTR(@l,66,4) as unsigned),
	`case-type301` = cast(SUBSTR(@l,70,4) as unsigned),
	`case-type302` = cast(SUBSTR(@l,74,4) as unsigned),
	`case-type303` = cast(SUBSTR(@l,78,4) as unsigned),
	`case-type304` = cast(SUBSTR(@l,82,4) as unsigned),
	`case-type305` = cast(SUBSTR(@l,86,4) as unsigned),
	`case-type306` = cast(SUBSTR(@l,90,4) as unsigned),
	`case-type307` = cast(SUBSTR(@l,94,4) as unsigned),
	`case-type308` = cast(SUBSTR(@l,98,4) as unsigned),
	`case-type309` = cast(SUBSTR(@l,102,4) as unsigned),
	`filler1` = SUBSTR(@l,106,12),
	`entry-dte` = str_to_date(SUBSTR(@l,118,8),'%Y%m%d'), 
	`entry-applid` = cast(SUBSTR(@l,126,8) as unsigned),
	`filler2` = SUBSTR(@l,134,8),
	`filing-dte` = str_to_date(SUBSTR(@l,142,8),'%Y%m%d'), 
	`file-type`  = SUBSTR(@l,150,1),
	`petn-atty` = cast(SUBSTR(@l,151,8) as unsigned),
	`undr-tenent` = SUBSTR(@l,159,36),
	`amt-demanded` = cast(SUBSTR(@l,195,7) as unsigned),  
	`case-relief` = cast(SUBSTR(@l,202,4) as unsigned),
# skipping 2 spaces - All zeros
	`comm-rent` = SUBSTR(@l,208,55), 
	`total-fees` = cast(SUBSTR(@l,263,6) as unsigned), 
	`legal-fees` = cast(SUBSTR(@l,269,6) as unsigned), 
	`fees-subt` = cast(SUBSTR(@l,275,6) as unsigned), 
	`mgr-agent` = cast(SUBSTR(@l,281,8) as unsigned),
# skipping 6 spaces
	`case-serv-seq` = cast(SUBSTR(@l,295,3) as unsigned),  
	`case-resp-seq` = cast(SUBSTR(@l,298,3) as unsigned), 
	`case-appr-sourc` = cast(SUBSTR(@l,301,3) as unsigned), 
	`case-appr-seq` = cast(SUBSTR(@l,304,3) as unsigned), 
	`landlord-ind` = SUBSTR(@l,307,1), 						# Good
	`jury-demanded-by` = SUBSTR(@l,308,1), 					# Good
	`filler3` = SUBSTR(@l,309,20), 
	`case-filler` = SUBSTR(@l,263,105);

delete from `evictions`.`cases` where `case-type` != 'C';

alter table evictions.cases  
	drop `case-type204`, drop `case-type205`,
	drop `case-type206`, drop `case-type207`,
	drop `case-type208`, drop `case-type209`,
	drop `case-type210`, drop `case-type304`, 
	drop `case-type305`, drop `case-type306`,
	drop `case-type307`, drop `case-type308`,
	drop `case-type309`, drop `filler1`, 
	drop `filler2`, drop `filler3`,	drop `case-filler`;

# identify duplicate records, inspection showed them to be fully duplicate

drop table if exists evictions.dupids;

create table evictions.dupids as
	select distinct `case-cnty-code`, `case-indx-year`, `case-indx-numb`,	
		`case-seq-num`, count(*) as cnt, max(id) as maxid
	from  evictions.cases
	group by `case-cnty-code`, `case-indx-year`, `case-indx-numb`,	`case-seq-num`
	having count(*) > 1
	order by cnt desc;

select * from evictions.dupids;

delete from evictions.cases 
	where id in 
		(select distinct maxid from evictions.dupids);

alter table evictions.cases drop `id`;

create unique index cases on evictions.cases (`case-cnty-code`, `case-indx-year`, `case-indx-numb`,	`case-seq-num`);
create unique index caseid on evictions.cases (`case-id`);

select * from cases limit 100;