-- Upgrade From Version 97

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
-- Clear AggregationDaily for sleep time and phone unlock events
--

UPDATE AggregationDaily
        SET Status = 1, IntegerValue = NULL, DecimalValue = NULL, StringValue = NULL
        WHERE Status != 0 AND (CalculationGroup = 'SleepTimeGroup' OR CalculationGroup = 'PhoneUnlockEventsGroup');
