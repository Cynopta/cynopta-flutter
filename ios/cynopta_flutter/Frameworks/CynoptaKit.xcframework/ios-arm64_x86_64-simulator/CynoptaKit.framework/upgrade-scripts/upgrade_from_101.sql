-- Upgrade From Version 101

--
-- New Metrics: Android's Trust Score micro-segments (CynoptaMetrics TrustMSCalculator)
--

-- The SDK takes these names from this version on. Nothing of the SDK's is stored under them yet, so a row is a host
-- app's own metric: remove it, rather than export the host's value under the SDK's name or mix the two. Names match
-- without case, as Stats lookups do.
DELETE FROM Stats WHERE LOWER(Name) IN ('isdebuggerattached', 'isnativedebuggerattached', 'debuggerreason',
    'simulatedinteractionspercentage', 'currentsessionsimulatedinteractionspercentage', 'simulatedinteractionsfeatures');

DELETE FROM Resource WHERE Source = 'host_application' AND LOWER(Name) IN ('isdebuggerattached',
    'isnativedebuggerattached', 'debuggerreason', 'simulatedinteractionspercentage',
    'currentsessionsimulatedinteractionspercentage', 'simulatedinteractionsfeatures');

-- OR REPLACE: any other row left under these names must not fail the whole upgrade.
INSERT OR REPLACE INTO Resource ("Name", "Type", "Class", "Source") VALUES
('IsDebuggerAttached', 'Metric', 'InternalMetrics', 'sdk'),
('IsNativeDebuggerAttached', 'Metric', 'InternalMetrics', 'sdk'),
('DebuggerReason', 'Metric', 'InternalMetrics', 'sdk'),
('SimulatedInteractionsPercentage', 'Metric', 'InternalMetrics', 'sdk'),
('CurrentSessionSimulatedInteractionsPercentage', 'Metric', 'InternalMetrics', 'sdk'),
('SimulatedInteractionsFeatures', 'Metric', 'InternalMetrics', 'sdk');
