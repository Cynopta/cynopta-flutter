-- Upgrade From Version 95

--
-- Clear Stats table
--

DELETE FROM Stats
WHERE Name IN (
    SELECT r.Name
    FROM Resource r
    WHERE r.Source = 'sdk'
);

--
-- Network Traffic Table & View
--

CREATE TABLE NetworkTraffic (
    _id                  INTEGER PRIMARY KEY,  -- Unique record ID
    Timestamp            INTEGER,              -- Unix timestamp (safe)
    TimeZoneSeconds      INTEGER,              -- secondsFromGMT (e.g., 7200 for +2)
    InterfaceName        TEXT,                 -- Interface name (e.g., en0, pdp_ip0)
    TransmittedBytes     INTEGER,              -- Bytes sent
    ReceivedBytes        INTEGER,              -- Bytes received
    ReceivedPackets      INTEGER,              -- Packets received
    TransmittedPackets   INTEGER,              -- Packets sent
    Flags                INTEGER,              -- Stores `ifa_flags` bitmask
    Address              TEXT                  -- IPv4 or IPv6 address
);

CREATE INDEX idx_NetworkTraffic_Timestamp ON NetworkTraffic(Timestamp);
CREATE INDEX idx_NetworkTraffic_InterfaceName ON NetworkTraffic(InterfaceName);

CREATE VIEW V_NetworkTraffic AS
SELECT
    c._id AS Id,
    datetime(c.Timestamp, 'unixepoch') AS DateTime, -- UTC time
    datetime(c.Timestamp + c.TimeZoneSeconds, 'unixepoch') AS DateTimeLocal, -- Local time
    c.TimeZoneSeconds,
    c.InterfaceName,
    c.TransmittedBytes,
    c.ReceivedBytes,
    c.ReceivedPackets,
    c.TransmittedPackets,
    c.Flags,
    c.Address
FROM NetworkTraffic AS c;

--
-- Create InstalledApps Table & View
--

CREATE TABLE InstalledApps
(
    Scheme                         TEXT,
    StartSearchTimestampLocal      INTEGER,
    FirstAppearanceTimestampLocal  INTEGER,
    LastAppearanceTimestampLocal   INTEGER,
    PRIMARY KEY (Scheme)
);

CREATE VIEW V_InstalledApps AS
SELECT
    p.Scheme                           AS Scheme,
    datetime(p.StartSearchTimestampLocal/1000, 'unixepoch')     AS StartSearchDateLocal,
    datetime(p.FirstAppearanceTimestampLocal/1000, 'unixepoch') AS FirstAppearanceDateLocal,
    datetime(p.LastAppearanceTimestampLocal/1000, 'unixepoch')  AS LastAppearanceDateLocal
FROM InstalledApps AS p
ORDER BY p.Scheme;


--
-- New Metrics
--

INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('NetProviderWorkASNNumber', 'Metric', 'InternalMetrics', 'sdk'),
('NetProviderCellularASNOrganization', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficMobileUsagePerDay', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficWifiUsagePerDay', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficMobileTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficWifiTotalUsage', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficMobileTypicalUsagePerWeekday', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficWifiTypicalUsagePerWeekday', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficMobileTypicalUsagePer6HourBlocks', 'Metric', 'InternalMetrics', 'sdk'),
('NetTrafficWifiTypicalUsagePer6HourBlocks', 'Metric', 'InternalMetrics', 'sdk'),
('HoursSinceLastMobileDataUsage', 'Metric', 'InternalMetrics', 'sdk');
