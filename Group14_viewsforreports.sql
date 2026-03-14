
-- =====================================================================
-- Homeless Shelter Database — Reporting Views
-- Date: 2026-03-11
-- Description: Creates five read-only views used for common reports.
--   1) v_clients_served_last_6_months
--   2) v_program_utilization, v_program_utilization_top10
--   3) v_inventory_on_hand
--   4) v_items_below_reorder
--   5) v_staff_activity_90d
-- Notes:
--   * All objects are created in the public schema with explicit quoting
--     to match the provided DDL.
--   * ORDER BY in views is generally not guaranteed on SELECT * FROM view;
--     where ordering matters for ranking we expose a dedicated *_top10 view.
-- =====================================================================

-- 1) Unduplicated clients served by month (last 6 months)
CREATE OR REPLACE VIEW public."v_clients_served_last_6_months" AS
SELECT
  date_trunc('month', si."InteractionDate")::date AS month,
  COUNT(DISTINCT si."ClientID")                    AS distinct_clients
FROM public."ServiceInteraction" AS si
WHERE si."InteractionDate" >= (current_date - interval '6 months')
GROUP BY 1
ORDER BY 1;


-- 2) Program utilization leaderboard (base + top10)
CREATE OR REPLACE VIEW public."v_program_utilization" AS
SELECT
  p."Name"                               AS program,
  COUNT(si."ServiceInteractionID")       AS interactions,
  COALESCE(SUM(si."Units"), 0)           AS total_units
FROM public."Program" AS p
JOIN public."ServiceInteraction" AS si
  ON si."ProgramID" = p."ProgramID"
GROUP BY p."Name";

CREATE OR REPLACE VIEW public."v_program_utilization_top10" AS
SELECT *
FROM public."v_program_utilization"
ORDER BY interactions DESC, total_units DESC, program
LIMIT 10;


-- 3) Inventory on-hand by item
CREATE OR REPLACE VIEW public."v_inventory_on_hand" AS
WITH signed AS (
  SELECT
    it."ItemID",
    CASE it."TxnType"
      WHEN 'RECEIPT'   THEN  it."Quantity"
      WHEN 'ISSUE'     THEN -it."Quantity"
      ELSE                  it."Quantity"   -- ADJUSTMENT (treat as signed already)
    END AS delta
  FROM public."InventoryTransaction" AS it
)
SELECT
  i."ItemID",
  i."Name"                         AS item,
  ROUND(COALESCE(SUM(s.delta),0), 2) AS on_hand
FROM public."InventoryItem" AS i
LEFT JOIN signed AS s
  ON s."ItemID" = i."ItemID"
GROUP BY i."ItemID", i."Name"
ORDER BY item;


-- 4) Items below their reorder point (needs re-stock)
CREATE OR REPLACE VIEW public."v_items_below_reorder" AS
WITH signed AS (
  SELECT
    it."ItemID",
    CASE it."TxnType"
      WHEN 'RECEIPT'   THEN  it."Quantity"
      WHEN 'ISSUE'     THEN -it."Quantity"
      ELSE                  it."Quantity"   -- ADJUSTMENT
    END AS delta
  FROM public."InventoryTransaction" AS it
),
onhand AS (
  SELECT
    i."ItemID",
    i."Name",
    i."ReorderPoint",
    ROUND(COALESCE(SUM(s.delta),0), 2) AS on_hand
  FROM public."InventoryItem" AS i
  LEFT JOIN signed AS s
    ON s."ItemID" = i."ItemID"
  GROUP BY i."ItemID", i."Name", i."ReorderPoint"
)
SELECT
  "ItemID",
  "Name" AS item,
  on_hand,
  "ReorderPoint",
  ("ReorderPoint" - on_hand) AS shortage
FROM onhand
WHERE "ReorderPoint" IS NOT NULL
  AND on_hand < "ReorderPoint"
ORDER BY shortage DESC, item;


-- 5) Staff activity (last 90 days): service interactions and case notes
CREATE OR REPLACE VIEW public."v_staff_activity_90d" AS
WITH si AS (
  SELECT
    "CreatedByUserID" AS uid,
    COUNT(*)          AS si_count
  FROM public."ServiceInteraction"
  WHERE "InteractionDate" >= current_date - interval '90 days'
  GROUP BY "CreatedByUserID"
),
cn AS (
  SELECT
    "AuthorUserID" AS uid,
    COUNT(*)       AS cn_count
  FROM public."CaseNote"
  WHERE "NoteDate" >= now() - interval '90 days'
  GROUP BY "AuthorUserID"
)
SELECT
  u."UserID",
  u."Username",
  COALESCE(si.si_count, 0) AS interactions_90d,
  COALESCE(cn.cn_count, 0) AS casenotes_90d
FROM public."User" AS u
LEFT JOIN si ON si.uid = u."UserID"
LEFT JOIN cn ON cn.uid = u."UserID"
ORDER BY interactions_90d DESC, casenotes_90d DESC, u."Username";


-- =====================
-- Quick smoke tests
-- =====================
-- SELECT * FROM public."v_clients_served_last_6_months";
-- SELECT * FROM public."v_program_utilization_top10";
-- SELECT * FROM public."v_inventory_on_hand" LIMIT 25;
-- SELECT * FROM public."v_items_below_reorder" LIMIT 25;
-- SELECT * FROM public."v_staff_activity_90d" LIMIT 25;
