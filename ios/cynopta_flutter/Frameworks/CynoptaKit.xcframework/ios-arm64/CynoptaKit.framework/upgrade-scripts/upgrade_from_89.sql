-- Upgrade From Version 89

--
-- ISPPresence table
--

CREATE TABLE ISPPresence
(
    _id                  INTEGER PRIMARY KEY,
    StartTimestamp       INTEGER,
    StopTimestamp        INTEGER,
    StartTimestampLocal  INTEGER,
    StopTimestampLocal   INTEGER,
    ISP                  TEXT,
    Tags                 TEXT,
    ExtraState           TEXT
);

CREATE INDEX ISPPresence_StartTimestamp_IDX ON ISPPresence (StartTimestamp);
CREATE INDEX ISPPresence_StopTimestamp_IDX ON ISPPresence (StopTimestamp);
CREATE INDEX ISPPresence_StartTimestampLocal_IDX ON ISPPresence (StartTimestampLocal);
CREATE INDEX ISPPresence_StopTimestampLocal_IDX ON ISPPresence (StopTimestampLocal);
CREATE INDEX ISPPresence_Tags_NOCASE_IDX ON ISPPresence (Tags COLLATE NOCASE ASC);
CREATE INDEX ISPPresence_ISP_IDX ON ISPPresence (ISP);

CREATE VIEW V_ISPPresence AS
SELECT p._id AS Id,
    datetime((p.StartTimestamp)/1000,'unixepoch') AS StartDate,
    datetime((p.StopTimestamp)/1000,'unixepoch') AS StopDate,
    datetime((p.StartTimestampLocal)/1000,'unixepoch') AS StartDateLocal,
    datetime((p.StopTimestampLocal)/1000,'unixepoch') AS StopDateLocal,
    p.ISP,
    p.Tags,
    p.ExtraState
    FROM ISPPresence AS p
    ORDER BY p.StartTimestamp;
