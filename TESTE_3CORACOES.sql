-- RESPOSTA ITEM_1
SELECT
    oc."CD_ORD_COM",
    COUNT(ip."CD_PRODUTO") AS QTD_ITENS_POR_PEDIDO
FROM
    raw_mv.ord_com oc
    LEFT JOIN raw_mv.itord_pro ip ON oc."CD_ORD_COM" = ip."CD_ORD_COM"
GROUP BY
    oc."CD_ORD_COM"
HAVING
    COUNT(ip."CD_PRODUTO") > 0
ORDER BY
    COUNT(ip."CD_PRODUTO") DESC;



-- RESPOSTA ITEM_2
SELECT
    DISTINCT oc."CD_ORD_COM",
    COUNT(DISTINCT oc."CD_ORD_COM") AS QTD_PEDIDOS_PENDENTES
FROM
    raw_mv.ord_com oc
WHERE
    oc."TP_SITUACAO" = 'T'
GROUP BY
    oc."CD_ORD_COM"
ORDER BY
    QTD_PEDIDOS_PENDENTES DESC;



-- RESULTADO DO ITEM_3
WITH PEDIDOS_POR_CLIENTE AS (
    SELECT
        sc."CD_SETOR",
        COUNT(*) AS QDT_PEDIDOS
    FROM
        raw_mv.sol_com sc
    GROUP BY
        sc."CD_SETOR"
)
SELECT
    "CD_SETOR",
    AVG(QDT_PEDIDOS) AS MEDIA_PEDIDOS_POR_CLIENTE
FROM
    PEDIDOS_POR_CLIENTE
GROUP BY
    "CD_SETOR"
ORDER BY
    AVG(QDT_PEDIDOS) DESC;



-- RESPOSTA ITEM_4
WITH RESPOSTA_ITEM_1 AS (
    SELECT
        oc."CD_ORD_COM",
        COUNT(ip."CD_PRODUTO") AS QTD_ITENS_POR_PEDIDO
    FROM
        raw_mv.ord_com oc
        LEFT JOIN raw_mv.itord_pro ip ON oc."CD_ORD_COM" = ip."CD_ORD_COM"
    GROUP BY
        oc."CD_ORD_COM"
)
SELECT
    *
FROM
    RESPOSTA_ITEM_1
GROUP BY
    1, 2
HAVING
    QTD_ITENS_POR_PEDIDO > 5
ORDER BY
    QTD_ITENS_POR_PEDIDO ASC;



-- RESPOSTA ITEM_5
SELECT
    ip."CD_PRODUTO",
    SUM(ip."VL_TOTAL") / NULLIF(COUNT(*), 0) AS MEDIA_VALOR_VENDA
FROM
    staging.stg_ord_com oc
    LEFT JOIN staging.stg_itord_pro ip ON oc."CD_ORD_COM" = ip."CD_ORD_COM"
GROUP BY
    ip."CD_PRODUTO"
HAVING
    SUM(ip."VL_TOTAL") > 0
ORDER BY
    MEDIA_VALOR_VENDA DESC;

WITH VALOR_TOTAL AS (
    SELECT
        ip."CD_PRODUTO",
        SUM(ip."VL_TOTAL") AS VALOR_TOTAL
    FROM
        staging.stg_ord_com oc
        LEFT JOIN staging.stg_itord_pro ip ON oc."CD_ORD_COM" = ip."CD_ORD_COM"
    GROUP BY
        ip."CD_PRODUTO"
    HAVING
        SUM(ip."VL_TOTAL") > 0
),
QTD_VENDIDA AS (
    SELECT
        ip."CD_PRODUTO",
        COUNT(*) AS QTD_VENDIDA
    FROM
        staging.stg_ord_com oc
        LEFT JOIN staging.stg_itord_pro ip ON oc."CD_ORD_COM" = ip."CD_ORD_COM"
    GROUP BY
        ip."CD_PRODUTO"
    HAVING
        COUNT(*) > 0
)
SELECT
    vl."CD_PRODUTO",
    (vl.VALOR_TOTAL / qv.QTD_VENDIDA) AS MEDIA_VALOR_VENDA_POR_ITEM
FROM
    VALOR_TOTAL vl
    INNER JOIN QTD_VENDIDA qv ON vl."CD_PRODUTO" = qv."CD_PRODUTO"
ORDER BY
    MEDIA_VALOR_VENDA_POR_ITEM DESC;