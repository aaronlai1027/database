#Q1
select count(productcode) numProducts from product;

#Q2
select cc.compcatname, c.compname, r.qty, u.unitname
from recipeitem r 
left join product p on r.productcode = p.productcode
left join component c on r.compid = c.compid
left join componentcategory cc on r.compcatid = cc.compcatid
left join unit u on r.unitid = u.unitid
where productname = 'turtle sundae'
order by r.recipeitemid;

#Q3
select e.eventname, e.eventstart, sum(i.qty) NumOfCones
from event e
join ticket t on t.eventid = e.eventid
join productsold ps on t.ticketid = ps.ticketid
join product p on  ps.productcode = p.productcode
join itemsold i on ps.productsoldid = i.productsoldid
join component c on i.compid = c.compid
join componentcategory cc on cc.compcatid = c.compcatid
join location l on e.locationid = l.locationid
where cc.compcatname = 'cone'  and l.locationname = 'Valhalla'
group by e.eventname, e.eventstart;

#Q4
drop view if exists ticketprice;
create view ticketprice as
select t.ticketid, t.eventid, t.tickettime, t.soldby, t.numproducts, m.menuid, sum(price) totalPrice
from ticket t
join productsold ps on t.ticketid = ps.ticketid
join product p on  ps.productcode = p.productcode
join menuitem mi on p.productcode = mi.productcode
join menu m on m.menuid = mi.menuid
join event e on e.eventid = t.eventid and e.menuid = m.menuid
group by t.ticketid, t.numproducts;

select * from ticketprice;

alter table ticket
add totalPrice decimal(5,2);

set SQL_SAFE_UPDATES = 0;

update ticket inner join ticketprice
on ticket.ticketid = ticketprice.ticketid
set ticket.totalPrice = ticketprice.totalPrice;

select ticketid, numproducts, totalPrice
from ticket where ticketid in (170,1089)
order by ticketid;

#Q5a
select a.eventid, a.eventname, a.locationname, round(a.money/a.NumOfHour, 2) PricePerHour
from(
	select e.eventid, e.eventname, l.locationname, e.eventstart, e.eventend, sum(mi.price) money, 
		round(time_to_sec(timediff(e.eventend, e.eventstart))/3600, 2) NumOfHour
	from ticket t
	join productsold ps on t.ticketid = ps.ticketid
	join product p on  ps.productcode = p.productcode
	join menuitem mi on p.productcode = mi.productcode
	join menu m on m.menuid = mi.menuid
	join event e on e.eventid = t.eventid and e.menuid = m.menuid
	join location l on e.locationid = l.locationid
	group by e.eventid) a
order by PricePerHour desc
limit 10;

#Q5b
select a.eventid, a.eventname, a.locationname, round(a.money/a.NumOfHour, 2) PricePerHour
from(
	select e.eventid, e.eventname, l.locationname, e.eventstart, e.eventend, sum(mi.price) money, 
		round(time_to_sec(timediff(e.eventend, e.eventstart))/3600, 2) NumOfHour
	from ticket t
	join productsold ps on t.ticketid = ps.ticketid
	join product p on  ps.productcode = p.productcode
	join menuitem mi on p.productcode = mi.productcode
	join menu m on m.menuid = mi.menuid
	join event e on e.eventid = t.eventid and e.menuid = m.menuid
	join location l on e.locationid = l.locationid
	where e.eventname like '%college%'
	group by e.eventid) a
order by PricePerHour desc
limit 2;

#Q6a
select c.compcatid, c.compname, count(cc.compcatname) Quantity
from ticket t
	join productsold ps on t.ticketid = ps.ticketid
	join product p on  ps.productcode = p.productcode 
	join itemsold io on io.productsoldid = ps.productsoldid
    join component c on c.compid = io.compid
    join componentcategory cc on cc.compcatid = c.compcatid and cc.compcatname in ( 'topping', 'flavor')
    where p.productname like '%cone%' or p.productname like '%dish%' or p.productname like '%topping%'
    group by c.compname, c.compcatid
    order by Quantity desc;
    #limit 3;

#Q6b
select *
from component c 
where c.compid not in(
select c.compid
from ticket t
	join productsold ps on t.ticketid = ps.ticketid
	join product p on  ps.productcode = p.productcode 
	join itemsold io on io.productsoldid = ps.productsoldid
    join component c on c.compid = io.compid
    join componentcategory cc on cc.compcatid = c.compcatid);

#Q7a
insert into location ()
values (33,'Willy''s hub', 'RMC Basement', 'Houston', 'TX', '77005');

insert into componentcategory ()
values (19, 'alcoholic beverage');

insert into component () 
values (74, 'beer', 19);

insert into product ()
values ('be', 'beer')
, ('bd', 'beer floats');

insert into recipeitem (recipeitemid, productcode, compcatid, qty, unitid, compid)
values (130, (select productcode from product where productname = 'beer'), (select compcatid from componentcategory where compcatname = 'alcoholic beverage'), 1, 2, (select compid from component where compname ='beer'))
, (131, (select productcode from product where productname = 'beer floats'), (select compcatid from componentcategory where compcatname = 'alcoholic beverage'), 12, 1, (select compid from component where compname ='beer'))
, (132, (select productcode from product where productname = 'beer floats'), (select compcatid from componentcategory where compcatname = 'alcoholic beverage'), 5, 1, null) 
, (133, (select productcode from product where productname = 'beer floats'), 13, 1, 3, 41) 
, (134, (select productcode from product where productname = 'beer floats'), 5, 1, 3, 38)
, (135, (select productcode from product where productname = 'beer floats'), 14, 1, 3, 46);

insert into menu ()
values (5, 'Beer event');

insert into menuitem ()
values (63, 5, 'be', 5.00)
,(64, 5, 'dk', 1.00)
,(65, 5, 'bd', 7.00);

insert into event ()
values (80, 'Beer Debate', '2017-11-09 19:00:00', '2017-11-9 23:00:00', 33, 5);

#Q7b
select m.menuname, p.productcode, p.productname, mi.price
from menu m
join menuitem mi on m.menuid = mi.menuid
join product p on p.productcode = mi.productcode
where m.menuid = 5
order by p.productcode;

#Q7c
select cc.compcatname, c.compname, r.qty, u.unitname
from recipeitem r 
left join product p on r.productcode = p.productcode
left join component c on r.compid = c.compid
left join componentcategory cc on r.compcatid = cc.compcatid
left join unit u on r.unitid = u.unitid
where productname = 'beer floats'
order by r.recipeitemid;

#8a
update menu
set menuname = 'Beer Debate Menu'
where menuname = 'Beer event';

#8b
select m.menuname, p.productcode, p.productname, mi.price
from menu m
join menuitem mi on m.menuid = mi.menuid
join product p on p.productcode = mi.productcode
where m.menuname = 'Beer Debate Menu' or m.menuname = 'Beer event'
order by p.productcode;


#Short Answer 1
#if the string length is fixed like location state, I would use char type to save the time in computing.
#if the string length is not fixed like location name, I would use varchar type to save the storage.


#Short Answer 2
#if the number of data is integer and could increases to a large number like productsold ID, I would use int to ensure the data accuracy.
#if the number of data is integer and small like quantity, I would use smallint or tinyint to save the storage.
#if the number of data has both the integer part and the fractional part like quantity, I would use decimal to ensure the data accuracy.

#Survey
#N = 15

 
select * from recipeitem;
select * from itemsold;
select * from event;
select * from productsold;
select * from product;
select * from ticket;
select * from location;
select * from component;
select * from componentcategory;
select * from menuitem;
select * from menu;
select * from unit;
select * from event;