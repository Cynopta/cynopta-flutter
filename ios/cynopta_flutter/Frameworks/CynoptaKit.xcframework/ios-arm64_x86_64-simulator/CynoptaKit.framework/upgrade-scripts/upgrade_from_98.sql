-- Upgrade From Version 98

--
-- Remove deprecated tables and views
--

DROP TABLE IF EXISTS Activity;
DROP TABLE IF EXISTS AggregationWeekly;
DROP TABLE IF EXISTS AggregationMonthly;
DROP TABLE IF EXISTS ChargerPresence;
DROP TABLE IF EXISTS Cluster;
DROP TABLE IF EXISTS ClusteredVisits;
DROP TABLE IF EXISTS ClusteredActivities;
DROP TABLE IF EXISTS PedometerActivity;
DROP TABLE IF EXISTS PersonalPoi;
DROP TABLE IF EXISTS SensorActivity;
DROP TABLE IF EXISTS Steps;
DROP TABLE IF EXISTS Visit;
DROP TABLE IF EXISTS VisitedPois;
DROP TABLE IF EXISTS SDKVersion;
DROP TABLE IF EXISTS CarAudioPresence;

DROP VIEW IF EXISTS Trip;
DROP VIEW IF EXISTS V_Trip;
DROP VIEW IF EXISTS V_Activity;
DROP VIEW IF EXISTS V_ChargerPresence;
DROP VIEW IF EXISTS V_PedometerActivity;
DROP VIEW IF EXISTS V_SensorActivity;
DROP VIEW IF EXISTS V_Steps;
DROP VIEW IF EXISTS V_Visit;
DROP VIEW IF EXISTS V_CarAudioPresence;

---
--- Create AudioPresence table
---

CREATE TABLE AudioPresence
(
    _id                  INTEGER PRIMARY KEY,
    Timestamp            INTEGER,
    TimestampLocal       INTEGER,
    PortName             TEXT,
    PortUid              TEXT,
    PortType             TEXT,
    RouteMode            TEXT,
    RouteCategory        TEXT,
    IsPlayingAudio       INTEGER
);

CREATE INDEX AudioPresence_Timestamp_IDX ON AudioPresence (Timestamp);
CREATE INDEX AudioPresence_TimestampLocal_IDX ON AudioPresence (TimestampLocal);
CREATE INDEX AudioPresence_Name_IDX ON AudioPresence (PortName);
CREATE INDEX AudioPresence_Type_IDX ON AudioPresence (PortType);

CREATE VIEW V_AudioPresence AS
SELECT p._id AS Id,
    datetime((p.Timestamp)/1000,'unixepoch') AS StartDate,
    datetime((p.TimestampLocal)/1000,'unixepoch') AS StartDateLocal,
    p.PortName,
    p.PortUID,
    p.PortType,
    p.RouteMode,
    p.RouteCategory,
    p.IsPlayingAudio
    FROM AudioPresence AS p
    ORDER BY p.Timestamp;

--
-- Create WiFiPresenceTagCache table
--

CREATE TABLE WiFiPresenceTagCache (
    id INTEGER PRIMARY KEY,
    updateDate INTEGER,
    networkCidr TEXT,
    prefixLength INTEGER CHECK (prefixLength BETWEEN 0 AND 32),
    ipStart INTEGER,
    ipEnd INTEGER,
    tag TEXT,
    asnNumber INTEGER,
    extIp TEXT,
    CHECK (ipStart <= ipEnd)
);

CREATE INDEX idx_WiFiPresenceTagCache_range ON WiFiPresenceTagCache (ipStart, ipEnd, prefixLength DESC);
CREATE INDEX idx_WiFiPresenceTagCache_update ON WiFiPresenceTagCache (updateDate);
CREATE INDEX idx_WiFiPresenceTagCache_asn ON WiFiPresenceTagCache (asnNumber);
CREATE INDEX idx_WiFiPresenceTagCache_extip ON WiFiPresenceTagCache (extIp);

CREATE VIEW V_WiFiPresenceTagCache AS
SELECT
    id,
    updateDate,
    datetime(updateDate, 'unixepoch') AS updateDateReadable,
    networkCidr,
    prefixLength,
    ipStart,
    ipEnd,
    tag,
    asnNumber,
    extIp
FROM WiFiPresenceTagCache;

--
-- Add AsnNumber & externalIP & SubnetMask to WiFiPrecesne table
--

ALTER TABLE WiFiPresence
ADD COLUMN SubnetMask TEXT;

