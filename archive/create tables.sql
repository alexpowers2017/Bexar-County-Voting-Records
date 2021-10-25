
if object_id('votes', 'u') is not null
	drop table [votes];

if object_id('totals', 'u') is not null
	drop table [totals];

if object_id('candidate_dim', 'u') is not null
	drop table [candidate_dim];

if object_id('office_dim', 'u') is not null
	drop table [office_dim];

if object_id('election_dim', 'u') is not null
	drop table [election_dim];


create table [candidate_dim] (
	[candidate_id] smallint not null,
	[candidate] nvarchar(50) not null,

	constraint [pk_candidate_dim] primary key ([candidate_id])
);
go

create table [office_dim] (
	[office_id] smallint not null,
	[office] nvarchar(100) not null,

	constraint [pk_office_dim] primary key ([office_id])
);
go

create table [election_dim] (
	[election_id] smallint not null,
	[date] date not null,
	[description] varchar(50) not null,
	[primary_party] char(1) not null,

	constraint [pk_election_dim] primary key ([election_id])
);
go


create table [votes] (
	[election_id] smallint not null,
	[precinct] smallint not null,
	[office_id] smallint not null,
	[candidate_id] smallint not null,
	[total] int not null,
	[election_day] smallint not null,
	[absentee] smallint not null,
	[early] smallint not null,

	constraint [pk_votes] primary key ([election_id], [precinct], [office_id], [candidate_id]),

	constraint [fk_votes_election_dim] foreign key ([election_id]) references [election_dim]([election_id]),
	constraint [fk_votes_office_dim] foreign key ([office_id]) references [office_dim]([office_id]),
	constraint [fk_votes_candidate_dim] foreign key ([candidate_id]) references [candidate_dim]([candidate_id])
);
go

create table [house_district_precincts] (
	[district] smallint not null,
	[precinct] smallint not null
);
go
