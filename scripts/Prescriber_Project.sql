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
	,	CONCAT(p1.nppes_provider_first_name, ' ', p1.nppes_provider_last_org_name) AS Name
	,	p1.specialty_description
	, 	SUM(p2.total_claim_count) AS Total_Claim_Count 
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	USING (npi)
WHERE p2.total_claim_count IS NOT NULL
GROUP BY p1.npi, p1.nppes_provider_last_org_name, p1.nppes_provider_first_name, p1.specialty_description
ORDER BY Total_Claim_Count DESC

--Answer: Bruce Pendley, NPI #1881634483, specialty description Family Practice, has the highest total claim count of 99,707.

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

SELECT    DISTINCT p1.specialty_description AS Specialty
	,     p2.drug_name AS Prescription
FROM prescriber AS p1
FULL JOIN prescription AS p2
   USING (npi)
WHERE p2.drug_name IS NULL
GROUP BY specialty, prescription


--d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?



--Question 3: 

--a. Which drug (generic_name) had the highest total drug cost?

SELECT 	d.generic_name
	,	SUM(p.total_drug_cost)::MONEY AS Cost
FROM prescription AS p
LEFT JOIN drug AS d
	USING (drug_name)
GROUP BY generic_name
ORDER BY Cost DESC

--Answer: Insulin Glargine cost $104,264,066.35

--b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT  d.generic_name
    ,   ROUND(SUM(p.total_drug_cost)/SUM(p.total_day_supply), 2)::MONEY AS Daily_Cost
FROM drug AS d
LEFT JOIN prescription AS p
        USING (drug_name)
WHERE p.total_drug_cost IS NOT NULL
GROUP BY d.generic_name
ORDER BY Daily_Cost DESC

--Answer: C1 Esterase Inhibitor has the highest cost per day at $3,495.22

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
WHERE p.total_drug_cost IS NOT NULL
GROUP BY drug_type
ORDER BY Total_Cost DESC

--Answer: More was spent on opioids.

--Question 5:

--a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(DISTINCT c.cbsa) AS Num_of_CBSA, f.state
FROM cbsa AS c
LEFT JOIN fips_county AS f
	USING(fipscounty)
WHERE f.state = 'TN'
GROUP BY f.state

--Answer: There are 10 CBSAs in TN.

--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT 	c.cbsaname
	,	SUM(p.population) AS population
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

SELECT 	SUM(p.population) AS population
	, 	f.county
FROM population AS p
FULL JOIN fips_county AS f
	USING(fipscounty)
FULL JOIN cbsa AS c
	USING(fipscounty)
WHERE 	p.population IS NOT NULL 
	AND c.cbsa IS NULL
GROUP BY f.county
ORDER BY population DESC

--Answer: Sevier County is the largest county by population that is not included in a CBSA.

--Question 6:

--a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT p.drug_name, SUM(p.total_claim_count)
FROM prescription AS p
WHERE p.total_claim_count >=3000
GROUP BY p.drug_name
ORDER BY SUM(p.total_claim_count) DESC

SELECT p.drug_name, p.total_claim_count, p.npi
FROM prescription AS p
WHERE p.total_claim_count >=3000
--GROUP BY p.drug_name, p.npi
ORDER BY p.total_claim_count DESC


--Answer: There are 7 prescriptions with a total claim count over 3000. Bottom query returns 9 rows due to different npis.
/* 	1. LEVOTHYROXINE SODIUM 		@ 9262
	2. OXYCODONE HCL				@ 4538
	3. LISINOPRIL					@ 3655
	4. GABAPENTIN					@ 3531
	5. HYDROCODONE-ACETAMINOPHEN	@ 3376
	6. MIRTAZAPINE					@ 3085
	7. FUROSEMIDE					@ 3083
*/

--b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT p.drug_name, SUM(p.total_claim_count), d.opioid_drug_flag
FROM prescription AS p
RIGHT JOIN drug as d
	USING(drug_name)
WHERE p.total_claim_count >3000
GROUP BY p.drug_name, d.opioid_drug_flag
ORDER BY SUM(p.total_claim_count) DESC

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT 	CONCAT(p2.nppes_provider_first_name,' ',p2.nppes_provider_last_org_name) AS Provider_Name
	, 	p1.drug_name AS Drug
	, 	SUM(p1.total_claim_count) AS Total_Claim_Count
	, 	d.opioid_drug_flag AS Opioid
FROM prescription AS p1
RIGHT JOIN drug as d
	USING(drug_name)
RIGHT JOIN prescriber AS p2
	USING(npi)
WHERE p1.total_claim_count >3000
GROUP BY 	p1.drug_name, d.opioid_drug_flag
	, 		p2.nppes_provider_first_name
	, 		p2.nppes_provider_last_org_name
ORDER BY SUM(p1.total_claim_count) DESC

--Question 7: The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


SELECT 	p.npi
	, 	d.drug_name
FROM prescriber as p
CROSS JOIN drug as d
	WHERE 	p.specialty_description ='Pain Management' 
	AND 	p.nppes_provider_city = 'NASHVILLE' 
	AND 	d.opioid_drug_flag = 'Y'

--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT	p1.npi, d.drug_name
	,	SUM(p2.total_claim_count) AS Total_Drug_Count
FROM prescriber as p1
	CROSS JOIN drug as d
	LEFT JOIN prescription AS p2
		USING (drug_name)
WHERE p1.specialty_description ='Pain Management'
		AND p1.nppes_provider_city = 'NASHVILLE'
		AND d.opioid_drug_flag = 'Y'
GROUP BY 	p1.npi
	, 		d.drug_name
ORDER BY npi DESC

--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT	p1.npi, d.drug_name
	,	COALESCE((SUM(p2.total_claim_count)), 0) AS Total_Drug_Count
FROM prescriber as p1
	CROSS JOIN drug as d
	LEFT JOIN prescription AS p2
		USING (drug_name)
WHERE p1.specialty_description ='Pain Management' 
		AND p1.nppes_provider_city = 'NASHVILLE'
		AND d.opioid_drug_flag = 'Y'
GROUP BY p1.npi, d.drug_name
ORDER BY npi DESC