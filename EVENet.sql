create database [EVENet]
GO

use [EVENeT]
GO
create table [User]
(
	Username varchar(32) not null,
	Password varchar(64) not null,
	ProfilePicture varchar(256) not null,
	RegisterDate datetime,
	primary key(Username)
)
GO

create table Individual
(
	UserName varchar(32) not null,
	FirstName nvarchar(16) not null,
	MidName nvarchar(16),
	LastName nvarchar(16),
	DOB date,
	Gender bit,
	primary key(Username)
)
GO

create table Organization
(
	Username varchar(32) not null,
	Description nvarchar(1024) not null,
	Slogan nchar(64),
	Logo nvarchar(256) not null,
	Website varchar(256),
	primary key(Username)
)
GO

create table [Event]
(
	BeginTime datetime not null,
	EndTime datetime not null,
	Description nvarchar(1024) not null,
	Title nvarchar(64) not null,
	ID int not null,
	Location int not null,
	Username varchar(32) not null,
	PublishDate datetime not null,
	primary key(ID)
)
GO

create table Location
(
	ID int not null,
	Name nvarchar(32),
	Description nvarchar(1024),
	Address nvarchar(64) not null,
	Thumbnail varchar(126)
	primary key(ID)
)
GO

create table Event_Tag
(
	Event int not null,
	Tag int not null,
	primary key(Event, Tag)
)
GO

create table User_User
(
	Username_1 varchar(32) not null,
	Username_2 varchar(32) not null,
	primary key(Username_1, Username_2)
)
GO

create table Tag
(
	ID int not null,
	Name nvarchar(32) not null,
	primary key(ID)
)
GO

create table Interest
(
	Name nvarchar(32) not null,
	ID int not null,
	Description nvarchar(1024),
	Thumbnail varchar(256),
	primary key(ID)
)
GO

create table User_Interest
(
	Username varchar(32) not null,
	Interest int,
	primary key(Username, Interest)
)
GO

create table Admin
(
	Username varchar(32)
)
GO


alter table Individual
add constraint FK_Movies_Genres
Foreign key (GenreId)
References Genres (GenreId)
GO