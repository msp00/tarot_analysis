-- =========================
-- STRUCTRAL CHECKS
-- =========================

---------------------------------------------------

-- How many total draws have been recorded?

SELECT COUNT(*) AS num_draws
FROM tarot_draws;

-- | num_draws |
-- | ----- |
-- | 161   |

---------------------------------------------------

-- How many total tarot cards are in the dataset?

SELECT COUNT(*) AS num_cards
FROM tarot_cards;

-- | num_cards |
-- | --------- |
-- | 78        |

---------------------------------------------------

-- What is the date range of the draws?

SELECT MIN(draw_date) AS first_draw, MAX(draw_date) AS last_draw
FROM tarot_draws;

-- | first_draw | last_draw  |
-- | ---------- | ---------- |
-- | 2025-05-20 | 2025-10-28 |

---------------------------------------------------

-- Are there any missing values in card_id or draw_date?

SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN card_id IS NULL THEN 1 ELSE 0 END) AS missing_card_id,
  SUM(CASE WHEN draw_date IS NULL THEN 1 ELSE 0 END) AS missing_draw_date
FROM tarot_draws;

-- Note: I identified and removed a row in which no draw occurred on 10-14-2025, which will permit accurate analysis

---------------------------------------------------

-- Do any cards appear in the draws that are not in the tarot_cards table?

SELECT *
FROM tarot_draws d
LEFT JOIN tarot_cards c
ON d.card_id = c.id
WHERE c.id IS NULL;

-- Negative result here means all drawn cards are accounted for in the tarot_cards table, which is good data integrity.

---------------------------------------------------

-- Were there any days where more than one draw occurred?

SELECT draw_date, COUNT(draw_date) AS num_cards_drawn
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
GROUP BY draw_date
HAVING COUNT(draw_date) > 1;

-- No rows returned

---------------------------------------------------

-- =========================
-- CARD DISTRIBUTIONS
-- =========================

-- How many Major vs Minor Arcana cards exist?

SELECT arcana_type, COUNT(arcana_type) AS arcana_count
FROM tarot_cards
GROUP BY arcana_type;

-- | arcana_type | arcana_count |
-- | ----------- | ----- |
-- | Major       | 22    |
-- | Minor       | 56    |

---------------------------------------------------

-- How many cards belong to each suit?

SELECT  s.suit, COUNT(c.suit_id) AS suit_count
FROM tarot_cards c
JOIN suits s
ON s.id = c.suit_id
GROUP BY c.suit_id, s.suit
ORDER BY suit_id;

-- | suit      | suit_count |
-- | --------- | ----- |
-- | Cups      | 14    |
-- | Wands     | 14    |
-- | Swords    | 14    |
-- | Pentacles | 14    |

---------------------------------------------------

-- What is the distribution of elements across all cards?
-- Which planets are most commonly associated with cards?
-- How many cards are assigned to each chakra?

---------------------------------------------------

-- What are the top 10 most frequent individual cards overall (in draws)?

SELECT d.card_id, c.card_name, COUNT(d.card_id) num_drawn
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
GROUP BY d.card_id, c.card_name
ORDER BY num_drawn DESC
LIMIT 10;

-- | card_name          | num_drawn |
-- | ------------------ | --------- |
-- | The World          | 12        |
-- | Judgement          | 9         |
-- | King of Swords     | 9         |
-- | Nine of Pentacles  | 8         |
-- | Seven of Pentacles | 8         |
-- | Five of Pentacles  | 7         |
-- | Eight of Pentacles | 7         |
-- | Four of Pentacles  | 6         |
-- | The Star           | 6         |
-- | Six of Pentacles   | 6         |

---------------------------------------------------

-- What are the least frequently drawn cards?

SELECT c.card_name, COUNT(d.card_id) num_drawn
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
GROUP BY d.card_id, c.card_name
HAVING COUNT(d.card_id) = 1;

