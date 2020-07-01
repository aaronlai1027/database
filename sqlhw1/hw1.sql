## Q1 How many patients are male?
select count(c.id) Male from an_case c where sex = 'M';

## Q2 What are the names of the different signals recorded in the vitals table (in alphabetical order)?
select distinct v.signalname from an_vitals v order by v.signalname ASC;

## Q3 How old was each patient at the time of the operation? (show id and age in years). Sort in order by age from youngest to oldest.
select id, timestampdiff(year, c.dob, c.opDate) age from an_case c order by age asc;

## Q4 Which patients are either smokers or have allergies? Use a UNION operator in this query.
## 	  List the relevant patient ids, first and last names in order by last then first name.
select co.id, c.firstName, c.lastName from an_comorbid co join an_case c on co.id = c.id where co.descr = 'allergy'
union
select co.id, c.firstName, c.lastName from an_comorbid co join an_case c on co.id = c.id where co.descr = 'Smoker'
order by lastName, firstName;

## Q5 Which woman’s highest systolic blood pressure was over 170? Show her first and last name.
select distinct c.firstName, c.lastName from an_case c join an_vitals v on c.id = v.id 
where c.sex = "F" and v.signalname = 'SBP' and v.value > 170;

## Q6 Which patients who are at least 40 years old at the time of surgery, had a max SBP < 120? Show lastname, firstname, max SBP
select c. id, c.lastName, c.firstName , max(v.value) MaxSBP
from an_case c 
join an_vitals v on c.id = v.id 
where timestampdiff(YEAR, c.dob, c.opDate) >= 40 and v.signalname = 'SBP'
group by c.id, c.lastName, c.firstName
having max(v.value) < 120;

## Q7 What is the average number of comorbidities? (to two decimal places)
select round((avg(com)), 2) average from
(select count(descr) com from an_comorbid co group by co.descr) num ;

## Q8 What are the 3 most frequent comorbidity ICD codes? 
##	  Show the ICD code, description and the number of occurrences. List in descending order by frequency.
select icd, descr, count(icd) NumOfOccur from an_comorbid group by icd, descr order by count(icd) desc limit 3;

## Q9 What is the eventdescr value for the last event for Patient 3?
select id, eventdescr from an_event where id = 3 order by eventtime desc limit 1;

## Q10 Which patient(s) do not have a "knife to skin" event? List id(s) in numerical order. Do not repeat Ids.
select  distinct id from an_event where id
not in (select  distinct id from an_event where eventdescr = 'knife to skin');

## Q11 How long was each patients’ surgery (in minutes)? Round to the nearest minute using the SQL ROUND command. 
##     List the case id and the number of minutes, in order from shortest to longest, then by id.
##	//assume patient's surgery time is from the first event to last one.//
select id, round((M - mi)/60) SurTime
from
(select id, max(eventtime) M, min(eventtime) mi
from an_event
group by id) diff
order by round((M - mi)/60) asc, id;

## Q12 Which case had the longest surgical time? (Knife to skin to Surgery / operation over events). Give the case id.
select id
from
(select id, max(eventtime) tMax, min(eventtime) tMin from an_event 
where eventdescr like '%knife%' or eventdescr like '%sur%' or eventdescr like '%operation%' or eventdescr like '%over%'
group by id) diff
order by (tMax-tMin) desc
limit 1;

## Q13 How long was the case? (Knife to skin to Surgery / operation over events). Give the answer in whole minutes.
select round((tMax-tMin)/60) SurTime
from
(select id, max(eventtime) tMax, min(eventtime) tMin from an_event 
where eventdescr like '%knife%' or eventdescr like '%sur%' or eventdescr like '%operation%' or eventdescr like '%over%'
group by id) diff
order by (tMax-tMin) desc
limit 1;

