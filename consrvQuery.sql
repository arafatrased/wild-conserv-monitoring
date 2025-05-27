-- Active: 1747581925403@@localhost@5432@conservation_db@public
CREATE TABLE rangers(
    ranger_id SERIAL PRIMARY key,
    name VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL
);

INSERT INTO rangers (name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');

SELECT * FROM rangers

CREATE Table species(
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(50) NOT NULL,
    scientific_name VARCHAR(70),
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) CHECK (conservation_status IN ('Endangered', 'Vulnerable'))
)


INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

SELECT * FROM species

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    species_id INT NOT NULL REFERENCES species(species_id),
    ranger_id INT NOT NULL REFERENCES rangers(ranger_id),
    location VARCHAR(150) NOT NULL,
    sighting_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL);


SELECT * FROM sightings

--Problem-1: Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'

INSERT INTO rangers (name, region)
VALUES ('Derek Fox', 'Coastal Plains');

SELECT * FROM rangers

--Problem-2: Count unique species ever sighted.

SELECT COUNT(DISTINCT species_id) AS unique_species_count
FROM sightings;

--Problem-3: Find all sightings where the location includes "Pass".
SELECT * FROM sightings
WHERE location ILIKE '%Pass%';

--Problem-4:  List each ranger's name and their total number of sightings.
SELECT rangers.name, COUNT(sightings.sighting_id) AS total_sightings
FROM rangers
LEFT JOIN sightings ON rangers.ranger_id = sightings.ranger_id
GROUP BY rangers.name
ORDER BY rangers.name;

--Problem-5: List species that have never been sighted.

SELECT species.common_name
FROM species
LEFT JOIN sightings ON species.species_id = sightings.species_id
WHERE sightings.species_id IS NULL;

--Problem-6: Show the most recent 2 sightings.
SELECT species.common_name, sightings.sighting_time, rangers.name
FROM sightings
JOIN species ON sightings.species_id = species.species_id
JOIN rangers ON sightings.ranger_id = rangers.ranger_id
ORDER BY sightings.sighting_time DESC
LIMIT 2;

--Problem-7: Update all species discovered before year 1800 to have status 'Historic'.

ALTER TABLE species DROP CONSTRAINT species_conservation_status_check;
ALTER TABLE species ADD CONSTRAINT species_conservation_status_check
CHECK (conservation_status IN ('Endangered', 'Vulnerable', 'Historic'));

UPDATE species 
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';

SELECT * FROM species

--Problem-8: Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.

SELECT 
  sighting_id,
  CASE
    WHEN EXTRACT(HOUR FROM sighting_time) < 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM sighting_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS time_of_day
FROM sightings;


--Problem-9:  Delete rangers who have never sighted any species

DELETE FROM rangers
WHERE ranger_id NOT IN (SELECT DISTINCT ranger_id FROM sightings);

SELECT * FROM rangers;