ALTER TABLE WiFiPresence
ADD COLUMN AsnNumber INTEGER;

ALTER TABLE WiFiPresence
ADD COLUMN ExtIp TEXT;

DROP VIEW IF EXISTS V_WiFiPresence;

CREATE VIEW V_WiFiPresence AS
SELECT p._id AS Id,
       datetime((p.StartTimestamp)/1000,'unixepoch') AS StartDate,
       datetime((p.StopTimestamp)/1000,'unixepoch') AS StopDate,
       datetime((p.StartTimestampLocal)/1000,'unixepoch') AS StartDateLocal,
       datetime((p.StopTimestampLocal)/1000,'unixepoch') AS StopDateLocal,
       p.SSID,
       p.BSSID,
       p.NetAddress,
       p.SubnetMask,
       p.Tags,
       p.ExtraState,
       p.AsnNumber,
       p.ExtIp
FROM WiFiPresence AS p
ORDER BY p.StartTimestamp;

--
-- Clear the Stats, Resource, cache and Aggregation tables
--

DELETE FROM Stats
WHERE Name IN (
  'DrivingTime',
  'DrivingDistance',
  'DrivingAvgSpeed',
  'DrivingEvents',
  'FlightsDomestic',
  'FlightsInternational',
  'DaysAbroad',
  'PhysicalExerciseDuration',
  'PhysicalExerciseTotalDaysCount',
  'PhysicalExerciseTypicalDuration',
  'PhysicalExerciseDaysTypicalFrequency',
  'BrandLastVisitDate',
  'BrandFirstVisitDate',
  'BrandVisitDuration',
  'BrandVisitTypicalFrequency',
  'BrandVisitTypicalDuration',
  'BrandVisits',
  'SocialActivityAvgDaysPerCalendarWeek',
  'StepsAvgPerWeekday',
  'Steps',
  'UsuallyEnterHomeAfterWork',
  'UsuallyLeaveHomeToWork',
  'UsuallyEnterWork',
  'UsuallyLeaveWork',
  'HomeToWorkCommuteTime',
  'WorkToHomeCommuteTime',
  'CommuteDistance',
  'POIVisits',
  'POIVisitDuration',
  'POIVisitTypicalFrequency',
  'POIVisitTypicalDuration',
  'POILastVisitDate',
  'POIFirstVisitDate',
  'RideDuration',
  'RideEvents',
  'RideDistance',
  'RideTypicalDuration',
  'RideTypicalFrequency',
  'RideDaysTypicalFrequency',
  'RideTypicalDistance',
  'BatteryLevelAtChargeStart',
  'BatteryLevelAtChargeStartWeekDays',
  'BatteryLevelAtChargeStartWeekEnds',
  'BatteryLevelAtChargeStop',
  'BatteryLevelAtChargeStopWeekDays',
  'BatteryLevelAtChargeStopWeekEnds',
  'BatteryChargeDuration',
  'BatteryChargeDurationWeekDays',
  'BatteryChargeDurationWeekEnds',
  'BatteryDrainDuration',
  'BatteryDrainDurationWeekDays',
  'BatteryDrainDurationWeekEnds',
  'BatteryDrainSessionCount',
  'BatteryDrainSessionCountWeekDays',
  'BatteryDrainSessionCountWeekEnds',
  'BatteryDrainPercentagePerHour',
  'BatteryDrainPercentagePerHourWeekDays',
  'BatteryDrainPercentagePerHourWeekEnds',
  'BatteryChargeSessionCount',
  'BatteryChargeSessionCountWeekDays',
  'BatteryChargeSessionCountWeekEnds',
  'ActivityRecognitionPermissionGranted'
);

