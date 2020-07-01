1. How many patients are male? 13
%%sql
SELECT COUNT(sex)
FROM an_case
WHERE sex = 'M';

2. What are the different signals recorded in the vitals table (in alphabetical order)? DBP, HR, SBP
%%sql
SELECT DISTINCT
    signalname
FROM
    an_vitals
ORDER BY signalname;

signalname
DBP
HR
SBP

3. How old was each patient at the time of the operation? (show id and age in years). Sort in order by age from youngest to oldest.
%%sql
SELECT 
    id, TIMESTAMPDIFF(YEAR, dob, opDate) compAge
FROM
    an_case
ORDER BY compAge;

id  compAge
16  21
10  23
17  23
4   30
1   31
5   35
6   37
13  37
14  40
2   42
12  45
8   46
18  50
19  50
9   53
15  57
11  60
7   63
20  67
3   70

4. Which patients are either smokers or have allergies? 
-- using UNION  # deduct for duplicate entries SELECT DISTINCT with UNION ALL is fine
%%sql
SELECT 
    id, firstname, lastname
FROM
    (SELECT 
        c.*
    FROM
        an_case c
    JOIN an_comorbid m ON c.id = m.id
    WHERE
        m.descr = 'Smoker' 
    UNION ALL SELECT 
        a.*
    FROM
        an_case a
    JOIN an_comorbid m ON a.id = m.id
    WHERE
        m.descr = 'Allergy') q
ORDER BY lastname, firstname;

id  firstname   lastname
2   Kayla   Baker
12  Teresa  Gomez
9   Tomas   Hernandez
20  Jose    Jones
4   Tyler   Little
3   Judy    Perez
14  Dante   Peterson
8   Christine   Walker
13  Sophia  Ward
10  David   Young

5. Which woman's max sbp > 170? --' Judy Perez
%%sql
SELECT 
    firstname, lastname
FROM
    an_case c
        JOIN
    (SELECT DISTINCT
        id
    FROM
        an_vitals
    WHERE
        signalname = 'SBP' AND value > 170) v ON c.id = v.id
WHERE
    sex = 'F'
ORDER BY c.id

or 

Select distinct firstname, lastname, value
from an_case, an_vitals 
where an_case.id = an_vitals.id
and sex = 'F'
and signalname = 'SBP'
and value > 170

firstname   lastname
Judy    Perez

6.  The function TIMESTAMPDIFF(unit,startingDatetime,endingDatetime) can be used to calculate elapsed time in different units. You may use this function to help answer this question.

--Which patients who are at least 40 years old at the time of surgery, had a max SBP < 120? 
--Show lastname, firstname, max SBP
%%sql
SELECT 
    lastname,
    firstname,
    maxSBP
FROM
    (SELECT 
        *
    FROM
        an_case
    WHERE
        TIMESTAMPDIFF(YEAR, dob, opDate) >= 40) c
        JOIN
    (SELECT 
        id, MAX(value) maxSBP
    FROM
        an_vitals
    WHERE
        signalname = 'SBP'
    GROUP BY id
    HAVING maxSBP < 120) v ON c.id = v.id;

    
# lastName, firstName, maxSBP
Jones, Jose, 105
Peterson, Dante, 117


7. What is the average number of comorbidities? (to two decimal places) 1.05
%%sql
SELECT ROUND(AVG(numComorbid),2) as avgNumComorbidities
FROM (
SELECT p.id, COUNT(icd) numComorbid
FROM an_case p
LEFT OUTER JOIN an_comorbid c ON p.id = c.id
GROUP BY p.id) q

avgNumComorbidities
1.05

You MUST include people with 0 comorbidities in the calculation

8. What are the 3 most frequent comorbidity ICD codes?
%%sql
SELECT 
    icd, descr, count(icd) frequency
FROM
    an_comorbid c
GROUP BY icd, descr
ORDER BY COUNT(icd) DESC
LIMIT 3; 

icd 	descr 	frequency
Z72.0 	Smoker 	5
J45.9 	Asthma 	4
Z88.6 	Allergy 	3


9. What is the eventdescr value for the last event for Patient 3? Answer: Extubation; 
Patient leaves OR is incorrect
%%sql
SELECT 
    eventdescr
FROM
    an_event e
WHERE id = 3
ORDER BY eventtime DESC
LIMIT 1;

eventdescr
Extubation

10. Which patient(s) do not have a "knife to skin" event? 14, 19
%%sql
SELECT 
    id
FROM
    an_case
WHERE
    id NOT IN (SELECT 
            id
        FROM
            an_event
        WHERE
            eventdescr = 'Knife to skin');
id
14
19


11. How long was each patients' surgery?
--'
%%sql
SELECT 
   f.id, ROUND((lastevent - firstevent) / 60,0) mins
