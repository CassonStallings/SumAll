create database if not exists evictions;

create table if not exists evictions2.warrents (
	id int, 
	oldid int,
	`warr-type` char(1),
	`warr-cnty-code` char(2),
	`warr-indx-year` char(4),
	`warr-indx-numb` char(7),
	`warr-sourc-type` char(2),
	`warr-sourc-num` char(3),
	`warr-seq-num` char(3),
	`warr-return-dte` date,
	`warr-by-whom` char(1),
	`warr-used` char(1),
	`warr-recvd-dte` date,
	`warr-stayed-dte` date,
	`warr-marshal` int(8) unsigned,
	`warr-marsh-dte` date,
	`warr-filler` text(339)
);

LOAD DATA LOCAL INFILE 'T:/Uncom/evictionsW.csv'
INTO TABLE `evictions`.`evictionsW`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';
