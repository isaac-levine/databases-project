drop database if exists adoptables;
create database adoptables;

use adoptables;

drop table if exists animal;
create table animal(
	animal_id int primary key,
    type varchar(50) not null,
    breed varchar(50),
    name varchar(50) not null,
    dob date,
    kidFriendly tinyint not null,
    pottyTrained tinyint,
    adoptionPrice varchar(50)
);

drop table if exists animalHome;
create table animalHome(
	animalHome int primary key,
    animal_id int not null,
    person_id int,
    place_id int,
    check ((person_id is not null and place_id is null) 
    or (place_id is not null and person_id is null))
);

drop table if exists person;
create table person(
	person_id int primary key,
    place_id int,
    firstName varchar(50) not null,
    lastName varchar(50) not null,
    city varchar(50) not null,
    state varchar(2) not null
);

drop table if exists place;
create table place(
	place_id int primary key,
    city varchar(50) not null,
    state varchar(2) not null,
    capacity int
);

drop table if exists sponsors;
create table sponsors(
	company_id int not null,
    place_id int,
    animal_id int,
    amount int not null,
    check ((animal_id is not null and place_id is null) 
    or (place_id is not null and animal_id is null))
);

drop table if exists company;
create table company(
	company_id int primary key,
    companyName varchar(50) not null
);

# Example query 1: Someone looking for a potty trained dog under the age of 3. 
# The person has kids, prefers spaniels, and has a budget of $300.
select * 
from animal
join sponsors on (animal.animal_id = sponsors.animal_id)
where (kidFriendly = 1) and (breed = "%spaniel%") and ((year(CURRENT_TIMESTAMP) - year(dob)) < 3)
	and (adoptionPrice is not null and ((adoptionPrice < 300) or (adoptionPrice-sponsors.amount < 300)));
    
# Example query 2: A shelter trying to place a cat in Boston. The cat can go to 
# either a shelter or a person
select *
from person
where (city = "Boston") and (state = "MA");
select *
from place
where (city = "Boston") and (state = "MA")
	and ((place_id in (select animalHome.place_id
			from animalHome
			join place on (animalHome.place_id = place.place_id)
			group by animalHome.place_id
            having count(animalHome.animal_id)<place.capacity))
		or capacity = null);
        
# Example query 3: A shelter looking to hire workers in the same city that already 
# owns a turtle
select *
from person
join animalHome on (person.person_id = animalHome.person_id)
join animal on (animalHome.animal_id = animal.animal_id)
where (animal.type = "turtle") and (person.city = "Boston") and (person.state = "MA")
	and (person.place_id = null);