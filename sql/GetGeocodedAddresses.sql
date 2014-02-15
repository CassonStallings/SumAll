
create schema if not exists hb;
create schema if not exists exits;
create schema if not exists evictions;
create schema if not exists working;

drop table if exists exits.exit_adds;
drop table if exists exits.entry_adds;
drop table if exists hb.hb_adds;
drop table if exists evictions.eviction_adds;

# Read data file with addresses from Entries, Exits, HB, and Evictions;

use working;

drop table if exists all_adds;
create table all_adds 
	(
	fid int,
	b int,
	dbcode char(1),
	id int,
	apn char(20),
	strtno char(10),
	strt char(32),       
	boroughcode int,
	i char(10), j char(10),	k char(10), 
	l int,	m char(4),  n char(20), o char(20), 
	spx int8, spy int8, 
	latitude float8, longitude float8);

LOAD DATA LOCAL INFILE 'T:/tmp/uniqueaddswithll_tab.txt'
IGNORE
INTO TABLE `all_adds`
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n';

alter table all_adds
	drop fid, drop b, drop dbcode, 
	drop id, drop i, drop j, drop k, 
	drop l, drop m, drop n, drop o;

# 439608 Unique addresses
create table all_adds2 as select distinct * from all_adds;

create index idindex on all_adds(apn, strtno, strt, boroughcode);


# Read in the addresses output from python with ids and standardized fields
# Home Base enrollments (hbenrollments2.txt)

drop table if exists hb_id_std;

create table hb_id_std
	(id int, jid int, 
	strtno char(20),
	strt char(50),
	apn char(20), 
	borough char(24),
	zip char(5),
	jid2 int,
	jcode char(2),
	apn_std char(20),
	strtno_std char(20),
	strt_std char(50),
	boroughcode_std int);


LOAD DATA LOCAL INFILE 'T:/tmp/hbenrollments2.txt'
IGNORE
INTO TABLE hb_id_std
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n';

create index idindex on hb_id_std (apn_std, strtno_std, strt_std, boroughcode_std);



# Get the evictions2 with ids and standardized addresses

drop table if exists evic_id_std;

create table evic_id_std
	(id int, 
	`case-type` char(1),
	`case-cnty-code` char(2),
	`case-indx-year` char(4),
	`case-indx-numb` char(7),	
	`case-seq-num` char(3),
	`case-id` char(16),
	h char (50), j char(50), k char(50), l char(50), m char(50), 
	n char(50), o char(50), p char(50), q char(50),	r char(50), 
	s char(50), t char(50),	u char(50), v char(50),	w char(50), 
	x char(50), y char(50), z char(50), aa char(75), ab char(50),
	ac char(100), ad char(50), ae char(50), af char(50),	ag char(50),
	ah char(50), ai char(50), aj char(50), ak char(50), al char(50),
	am char(50), an char(50), ao char(50), ap char(50), aq char(50), 
	ar char(50),  as1 char(50), at1 char(50), av char(50), 
	aw char(50), ax char(50), ay char(50), az char(50), ba char(50),
	bb char(50), bc char(50), bd char(50), 
	servstrtno char(20), servstrt char(50), servapn char(20),
	servborough char(24), servstate char(2), servzip9 char(9),
	id3 int,  datasetcode char(2),
	apn_std char(16),
	strtno_std char(10),
	strt_std char(50),
	boroughcode_std int);

LOAD DATA LOCAL INFILE 'T:/tmp/evictions2.txt' 
IGNORE
INTO TABLE evic_id_std
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n';


alter table evic_id_std
	drop h, drop j, drop k, drop l, drop m,
	drop n, drop o, drop p, drop q,
	drop r, drop s, drop t, drop u,
	drop v, drop w, drop x, drop y,
	drop z, drop aa, drop ab, drop ac,
	drop ad, drop ae, drop af, drop ag, 
	drop ah, drop ai, drop aj, drop ak, 
	drop al, drop am, drop an, drop ao,
	drop ap, drop aq, drop ar, drop as1,
	drop at1, drop av, drop aw, drop ax,
	drop ay, drop az, drop ba, drop bb,
	drop bc, drop bd;


create index idindex on evic_id_std (apn_std, strtno_std, strt_std, boroughcode_std);


# Get Exits2.txt with familiy IDs and standardized addresses
# 901,214 records

drop table if exists exit_id_std;

create table exit_id_std
	(id int, 
	`FAMILY_ID_rcd` char(10),
	`CASE_NUMBER_rcd` char(10),
	`CARES_ID_rcd` char(10),
	`N` char(7),	
	`ORIGIN_DT` char(10),
	`UNITBED_START_DT` char(19),
	`UNITBED_END_DT` char(19),
	`EXIT_DT` char(19),
	j char(50), k char(50), l char(50), m char(50), 
	n2 char(50), o char(50), p char(50), q char(50),	r char(50), 
	s char(50), t char(80),	u char(50), v char(50),	w char(50), 
	x char(50), y char(50), z char(50), aa char(50), ab char(50),
	ac char(100), ad char(50), ae char(50), af char(50),	
	ag char(50), ah char(50), 
	id2 int,  datasetcode char(2),
	apn_std char(16),
	strtno_std char(10),
	strt_std char(50),
	boroughcode_std int(1));