## Q14 The hospital wants to reduce it’s inventory. So, it wants to review drugs that are used infrequently. 
##	   Find all the named drugs (from the drugs table or from the drug category table) used in less than 2 cases. 
##	   List the drug name and the number of cases it was used in. Sort by drug name.
select drname, count(distinct d.id) cases from an_drug d group by d.drname having count(distinct d.id) < 2
union
select drname, 0 cases from an_drugCategory dc where dc.drname not in
(select distinct d.drname from an_drug d where d.drname = dc.drname)
order by drname;

## Q15 
select bp.id, c.ebl EBL,
case when c.ebl >= 1000 then 0
	 when c.ebl >= 601 and c.ebl < 1000 then 1
	 when c.ebl >= 101 and c.ebl < 601 then 2
     when c.ebl < 101 then 3
end EBLpoints,
round(min(bp.MBP),2) MinBP, 
case when min(bp.MBP) < 40 then 0
	 when min(bp.MBP) >= 40 and min(bp.MBP) < 55 then 1
	 when min(bp.MBP) >= 55 and min(bp.MBP) < 70 then 2 
     when min(bp.MBP) >= 70 then 3
end BPpoints, 
	min(h.value) MinHR,
case when min(h.value) >= 85 then 0
	 when min(h.value) >= 76 and min(h.value) < 85 then 1
	 when min(h.value) >= 66 and min(h.value) < 76 then 2 
     when min(h.value) >= 56 and min(h.value) < 66 then 3
     when min(h.value) < 56 then 4
end HRpoints,
(
case when c.ebl >= 1000 then 0
	 when c.ebl >= 601 and c.ebl < 1000 then 1
	 when c.ebl >= 101 and c.ebl < 601 then 2
     when c.ebl < 101 then 3
end+
case when min(bp.MBP) < 40 then 0
	 when min(bp.MBP) >= 40 and min(bp.MBP) < 55 then 1
	 when min(bp.MBP) >= 55 and min(bp.MBP) < 70 then 2 
     when min(bp.MBP) >= 70 then 3
end+
case when min(h.value) >= 85 then 0
	 when min(h.value) >= 76 and min(h.value) < 85 then 1
	 when min(h.value) >= 66 and min(h.value) < 76 then 2 
     when min(h.value) >= 56 and min(h.value) < 66 then 3
     when min(h.value) < 56 then 4
end
) Score
from
(
select s.id, s.signaltime, s.value SBP, d.value DBP, ((s.value+2*d.value)/3) MBP from
(
(select id, signaltime, signalname, value from an_vitals where signalname = 'SBP' and value > 40) s
join
(select id, signaltime, signalname, value from an_vitals where signalname = 'DBP' and value > 20) d
on s.signaltime = d.signaltime and s.id = d.id
)
) bp
join
(select id, signaltime, signalname, value from an_vitals where signalname = 'HR') h
on bp.id = h.id
join
an_case c
on c.id = bp.id
group by bp.id, c.ebl;



## SA1:
## (a) I think it's a better way to set up a table that each row includes id, signaltime, HR value, SBP value and DBP value.
## (b) Advantages: We can easily find out 3 signalvalues for each case at a certain time.
##	   Disadvantages: There'll be some NULL data which would occupy useless storage capacity if each case doesn't have all 3 sign values at a certain time.

## SA2:
## The BP value can't go out of the range between 0-255.
## So it'll be more compact if the integer type of BP could be TINYINT which has values from 0-255 but only occupies 1 byte. 
## Each data in TINYINT type saves 3 bytes comparing with being in INT type.
## We have total 8726 data in BP, so we can save 8726*3 = 26178 bytes in this case.

## SA3:
## (a) I think the negative eventtime means that event is before the predicted surgery time when everything neccessary for the surgery is set up,
##     including the surgeon, nursing, anesthesia professionals and documents.
## (b) That is to say, when the eventtime is positive, it means they can start the surgery anytime. 
##     That's why 'LMA inserted' is always positive.
## (c) I think the eventtime type could be changed to 'HHH:MM:SS' which may range from '-838:59:59' to '838:59:59'.
##	   It's more easy to understand how many hours, minutes or seconds are between events.
##	   We can also apply lots of time function to it. That could be more convenient to find out any kinds of results we want.

## Survey
## N=25