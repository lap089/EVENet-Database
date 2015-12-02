
use[EVENet]
go


/* ERRORS & EXCEPTION:
  * createInterest, deleteInterest: No permission 10, 0 -> occurs when an user tries to create/delete an Interest
  * deleteEvent, setEvent: No permission 10, 1 -> occurs when an user tries to delete/set an event
  */


/*Create an interest (Admin only)*/
create procedure createInterest
 @name nvarchar(32), @description nvarchar(1024), @thumbnail image
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
 @endtime datetime, @description nvarchar(1024), @title nvarchar(128),   
 @location int
 as
 begin
	if( dbo.isHost(@username,@id) = 0 and dbo.isAdmin(@username) =0)
	raiserror('Only author or admin can edit',10,1)
	else
	update [Event]
	set beginTime = @begintime, endTime = @endtime, description = @description,title =@title, location = @location
	where id = @id
 end
 go



