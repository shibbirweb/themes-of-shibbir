-- SQL sample: DDL, DML, joins, CTEs, and window functions.

CREATE TABLE IF NOT EXISTS themes (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name          VARCHAR(120)    NOT NULL,
    ui_theme      ENUM('vs', 'vs-dark') NOT NULL DEFAULT 'vs-dark',
    is_published  TINYINT(1)      NOT NULL DEFAULT 0,
    rating        DECIMAL(3, 2)   NULL,
    created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY themes_name_unique (name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE swatches (
    id        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    theme_id  BIGINT UNSIGNED NOT NULL,
    label     VARCHAR(60)     NOT NULL,
    hex       CHAR(7)         NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT swatches_theme_id_foreign FOREIGN KEY (theme_id)
        REFERENCES themes (id) ON DELETE CASCADE
);

CREATE INDEX swatches_theme_id_index ON swatches (theme_id);

INSERT INTO themes (name, ui_theme, is_published, rating)
VALUES
    ('Themes of Shibbir', 'vs-dark', 1, 4.75),
    ('Material Ocean', 'vs-dark', 1, 4.50);

UPDATE themes
SET is_published = 0,
    rating = NULL
WHERE name LIKE '%Ocean%'
  AND created_at < NOW() - INTERVAL 30 DAY;

WITH ranked AS (
    SELECT
        t.id,
        t.name,
        COUNT(s.id)                                        AS swatch_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(s.id) DESC)      AS position,
        AVG(t.rating) OVER (PARTITION BY t.ui_theme)       AS avg_rating
    FROM themes AS t
    LEFT JOIN swatches AS s ON s.theme_id = t.id
    WHERE t.is_published = 1
    GROUP BY t.id, t.name, t.ui_theme
    HAVING COUNT(s.id) > 0
)
SELECT
    r.name,
    r.swatch_count,
    ROUND(r.avg_rating, 2) AS avg_rating,
    CASE
        WHEN r.swatch_count >= 50 THEN 'comprehensive'
        WHEN r.swatch_count >= 10 THEN 'moderate'
        ELSE 'minimal'
    END AS coverage
FROM ranked AS r
WHERE r.position <= 10
ORDER BY r.swatch_count DESC, r.name ASC
LIMIT 10 OFFSET 0;

DROP TABLE IF EXISTS swatches;
