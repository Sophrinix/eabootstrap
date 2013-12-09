/* Financial instrument's meta-information. */
CREATE TABLE eurusd_meta (
  short_name    VARCHAR(10)  NOT NULL UNIQUE PRIMARY KEY,
  full_name     VARCHAR(100) NOT NULL,
  leverage      INTEGER      NOT NULL,
  pip_size      FLOAT        NOT NULL,
  digits        INTEGER      NOT NULL,
  stop_level    FLOAT        NOT NULL,
  freeze_level  FLOAT        NOT NULL,
  standard_lot  INTEGER      NOT NULL
);

/* Financial instrument's series. */
CREATE TABLE eurusd_d1 (
  date   TIMESTAMP NOT NULL UNIQUE PRIMARY KEY,
  open   FLOAT     NOT NULL,
  high   FLOAT     NOT NULL,
  low    FLOAT     NOT NULL,
  close  FLOAT     NOT NULL,
  volume INTEGER   NOT NULL
);

/* Import data. */
COPY eurusd_meta
FROM '/tmp/eurusd_meta.csv'
WITH DELIMITER AS ','
CSV HEADER;

COPY eurusd_d1
FROM '/tmp/eurusd_d1.csv'
WITH DELIMITER AS ','
CSV HEADER;