DELETE FROM Resource
WHERE Type = 'Metric'
  AND Class = 'InternalMetrics'
  AND Source = 'sdk'
  AND Name IN (
    'DrivingTime',
    'DrivingDistance',
    'DrivingAvgSpeed',
    'DrivingEvents',
    'FlightsDomestic',
    'FlightsInternational',
    'DaysAbroad',
    'PhysicalExerciseDuration',
    'PhysicalExerciseTotalDaysCount',
    'PhysicalExerciseTypicalDuration',
    'PhysicalExerciseDaysTypicalFrequency',
    'BrandLastVisitDate',
    'BrandFirstVisitDate',
    'BrandVisitDuration',
    'BrandVisitTypicalFrequency',
    'BrandVisitTypicalDuration',
    'BrandVisits',
    'SocialActivityAvgDaysPerCalendarWeek',
    'StepsAvgPerWeekday',
    'Steps',
    'UsuallyEnterHomeAfterWork',
    'UsuallyLeaveHomeToWork',
    'UsuallyEnterWork',
    'UsuallyLeaveWork',
    'HomeToWorkCommuteTime',
    'WorkToHomeCommuteTime',
    'CommuteDistance',
    'POIVisits',
    'POIVisitDuration',
    'POIVisitTypicalFrequency',
    'POIVisitTypicalDuration',
    'POILastVisitDate',
    'POIFirstVisitDate',
    'RideDuration',
    'RideEvents',
    'RideDistance',
    'RideTypicalDuration',
    'RideTypicalFrequency',
    'RideDaysTypicalFrequency',
    'RideTypicalDistance',
    'BatteryLevelAtChargeStart',
    'BatteryLevelAtChargeStartWeekDays',
    'BatteryLevelAtChargeStartWeekEnds',
    'BatteryLevelAtChargeStop',
    'BatteryLevelAtChargeStopWeekDays',
    'BatteryLevelAtChargeStopWeekEnds',
    'BatteryChargeDuration',
    'BatteryChargeDurationWeekDays',
    'BatteryChargeDurationWeekEnds',
    'BatteryDrainDuration',
    'BatteryDrainDurationWeekDays',
    'BatteryDrainDurationWeekEnds',
    'BatteryDrainSessionCount',
    'BatteryDrainSessionCountWeekDays',
    'BatteryDrainSessionCountWeekEnds',
    'BatteryDrainPercentagePerHour',
    'BatteryDrainPercentagePerHourWeekDays',
    'BatteryDrainPercentagePerHourWeekEnds',
    'BatteryChargeSessionCount',
    'BatteryChargeSessionCountWeekDays',
    'BatteryChargeSessionCountWeekEnds',
    'ActivityRecognitionPermissionGranted'
  );

DELETE FROM AggregationDaily
WHERE CalculationGroup IN (
    'DrivingGroup',
    'PhysicalExercisesGroup',
    'StepsGroup',
    'CommutingGroup',
    'BrandGroup',
    'POIVisitsGroup',
    'RidesGroup',
    'BatteryGroup'
);

--
-- New Metrics
-- And fixing source values
--

CREATE UNIQUE INDEX Resource_Name_Type_Unique_IDX ON Resource (Name, Type);

INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('ProcessCpuTimeLastDay', 'Metric', 'InternalMetrics', 'sdk'),
('HomeLeaveTimeMorning', 'Metric', 'InternalMetrics', 'sdk'),
('HomeArrivalTimeEvening', 'Metric', 'InternalMetrics', 'sdk'),
('WorkArrivalTimeMorning', 'Metric', 'InternalMetrics', 'sdk'),
('WorkLeaveTimeEvening', 'Metric', 'InternalMetrics', 'sdk'),
('HomeWorkCommuteTime', 'Metric', 'InternalMetrics', 'sdk'),
('WorkHomeCommuteTime', 'Metric', 'InternalMetrics', 'sdk'),
('IsHomeDetected', 'Metric', 'InternalMetrics', 'sdk'),
('IsWorkDetected', 'Metric', 'InternalMetrics', 'sdk'),
('HomeStayDays', 'Metric', 'InternalMetrics', 'sdk'),
('HomeDuration', 'Metric', 'InternalMetrics', 'sdk'),
('HomeDurationEvenings', 'Metric', 'InternalMetrics', 'sdk'),
('HomeDurationWeekDays', 'Metric', 'InternalMetrics', 'sdk'),
('HomeDurationWeekEnds', 'Metric', 'InternalMetrics', 'sdk'),
('WorkDuration', 'Metric', 'InternalMetrics', 'sdk'),
('WorkDurationWeekEnds', 'Metric', 'InternalMetrics', 'sdk'),
('NumDaysAbroad', 'Metric', 'InternalMetrics', 'sdk'),
('NumCountriesVisited', 'Metric', 'InternalMetrics', 'sdk'),
('InternationalTravels', 'Metric', 'InternalMetrics', 'sdk'),
('DrivingPresencePerHour', 'Metric', 'InternalMetrics', 'sdk'),
('DrivingPresencePerWeekDay', 'Metric', 'InternalMetrics', 'sdk')
ON CONFLICT("Name", "Type") DO UPDATE SET
    "Class" = excluded."Class",
    "Source" = excluded."Source";
