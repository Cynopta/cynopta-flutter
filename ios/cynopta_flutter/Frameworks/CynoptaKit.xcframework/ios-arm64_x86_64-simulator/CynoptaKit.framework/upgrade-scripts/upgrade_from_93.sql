-- Upgrade From Version 93

--
-- New Metrics
--

INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('CellularConnectionQuality', 'Metric', 'InternalMetrics', 'sdk'),
('CellularConnectionQualityVariance', 'Metric', 'InternalMetrics', 'sdk'),
('CellularConnectionQualityHistogram', 'Metric', 'InternalMetrics', 'sdk');
