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

select * from animal;
select * from sponsors;

select * 
from animal
join sponsors on (animal.animal_id = sponsors.animal_id);


# Modified Query 1: Looking for kid-friendly dogs with breed containing "spaniel" 
# (removed the age and price constraints that were filtering out matches)
select * 
from animal
left join sponsors on (animal.animal_id = sponsors.animal_id)
where (kidFriendly = 1) 
  and (breed like "%spaniel%") 
  and (type = "dog");
    
# Query 2: Looking for homes for animals in Boston 

# Part 1: All people in Boston who could adopt
select person_id, firstName, lastName, city, state
from person
where (city = "Boston") and (state = "MA");

# Part 2: All shelters in Boston with capacity
select *
from place
where (city = "Boston") and (state = "MA");
        

# Example query 3: A shelter looking to hire workers in the same city that already 
# owns a turtle
select *
from person
join animalHome on (person.person_id = animalHome.person_id)
join animal on (animalHome.animal_id = animal.animal_id)
where (animal.type = "turtle") and (person.city = "Boston") and (person.state = "MA");
    
# Query 4: Find all animals that are currently in shelters (places), 
# showing shelter city and state
SELECT animal.animal_id, animal.name, animal.type, animal.breed, 
       place.place_id, place.city, place.state
FROM animal
JOIN animalHome ON animal.animal_id = animalHome.animal_id
JOIN place ON animalHome.place_id = place.place_id
ORDER BY place.city, animal.type;

# Query 5: List all sponsors with the animals they support and the sponsorship amount
SELECT company.companyName, animal.name, animal.type, sponsors.amount,
       (animal.adoptionPrice - sponsors.amount) AS discounted_price
FROM sponsors
JOIN company ON sponsors.company_id = company.company_id
JOIN animal ON sponsors.animal_id = animal.animal_id
WHERE sponsors.animal_id IS NOT NULL
ORDER BY sponsors.amount DESC;


# Query 6: Find people in Boston who might be interested in adopting another animal
SELECT person.person_id, person.firstName, person.lastName, 
       COUNT(animalHome.animal_id) AS current_pets,
       GROUP_CONCAT(animal.type) AS pet_types
FROM person
LEFT JOIN animalHome ON person.person_id = animalHome.person_id
LEFT JOIN animal ON animalHome.animal_id = animal.animal_id
WHERE person.city = 'Boston' AND person.state = 'MA'
GROUP BY person.person_id
ORDER BY current_pets;

# Query 7: Find shelters with the most capacity available
SELECT place.place_id, place.city, place.state, place.capacity,
       COUNT(animalHome.animal_id) AS current_animals,
       (place.capacity - COUNT(animalHome.animal_id)) AS available_capacity
FROM place
LEFT JOIN animalHome ON place.place_id = animalHome.place_id
GROUP BY place.place_id
ORDER BY available_capacity DESC;