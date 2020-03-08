## What is ROWGEN().
ROWGEN() is a (very) simple User Defined Transform Function coded in C++ to generate rows. It just *counts* from 1 to the number passed as argument. Example:

```sql
SELECT ROWGEN(10) OVER();
series
--------
1
2
3
4
5
6
7
8
9
10
(10 rows)
```
## What ROWGEN() can be used for.
The main use case for ROWGEN() is in-database data generation. We often have to create test data out of nothing and... while we can use a plethora of functions to generate **column** values, we also need to generate "the other dimension"... **rows**.

With Vertica people often use the *TIMESERIES trick* to generate rows, for example...

```sql
SELECT
    ROW_NUMBER() OVER() 
FROM ( 
        SELECT 1 FROM (
            SELECT NOW() + INTERVAL '1 second'  AS mytime 
            UNION ALL 
            SELECT NOW() + INTERVAL '10 seconds' AS mytime 
        ) x
        TIMESERIES ts AS '1 second' OVER(ORDER BY mytime) 
     ) y
;
```
will produce **exactly** the same sequence of rows from 1 to 10 as ```SELECT ROWGEN(10) OVER()``` but - frankly speaking - I found the second much easier to remember :-)

## Sample data generation example.
Suppose we want to generate 1,000 rows of test data with the following structure:
- ```fnme``` (first name) using a random name from a given list
- ```lname``` (last name) using a random name from a given list
- ```depid```(department id) in [100,200,300]
- ```hdate``` (hire date) a random date after 01 Jan 2001
- ```salary``` value between 10,000 and 19,000

We can use ROWGEN and Vertica's ARRAY data type to write something like this:
```sql
SELECT 
    (ARRAY['Ann','Elyzabeth','Lucy','John','Ellen','Robert','Andrew','Mary','Matt'])[RANDOMINT(9)]::VARCHAR AS fname,
    (ARRAY['Gates','Lee','Ellison','Ross','Smith','Davis','Kennedy','Clark','Moore','Taylor'])[RANDOMINT(10)]::VARCHAR AS lname,
    ( RANDOMINT(3) + 1 ) * 100 AS depid,
    '2001-01-01'::DATE + RANDOMINT(365*10) AS hire_date,
    (10000 + RANDOM()*9000)::NUMERIC(7,2) AS salary
FROM
    ( SELECT ROWGEN(1,000) OVER() ) x;
   fname   |  lname  | depid | hire_date  |  salary  
-----------+---------+-------+------------+----------
 Mary      | Clark   |   200 | 2003-05-08 | 12512.02
 Andrew    | Lee     |   300 | 2010-09-12 | 17046.66
 Ellen     | Clark   |   100 | 2002-06-04 | 12710.49
 Mary      | Kennedy |   200 | 2008-04-27 | 18996.75
 Ann       | Clark   |   300 | 2006-02-19 | 14206.84
 John      | Davis   |   100 | 2003-09-05 | 10777.43
 Robert    | Smith   |   200 | 2004-03-02 | 12434.80
 John      | Moore   |   100 | 2007-10-07 | 14213.92
 Elyzabeth | Gates   |   200 | 2005-02-01 | 16685.84
 Ann       | Davis   |   300 | 2003-08-18 | 16592.06
 Mary      | Gates   |   300 | 2007-12-07 | 16869.87
 Matt      | Ross    |   200 | 2004-08-28 | 12944.05
 Matt      | Clark   |   100 | 2007-05-02 | 12096.31
 Robert    | Davis   |   300 | 2008-10-21 | 10342.12
 Lucy      | Moore   |   200 | 2005-10-12 | 12652.80
 Mary      | Taylor  |   200 | 2004-03-10 | 15921.94
 Robert    | Taylor  |   200 | 2007-09-25 | 16721.34
 Ellen     | Lee     |   200 | 2008-12-08 | 10411.04
 Andrew    | Gates   |   300 | 2009-09-23 | 18468.49
...
```
## How to install ROWGEN()
- First step is to compile the source code: ```make```
- Then - as dbadmin - deploy the code in Vertica: ```make deploy```
- You can run ```make test``` tocheck everything is ok

Please have a look to the Makefile before running ```make``` and change it if needed.
