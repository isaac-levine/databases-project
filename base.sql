drop database if exists adoptables;
create database adoptables;

use adoptables;

drop table if exists animal;
create table animal(
	animal_id int primary key,
    type varchar(50) not null,
    breed varchar(50),
    name varchar(50) not null,
    dot date,
    kidFriendly tinyint not null,
    pottyTrained tinyint,
    adoptionPrice varchar(50)
);