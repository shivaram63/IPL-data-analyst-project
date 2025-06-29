# PHASE 1-Basic SQL Analysis on IPL Dataset



SELECT * FROM newschema.matches;
select count(*) as total_matches from matches; # To find out how many IPL matches played in total
select * from matches;
select count(distinct id) as unique_matches from matches;

# List all unique seasons and there Match count
select season, count(*) as matches_played
from matches
group by season
order by season;

# Top 10 Venues Where Most Matches Were Played
select venue, count(*) as match_count
from matches
group by venue
order by match_count desc
limit 10;

# Teams that Played the Most Matches
select team, count(*) as total_matches
from (
	select team1 as team from matches
    union all
    select team2 as team from matches
) as all_teams
group by team
order by total_matches desc;

# Most Successful Teams (by wins)
select winner as team, count(*) as wins
from matches
where winner is not null
group by winner
order by wins desc;

# Step 6: Toss Decision Distribution (Bat or Field)
select toss_decision, count(*) as decision_count
from matches
group by toss_decision
order by decision_count desc;

# Step 7: Toss Winner vs Match Winner - Did Toss Help?
select
	case
		when toss_winner = winner then 'Toss & Match Won'
        else 'Only Toss Won'
    end as result_type,
    count(*) as match_count
from matches
where winner is not null
group by result_type;

# Step 8: Which Toss Decision Leads to More Wins?
select toss_decision, count(*) as wins
from matches
where toss_winner = winner
group by toss_decision
order by wins desc;    

# PHASE 3: Player Performance Analysis(SQL)


SELECT * FROM newschema.deliveries;



# Step 9: Top 10 Run Scorers
SELECT batter, SUM(batsman_runs) AS total_runs
FROM deliveries
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;



# Step10: Top Boundary Hitters (Fours & Sixes)
select
	batter,
    sum(case when batsman_runs = 4 then 1 else 0 end) as total_fours,
    sum(case when batsman_runs = 6 then 1 else 0 end) as total_sixes
from deliveries
group by batter
order by total_sixes desc
limit 10;    



# Step 11: Highest Strike Rate (min 200 balls faced)
select batter,
	sum(batsman_runs) as runs,
    count(*) as balls_faced,
    round((sum(batsman_runs) * 100.0) / count(*), 2) as strike_rate
from deliveries
group by batter
having count(*) >=50
order by strike_rate desc
limit 10;


# Step12: Top 10 Wicket-Takers
select bowler, count(*) as wickets
from deliveries
where dismissal_kind in ('caught','bowled','lbw','caught and bowled','stumped','hit wicket')
group by bowler
order by wickets desc
limit 10;


# Step13: Most Economical Bowlers (min 50 balls)
select bowler,
		sum(total_runs) as runs_conceded,
        count(*) as balls_bowled,
        round(sum(total_runs) * 6.0 / count(*), 2) as economy_rate
from deliveries
group by bowler
having count(*) >=50
order by economy_rate asc
limit 10;        
    

# Step14: Most Dot Balls Bowled (Top Dot Balls Specialists)
select 
	bowler,
    count(*) as dot_balls
from deliveries
where total_runs = 0
group by bowler
order by dot_balls desc
limit 10;


# Step15: Match Winning Performances 
select match_id, batter, sum(batsman_runs) as runs_scored
from deliveries
group by match_id, batter
having sum(batsman_runs) >= 50
order by runs_scored desc
limit 10;    
    
    # PHASE4: Advanced SQL Insights

SELECT * FROM newschema.deliveries;

# Step16: Most Economical Bowlers (min 50 balls)
select
	bowler,
    count(*) as balls_bowled,
    sum(total_runs) as runs_conceded,
    round(sum(total_runs) / (count(*) / 6), 2) as economy_rate
from deliveries
group by bowler
having count(*) >=50
order by economy_rate asc
limit 10;    


# Step17: Batsman vs Bowler Head-to-Head
select 
	batter,
    bowler,
    count(*) as balls_faced,
	sum(batsman_runs) as runs_scored,
    round(sum(batsman_runs) * 1.0/count(*),2) as strike_rate
from deliveries
group by batter, bowler    
having balls_faced >=10
order by strike_rate desc
limit 20;


# Step18: from matches3

# Step21: Match With Highest Total Runs (Both Teams)
select match_id, batting_team, bowling_team, sum(total_runs) as total_match_runs
from deliveries
group by match_id, batting_team, bowling_team
order by total_match_runs desc
limit 10;

# Step22: Number of Dot Balls Per Bowler
select bowler,count(*) as dot_balls
from deliveries
where total_runs=0
group by bowler
order by dot_balls desc
limit 10;


# Step23: Batsman vs Bowler-Head-to-Head Battle
# Objective: Understand how a specific batter has performed against a particular bowler-total_runs, balls_faced, dismissals.
select 
	batter,
    bowler,
    count(*) as balls_faced,
    sum(batsman_runs) as runs_scored,
    sum(case when dismissal_kind is not null and player_dismissed =batter then 1 else 0 end) as times_dismissed,
    round(sum(batsman_runs) / nullif(sum(case when dismissal_kind is not null and player_dismissed = batter then 1 else 0 end),0),2) as average
    from deliveries
    group by batter, bowler
    having balls_faced >= 10
    order by average desc
    limit 10;

# PHASE4: Advanced SQL Insights 

SELECT * FROM newschema.matches;

# Step18: Most Matches Played by Players
select player_of_match, count(*) as awards
from matches 
group by player_of_match
order by awards desc;

# Step19: Most Wins by Team
select winner, count(*) as wins
from matches
group by winner
order by wins desc;

# Step20: Win % While Chasing vs Batting First 
	# 1.Batting first win%
select 
	toss_decision,
    count(*) as total_matches,
    sum(case when toss_decision = 'bat' and winner = team1 then 1 else 0 end) as wins
    from matches
    group by toss_decision;
    
    # 2.Chasing win%
select 
	toss_decision,
	count(*) as total_matches,
    sum(case when toss_decision = 'field' and winner=team2 then 1 else 0 end) as wins
from matches 
group by toss_decision;   


    # Step24: Most Successful Chasing Teams 
    # Objective: Who are the best teams while chasing targets?
SELECT 
    m.winner,
    COUNT(*) AS chasing_wins
FROM matches m
JOIN (
    SELECT match_id, MAX(inning) AS last_inning
    FROM deliveries
    GROUP BY match_id
) d ON m.id = d.match_id
WHERE d.last_inning = 2 AND m.winner = m.team2
GROUP BY m.winner
ORDER BY chasing_wins DESC;


# Step25: Match Results by Venue
select
	venue,
    count(*) as matches_played,
    count(distinct winner) as unique_winners
from matches
group by venue
order by matches_played desc;


# Step26: Win % by Toss Decision
select
	toss_decision,
    count(*) as total_matches,
    sum(case when toss_winner = winner then 1 else 0 end) as toss_and_match_wins,
    round(sum(case when toss_winner = winner then 1 else 0 end)* 100.0/count(*),2) as win_percentage
from matches
group by toss_decision; 
      