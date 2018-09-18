-- Copyright 2004-2018 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (http://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT FIRST_VALUE(1) OVER (PARTITION BY ID);
> exception COLUMN_NOT_FOUND_1

SELECT FIRST_VALUE(1) OVER (ORDER BY ID);
> exception COLUMN_NOT_FOUND_1

CREATE TABLE TEST (ID INT PRIMARY KEY, CATEGORY INT, VALUE INT);
> ok

INSERT INTO TEST VALUES
    (1, 1, NULL),
    (2, 1, 12),
    (3, 1, NULL),
    (4, 1, 13),
    (5, 1, NULL),
    (6, 1, 13),
    (7, 2, 21),
    (8, 2, 22),
    (9, 3, 31),
    (10, 3, 32),
    (11, 3, 33),
    (12, 4, 41),
    (13, 4, NULL);
> update count: 13

SELECT *,
    FIRST_VALUE(VALUE) OVER (ORDER BY ID) FIRST,
    FIRST_VALUE(VALUE) RESPECT NULLS OVER (ORDER BY ID) FIRST_N,
    FIRST_VALUE(VALUE) IGNORE NULLS OVER (ORDER BY ID) FIRST_NN,
    LAST_VALUE(VALUE) OVER (ORDER BY ID) LAST,
    LAST_VALUE(VALUE) RESPECT NULLS OVER (ORDER BY ID) LAST_N,
    LAST_VALUE(VALUE) IGNORE NULLS OVER (ORDER BY ID) LAST_NN
    FROM TEST FETCH FIRST 6 ROWS ONLY;
> ID CATEGORY VALUE FIRST FIRST_N FIRST_NN LAST LAST_N LAST_NN
> -- -------- ----- ----- ------- -------- ---- ------ -------
> 1  1        null  null  null    null     null null   null
> 2  1        12    null  null    12       12   12     12
> 3  1        null  null  null    12       null null   12
> 4  1        13    null  null    12       13   13     13
> 5  1        null  null  null    12       null null   13
> 6  1        13    null  null    12       13   13     13
> rows (ordered): 6

SELECT *,
    FIRST_VALUE(VALUE) OVER (ORDER BY ID) FIRST,
    FIRST_VALUE(VALUE) RESPECT NULLS OVER (ORDER BY ID) FIRST_N,
    FIRST_VALUE(VALUE) IGNORE NULLS OVER (ORDER BY ID) FIRST_NN,
    LAST_VALUE(VALUE) OVER (ORDER BY ID) LAST,
    LAST_VALUE(VALUE) RESPECT NULLS OVER (ORDER BY ID) LAST_N,
    LAST_VALUE(VALUE) IGNORE NULLS OVER (ORDER BY ID) LAST_NN
    FROM TEST WHERE ID > 1 FETCH FIRST 3 ROWS ONLY;
> ID CATEGORY VALUE FIRST FIRST_N FIRST_NN LAST LAST_N LAST_NN
> -- -------- ----- ----- ------- -------- ---- ------ -------
> 2  1        12    12    12      12       12   12     12
> 3  1        null  12    12      12       null null   12
> 4  1        13    12    12      12       13   13     13
> rows (ordered): 3

SELECT *,
    NTH_VALUE(VALUE, 2) OVER (ORDER BY ID) NTH,
    NTH_VALUE(VALUE, 2) FROM FIRST OVER (ORDER BY ID) NTH_FF,
    NTH_VALUE(VALUE, 2) FROM LAST OVER (ORDER BY ID) NTH_FL,
    NTH_VALUE(VALUE, 2) RESPECT NULLS OVER (ORDER BY ID) NTH_N,
    NTH_VALUE(VALUE, 2) FROM FIRST RESPECT NULLS OVER (ORDER BY ID) NTH_FF_N,
    NTH_VALUE(VALUE, 2) FROM LAST RESPECT NULLS OVER (ORDER BY ID) NTH_FL_N,
    NTH_VALUE(VALUE, 2) IGNORE NULLS OVER (ORDER BY ID) NTH_NN,
    NTH_VALUE(VALUE, 2) FROM FIRST IGNORE NULLS OVER (ORDER BY ID) NTH_FF_NN,
    NTH_VALUE(VALUE, 2) FROM LAST IGNORE NULLS OVER (ORDER BY ID) NTH_FL_NN
    FROM TEST FETCH FIRST 6 ROWS ONLY;
> ID CATEGORY VALUE NTH  NTH_FF NTH_FL NTH_N NTH_FF_N NTH_FL_N NTH_NN NTH_FF_NN NTH_FL_NN
> -- -------- ----- ---- ------ ------ ----- -------- -------- ------ --------- ---------
> 1  1        null  null null   null   null  null     null     null   null      null
> 2  1        12    12   12     null   12    12       null     null   null      null
> 3  1        null  12   12     12     12    12       12       null   null      null
> 4  1        13    12   12     null   12    12       null     13     13        12
> 5  1        null  12   12     13     12    12       13       13     13        12
> 6  1        13    12   12     null   12    12       null     13     13        13
> rows (ordered): 6

SELECT NTH_VALUE(VALUE, 0) OVER (ORDER BY ID) FROM TEST;
> exception INVALID_VALUE_2

SELECT *,
    FIRST_VALUE(VALUE) OVER (PARTITION BY CATEGORY ORDER BY ID) FIRST,
    LAST_VALUE(VALUE) OVER (PARTITION BY CATEGORY ORDER BY ID) LAST,
    NTH_VALUE(VALUE, 2) OVER (PARTITION BY CATEGORY ORDER BY ID) NTH
    FROM TEST;
> ID CATEGORY VALUE FIRST LAST NTH
> -- -------- ----- ----- ---- ----
> 1  1        null  null  null null
> 2  1        12    null  12   12
> 3  1        null  null  null 12
> 4  1        13    null  13   12
> 5  1        null  null  null 12
> 6  1        13    null  13   12
> 7  2        21    21    21   null
> 8  2        22    21    22   22
> 9  3        31    31    31   null
> 10 3        32    31    32   32
> 11 3        33    31    33   32
> 12 4        41    41    41   null
> 13 4        null  41    null null
> rows (ordered): 13

DROP TABLE TEST;
> ok
