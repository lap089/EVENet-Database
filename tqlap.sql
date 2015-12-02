
use[EVENet]
go


/*Create an interest (Admin only)*/
create procedure createInterest
 @name nvarchar(32), @description ntext, @thumbnail image
 as
 begin
	insert into [Interest]
	values(@name, @description, @thumbnail)
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
	delete from [Interest]
	where name = @name
end
go



--create procedure searchInterestFromName
--@name nvarchar(32)
-- as
-- begin
--	select * from Interest
--	where name like '%'+@name+'%'
-- end
--go


--create procedure searchUserFromInterest
--@name nvarchar(32)
-- as
-- begin
--	select u.* from UserInterest ui, [User] u 
--	where u.username = ui.username and ui.interest = @name
-- end
--go



/*delete an Event (must pass an username to check if it is author or admin)*/
create procedure deleteEvent
@id int, @username varchar(32)
as
begin
	if (dbo.isHost(@username,@id) = 0 and dbo.isAdmin(@username) = 0 )
	raiserror('Only author or admin can edit',10,0)
	else
	delete from [Event] where id = @id
end
go



/*Change an Event (must pass an username to check if it is author or admin)*/
create procedure setEvent
@id int, @username nvarchar(32), @begintime datetime,
 @endtime datetime, @description ntext, @title nvarchar(128),   
 @location int
 as
 begin
	if( dbo.isHost(@username,@id) = 0 and dbo.isAdmin(@username) =0)
	raiserror('Only author or admin can edit',10,0)
	else
	update [Event]
	set beginTime = @begintime, endTime = @endtime, description = @description,title =@title, location = @location
	where id = @id
 end
 go




--create procedure getTag
-- @name varchar(32)
-- as
-- begin
--	select * from Tag
--	where id = @name
-- end
--go

--create procedure createTag
-- @name varchar(32)
-- as 
-- begin
--	insert into Tag
--	values(@name)
-- end
--go


--create procedure addTagToEvent
-- @tag varchar(32), @event int
-- as 
-- begin
--	insert into EventTag
--	values(@event,@tag)
-- end
--go


--create procedure isTagExist
--@tag varchar(32)
--as
--begin
--	return (select count(*) from Tag where id = @tag)
--end
--go

--create procedure searchEventFromTag
--@tag varchar(32)
--as
--begin
--	select e.* from EventTag et, [Event] e where et.tag= @tag and e.id = et.event 
--end
--go





-- Check functions:

/* Check if a user is an admin */
create function isAdmin(@username varchar(32))
	returns bit
as begin
	
	if exists (select * from [Admin] where username = @username) begin
		return 1
	end
	return 0
end
go


/*  Check if an user is an event host */
create function isHost(@username varchar(32), @eventId int)
	returns bit
as begin
	if exists (select * from [Event] where username = @username and id = @eventId) begin
		return 1
	end
	return 0
end
go