-- | card_name         | num_drawn |
-- | ----------------- | --------- |
-- | Seven of Cups     | 1         |
-- | Five of Cups      | 1         |
-- | Knight of Wands   | 1         |
-- | Knight of Swords  | 1         |
-- | Strength          | 1         |
-- | The Hermit        | 1         |
-- | Ten of Cups       | 1         |
-- | Two of Pentacles  | 1         |
-- | Ace of Wands      | 1         |
-- | Nine of Cups      | 1         |
-- | Six of Wands      | 1         |
-- | Nine of Swords    | 1         |
-- | The Sun           | 1         |
-- | King of Pentacles | 1         |
-- | Queen of Swords   | 1         |
-- | Three of Cups     | 1         |
-- | Five of Wands     | 1         |

---------------------------------------------------

-- Are some cards never drawn at all?

SELECT c.card_name AS cards_never_drawn
FROM tarot_cards c
LEFT JOIN tarot_draws d
ON d.card_id = c.id
WHERE d.card_id IS NULL;

-- | cards_never_drawn  |
-- | ------------------ |
-- | Justice            |
-- | Four of Cups       |
-- | Three of Pentacles |
-- | The Fool           |
-- | Eight of Swords    |
-- | Ten of Wands       |
-- | Queen of Wands     |
-- | Ace of Pentacles   |
-- | Knight of Cups     |
-- | Page of Cups       |
-- | Seven of Swords    |
-- | Three of Swords    |
-- | Two of Cups        |
-- | Page of Wands      |
-- | Three of Wands     |
-- | Six of Swords      |
-- | Queen of Cups      |
-- | Nine of Wands      |
-- | Ace of Swords      |
-- | Two of Swords      |
-- | Queen of Pentacles |
-- | Ten of Swords      |
-- | The Lovers         |
-- | Eight of Wands     |
-- | Five of Swords     |
-- | Ace of Cups        |
-- | Two of Wands       |
-- | King of Cups       |
-- | Page of Swords     |
-- | Eight of Cups      |
-- | King of Wands      |

---------------------------------------------------

-- What is the ratio of repeated cards vs unique cards drawn?

SELECT *, ROUND(repeated_draws * 1.0 / single_draws, 2) AS ratio
FROM (
  SELECT
    SUM(CASE WHEN cnt > 1 THEN 1 ELSE 0 END) AS repeated_draws,
    SUM(CASE WHEN cnt = 1 THEN 1 ELSE 0 END) AS single_draws
  FROM (
    SELECT card_id, COUNT(card_id) AS cnt
    FROM tarot_draws
    GROUP BY card_id
    ORDER BY cnt DESC
  )
);

-- | repeated_draws | single_draws | ratio |
-- | -------------- | ------------ | ----- |
-- | 30             | 17           | 1.76  |

---------------------------------------------------

-- =========================
-- RELATIONSHIPS
-- =========================

-- What is the most common element among drawn cards?

SELECT e.element, COUNT(c.element_id) AS element_count
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
JOIN elements e
ON e.id = c.element_id
GROUP BY e.element
ORDER BY COUNT(c.element_id) DESC;

-- | element | element_count |
-- | ------- | ------------- |
-- | Earth   | 85            |
-- | Fire    | 31            |
-- | Water   | 24            |
-- | Air     | 21            |

---------------------------------------------------

-- What suit appears most frequently in drawn cards?

SELECT s.suit, COUNT(c.suit_id) AS suit_count
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
JOIN suits s
ON s.id = c.suit_id
GROUP BY s.suit
ORDER BY COUNT(c.suit_id) DESC;

-- | suit      | suit_count |
-- | --------- | ---------- |
-- | Pentacles | 53         |
-- | Swords    | 15         |
-- | Wands     | 8          |
-- | Cups      | 8          |

---------------------------------------------------

-- Which chakra appears most in drawn cards?

SELECT chakras.chakra, COUNT(*) AS chakra_count
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
JOIN chakras
ON c.chakra_id = chakras.id
GROUP BY chakras.chakra
ORDER BY COUNT(chakra) DESC;

-- | chakra       | chakra_count |
-- | ------------ | ------------ |
-- | Crown        | 28           |
-- | Root         | 13           |
-- | Third Eye    | 10           |
-- | Heart        | 8            |
-- | Solar Plexus | 7            |
-- | Throat       | 6            |
-- | Sacral       | 5            |