LOAD DATA LOCAL INFILE 'T:/tmp/exits2.txt' 
IGNORE
INTO TABLE exit_id_std
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n';

alter table exit_id_std
	drop j, drop k, drop l, drop m,
	drop n, drop o, drop p, drop q,
	drop r, drop s, drop t, drop u,
	drop v, drop w, drop x, drop y,
	drop z, drop aa, drop ab, drop ac,
	drop ad, drop ae, drop af, drop ag, 
	drop ah;


create index idindex on exit_id_std (apn_std, strtno_std, strt_std, boroughcode_std);


# Get the entrants2.txt. Identical to exits2 except with standardized entrance adds

drop table if exists entry_id_std;

create table entry_id_std
	(id int, 
	`FAMILY_ID_rcd` char(10),
	`CASE_NUMBER_rcd` char(10),
	`CARES_ID_rcd` char(10),
	`N` char(7),	
	`ORIGIN_DT` char(10),
	`UNITBED_START_DT` char(19),
	`UNITBED_END_DT` char(19),
	`EXIT_DT` char(19),
	j char(50), k char(50), l char(50), m char(50), 
	n2 char(50), o char(50), p char(50), q char(50),	r char(50), 
	s char(50), t char(50),	u char(50), v char(50),	w char(50), 
	x char(50), y char(50), z char(50), aa char(50), ab char(50),
	ac char(100), ad char(50), ae char(50), af char(50),	
	ag char(50), ah char(50), 
	id2 int,  datasetcode char(2),
	apn_std char(16),
	strtno_std char(10),
	strt_std char(50),
	boroughcode_std int(1));


LOAD DATA LOCAL INFILE 'T:/tmp/entrants2.txt' 
IGNORE
INTO TABLE entry_id_std
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n';

alter table entry_id_std
	drop j, drop k, drop l, drop m,
	drop n, drop o, drop p, drop q,
	drop r, drop s, drop t, drop u,
	drop v, drop w, drop x, drop y,
	drop z, drop aa, drop ab, drop ac,
	drop ad, drop ae, drop af, drop ag, 
	drop ah;

create index idindex on entry_id_std (apn_std, strtno_std, strt_std, boroughcode_std);


##################################################################################


# Join homebase enrollment ids with locations using the standarized addresses;

drop table if exists hb.hb_adds;

create table hb.hb_adds as
	select distinct h.id, h.apn_std, h.strtno_std, h.strt_std, h.boroughcode_std,
		#a.apn, a.strtno, a.strt, a.boroughcode, a.dbcode,
		a.spx, a.spy, a.latitude, a.longitude
	from hb_id_std h left join working.all_adds a
	on apn_std=a.apn 
		and strtno_std=a.strtno
		and strt_std=a.strt
		and boroughcode_std=a.boroughcode;




# Join eviction id fields with locations using the standarized addresses;

drop table if exists evictions.evic_adds;

create table evictions.evic_adds as
	select distinct e.id, 
		`case-type`, `case-cnty-code`, 
		`case-indx-year`, `case-indx-numb`, 
		`case-seq-num`, `case-id`, 
		apn_std, strtno_std, strt_std, boroughcode_std,
		a.spx, a.spy, a.latitude, a.longitude
	from evic_id_std e left join all_adds a
	on apn_std=a.apn 
		and strtno_std=a.strtno
		and strt_std=a.strt
		and boroughcode_std=a.boroughcode;




# Join shelter exit ids with locations using the standarized addresses;
# 901,214 records

drop table if exists exits.exit_adds;

create table exits.exit_adds as
	select distinct e.id, `FAMILY_ID_rcd`,
	`CASE_NUMBER_rcd`, `CARES_ID_rcd`,
	`ORIGIN_DT`, `UNITBED_START_DT`,
	`UNITBED_END_DT`, `EXIT_DT`, 
		apn_std, strtno_std, strt_std, boroughcode_std,
		a.spx, a.spy, a.latitude, a.longitude
	from exit_id_std e left join all_adds a
	on apn_std=a.apn 
		and strtno_std=a.strtno
		and strt_std=a.strt
		and boroughcode_std=a.boroughcode;


# Join entrants enrollment ids with locations using the standarized addresses;
# 901205 records 

drop table if exists exits.entry_adds;

create table exits.entry_adds as
	select distinct e.id, `FAMILY_ID_rcd`,
	`CASE_NUMBER_rcd`, `CARES_ID_rcd`,
	`ORIGIN_DT`, `UNITBED_START_DT`,
	`UNITBED_END_DT`, `EXIT_DT`, 
		apn_std, strtno_std, strt_std, boroughcode_std,
		a.spx, a.spy, a.latitude, a.longitude
	from entry_id_std e left join all_adds a
	on apn_std=a.apn 
		and strtno_std=a.strtno
		and strt_std=a.strt
		and boroughcode_std=a.boroughcode;

# Output tables to csv

SELECT * INTO OUTFILE 't:/tmp/evic_adds.txt'
  FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  FROM evictions.evic_adds;

	
SELECT * INTO OUTFILE 't:/tmp/hb_adds.txt'
  FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  FROM hb.hb_adds;

SELECT * INTO OUTFILE 't:/tmp/entry_adds.txt'
  FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  FROM exits.entry_adds;

SELECT * INTO OUTFILE 't:/tmp/exit_adds.txt'
  FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  FROM exits.exit_adds;