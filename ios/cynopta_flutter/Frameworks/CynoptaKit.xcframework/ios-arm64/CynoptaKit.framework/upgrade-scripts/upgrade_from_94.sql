-- Upgrade From Version 94

--
-- New Metrics
--

INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('BatteryChargingEventsHeatMapPerHour', 'Metric', 'InternalMetrics', 'sdk'),
('BatteryMedianLevelHeatMapPerHour', 'Metric', 'InternalMetrics', 'sdk'),
('BatteryLevelRangesHeatMapBy10s', 'Metric', 'InternalMetrics', 'sdk'),
('BatteryLevelRangesHeatMapBy0_25_75_100', 'Metric', 'InternalMetrics', 'sdk'),
('BatteryLevelRangesHeatMapBy0_20_50_100', 'Metric', 'InternalMetrics', 'sdk'),
('CellularNetworkGenerationHistogram', 'Metric', 'InternalMetrics', 'sdk'),
('CellularNetworkGenerationMostFrequentPercentage', 'Metric', 'InternalMetrics', 'sdk'),
('CellularNetworkGenerationMostFrequent', 'Metric', 'InternalMetrics', 'sdk');
