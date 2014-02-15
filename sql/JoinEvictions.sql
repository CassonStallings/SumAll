
drop table if exists evictions.evictions0;
drop table if exists evictions.evictions;


create table evictions.evictions0 as
	select c.*, x.*
	from evictions.cases c left join  evictions.xrefs x
	on c.`case-id`=x.`xref-id`;
	
# This always times out after 10 minutes
#create table evictions.evictions1 as
#	select c.*, wc.*
#	from evictions0 c inner join evictions.`warr-count` wc
#	on c.`case-id`=wc.`warr-id`;


set @rn := 0;
create table evictions as
	select @rn:=@rn+1 as rowid, x.* 
		from  (select * from evictions0) x;



/*
create table headers as
	select * from evictions limit 2;

create table first as 
	select * from evictions
		where rowid < 500000;

create table second as 
	select * from evictions
		where rowid >= 500000;
*/
#select * into outfile 't:\\tmp\\evictions_table.txt'
#	fields terminated by ','
#	from evictions 