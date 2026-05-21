CREATE TABLE chakras (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  chakra TEXT NOT NULL UNIQUE
);

CREATE TABLE elements (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  element TEXT NOT NULL UNIQUE CHECK (element IN ('Earth','Water','Air','Fire'))
);

CREATE TABLE planets (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  planet TEXT NOT NULL UNIQUE
);

CREATE TABLE suits (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  suit TEXT NOT NULL UNIQUE
);

CREATE TABLE tarot_cards (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  card_name TEXT NOT NULL,
  element_id INTEGER REFERENCES elements(id),
  chakra_id INTEGER REFERENCES chakras(id),
  arcana_type TEXT CHECK (arcana_type IN ('Major','Minor')),
  suit_id INTEGER REFERENCES suits(id),
  planet_id INTEGER REFERENCES planets(id),
  card_rank INTEGER
);

CREATE TABLE tarot_draws (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  draw_date DATE,
  card_id INTEGER REFERENCES tarot_cards(id)
);