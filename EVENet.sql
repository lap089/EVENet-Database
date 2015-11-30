/* Authors: Khoi Hoang, Quoc-Lap Trieu */
/* ADD TABLES */

create database EVENet
go

use [EVENeT]
go
create table [User] (
	username varchar(32) not null,
	password varchar(64) not null,
	profilePicture image,
	registerDate datetime default getdate() not null,
	userType int not null,
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
	[type] nvarchar(32) not null,
	[phone] varchar(16),
	website varchar(256),
	primary key(username)
)
go

create table [Type] (
	name nvarchar(32),
	primary key (name)
)

create table [Event] (
	id int identity(1, 1) not null,
	beginTime datetime not null,
	endTime datetime not null,
	description nvarchar(1024) not null,
	title nvarchar(64) not null,
	location int not null,
	username varchar(32) not null,
	publishDate datetime not null,
	primary key(id)
)
go

create table [Location] (
	id int identity(1, 1) not null,
	name nvarchar(32) not null,
	description nvarchar(1024),
	address nvarchar(64) not null,
	longitude real,
	latitude real,
	thumbnail image,
	primary key(ID)
)
go

create table [EventTag] (
	event int not null,
	tag varchar(32) not null,
	primary key(Event, Tag)
)
go

create table [UserUser] (
	username1 varchar(32) not null,
	username2 varchar(32) not null,
	primary key(username1, Username2)
)
go

create table [Tag] (
	id varchar(32) not null,
	primary key(id)
)
go

create table [Interest] (
	id int identity(1, 1) not null,
	name nvarchar(32) not null,
	description nvarchar(1024),
	thumbnail varchar(256),
	primary key(id)
)
go

create table [UserInterest] (
	username varchar(32) not null,
	interest int,
	primary key(username, interest)
)
go

create table [Admin] (
	username varchar(32)
)
go

create table [UserEvent] (
	username varchar(32),
	event int,
	attend int default 0 not null,

	primary key(username, event)
)

go

create table [Photo] (
	eventId int not null,
	[order] int not null,
	data image not null,

	primary key (eventId, [order])
)

create table [Comment] (
	id int identity(1, 1),
	content nvarchar(256),
	eventId int,
	author varchar(32),

	primary key(id)
)
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
references [Individual]([username])

alter table [UserUser]
add constraint FK_UserUser_User1 foreign key ([username1])
references [User]([username])

alter table [UserUser]
add constraint FK_UserUser_User2 foreign key ([username2])
references [User]([username])

alter table [UserEvent]
add constraint FK_UserEvent_User foreign key (username)
references [User](username)

alter table [UserEvent]
add constraint FK_UserEvent_Event foreign key (event)
references [Event](id)

alter table [Photo]
add constraint FK_Photo_Event
foreign key (eventId) references [Event](id)

alter table [Organization]
add constraint FK_Organization_Type
foreign key ([type]) references [Type](name)

alter table [Comment]
add constraint FK_Comment_Event
foreign key (eventId) references [Event](id)

alter table [Comment]
add constraint FK_Comment_Author
foreign key (author) references [User]([username])

/* ADD CONSTRAINTS */

alter table [User]
add constraint CST_Password check(len(password) > 7)

alter table [Event]
add constraint CST_Event_Time check(beginTime < endTime and getdate() <= beginTime)

alter table [Event]
add constraint CST_Title_Length check(len(title) > 3)

alter table [User]				/* UNDER CONSTRUCTION */
add constraint CST_Valid_Email 
check(username like '%@%.%' and username not like '%[@,/,\, ]%@.%')

alter table [Individual]
add constraint CST_Valid_DOB
check (DOB < getdate())

alter table [User]
add constraint CST_Valid_Type
check (userType = 0 or userType = 1 or userType = 2)

alter table UserEvent
add constraint CST_Valid_Status
check (attend = -1 or attend = 0 or attend = 1)


go
create procedure getOrganization
 @username varchar(32)
 as
 begin
	select * from Organization
	where username = @username
 end
go

create procedure setInterest
 @id int,
 @name nvarchar(32), @description nvarchar(1024), @thumbnail varchar(256)
 as
 begin
	update Interest
	set @name =name , @description = description, @thumbnail = thumbnail
	where id = @id
 end
go

create procedure createInterest
 @name nvarchar(32), @description nvarchar(1024), @thumbnail varchar(256)
 as
 begin
	insert into Interest(name,description,thumbnail)
	values(@name,@description,@thumbnail)
 end
go

create procedure getInterest
 @id int
 as
 begin
	select * from Interest
	where id = @id
 end
go

create procedure searchInterestFromName
@name nvarchar(32)
 as
 begin
	select * from Interest
	where name like '%'+@name+'%'
 end
go

create procedure searchUserFromInterest
@name nvarchar(32)
 as
 begin
	select u.* from UserInterest ui, [User] u 
	where u.username = ui.username and ui.interest = @name
 end
go



create procedure getTag
 @name varchar(32)
 as
 begin
	select * from Tag
	where id = @name
 end
go

create procedure createTag
 @name varchar(32)
 as 
 begin
	insert into Tag
	values(@name)
 end
go


create procedure addTagToEvent
 @tag varchar(32), @event int
 as 
 begin
	insert into EventTag
	values(@event,@tag)
 end
go


create procedure isTagExist
@tag varchar(32)
as
begin
	return (select count(*) from Tag where id = @tag)
end
go

create procedure searchEventFromTag
@tag varchar(32)
as
begin
	select e.* from EventTag et, [Event] e where et.tag= @tag and e.id = et.event 
end
go