FROM
    (SELECT 
        id, MIN(eventtime) firstevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery start' , 'knife to skin')
    GROUP BY id , eventdescr) f
JOIN
    (SELECT 
        id, eventtime lastevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery over' , 'Surgery finished', 'Surgery complete', 'Operation over', 'Sugery over')) l ON f.id = l.id
ORDER BY mins, f.id;

# id, mins
14, 12
18, 18
2, 32
5, 39
15, 41
4, 60
9, 60
20, 61
19, 63
12, 65
1, 82
7, 88
11, 90
17, 100
16, 104
8, 106
3, 109
6, 115
10, 117
13, 158


-- you have to figure out which events signal the end of surgery
select id, eventtime, eventdescr 
from events
where eventdescr in ('Surgery over', 'Surgery finished', 'Surgery complete', 'Operation over', 'Sugery over')
order by id;

-- and which are first? patient 11 has two knife to skin events, use the first one
select id, min(eventtime) firstevent, eventdescr 
from events
where eventdescr in ('Surgery start', 'knife to skin')
group by id, eventdescr
order by id;

12. Which patient had the longest surgical time? (Knife to skin to Surgery / operation over events) 13
%%sql
SELECT 
   f.id
FROM
    (SELECT 
        id, MIN(eventtime) firstevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery start' , 'knife to skin')
    GROUP BY id , eventdescr) f
        JOIN
    (SELECT 
        id, eventtime lastevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery over' , 'Surgery finished', 'Surgery complete', 'Operation over', 'Sugery over')) l ON f.id = l.id
ORDER BY (lastevent - firstevent) / 60 DESC
LIMIT 1;


id
13

13. How long was it (in minutes)? 158
%%sql
SELECT 
    round(MAX(mins),0)
FROM
    (SELECT 
        f.id, (lastevent - firstevent) / 60 mins
    FROM
        (SELECT 
        id, MIN(eventtime) firstevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery start' , 'knife to skin')
    GROUP BY id , eventdescr) f
    JOIN (SELECT 
        id, eventtime lastevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery over' , 'Surgery finished', 'Surgery complete', 'Operation over', 'Sugery over')) l ON f.id = l.id) q


or 

%%sql
SELECT 
    round((lastevent - firstevent) / 60,0) mins
FROM
    (SELECT 
        id, MIN(eventtime) firstevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery start' , 'knife to skin')
    GROUP BY id , eventdescr) f
        JOIN
    (SELECT 
        id, eventtime lastevent, eventdescr
    FROM
        an_event
    WHERE
        eventdescr IN ('Surgery over' , 'Surgery finished', 'Surgery complete', 'Operation over', 'Sugery over')) l ON f.id = l.id
ORDER BY (lastevent - firstevent) / 60 DESC
LIMIT 1




-- 14. 

-- The hospital wants to reduce it's inventory. So, it wants to review drugs that are infrequently used.
-- find all the named drugs (from the drugs table or from the drug category table) used in < 2 cases. List the drug name and the number of cases it was used in. Sort by drug name.
%%sql
CREATE OR REPLACE VIEW an_allDrugs AS
    SELECT 
        d.drname
    FROM
        an_drug d 
    UNION  
    SELECT 
        c.drname
    FROM
        an_drugcategory c;

SELECT 
    drname, COUNT(id) caseCount
FROM
    (SELECT 
        a.drname, d.id
    FROM
        an_allDrugs a
    LEFT OUTER JOIN an_drug d ON a.drname = d.drname
    GROUP BY a.drname , d.id) q
GROUP BY drname
HAVING caseCount < 2
ORDER BY drname;

# drname, caseCount
drname  caseCount
Atracurium  1
Augmentin   1
Bupivicane  1
Clonidine   1
Halothane   0
Lignocaine  1
Morphine    1
Remifentynal    1
Rocuronium  0
Tetracaine  0
Tranexamic Acid     1


-- The hospital wants to predict patients that might have complications. One way to do this is to use the Surgical Apgar score. 
--The score uses estimated blood loss (the EBL column in our case table), the patient's minimum mean blood pressure (they want arterial, but our noninvasive measure will suffice), and lowest heart rate.

-- You MUST show that you can handle all ranges of values in the score, even if they don't exist in the current dataset.
-- ebl
%%sql
CREATE OR REPLACE VIEW an_vEBLpoints AS
    SELECT 
        id,
        CASE
            WHEN ebl <= 100 THEN 3
            WHEN ebl BETWEEN 101 AND 600 THEN 2
            WHEN ebl BETWEEN 601 AND 1000 THEN 1
            ELSE 0
        END eblPoints
    FROM
        an_case;

-- meanBP
CREATE OR REPLACE VIEW an_vBPpoints AS
SELECT 
    id,meanBP,
    CASE
        WHEN meanBP >= 70 THEN 3
        WHEN meanBP >= 55 AND meanBP < 70 THEN 2
        WHEN meanBP >= 40 AND meanBP < 55 THEN 1
        ELSE 0
    END bpPoints
FROM
    (SELECT  sbp.id, MIN((sbp.value + 2 * dbp.value) / 3) meanBP
        FROM an_vitals sbp, an_vitals dbp
        WHERE sbp.id = dbp.id
        AND sbp.signalname = 'SBP' and dbp.signalname = 'DBP'
        AND sbp.signaltime = dbp.signaltime
        AND dbp.value != 0 AND sbp.value != 0
        GROUP BY sbp.id) q
ORDER BY id;



-- lowest HR
CREATE OR REPLACE VIEW an_vHRpoints AS
    SELECT 
        id,
        CASE
            WHEN lowestHR <= 55 THEN 4
            WHEN lowestHR BETWEEN 56 AND 65 THEN 3
            WHEN lowestHR BETWEEN 66 AND 75 THEN 2
            WHEN lowestHR BETWEEN 76 AND 85 THEN 1
            ELSE 0
        END hrPoints
    FROM
        (SELECT 
            id, MIN(value) lowestHR
        FROM
            an_vitals
        WHERE
            signalname = 'HR'
        GROUP BY id) q;


SELECT 
    e.id,
    e.eblPoints,
    b.bpPoints,
    h.hrPoints,
    e.eblPoints + b.bpPoints + h.hrPoints surgicalApgar
FROM
    an_vEBLpoints e
        JOIN
    an_vBPpoints b ON b.id = e.id
        JOIN
    an_vHRpoints h ON h.id = e.id;

# id, eblPoints, bpPoints, hrPoints, surgicalApgar
1, 3, 2, 1, 6
2, 3, 1, 2, 6
3, 3, 2, 4, 9
4, 3, 3, 4, 10
5, 3, 2, 4, 9
6, 3, 1, 4, 8
7, 3, 2, 3, 8
8, 3, 1, 4, 8
9, 3, 1, 4, 8
10, 3, 1, 4, 8
11, 2, 2, 4, 8
12, 3, 3, 4, 10
13, 3, 1, 4, 8
14, 3, 2, 4, 9
15, 3, 2, 3, 8
16, 3, 2, 4, 9
17, 3, 3, 4, 10
18, 3, 3, 3, 9
19, 3, 2, 4, 9
20, 3, 2, 4, 9


%% 1.5 Short answer questions

1.5.1
Describe another way of structuring the RTD. What the are advantages and disadvantages? 
Specifically address storage space and how you can access values for more than one signal at any given time point
-- The current approach is very flexible - it is easy to add any new type of signal by adding rows with a new signalName value. However, obtaining values that occur at the same time requires joins
-- Option 1: You could build a table with 3 columns, one for each of the vitals signs: HR, SBP, DBP. SBP and DBP are always collected at the same time. This approach would reduce the repeated information (id, signalTime, signalname).
	However, there would be some wasted space when there are only 1 or 2 signals at a particular point in time.
-- Option 2: You could also build a separate table for each vital sign. This approach reduces the need to filter the an_vitals table when we are looking for a specific vital sign.

1.5.2
Ignoring any table or row overhead, the current approach uses 15 bytes for attribute data storage per row: 
4 bytes each for the id, signaltime and value and 3 bytes for the signalname. If, for estimation purposes, we assume each vital sign is sampled at the same time and we have 100 of each signal per case, we have 300 rows (100 rows for each of the 3 signals).
This approach uses 15 x 100 x 3 or 4,500 bytes per case. 

Option 1:
Here, we increase the row size to 20 bytes (4 bytes each for id, signaltime, hrvalue, sbpvalue, dbpvalue), but reduce the total number of rows to 100, yielding a total space requirement of 2,000 bytes, a savings of over half!

Option 2:
This approach also saves space. We eliminate the signalname from each row, since each signal has its own table.
This reduces the per row storage requirement to 12 bytes. 12 bytes * 100 rows * 3 signals = 3,600 bytes per case. Again, a savings over the original structure.

1.5.3
First off, why don't we just have datetimestamps? These sequential numeric values could be used in lieu of actual timestamps, to help protect patient privacy.

If there were just a few negative signal times, and they occurred for many cases, they might be artifact. Depending on how the time values are collected, they could be invalid values. 
If that is the case, including these infeasible times and corresponding values can result in incorrect answers.
You could exclude obviously bad times (e.g. negative numbers or times outside a reasonable range). 

These values could also be relative to a particular reference time. Say the time the patient entered the Operating Room or the time the surgery was scheduled to begin.
You would have to be careful when using these values in computations to be sure you are computing durations correctly. 
You might choose to compute a new time field that is non-negative and starts at the first recorded value/time. You could also use this information to learn more about the cases - for example how many started early or late or before the patient entered to operating room.




