/* Authors: Khoi Hoang, Quoc-Lap Trieu */
/* ADD TABLES */

create database EVENet
go

use [EVENeT]
go
create table [User] (
	username  varchar(32) not null ,
	password varchar(64) not null,
	profilePicture varchar(256),
	coverPicture varchar(256),
	registerDate datetime default getdate() not null,
	userType int not null,

)


ALTER TABLE [User]
ALTER COLUMN password varchar(64)
COLLATE Latin1_General_CS_AS not null

ALTER TABLE [User]
ALTER COLUMN username varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [user]
ADD PRIMARY KEY (username)
go



create table [Individual] (
	username varchar(32) not null,
	firstName nvarchar(16) not null,
	midName nvarchar(16),
	lastName nvarchar(16) not null,
	DOB date not null,
	gender bit not null,
	
)

ALTER TABLE [Individual]
ALTER COLUMN username varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [Individual]
ADD PRIMARY KEY (username)
go



create table [Organization] (
	username varchar(32) not null,
	name nvarchar(64) not null,
	description nvarchar(max) not null,
	[type] nvarchar(32) not null,
	[phone] varchar(16),
	website varchar(256),
)
ALTER TABLE [Organization]
ALTER COLUMN username varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [Organization]
ADD PRIMARY KEY (username)
go



create table [Type] (
	name nvarchar(32),
	primary key(name)
)



create table [Event] (
	id int identity(1, 1) not null,
	beginTime datetime not null,
	endTime datetime not null,
	description nvarchar(1024) not null,
	thumbnail varchar(256),
	title nvarchar(128) not null,
	location int not null,
	username varchar(32) not null,
	publishDate datetime default getdate(),
	primary key(id)
)
ALTER TABLE [Event]
ALTER COLUMN username varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 
go



create table [Location] (
	id int identity(1, 1) not null,
	name nvarchar(32) not null,
	description nvarchar(1024),
	address nvarchar(64) not null,
	latitude float not null,
	longitude float not null,
	thumbnail varchar(256),
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
)
ALTER TABLE [UserUser]
ALTER COLUMN username1 varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [UserUser]
ALTER COLUMN username2 varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [UserUser]
ADD PRIMARY KEY (username2, username1)
go



create table [Tag] (
	id varchar(32) not null,
	occurrence int default 1 not null,
	primary key(id)
)
go


create table [Interest] (
	name nvarchar(32),
	description nvarchar(1024),
	thumbnail varchar(256),
	primary key(name)
)
go

create table [IndividualInterest] (
	username varchar(32) not null,
	interest nvarchar(32) not null,
)

ALTER TABLE [IndividualInterest]
ALTER COLUMN username varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [IndividualInterest]
ADD PRIMARY KEY (username, interest)
go


create table [Admin] (
	username varchar(32),
)

ALTER TABLE [Admin]
ALTER COLUMN username varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [Admin]
ADD PRIMARY KEY (username)
go


create table [UserEventAttendants] (
	username varchar(32) not null,
	event int not null,
	attend int default 0 not null,
)

ALTER TABLE [UserEventAttendants]
ALTER COLUMN username varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [UserEventAttendants]
ADD PRIMARY KEY (username,event)
go


create table [Photo] (
	eventId int not null,
	[order] int not null,
	data varchar(256) not null,

	primary key (eventId, [order])
)

create table [Comment] (
	id int identity(1, 1),
	content nvarchar(1024) not null,
	eventId int,
	author varchar(32),
	primary key(id)
)

ALTER TABLE [Comment]
ALTER COLUMN author varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 
go


create table [Notification](
	id int identity(1,1),
	receiver varchar(32) not null,
	sender varchar(32) not null,
	eventId int,
	typeInfo int,
	Seen bit default 0,
	timeSent datetime default getdate(),
	primary key(id)
)

ALTER TABLE [Notification]
ALTER COLUMN receiver varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 

ALTER TABLE [Notification]
ALTER COLUMN sender varchar(32)
COLLATE SQL_Latin1_General_CP1_CS_AS not null 
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

alter table [IndividualInterest]
add constraint FK_IndividualInterest_Interest foreign key ([interest])
references [Interest]([name])

alter table [IndividualInterest]
add constraint FK_IndividualInterest_User foreign key ([username])
references [Individual]([username])

alter table [UserUser]
add constraint FK_UserUser_User1 foreign key ([username1])
references [User]([username])

alter table [UserUser]
add constraint FK_UserUser_User2 foreign key ([username2])
references [User]([username])

alter table [UserEventAttendants]
add constraint FK_UserEventAttendants_User foreign key (username)
references [User](username)

alter table [UserEventAttendants]
add constraint FK_UserEventAttendants_Event foreign key (event)
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

alter table [Notification]
add constraint FK_Notify_Receiver
foreign key (receiver) references [User]([username])


alter table [Notification]
add constraint FK_Notify_Sender
foreign key (sender) references [User]([username])


alter table [Notification]
add constraint FK_Notify_Event
foreign key (eventId) references [Event](id)





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

alter table UserEventAttendants
add constraint CST_Valid_Status
check (attend = -1 or attend = 0 or attend = 1)

alter table [UserUser]
add constraint CST_Valid_Follow
check (username1 != username2)

alter table [Tag]
add constraint CST_No_Space
check (id not like '% %')

alter table [Notification]
add constraint CST_Reciever_Sender
check (receiver not like sender)

go
create trigger userInviteHimself
on [UserEventAttendants]
for insert, update
as
begin
	declare @username nvarchar(32) , @event int
	select @username = username, @event = event from inserted
	 if exists (select * from [Event] e, [UserEventAttendants] uea where e.username = uea.username and e.id = uea.event)
		begin
		raiserror('User cannot invite himself',10,3)
		rollback
		end
end
go



