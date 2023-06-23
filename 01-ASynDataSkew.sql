WITH Rowcount_CTE (TwoPartName, dist_row_count)
AS
 (
  SELECT QUOTENAME(s.name)+'.'+QUOTENAME(t.name) AS TwoPartName, SUM(nps.row_count) AS dist_row_count
  from 
    sys.schemas s
INNER JOIN sys.tables t
    ON s.[schema_id] = t.[schema_id]
INNER JOIN sys.indexes i
    ON  t.[object_id] = i.[object_id]
    AND i.[index_id] <= 1
INNER JOIN sys.pdw_table_distribution_properties tp
    ON t.[object_id] = tp.[object_id]
INNER JOIN sys.pdw_table_mappings tm
    ON t.[object_id] = tm.[object_id]
INNER JOIN sys.pdw_nodes_tables nt
    ON tm.[physical_name] = nt.[name]
INNER JOIN sys.dm_pdw_nodes pn
    ON  nt.[pdw_node_id] = pn.[pdw_node_id]
INNER JOIN sys.pdw_distributions di
    ON  nt.[distribution_id] = di.[distribution_id]
INNER JOIN sys.dm_pdw_nodes_db_partition_stats nps
    ON nt.[object_id] = nps.[object_id]
    AND nt.[pdw_node_id] = nps.[pdw_node_id]
    AND nt.[distribution_id] = nps.[distribution_id]
	WHERE tp.distribution_policy <> 3
  GROUP BY nt.name, nps.pdw_node_id, s.name, t.name
  
 )

 SELECT TwoPartName, (1 - (MIN(dist_row_count * 1.000)/MAX(dist_row_count * 1.000))) * 100 AS Skew_Pct
 FROM Rowcount_CTE
 WHERE dist_row_count > 0
 GROUP BY TwoPartName
 HAVING MIN(dist_row_count *1.000)/MAX(dist_row_count * 1.000) < .90;