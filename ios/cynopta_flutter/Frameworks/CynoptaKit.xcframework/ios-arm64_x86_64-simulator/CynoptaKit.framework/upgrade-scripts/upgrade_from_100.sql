-- Upgrade From Version 100

--
-- New Metrics
--


INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('NetTrafficUploadTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficDownloadTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficUploadDownloadRatio', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficMobileUploadTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficMobileDownloadTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficMobileUploadDownloadRatio', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficWifiUploadTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficWifiDownloadTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficWifiUploadDownloadRatio', 'Metric', 'InternalMetrics', 'sdk'),
('HomeTimeZone', 'Metric', 'InternalMetrics', 'sdk'),
('CurrentlyTimeZoneAbroad', 'Metric', 'InternalMetrics', 'sdk'),
('RecentTimeZones', 'Metric', 'InternalMetrics', 'sdk'),
('InFlightConnectivityDetected', 'Metric', 'InternalMetrics', 'sdk'),
('StarLinkConnectivityDetected', 'Metric', 'InternalMetrics', 'sdk'),
('NetProviderWifiISPASNNumberUniqueList', 'Metric', 'InternalMetrics', 'sdk'),
('NetProviderWifiISPObservationCount', 'Metric', 'InternalMetrics', 'sdk'),
('NetProviderWifiISPUniqueCount', 'Metric', 'InternalMetrics', 'sdk'),
('NetProviderWifiISPDailyMedianUniqueCount', 'Metric', 'InternalMetrics', 'sdk'),
('SchemeNamesLsh', 'Metric', 'InternalMetrics', 'sdk');

--
-- TimeZonePresence table
--

CREATE TABLE TimeZonePresence
(
    _id                  INTEGER PRIMARY KEY,
    StartTimestamp       INTEGER,
    StopTimestamp        INTEGER,
    StartTimestampLocal  INTEGER,
    StopTimestampLocal   INTEGER,
    TimeZone             TEXT,
    Tags                 TEXT
);

CREATE INDEX TimeZonePresence_StartTimestamp_IDX ON TimeZonePresence (StartTimestamp);
CREATE INDEX TimeZonePresence_StopTimestamp_IDX ON TimeZonePresence (StopTimestamp);
CREATE INDEX TimeZonePresence_StartTimestampLocal_IDX ON TimeZonePresence (StartTimestampLocal);
CREATE INDEX TimeZonePresence_StopTimestampLocal_IDX ON TimeZonePresence (StopTimestampLocal);
CREATE INDEX TimeZonePresence_Tags_NOCASE_IDX ON TimeZonePresence (Tags COLLATE NOCASE ASC);
CREATE INDEX TimeZonePresence_TimeZone_IDX ON TimeZonePresence (TimeZone);

CREATE VIEW V_TimeZonePresence AS
SELECT t._id AS Id,
    datetime((t.StartTimestamp)/1000,'unixepoch') AS StartDate,
    datetime((t.StopTimestamp)/1000,'unixepoch') AS StopDate,
    datetime((t.StartTimestampLocal)/1000,'unixepoch') AS StartDateLocal,
    datetime((t.StopTimestampLocal)/1000,'unixepoch') AS StopDateLocal,
    t.TimeZone,
    t.Tags
    FROM TimeZonePresence AS t
    ORDER BY t.StartTimestamp;

--
-- Reset Driving MSs
--

DELETE FROM Stats
WHERE Name IN (
  'DrivingPresencePerHour',
  'DrivingPresencePerWeekDay'
);
