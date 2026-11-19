-- Upgrade From Version 88

--
-- New Metrics
--

INSERT INTO Resource ("Name", "Type", "Class", "Source") VALUES
('PhoneInteractionLeastActiveHour', 'Metric', 'InternalMetrics', 'sdk'),
('PhoneInteractionMostActiveHour', 'Metric', 'InternalMetrics', 'sdk'),
('PhoneInteractionHeatMap', 'Metric', 'InternalMetrics', 'sdk');
