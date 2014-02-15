
drop table if exists evictions.warrents;


create table if not exists evictions.warrants (
	`wid` int(8) auto_increment primary key,
	`warr-type` char(1),
	`warr-cnty-code` char(2),
	`warr-indx-year` char(4),
	`warr-indx-numb` char(7),
	`warr-seq-num` char(3),
	`warr-id` char(16),
	`warr-sourc-type` char(2),
	`warr-sourc-num` char(3),
	`warr-return-dte` date,
	`warr-by-whom` char(1),
	`warr-used` char(1),
	`warr-recvd-dte` date,
	`warr-stayed-dte` date,
	`warr-marshal` int(8) unsigned,
	`warr-marsh-dte` date);


#'T:/Uncom/dhs13.cnty62'
LOAD DATA LOCAL INFILE 'T:/Uncom/dhs_evictions_data.txt'
IGNORE
INTO TABLE `evictions`.`warrants`
LINES TERMINATED BY '\r\n'
(@l)
 set
	`warr-type` = SUBSTR(@l,1,1),
	`warr-cnty-code` = SUBSTR(@l,2,2),
	`warr-indx-year` = SUBSTR(@l,4,4),
	`warr-indx-numb` = SUBSTR(@l,8,7),
	`warr-sourc-type` = SUBSTR(@l,15,2),
	`warr-sourc-num` = SUBSTR(@l,17,3),
	`warr-seq-num` = SUBSTR(@l,20,3),
	`warr-return-dte` = str_to_date(SUBSTR(@l,23,8),'%Y%m%d'), 
	`warr-by-whom` = SUBSTR(@l,31,1),
	`warr-used` = SUBSTR(@l,32,1),
	`warr-recvd-dte` = str_to_date(SUBSTR(@l,33,8),'%Y%m%d'),
	`warr-stayed-dte` = str_to_date(SUBSTR(@l,41,8),'%Y%m%d'),
	`warr-marshal` = cast(SUBSTR(@l,49,8) as unsigned),
	`warr-marsh-dte` =  str_to_date(SUBSTR(@l,57,8),'$%Y%m%d'),
	`warr-id` = concat(SUBSTR(@l,2,13),SUBSTR(@l,20,3));


delete from `evictions`.`warrants` where `warr-type` != 'W';
create index warrid on evictions.warrants (`warr-id`);

#select distinct `warr-stayed-dte`, `warr-marsh-dte` from evictions.warrents;

#alter table evictions.warrents drop `warr-id`;

select * from evictions.warrants limit 200;

create table evictions.`warr-count` as
	select distinct `warr-id`, count(*) as `warrant-count`
	from evictions.warrants
	group by `warr-id`;


