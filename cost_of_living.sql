/*

Data Exploration and Cleaning

I used US Cost of Living data from Kaggle:
https://www.kaggle.com/datasets/asaniczka/us-cost-of-living-dataset-3171-counties

*/


Select *
From PortfolioProject.dbo.cost_of_living_us
--Where median_family_income is Null


-------------------------------------------------------------------------------------------------------

-- Breaking out family_member_count into individual columns (parent_number, child_number)


Select 
	SUBSTRING(family_member_count, 1, 1) as parent_number,
	SUBSTRING(family_member_count,3,1) as child_number
From PortfolioProject.dbo.cost_of_living_us


ALTER TABLE PortfolioProject.dbo.cost_of_living_us
Add parent_number int;

Update PortfolioProject.dbo.cost_of_living_us
SET parent_number = SUBSTRING(family_member_count, 1, 1)


ALTER TABLE PortfolioProject.dbo.cost_of_living_us
Add child_number int;

Update PortfolioProject.dbo.cost_of_living_us
SET child_number = SUBSTRING(family_member_count, 3, 1)


-------------------------------------------------------------------------------------------------------


-- Round the numbers


Update PortfolioProject.dbo.cost_of_living_us
SET housing_cost = ROUND(housing_cost, 2), 
	food_cost = ROUND(food_cost, 2),
	transportation_cost = ROUND(transportation_cost, 2),
	healthcare_cost = ROUND(healthcare_cost, 2),
	other_necessities_cost = ROUND(other_necessities_cost, 2),
	childcare_cost = ROUND(childcare_cost, 2),
	taxes = ROUND(taxes, 2),
	total_cost = ROUND(total_cost, 2),
	median_family_income = ROUND(median_family_income, 2)


--------------------------------------------------------------------------------------------------------

-- Single Parent cost of living and what percent of median income they need to cover their expenses
-- and using CTE to perform more calculations


With MinnesotaSingleParent (isMetro, state, county, total_cost, median_family_income, parent_number, 
						 child_number, PercentMedInNeeded)
AS
(
Select isMetro, state, county, total_cost, median_family_income, parent_number, child_number,
	   Round((total_cost/median_family_income)*100, 2) as PercentMedInNeeded
From PortfolioProject..cost_of_living_us
Where state = 'MN' AND parent_number = 1 AND child_number > 0
)
Select *, ROUND(PercentMedInNeeded/(parent_number + child_number),2) as PercentMedInNeededPerPerson
From MinnesotaSingleParent
Order BY PercentMedInNeeded Desc


-----------------------------------------------------------------------------------------------------------

-- Two Parents cost of living and what percent of median income they need to cover their expenses


With MinnesotaTwoParent ( isMetro, state, county, total_cost, median_family_income, parent_number, 
						 child_number, PercentMedInNeeded)
AS
(
Select  isMetro, state, county, total_cost, median_family_income, parent_number, child_number,
	   Round((total_cost/median_family_income)*100, 2) as PercentMedInNeeded
From PortfolioProject..cost_of_living_us
Where state = 'MN' AND parent_number = 2 AND child_number > 0
)
Select *, ROUND(PercentMedInNeeded/(parent_number + child_number),2) as PercentMedInNeededPerPerson
From MinnesotaTwoParent
Order BY PercentMedInNeededPerPerson Desc


-----------------------------------------------------------------------------------------------------------

-- Cost of living alone


With MinnesotaSingle (state, county, total_cost, median_family_income, parent_number, 
						 child_number, PercentMedInNeeded)
AS
(
Select state, county, total_cost, median_family_income, parent_number, child_number,
	   Round((total_cost/median_family_income)*100, 2) as PercentMedInNeeded
From PortfolioProject..cost_of_living_us
Where state = 'MN' AND parent_number = 1 AND child_number = 0
)
Select *, PercentMedInNeeded/1 as PercentMedInNeededPerPerson
From MinnesotaSingle
Order BY PercentMedInNeededPerPerson Desc


-----------------------------------------------------------------------------------------------------------

-- Cost of living as double income no kids


