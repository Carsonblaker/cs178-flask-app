-- ============================================================
-- WORKOUT TRACKER SCHEMA
-- ============================================================

CREATE DATABASE IF NOT EXISTS workout_tracker;
USE workout_tracker;

-- ------------------------------------------------------------
-- EXERCISE
-- A library of movements (e.g. Bench Press, Squat, Curl)
-- ------------------------------------------------------------
CREATE TABLE exercise (
    exercise_id   INT           NOT NULL AUTO_INCREMENT,
    name          VARCHAR(100)  NOT NULL,
    muscle_group  VARCHAR(50),
    equipment     VARCHAR(50),
    notes         TEXT,
    PRIMARY KEY (exercise_id),
    UNIQUE KEY uq_exercise_name (name)
);

-- ------------------------------------------------------------
-- WORKOUT_SET
-- One "set" of an exercise (e.g. Set 2 of Bench Press at 135 lbs)
-- ------------------------------------------------------------
CREATE TABLE workout_set (
    set_id        INT           NOT NULL AUTO_INCREMENT,
    exercise_id   INT           NOT NULL,
    set_number    TINYINT       NOT NULL DEFAULT 1,
    weight_lbs    DECIMAL(6,2)  NOT NULL DEFAULT 0.00,
    performed_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (set_id),
    CONSTRAINT fk_set_exercise
        FOREIGN KEY (exercise_id) REFERENCES exercise (exercise_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- REP
-- Individual reps within a set, with optional form tracking
-- ------------------------------------------------------------
CREATE TABLE rep (
    rep_id        INT           NOT NULL AUTO_INCREMENT,
    set_id        INT           NOT NULL,
    rep_number    TINYINT       NOT NULL DEFAULT 1,
    form_rating   ENUM('poor','fair','good','excellent') DEFAULT 'good',
    notes         TEXT,
    PRIMARY KEY (rep_id),
    CONSTRAINT fk_rep_set
        FOREIGN KEY (set_id) REFERENCES workout_set (set_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- EXERCISES
INSERT INTO exercise (name, muscle_group, equipment) VALUES
    ('Bench Press',        'Chest',      'Barbell'),
    ('Squat',              'Quads',      'Barbell'),
    ('Deadlift',           'Hamstrings', 'Barbell'),
    ('Pull-Up',            'Back',       'Bodyweight'),
    ('Overhead Press',     'Shoulders',  'Barbell'),
    ('Barbell Row',        'Back',       'Barbell'),
    ('Dumbbell Curl',      'Biceps',     'Dumbbell'),
    ('Tricep Pushdown',    'Triceps',    'Cable'),
    ('Romanian Deadlift',  'Hamstrings', 'Barbell'),
    ('Leg Press',          'Quads',      'Machine');

-- WORKOUT SETS  (referencing exercise_id 1–5)
INSERT INTO workout_set (exercise_id, set_number, weight_lbs, performed_at) VALUES
    (1, 1, 135.00, '2024-06-01 08:00:00'),  -- Bench Press warm-up
    (1, 2, 155.00, '2024-06-01 08:05:00'),  -- Bench Press working set
    (1, 3, 155.00, '2024-06-01 08:10:00'),  -- Bench Press working set
    (2, 1, 185.00, '2024-06-01 08:30:00'),  -- Squat
    (2, 2, 205.00, '2024-06-01 08:37:00'),  -- Squat heavier
    (3, 1, 225.00, '2024-06-02 09:00:00'),  -- Deadlift
    (3, 2, 245.00, '2024-06-02 09:08:00'),  -- Deadlift PR attempt
    (4, 1,   0.00, '2024-06-03 07:15:00'),  -- Pull-Up bodyweight
    (5, 1,  95.00, '2024-06-03 07:45:00'),  -- Overhead Press
    (5, 2, 105.00, '2024-06-03 07:52:00');  -- Overhead Press

-- REPS  (referencing set_id 1–10)
INSERT INTO rep (set_id, rep_number, form_rating) VALUES
    (1, 1, 'excellent'), (1, 2, 'excellent'), (1, 3, 'good'),
    (2, 1, 'good'),      (2, 2, 'good'),      (2, 3, 'fair'),
    (3, 1, 'good'),      (3, 2, 'good'),      (3, 3, 'good'),
    (4, 1, 'excellent'), (4, 2, 'good'),      (4, 3, 'good'),
    (5, 1, 'good'),      (5, 2, 'fair'),      (5, 3, 'poor'),
    (6, 1, 'excellent'), (6, 2, 'excellent'), (6, 3, 'good'),
    (7, 1, 'good'),      (7, 2, 'fair'),
    (8, 1, 'excellent'), (8, 2, 'excellent'), (8, 3, 'good'), (8, 4, 'good'), (8, 5, 'excellent'),
    (9, 1, 'good'),      (9, 2, 'good'),      (9, 3, 'fair'),
    (10,1, 'excellent'), (10,2, 'good');


-- ============================================================
-- USEFUL JOIN QUERY
-- Full workout log: exercise → set → rep count + avg form
-- ============================================================
SELECT
    e.name                            AS exercise,
    ws.set_number,
    ws.weight_lbs,
    COUNT(r.rep_id)                   AS total_reps,
    AVG(CASE r.form_rating
          WHEN 'poor'      THEN 1
          WHEN 'fair'      THEN 2
          WHEN 'good'      THEN 3
          WHEN 'excellent' THEN 4
        END)                          AS avg_form_score,
    ws.performed_at
FROM exercise      e
JOIN workout_set   ws ON ws.exercise_id = e.exercise_id
JOIN rep           r  ON r.set_id       = ws.set_id
GROUP BY ws.set_id
ORDER BY ws.performed_at, ws.set_number;