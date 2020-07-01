delimiter //
drop trigger if exists updateTicket//
create trigger updateTicket after insert on productSold for each row
	begin
		update ticket inner join (
        select t.ticketId, count(ps.productSoldid) numProducts, sum(mi.price) totalPrice
		from ticket t
		join productsold ps on t.ticketid = ps.ticketid
		join menuitem mi on ps.productcode = mi.productcode
		join menu m on m.menuid = mi.menuid
		join event e on e.eventid = t.eventid and e.menuid = m.menuid
		group by t.ticketid
		order by t.ticketid
		) a
        on ticket.ticketId = a.ticketid
        set ticket.numProducts = new.a.numProducts, ticket.totalPrice = new.a.totalPrice;
	end //
delimiter ;

INSERT INTO productSold(productCode, ticketId) VALUES ('bs', 187);

SELECT * FROM ticket WHERE ticketId = 187;


select * from productsold order by productSoldid desc;
select * from ticket;