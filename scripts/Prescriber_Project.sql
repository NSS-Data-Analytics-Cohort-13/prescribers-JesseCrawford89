--Question 1: 

--a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

Select 	npi
	, 	SUM(total_claim_count) AS Total_Claim_Count 
FROM prescription
WHERE total_claim_count IS NOT NULL
GROUP BY npi
ORDER BY Total_Claim_Count DESC

--Answer: NPI #1881634483 has the highest total claim count of 99707.


--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

Select 	p1.npi
	, 	p1.nppes_provider_last_org_name AS Provider
	,	p1.nppes_provider_first_name AS First_Name
	,	p1.specialty_description
	, 	SUM(p2.total_claim_count) AS Total_Claim_Count 
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	USING (npi)
WHERE p2.total_claim_count IS NOT NULL
GROUP BY p1.npi, p1.nppes_provider_last_org_name, p1.nppes_provider_first_name, p1.specialty_description
ORDER BY Total_Claim_Count DESC

--Answer: Bruce Pendley, NPI #1881634483, specialty description Family Practice, has the highest total claim count of 99707.

--Question 2: 

--a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT 	p1.specialty_description AS Specialty
	, 	SUM(p2.total_claim_count) AS Total_Claim_Count
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	USING(npi)
WHERE Total_Claim_Count IS NOT NULL
GROUP BY p1.specialty_description
ORDER BY Total_Claim_Count DESC

--Answer: The family practice specialty had the highest total claim count at 9,752,347.

--b. Which specialty had the most total number of claims for opioids?

SELECT 	p1.specialty_description AS Specialty
	,	SUM(p2.total_claim_count) AS Claim_Count
	,	d.opioid_drug_flag AS Opioid
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	USING (npi)
RIGHT JOIN drug AS d
	USING(drug_name)
WHERE d.opioid_drug_flag = 'Y'
GROUP BY p1.specialty_description, d.opioid_drug_flag
ORDER BY Claim_Count DESC;

--Answer: Nurse Practitioners had the highest opioid claims at 900,845.

--c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT p1.specialty_description AS Specialty
	,	

--d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?


--Question 3: 

--a. Which drug (generic_name) had the highest total drug cost?

SELECT 	p.drug_name AS Name
	,	d.generic_name
	,	SUM(p.total_drug_cost) AS Cost
FROM prescription AS p
LEFT JOIN drug AS d
	USING (drug_name)
GROUP BY drug_name, generic_name
ORDER BY Cost DESC

--Answer: Pregabalin at 78,645,939.89

--b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT 	d.generic_name
	, 	ROUND((SUM(p.total_drug_cost)/(365*4)), 2) AS Daily_Cost
FROM drug AS d
LEFT JOIN prescription AS p
	USING (drug_name)
WHERE p.total_drug_cost IS NOT NULL
GROUP BY d.generic_name
ORDER BY Daily_Cost DESC

--Answer: Insulin has the highest cost per day at 71413.74

--Question 4

--a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT 	drug_name
	,	CASE
			WHEN opioid_drug_flag = 'Y' 
				THEN 'Opioid'
			WHEN antibiotic_drug_flag = 'Y' 
				THEN 'Antibiotic'
			ELSE 'Neither'
			END AS drug_type
FROM drug

--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 

SELECT 	CASE
			WHEN d.opioid_drug_flag = 'Y' 
				THEN 'Opioid'
			WHEN d.antibiotic_drug_flag = 'Y' 
				THEN 'Antibiotic'
			ELSE 'Neither'
			END AS drug_type
	,	SUM(p.total_drug_cost)::MONEY AS Total_Cost
FROM drug AS d
FULL JOIN prescription AS p
	USING (drug_name)
WHERE p.total_drug_cost IS NOT NULL --AND drug_type <> 'Neither'
GROUP BY drug_type
ORDER BY Total_Cost DESC

--Answer: More was spent on opioids.

--Question 5:

--a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(c.cbsa) AS Num_of_CBSA, f.state
FROM cbsa AS c
LEFT JOIN fips_county AS f
	USING(fipscounty)
WHERE f.state = 'TN'
GROUP BY f.state

--Answer: There are 42 CBSAs in TN.

--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT c.cbsaname, SUM(p.population) AS population
FROM cbsa AS c
LEFT JOIN population AS p
	USING (fipscounty)
WHERE p.population IS NOT NULL
GROUP BY c.cbsaname
ORDER BY population DESC

--Answer: 
		--Largest Population: Nashville-Davidson-Murfreesboro-Franklin, TN at 1,830,410.
		--Smallest Population: Morristown, TN at 116,352.

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT SUM(p.population) AS population, f.county, c.cbsa AS CBSA
FROM population AS p
FULL JOIN fips_county AS f
	USING(fipscounty)
FULL JOIN cbsa AS c
	USING(fipscounty)
WHERE p.population IS NOT NULL AND c.cbsa IS NULL
GROUP BY f.county, c.cbsa
ORDER BY population DESC

--Answer: Sevier County is the largest county by population that is not included in a CBSA.

--Question 6:

--a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.



--Answer:

--b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