With MinnesotaDinks (state, county, total_cost, median_family_income, parent_number, 
						 child_number, PercentMedInNeeded)
AS
(
Select state, county, total_cost, median_family_income, parent_number, child_number,
	   Round((total_cost/median_family_income)*100, 2) as PercentMedInNeeded
From PortfolioProject..cost_of_living_us
Where state = 'MN' AND parent_number = 2 AND child_number = 0
)
Select *, PercentMedInNeeded/2 as PercentMedInNeededPerPerson
From MinnesotaDinks
Order BY PercentMedInNeededPerPerson Desc


------------------------------------------------------------------------------------------------------------

-- Nonmetro area cost of living


With MnNonmetro ( isMetro, state, county, family_member_count, total_cost, median_family_income, parent_number, 
						 child_number, PercentMedInNeeded)
AS
(
Select  isMetro, state, county, family_member_count, total_cost, median_family_income, parent_number, child_number,
	   Round((total_cost/median_family_income)*100, 2) as PercentMedInNeeded
From PortfolioProject..cost_of_living_us
Where state = 'MN' and isMetro = 0
)
Select *, ROUND(PercentMedInNeeded/(parent_number + child_number),2) as PercentMedInNeededPerPerson
From MnNonmetro


-----------------------------------------------------------------------------------------------------------

-- Metro area cost of living


With MnMetro ( isMetro, state, county, family_member_count, total_cost, median_family_income, parent_number, 
			   child_number, PercentMedInNeeded)
AS
(
Select  isMetro, state, county, family_member_count, total_cost, median_family_income, parent_number, 
		child_number, Round((total_cost/median_family_income)*100, 2) as PercentMedInNeeded
From PortfolioProject..cost_of_living_us
Where state = 'MN' and isMetro = 1
)
Select *, ROUND(PercentMedInNeeded/(parent_number + child_number),2) as PercentMedInNeededPerPerson
From MnMetro


-------------------------------------------------------------------------------------------------------------

-- 1 parent vs # of child in metro areas


Select child_number, AVG(Round((median_family_income - total_cost),2)) as Affordability,
	   AVG(median_family_income) as AvgMedianIncome,
	   AVG(total_cost) as AvgTotalCost
From PortfolioProject..cost_of_living_us
Where state = 'MN' and isMetro = 1 and parent_number = 1
Group by child_number


-------------------------------------------------------------------------------------------------------------

-- 2 parents vs # of child in metro areas

Select child_number, AVG(Round((median_family_income - total_cost),2)) as Affordability,
	   AVG(median_family_income) as AvgMedianIncome,
	   AVG(total_cost) as AvgTotalCost
From PortfolioProject..cost_of_living_us
Where state = 'MN' and isMetro = 1 and parent_number = 2
Group by child_number


-------------------------------------------------------------------------------------------------------------

-- 1 parent vs # of child in nonmetro areas


Select child_number, AVG(Round((median_family_income - total_cost),2)) as Affordability,
	   AVG(median_family_income) as AvgMedianIncome,
	   AVG(total_cost) as AvgTotalCost
From PortfolioProject..cost_of_living_us
Where state = 'MN' and isMetro = 0 and parent_number = 1
Group by child_number


------------------------------------------------------------------------------------------------------------

-- 2 parents vs # of child in nonmetro areas


Select child_number, AVG(Round((median_family_income - total_cost),2)) as Affordability,
	   AVG(median_family_income) as AvgMedianIncome,
	   AVG(total_cost) as AvgTotalCost
From PortfolioProject..cost_of_living_us
Where state = 'MN' and isMetro = 0 and parent_number = 2
Group by child_number


------------------------------------------------------------------------------------------------------------

-- Median family income, average total cost, and average(median_family_income - total_cost) per county


Select state, county, AVG(total_cost) as AvgTotalCost, 
	   AVG(median_family_income) as MedianFamilyIncome, 
	   AVG(median_family_income - total_cost) as AvgAffordability
From PortfolioProject..cost_of_living_us
Where state = 'MN'
Group By county, state
Order By AvgAffordability Desc


-------------------------------------------------------------------------------------------------------------
