-- Upgrade From Version 90

--
-- Signal table
--

CREATE TABLE Signal
(
    _id                  INTEGER PRIMARY KEY,
    Date                 INTEGER,
    Hour                 INTEGER,
    Tags                 TEXT,
    ExtraState           TEXT,
    Data                 BLOB
);

CREATE INDEX Signal_Date_IDX ON Signal (Date);
CREATE INDEX Signal_DateHour_IDX ON Signal (Date, Hour);
CREATE INDEX Signal_Tags_NOCASE_IDX ON Signal (Tags COLLATE NOCASE ASC);

