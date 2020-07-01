DROP TABLE IF EXISTS itemSold;
DROP TABLE IF EXISTS productSold;
DROP TABLE IF EXISTS menuItem;
DROP TABLE IF EXISTS eventAssignment;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS eventIssue;
DROP TABLE IF EXISTS eventTask;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS recipeItem;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS component;
DROP TABLE IF EXISTS unit;
DROP TABLE IF EXISTS invLevel;
DROP TABLE IF EXISTS componentCategory;


CREATE TABLE IF NOT EXISTS product
(
	productCode char(3),
	productName varchar(25) NOT NULL,
	PRIMARY KEY(productCode),
	UNIQUE(productName)
);


CREATE TABLE IF NOT EXISTS componentCategory
(
	compCatId INTEGER AUTO_INCREMENT, 
	compCatName varchar(30) NOT NULL,
	PRIMARY KEY(compCatId),
	UNIQUE(compCatName)
);

CREATE TABLE IF NOT EXISTS component
(
	compId INTEGER AUTO_INCREMENT, 
	compName varchar(30) NOT NULL,
	compCatId INTEGER NULL,
	PRIMARY KEY(compId),
	FOREIGN KEY(compCatId) REFERENCES componentCategory(compCatId)
);

CREATE TABLE IF NOT EXISTS unit
(
	unitId integer AUTO_INCREMENT,
	unitName varchar(10) NOT NULL,
	PRIMARY KEY(unitId),
	UNIQUE (unitName)
);

CREATE TABLE IF NOT EXISTS recipeItem
(
	recipeItemId integer AUTO_INCREMENT,
	productCode char(3) NOT NULL,
	compCatId integer NOT NULL,
	qty float NOT NULL,
	unitId integer NOT NULL,
	compId integer NULL,
	PRIMARY KEY(recipeItemId),
	FOREIGN KEY(productCode) REFERENCES product(productCode),
	FOREIGN KEY(compCatId) REFERENCES componentCategory(compCatId),
	FOREIGN KEY(compId) REFERENCES component(compId),
	FOREIGN KEY(unitId) REFERENCES unit(unitId),
	UNIQUE(productCode,compCatId,compId)
);

CREATE TABLE IF NOT EXISTS location
(
	locationId integer AUTO_INCREMENT,
	locationName varchar(50) NOT NULL,
	locationAddress varchar(100) NULL,
	locationCity varchar(50) NULL,
	locationState char(2) NULL,
	locationZip char(5) NULL,
	PRIMARY KEY (locationId)
);


CREATE TABLE IF NOT EXISTS menu
(
	menuId integer AUTO_INCREMENT,
	menuName char(25),
	PRIMARY KEY(menuId),
	UNIQUE (menuName)
);

CREATE TABLE IF NOT EXISTS menuItem
(
	menuItemId integer AUTO_INCREMENT,
	menuId integer NOT NULL,
	productCode char(3) NOT NULL,
	price decimal (5,2) NOT NULL,
	PRIMARY KEY(menuItemId),
	UNIQUE(menuId, productCode),
	FOREIGN KEY(menuId) REFERENCES menu(menuId),
	FOREIGN KEY(productCode) REFERENCES product(productCode)
);

CREATE TABLE IF NOT EXISTS event
(
	eventId INTEGER AUTO_INCREMENT,
	eventName VARCHAR(100) NOT NULL,
	eventStart DATETIME NULL,
	eventEnd DATETIME NULL,
	locationId INTEGER NULL,
	menuId INTEGER NULL,
	PRIMARY KEY (eventId),
	FOREIGN KEY(locationId) REFERENCES location(locationId),
	FOREIGN KEY(menuId) REFERENCES menu(menuId)
);

CREATE TABLE IF NOT EXISTS employee
(
	employeeId integer AUTO_INCREMENT,
	firstName varchar(50) NOT NULL,
	lastName varchar(50) NOT NULL,
	DOB date NOT NULL,
	phone varchar(12) NULL,
	PRIMARY KEY(employeeId)
);


CREATE TABLE IF NOT EXISTS eventAssignment
(
	eventAssignmentId integer AUTO_INCREMENT,
	eventId integer NOT NULL,
	employeeId integer NOT NULL,
	PRIMARY KEY(eventAssignmentId),
	FOREIGN KEY(eventId) REFERENCES event(eventId),
	FOREIGN KEY(employeeId) REFERENCES employee(employeeId)
);

CREATE TABLE IF NOT EXISTS ticket
(
	ticketId integer AUTO_INCREMENT,
	eventId integer NOT NULL,
	ticketTime dateTime NOT NULL,
	soldBy integer NOT NULL,
	numProducts integer NOT NULL,
	totalPrice decimal(5,2) NULL,
	PRIMARY KEY (ticketId),
	FOREIGN KEY(eventId) REFERENCES event(eventId),
	FOREIGN KEY(soldBy) REFERENCES employee(employeeid)
);

CREATE TABLE IF NOT EXISTS productSold
(
	productSoldId integer AUTO_INCREMENT,
	productCode char(3) NOT NULL,
	ticketId integer NOT NULL,
	PRIMARY KEY(productSoldId),
	FOREIGN KEY(productCode) REFERENCES product(productCode),
	FOREIGN KEY(ticketId) REFERENCES ticket(ticketId)
);


CREATE TABLE IF NOT EXISTS itemSold
(
	itemSoldId integer AUTO_INCREMENT,
	productSoldId integer NOT NULL,
	compId integer NOT NULL,
	qty float NOT NULL,
	unitId integer NOT NULL,
	PRIMARY KEY(itemSoldId),
	FOREIGN KEY(productSoldId) REFERENCES productSold(productSoldId),
	FOREIGN KEY(compId) REFERENCES component(compId),
	FOREIGN KEY(unitId) REFERENCES unit(unitId)
);

LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/product.txt' INTO TABLE product fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/componentCategory.txt' INTO TABLE componentCategory fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/component.txt' INTO TABLE component fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/unit.txt' INTO TABLE unit fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/recipeItem.txt' INTO TABLE recipeItem fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/location.txt' INTO TABLE location fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/menu.txt' INTO TABLE menu fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/menuItem.txt' INTO TABLE menuItem fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/event.txt' INTO TABLE event fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/employee.txt' INTO TABLE employee fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/eventAssignment.txt' INTO TABLE eventAssignment fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/ticket.txt' INTO TABLE ticket fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/productSold.txt' INTO TABLE productSold fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/4code/data/itemSold.txt' INTO TABLE itemSold fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
