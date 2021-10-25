
create or replace table
`texas-elections.elections.candidate_dim`
(
    `candidate_id` integer options(description="Unique identifier for each candidate, shared across elections and offices. Primary key for this table. References [candidate_id] in [votes]."),
    `candidate_name` string options(description='Full name of candidate as a string.')
)
options(
    description='Holds information about individuals running for office, across elections and offices. Links to [votes] table by [candidate_id].'
);


create or replace table 
`texas-elections.elections.office_dim`
(
    `office_id` integer options(description='Unique identifier for each office shared across elections. Referenced by [office_id] in [votes].'),
    `branch` string options(description='Branch of government this office falls under. Possible values are "legislative", "executive", and "judicial".'),
    `level` string options(description='Level of government this office falls under. Possible values are "federal", "state", and "local".'),
    `title` string options(description='Job title of the office e.g. "senator" or "mayor".'),
    `location` string options(description='County, or City the office represents, if appropriate (e.g. "[Bexar County] Commissioner" or "[San Antonio] Mayor").'),
    `seat` integer options(description='Seat or District, for offices with numeric categories (e.g. "City Council Seat [4] or State Representative [125]th House District").')
)
options(
    description='Holds information about each office across elections and terms.'
);


create or replace table 
`texas-elections.elections.election_dim`
(
    `election_id` integer options(description='Unique identifier for each election. Democratic and Republican primaries counted together.'),
    `election_type` string options(description='Possible Values: "general", "primary", "special", "runoff", and "primary runoff". If a general election is combined with another type, it will be listed as "general".'),
    `election_date` date options(description='Date the election was held.')
)
options(
    description='Holds information about each election.'
);


create or replace table 
`texas-elections.elections.votes_fact`
(
    `candidate_id` integer options(description='Unique identifier for each candidate. References [candidate_id] in [candidate_dim].'),
    `race_id` integer options(description='Unique identifier for race to fill an office for a specific term. References [race_id] in [race_fact].'),
    `precinct` integer options(description='Voting District'),
    `county` string options(description='County where votes were collected.'),
    `total` integer options(description='Total number of votes cast for a candidate in precinct.'),
    `election_day` integer options(description='Number of votes cast for a candidate in person on election day in precinct.'),
    `absentee` integer options(description='Number of absentee votes cast for a candidate in precinct.'),
    `early` integer options(description='Number of early votes cast for a candidate in precinct.')
)
options(
    description='This table holds the vote counts for each candidate in each race in each precinct. The most granular vote data available.'
);



create or replace table
`texas-elections.elections.race_fact`
(
    `race_id` integer options(description='Unique identifier for race to fill an office for a specific term. Referenced by [race_id] in [votes_fact].'),
    `office_id` integer options(description='Unique identifier for each office shared across elections. References [office_id] in [office_dim].'),
    `general_election_id` integer options(description='Election ID of general election for this race, or special election ID if decided in special election.'),
    `primary_election_id` integer options(description='Election ID of primary election for this race.'),
    `runoff_election_id` integer options(description='Election ID of runoff election for this race, if applicable.'),
    `primary_runoff_election_id` integer options(description='Election ID of primary runoff election for this race, if applicable.'),
    `term_start` date options(description='Start date of the term for the office this race is for.'),
    `term_end` date options(description='End date of the term for the office this race is for.')
)
options(
    description='This table consolidates information about the entire race to fill an office for a specific term, across elections.'
);



create or replace table
`texas-elections.elections.precinct_dim`
(
    `precinct` integer options(description='Voting District.'),
    `county` string options(description='County where votes were collected.'),
    `geography` geography options(description='Geographical information about precinct.')
)
options(
    description='Information about each voting district/precinct.'
);

