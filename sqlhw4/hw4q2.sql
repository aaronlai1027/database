ALTER TABLE event
ADD valid tinyint default 0;

update event 
set valid = 1;

create table eventIssue (
neweventid int not null,
neweventname varchar(50) not null,
newstart datetime not null,
newend datetime not null,
existeventid int not null,
existeventname varchar(50) not null,
existstart datetime not null,
existend datetime not null,
status varchar(30)
);

delimiter //
drop trigger if exists insertevent //
create trigger insertevent 
after insert on event 
for each row
	begin
		
		DECLARE done INT DEFAULT 0; 
        declare oid int;
        declare ona varchar(50);
        declare os datetime;
        declare oe datetime;
        declare ce cursor for select eventid, eventName, eventStart, eventend from event;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
		
        open ce;
        read_loop:loop
        fetch ce into oid, ona, os, oe;
        
        if done THEN 
		leave read_loop; 
		end if; 
        
        if oe > new.eventStart and new.eventEnd > os 
		then insert  into eventIssue (neweventid, neweventname, newstart, newend, existeventid, existeventname, existstart, existend, status)
			 value (new.eventid, new.eventname, new.eventstart, new.eventend, oid, ona, os, oe, 'overlaps');
		elseif timestampdiff(minute,new.eventend, os) < 30
        then insert  into eventIssue (neweventid, neweventname, newstart, newend, existeventid, existeventname, existstart, existend, status)
			 value (new.eventid, new.eventname, new.eventstart, new.eventend, oid, ona, os, oe, 'travel');
		elseif timestampdiff(minute,new.eventstart, oe) < 30
        then insert  into eventIssue (neweventid, neweventname, newstart, newend, existeventid, existeventname, existstart, existend, status)
			 value (new.eventid, new.eventname, new.eventstart, new.eventend, oid, ona, os, oe, 'travel');
		end if;
        end loop;
        close ce;
	end//
delimiter ;

INSERT INTO event(eventName, eventStart, eventEnd, locationId, menuId) VALUES
('Mid afternoon tea', '2017-03-09 14:15:00', '2017-03-09 14:45:00', 24, 1), ('Dessert Bar', '2017-01-19 13:30:00', '2017-01-19 16:00:00', 25, 4),
('Ice cream for lunch', '2017-05-06 11:00:00', '2017-05-06 16:00:00', 17, 3);

SELECT *
FROM event where eventName in ('Dessert Bar', 'Ice cream for lunch', 'Mid after- noon tea')
ORDER BY eventName;

SELECT *
FROM eventIssue
ORDER BY newEventName;



show triggers;
select * from ticket;
select * from event;
select * from eventissue;

select eventid,
if locationid > 9 then locationid
elseif locationid > 4 then 100
else 0
end
from event
order by eventid;


