/* ADD TABLES */

create database [EVENet]
go

use [EVENeT]
go
create table [User] (
	username varchar(32) not null,
	password varchar(64) not null,
	profilePicture varchar(256),
	registerDate datetime default getdate() not null,
	primary key(username)
)
go

create table [Individual] (
	username varchar(32) not null,
	firstName nvarchar(16) not null,
	midName nvarchar(16),
	lastName nvarchar(16) not null,
	DOB date not null,
	gender bit not null,
	primary key(username)
)
go

create table [Organization] (
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
	id int identity(1, 1) not null,
	location int not null,
	username varchar(32) not null,
	publishDate datetime not null,
	primary key(ID)
)
go

create table [Location]
(
	id int identity(1, 1) not null,
	name nvarchar(32) not null,
	description nvarchar(1024),
	address nvarchar(64) not null,
	longitude real,
	latitude real,
	thumbnail varchar(126),
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
	id int identity(1, 1) not null,
	name nvarchar(32) not null,
	primary key(id)
)
go

create table [Interest]
(
	name nvarchar(32) not null,
	id int identity(1, 1) not null,
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

/* ADD FOREIGN KEYS */

alter table [Individual]
add constraint FK_Individual_User foreign key ([username])
references [User](username)

alter table [Organization]
add constraint FK_Organization_User foreign key ([username])
references [User](username)

alter table [Admin]
add constraint FK_Admin_User foreign key ([username])
references [User](username)

alter table [Event]
add constraint FK_Event_Location foreign key ([location])
references [Location](id)

alter table [Event]
add constraint FK_Event_User foreign key ([username])
references [User](username)

alter table [EventTag]
add constraint FK_EventTag_Event foreign key ([event])
references [Event]([id])

alter table [EventTag]
add constraint FK_EventTag_Tag foreign key ([tag])
references [Tag]([id])

alter table [UserInterest]
add constraint FK_UserInterest_Interest foreign key ([interest])
references [Interest]([id])

alter table [UserInterest]
add constraint FK_UserInterest_User foreign key ([username])
references [User]([username])

alter table [UserUser]
add constraint FK_UserUser_User1 foreign key ([username1])
references [User]([username])

alter table [UserUser]
add constraint FK_UserUser_User2 foreign key ([username2])
references [User]([username])

/* ADD CONSTRAINTS */

alter table [User]
add constraint CST_Password check(len(password) > 7)

alter table [Event]
add constraint CST_EventTime check(beginTime < endTime and getdate() <= beginTime)

alter table [Event]
add constraint CST_TitleLength check(len(title) > 3)

alter table [User]
add constraint CST_ValidEmail 
check(username like '%@%.%' and username not like '%[@,/,\, ]%@.%')

alter table [User]
drop CST_ValidEmail