---------------------------------------------------

-- Which planet appears most in drawn cards?

SELECT planet, COUNT(*) AS planet_count
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
JOIN planets p
ON p.id = c.planet_id
GROUP BY planet
ORDER BY COUNT(*) DESC;

-- | planet  | planet_count |
-- | ------- | ------------ |
-- | Pluto   | 25           |
-- | Uranus  | 13           |
-- | Mars    | 8            |
-- | Saturn  | 7            |
-- | Mercury | 6            |
-- | Neptune | 6            |
-- | Jupiter | 5            |
-- | Venus   | 5            |
-- | Moon    | 2            |

---------------------------------------------------

-- Which card ranks appear most in drawn cards?

SELECT card_rank, COUNT(*) AS rank_count
FROM tarot_draws d
JOIN tarot_cards c
ON d.card_id = c.id
WHERE card_rank IS NOT NULL
GROUP BY card_rank
ORDER BY COUNT(*) DESC;

-- | card_rank | rank_count |
-- | --------- | ---------- |
-- | 7         | 11         |
-- | 4         | 11         |
-- | 14        | 10         |
-- | 6         | 10         |
-- | 9         | 10         |
-- | 5         | 9          |
-- | 8         | 7          |
-- | 12        | 6          |
-- | 11        | 3          |
-- | 10        | 3          |
-- | 3         | 1          |
-- | 13        | 1          |
-- | 2         | 1          |
-- | 1         | 1          |

---------------------------------------------------

-- =========================
-- Repetition & randomness
-- =========================

---------------------------------------------------

-- Do any cards appear in consecutive draws?

SELECT c.card_name, d1.id AS draw_id_1, d1.draw_date AS draw_date_1, d2.id AS draw_id_2, d2.draw_date AS draw_date_2
FROM tarot_draws d1
JOIN tarot_draws d2
ON d2.id = d1.id + 1
JOIN tarot_cards c
ON d1.card_id = c.id
WHERE d1.card_id = d2.card_id;

-- | card_name          | draw_id_1 | draw_date_1 | draw_id_2 | draw_date_2 |
-- | ------------------ | --------- | ----------- | --------- | ----------- |
-- | Seven of Pentacles | 18        | 2025-06-06  | 19        | 2025-06-07  |
-- | Six of Pentacles   | 26        | 2025-06-14  | 27        | 2025-06-15  |
-- | The Magician       | 32        | 2025-06-20  | 33        | 2025-06-21  |
-- | Four of Pentacles  | 39        | 2025-06-27  | 40        | 2025-06-28  |
-- | Page of Pentacles  | 51        | 2025-07-09  | 52        | 2025-07-10  |
-- | The Star           | 63        | 2025-07-21  | 64        | 2025-07-22  |
-- | King of Swords     | 86        | 2025-08-13  | 87        | 2025-08-14  |
-- | The Tower          | 101       | 2025-08-28  | 102       | 2025-08-29  |
-- | The World          | 107       | 2025-09-03  | 108       | 2025-09-04  |
-- | Five of Pentacles  | 122       | 2025-09-18  | 123       | 2025-09-19  |
-- | Seven of Pentacles | 124       | 2025-09-20  | 125       | 2025-09-21  |
-- | The Star           | 126       | 2025-09-22  | 127       | 2025-09-23  |
-- | Five of Pentacles  | 129       | 2025-09-25  | 130       | 2025-09-26  |
-- | Eight of Pentacles | 132       | 2025-09-28  | 133       | 2025-09-29  |
-- | Four of Wands      | 139       | 2025-10-05  | 140       | 2025-10-06  |
-- | The Empress        | 147       | 2025-10-13  | 148       | 2025-10-15  |
-- | Judgement          | 152       | 2025-10-19  | 153       | 2025-10-20  |
-- | Nine of Pentacles  | 160       | 2025-10-27  | 161       | 2025-10-28  |


-- Note, there was no draw on 10-14-2025, which is why the Empress appears in consecutive draws on 10-13 and 10-15. I removed the row for 10-14 to maintain accurate analysis, so this is not a data integrity issue but rather a quirk of the dataset.


