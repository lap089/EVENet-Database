
use[EVENet]
go


/* ERRORS & EXCEPTION:
  * createInterest, deleteInterest: No permission 10, 0 -> occurs when an user tries to create/delete an Interest
  * deleteEvent, setEvent: No permission 10, 1 -> occurs when an user tries to delete/set an event
  * attachInterest: Individual only 10, 2 -> occurs when attaching an interest to an user
  
  */


/*Create an interest (Admin only)*/
create procedure createInterest
 @name nvarchar(32), @description nvarchar(1024), @thumbnail varchar(256)
 as
 begin
	if(dbo.isAdmin(@name) = 1)
	begin
	insert into [Interest]
	values(@name, @description, @thumbnail)
	end
	else raiserror('Only admin can edit',10,0)
 end
go

/*get an interest */
create procedure getInterest
 @name nvarchar(32)
 as
 begin
	select * from Interest
	where name = @name
 end
go


/*delete an interest (admin only)*/
create procedure deleteInterest
@name nvarchar(32)
as
begin
	if (dbo.isAdmin(@name) = 1)
	begin
	delete from [Interest]
	where name = @name
	end
	else raiserror('Only admin can edit',10,0)
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
@interest nvarchar(32)
 as
 begin
	select u.* from  [IndividualInterest] indin, [User] u 
	where u.username = indin.username and  indin.interest = @interest
 end
go

/*delete an Event (must pass an username to check if it is author or admin)*/
create procedure deleteEvent
@id int, @username varchar(32)
as
begin
	if (dbo.isHost(@username,@id) = 0 and dbo.isAdmin(@username) = 0 )
	raiserror('Only author or admin can edit',10,1)
	else
	delete from [Event] where id = @id
end
go



/*Change an Event (must pass an username to check if it is author or admin)*/
create procedure setEvent
@id int, @username nvarchar(32), @begintime datetime,
 @endtime datetime, @description nvarchar(1024),@thumbnail varchar(256) ,@title nvarchar(128), @ticket int,  
 @location int
 as
 begin
	if( dbo.isHost(@username,@id) = 0 and dbo.isAdmin(@username) =0)
	raiserror('Only author or admin can edit',10,1)
	else
	update [Event]
	set beginTime = @begintime, endTime = @endtime,
	 description = @description,title =@title, thumbnail = @thumbnail 
	 , ticket = @ticket,location = @location
	where id = @id
 end
 go





create procedure attachInterest
@username varchar(32), @interest nvarchar(32)
as
begin
	if(dbo.isIndividual(@username) = 1)
	begin
		insert into [IndividualInterest]
		values(@username,@interest)
	end
	else
		raiserror('Only individual can attach with interest',10,2)
end
go

create procedure dettachInterest
@username varchar(32), @interest nvarchar(32)
as
begin
	delete from [IndividualInterest]
	where username = @username and interest = @interest
end
go

--Check functions:
create function isIndividual(@username varchar(32))
	returns bit
as begin
	
	if exists (select * from [Individual] where username = @username) begin
		return 1
	end
	return 0
end
go




-- Check if individual account is fully set up
create function isIndividualFullySetUp(@username varchar(32))
	returns bit
as begin
	if exists (select * from [Individual] where username = @username AND firstName = '') begin
		return 1
	end
	return 0
end
go

​
-- Get user's type
create function getUserType(@username varchar(32))
returns int
as begin
	declare @result int
	Select @result = userType
	from [User]
	where username = @username
	return @result
end
go




​
-- Get number of ticket of an event
create function getNumberOfTicket(@eventId int)
returns int
as begin
	declare @result int
	Select @result = count(*)
	from [UserEventAttendants]
	where event = @eventId
	return @result
end
go





-- Get all events
create procedure getAllEvent
as
begin
	select * from [Event]
end
go


-- Get event from ID
create procedure getEventFromID
@eventid int
as
begin
	select * from [Event] where id = @eventid
end
go



----test:
--exec dbo.createRoot 'tqlap@apcs.vn','fsdfsdfsdf',null 
--exec dbo.createLocation 'here','fsdfdsf','fsdfew','321','3213',null


--exec dbo.createEvent '2016-3-3','2016-4-4','fdsgrefew',null,'test',1,'tqlap@apcs.vn'

--exec dbo.invite 6,'tqlap@apcs.vn'

--exec dbo.createIndividual 'lap@apcs.vn', '123456789', '','','','','','1995/1/1',1

--print dbo.auth('lap@apcs.vn','TrieuQuoc')

--exec dbo.createEvent '2016/1/1', '2016/2/2','just for test purpose','','test1', 1,10,'lap@apcs.vn' 
--exec dbo.createEvent '2016/1/1', '2016/2/2','jDid you know that the United States will select its next president in 2016? Come learn about the elections process in the United States through a series of talks with our consulate officers. Bring your friends!', '','test2', 1,10,'lap@apcs.vn' 

--exec dbo.createEvent '2016/1/1', '2016/2/2','just for test purpose','','test3', 1,10,'lap@apcs.vn' 
--exec dbo.createEvent '2016/1/1', '2016/2/2','just for test purpose','','test4', 1,10,'lap@apcs.vn' 
--exec dbo.createEvent '2016/1/1', '2016/2/2','just for test purpose','D:\Pictures\1604833_490094347765755_1526518009_n.jpg','test6', 1,10,'lap@apcs.vn' 
