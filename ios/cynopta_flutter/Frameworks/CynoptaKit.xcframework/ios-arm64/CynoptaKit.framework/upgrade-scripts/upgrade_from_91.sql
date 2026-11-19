-- Upgrade From Version 91

--
-- New Metrics
--

INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('PNSEvents', 'Metric', 'InternalMetrics', 'sdk'),
('PNSEventsDaily', 'Metric', 'InternalMetrics', 'sdk'),
('PNSEventsHeatMap', 'Metric', 'InternalMetrics', 'sdk');
