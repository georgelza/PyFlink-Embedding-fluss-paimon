
use catalog fluss_catalog;

use finflow;

CREATE TEMPORARY TABLE datagen_table (
    user_id     BIGINT,
    item_id     BIGINT,
    behavior    STRING,
    dt          STRING,
    hh          STRING,
    nation      STRING
) WITH (
     'connector'       = 'datagen'
    ,'rows-per-second' = '10'
);


ALTER TABLE datagen_table SET ('table.datalake.enabled' = 'true');



-- Add a partition to a single field partitioned table
-- ALTER TABLE datagen_table ADD PARTITION (dt = '2025-03-05');

-- Add a partition to a multi-field partitioned table
-- ALTER TABLE datagen_table ADD PARTITION (dt = '2025-12-05', nation = 'US');
-- ALTER TABLE datagen_table ADD PARTITION (dt = '2026-01-05', nation = 'US');
-- ALTER TABLE datagen_table ADD PARTITION (dt = '2026-01-05', nation = 'ZA');
-- ALTER TABLE datagen_table ADD PARTITION (dt = '2026-02-05', nation = 'US');
-- ALTER TABLE datagen_table ADD PARTITION (dt = '2026-02-05', nation = 'ZA');

SHOW PARTITIONS datagen_table;