drop table works;
drop table employee;
drop table company;

create table company(company_name varchar(50), city varchar(20), primary key (company_name, city));
create table employee(ID varchar(5), person_name varchar(10), street varchar(20), city varchar(20), primary key (ID));
create table works(ID varchar(5), company_name varchar(50), city varchar(20), salary int, primary key (ID), foreign key (ID) references employee (ID), foreign key (company_name, city) references company (company_name, city));

insert into company values ('First Bank Corporation', 'Brooklyn');
insert into company values ('First Bank Corporation', 'Palo Alto');
insert into company values ('First Bank Corporation', 'Horseneck');
insert into company values ('Second Bank Corporation', 'Palo Alto');
insert into company values ('Big Bank Corporation', 'Horseneck');
insert into company values ('Small Bank Corporation', 'Brooklyn');
insert into company values ('Small Bank Corporation', 'Palo Alto');

insert into employee values ('12345', 'Adams', 'Spring', 'Pittsfield');
insert into employee values ('11111', 'Brooks', 'Senator', 'Brooklyn');
insert into employee values ('22222', 'Curry', 'North', 'Rye');
insert into employee values ('33333', 'Glenn', 'Sand Hill', 'Woodside');
insert into employee values ('44444', 'Green', 'Walnut', 'Stamford');
insert into employee values ('55555', 'Hayes', 'Main', 'Harrison');
insert into employee values ('66666', 'Johnson', 'Alma', 'Palo Alto');
insert into employee values ('77777', 'Jones', 'Main', 'Harrison');
insert into employee values ('88888', 'Lindsay', 'Park', 'Pittsfiled');
insert into employee values ('99999', 'Smith', 'North', 'Rye');
insert into employee values ('00000', 'Turner', 'Putnam', 'Stamford');
insert into employee values ('54321', 'Williams', 'Nassau', 'Princeton');

insert into works values ('12345', 'First Bank Corporation', 'Brooklyn', 11000);
insert into works values ('11111', 'Second Bank Corporation', 'Palo Alto', 12000);
insert into works values ('22222', 'First Bank Corporation', 'Brooklyn', 22000);
insert into works values ('33333', 'Big Bank Corporation', 'Horseneck', 200000);
insert into works values ('44444', 'Second Bank Corporation', 'Palo Alto', 23000);
insert into works values ('55555', 'Big Bank Corporation', 'Horseneck', 120000);
insert into works values ('66666', 'Small Bank Corporation', 'Brooklyn', 9500);
insert into works values ('77777', 'First Bank Corporation', 'Palo Alto', 8000);
insert into works values ('88888', 'Second Bank Corporation', 'Palo Alto', 10000);
insert into works values ('99999', 'Big Bank Corporation', 'Horseneck', 110000);
insert into works values ('00000', 'Small Bank Corporation', 'Palo Alto', 11000);
insert into works values ('54321', 'Big Bank Corporation', 'Horseneck', 90000);

