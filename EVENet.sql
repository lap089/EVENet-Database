create database [EVENet]
go

use [EVENeT]
go
create table [User]
(
	username varchar(32) not null,
	password varchar(64) not null,
	profilePicture varchar(256) not null,
	registerDate datetime,
	primary key(username)
)
go

create table [Individual]
(
	username varchar(32) not null,
	firstName nvarchar(16) not null,
	midName nvarchar(16),
	lastName nvarchar(16),
	DOB date,
	gender bit,
	primary key(username)
)
go

create table [Organization]
(
	username varchar(32) not null,
	description nvarchar(1024) not null,
	slogan nchar(64),
	logo nvarchar(256) not null,
	website varchar(256),
	primary key(username)
)
go

create table [Event]
(
	beginTime datetime not null,
	endTime datetime not null,
	description nvarchar(1024) not null,
	title nvarchar(64) not null,
	id int not null,
	location int not null,
	username varchar(32) not null,
	publishDate datetime not null,
	primary key(ID)
)
go

create table [Location]
(
	id int not null,
	name nvarchar(32),
	description nvarchar(1024),
	address nvarchar(64) not null,
	thumbnail varchar(126)
	primary key(ID)
)
go

create table [EventTag]
(
	event int not null,
	tag int not null,
	primary key(Event, Tag)
)
go

create table [UserUser]
(
	username1 varchar(32) not null,
	username2 varchar(32) not null,
	primary key(username1, Username2)
)
go

create table [Tag]
(
	id int not null,
	name nvarchar(32) not null,
	primary key(id)
)
go

create table [Interest]
(
	name nvarchar(32) not null,
	id int not null,
	description nvarchar(1024),
	thumbnail varchar(256),
	primary key(id)
)
go

create table [UserInterest]
(
	username varchar(32) not null,
	interest int,
	primary key(username, interest)
)
go

create table [Admin]
(
	username varchar(32)
)
go

