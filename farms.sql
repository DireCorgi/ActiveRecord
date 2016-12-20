CREATE TABLE chickens (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  color VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES farmer(id)
);

CREATE TABLE cows (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  color VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES farmer(id)
);

CREATE TABLE farmers (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  age INTEGER NOT NULL,
  farm_id INTEGER,

  FOREIGN KEY(farm_id) REFERENCES farmer(id)
);

CREATE TABLE farms (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  state VARCHAR(255) NOT NULL,
  acres INTEGER NOT NULL
);

INSERT INTO
  farms (id, name, state, acres)
VALUES
  (1, "Sunnyside Farm", "North Virginia", 330),
  (2, "John & Peter Organic Valley", "New York", 420),
  (3, "Corgi Ranch", "Michigan", 120),
  (4, "Mega Farm", "Kansas", 900);

INSERT INTO
  farmers (id, fname, lname, age, farm_id)
VALUES
  (1, "Pete", "Smith", 39, 1),
  (2, "Martha", "Smith", 36, 1),
  (3, "Josh", "Smith", 8, 1),
  (4, "John", "Klar", 32, 2),
  (5, "Peter", "Klar", 31, 2),
  (6, "Frank", "Ye", 32, 3),
  (7, "Harry", "Stine", 74, 4),
  (8, "Bill", "Wiggins", 26, NULL);

INSERT INTO
  chickens (id, name, color, owner_id)
VALUES
  (1, "Steve", "brown", 1),
  (2, "Bob", "brown", 1),
  (3, "Joe", "white", 1),
  (4, "Piper", "brown", 3),
  (5, "Jessie", "black", 4),
  (6, "Maggie", "white", 4),
  (7, "Jenkins", "brown", 5),
  (8, "Chicken1", "brown", 7),
  (9, "Chicken2", "brown", 7),
  (10, "Chicken3", "brown", 7);

INSERT INTO
  cows (id, name, color, owner_id)
VALUES
  (1, "Candice", "brown", 1),
  (2, "Carrot", "spotted", 2),
  (3, "Niku", "brown", 4),
  (4, "Runaway", "brown", NULL),
  (5, "Corgi", "brown", 6),
  (6, "Cow1", "brown", 7),
  (7, "Cow2", "spotted", 7),
  (8, "Cow3", "spotted", 7);
