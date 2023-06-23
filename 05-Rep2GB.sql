SELECT QUOTENAME(s.name)+'.'+QUOTENAME(t.name) AS  [two_part_name], MAX(nps.[reserved_page_count])/131072.00 AS SizeGB
FROM sys.schemas s
INNER JOIN sys.tables t
    ON s.[schema_id] = t.[schema_id]
INNER JOIN sys.pdw_table_distribution_properties tp
    ON t.[object_id] = tp.[object_id]
INNER JOIN sys.pdw_table_mappings tm
    ON t.[object_id] = tm.[object_id]
INNER JOIN sys.pdw_nodes_tables nt
    ON tm.[physical_name] = nt.[name]
INNER JOIN sys.dm_pdw_nodes_db_partition_stats nps
    ON nt.[object_id] = nps.[object_id]
    AND nt.[pdw_node_id] = nps.[pdw_node_id]
WHERE tp.[distribution_policy_desc] = 'REPLICATE'
GROUP BY  QUOTENAME(s.name)+'.'+QUOTENAME(t.name)