-- Upgrade From Version 96

--
-- Fix V_InstalledApps
--

DROP VIEW IF EXISTS V_InstalledApps;

CREATE VIEW V_InstalledApps AS
SELECT
    p.Scheme                           AS Scheme,
    datetime(p.StartSearchTimestampLocal/1000, 'unixepoch')     AS StartSearchDateLocal,
    datetime(p.FirstAppearanceTimestampLocal/1000, 'unixepoch') AS FirstAppearanceDateLocal,
    datetime(p.LastAppearanceTimestampLocal/1000, 'unixepoch')  AS LastAppearanceDateLocal
FROM InstalledApps AS p
ORDER BY p.Scheme;

--
-- Clear PNS metrics from Stats table
--

DELETE FROM Stats
WHERE Name IN ('PNSEvents', 'PNSEventsDaily');

--
-- Fixing NetworkTraffic
--

ALTER TABLE NetworkTraffic ADD COLUMN Date TEXT;
ALTER TABLE NetworkTraffic ADD COLUMN Hour INTEGER;

UPDATE NetworkTraffic
SET Date = strftime('%Y%m%d', Timestamp + TimeZoneSeconds, 'unixepoch'),
    Hour = CAST(strftime('%H', Timestamp + TimeZoneSeconds, 'unixepoch') AS INTEGER);

CREATE INDEX idx_NetworkTraffic_Date ON NetworkTraffic(Date);
CREATE INDEX idx_NetworkTraffic_DateHour ON NetworkTraffic(Date, Hour);

--
-- Create ISPResolution
--

CREATE TABLE ISPResolution (
    Timestamp INTEGER,              -- Unix timestamp (safe)
    IpAddress VARCHAR(45) PRIMARY KEY,
    ResolutionData BLOB NOT NULL
);

--
-- Create SimCount
--


CREATE TABLE SimCount (
    _id   INTEGER PRIMARY KEY,  -- Unique record ID
    Date  INTEGER,              -- TomeRDate
    Count INTEGER
);

CREATE INDEX idx_SimCount_Date ON SimCount(Date);

--
-- Create DailyTrafficCache
--

CREATE TABLE DailyTrafficCache (
    CalendarDate INT NOT NULL,      -- TomeRDate
    DayOfWeek INT NOT NULL,
    SixHourBlock INT NOT NULL CHECK (SixHourBlock IN (-1, 0, 1, 2, 3)),
    ReceivedWifiBytes INT NOT NULL,
    SentWifiBytes INT NOT NULL,
    ReceivedMobileBytes INT NOT NULL,
    SentMobileBytes INT NOT NULL,
    PRIMARY KEY (CalendarDate, SixHourBlock)
);

--
-- Create DualSimCache
--

CREATE TABLE DualSimCache (
    Date INT NOT NULL,              -- TomeRDate
    SimCount INT NOT NULL,
    DataSimSwapCount INT NOT NULL,
    OperatorNames BLOB,
    DataUsedJson BLOB
);

-- Create index to optimize queries filtering by Date
CREATE UNIQUE INDEX unique_dualsim_date ON DualSimCache(Date);

--
-- New Metrics
--

INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('ActiveSimCardsCount', 'Metric', 'InternalMetrics', 'sdk'),
('CellularProvidersNames', 'Metric', 'InternalMetrics', 'sdk'),
('DataSimSwapCount', 'Metric', 'InternalMetrics', 'sdk'),
('DataUsedPerSimProvider', 'Metric', 'InternalMetrics', 'sdk');
