
--   SELECT
--     column_name,
--     data_type,
--     is_nullable,
--     character_maximum_length,
--     numeric_precision,
--     numeric_scale
-- FROM
--     information_schema.columns
-- WHERE
--     table_schema = 'public'  -- change if your table is in a different schema
--     AND table_name = 'grupo1'  -- replace with your table name
-- ORDER BY
--     ordinal_position;
SELECT
    c.column_name,
    c.data_type,
    c.is_nullable,
    CASE
        WHEN v.relkind = 'v' THEN 'view'
        WHEN v.relkind = 'm' THEN 'materialized view'
        WHEN v.relkind = 'r' THEN 'table'
        ELSE v.relkind
    END AS object_type
FROM
    information_schema.columns c
JOIN
    pg_class v ON c.table_name = v.relname
WHERE
    c.table_schema = 'public'
    AND c.table_name = 'pw_dia';
