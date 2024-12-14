-- Create your tables, views, functions and procedures here!
CREATE SCHEMA destruction;
USE destruction;

CREATE TABLE players (
  player_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  email VARCHAR(50)
);
  
CREATE TABLE characters (
  character_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  player_id INT UNSIGNED NOT NULL,
  name VARCHAR(30) NOT NULL,
  level INT UNSIGNED,
  FOREIGN KEY (player_id)
    REFERENCES players (player_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE winners ( 
  character_id INT UNSIGNED PRIMARY KEY NOT NULL,
  name VARCHAR(30) NOT NULL,
  FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE character_stats ( 
  character_id INT UNSIGNED PRIMARY KEY NOT NULL,
  health INT UNSIGNED,
  armor INT UNSIGNED,
  FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE teams (
  team_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT, 
  name VARCHAR(30) NOT NULL
);

CREATE TABLE team_members (
  team_member_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  team_id INT UNSIGNED NOT NULL,
  character_id INT UNSIGNED NOT NULL,
  FOREIGN KEY (team_id)
    REFERENCES teams (team_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE items (
  item_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  armor INT UNSIGNED,
  damage INT UNSIGNED
);

CREATE TABLE inventory (
  inventory_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  character_id INT UNSIGNED NOT NULL,
  item_id INT UNSIGNED NOT NULL,
  FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (item_id)
    REFERENCES items (item_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE equipped (
  equipped_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  character_id INT UNSIGNED NOT NULL,
  item_id INT UNSIGNED NOT NULL,
  FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (item_id)
    REFERENCES items (item_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE OR REPLACE VIEW character_items AS
  SELECT characters.character_id,
         characters.name AS character_name,
         items.name AS item_name,
         items.armor,
         items.damage
  FROM characters 
  INNER JOIN inventory ON characters.character_id = inventory.character_id
  INNER JOIN items ON inventory.item_id = items.item_id;

CREATE OR REPLACE VIEW team_items AS
  SELECT teams.team_id,
         teams.name AS team_name,
         items.name AS item_name,
         items.armor,
         items.damage
  FROM teams 
  INNER JOIN team_members ON teams.team_id = team_members.team_id
  INNER JOIN inventory ON team_members.character_id = inventory.character_id
  INNER JOIN items ON inventory.item_id = items.item_id;


SELECT * FROM character_items;
SELECT * FROM team_items;

DELIMITER ;;
CREATE FUNCTION armor_total(character_id INT UNSIGNED)
RETURNS INT UNSIGNED
READS SQL DATA
BEGIN
  DECLARE total_armor INT UNSIGNED DEFAULT 0;

  SELECT COALESCE(armor, 0) INTO total_armor
    FROM character_stats
    WHERE character_id = character_id;

  SELECT SUM(items.armor) INTO total_armor
    FROM equipped
    INNER JOIN items ON equipped.item_id = items.item_id
    WHERE equipped.character_id = character_id;
  
  RETURN total_armor;
END;;
DELIMITER ;
