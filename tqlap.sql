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