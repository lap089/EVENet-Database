/* NOTE:
 * userType: 0: Admin, 1: Individual, 2: Organization
 * gender: 0: Female, 1: Male
 * attendance: -1: No, 0: Maybe, 1: Yes
 */

 /* ERRORS & EXCEPTION:
  * createUser: No permission 18, 0 -> occurs when an user tries to create an admin
  * createType: No permission 18, 1 -> occurs when an user tries to create an organization type
  * createOrganization: Type not found 18, 2 -> occurs when organizations choose
  *						a type which is not existed.
  * setPassword: 18, 3: Wrong old password -> occurs when users input wrong old password but still can be
  *						able to change password.
  * deleteComment 18, 4: Remove a comment without authority
  */

  /* PERSONAL NOTE:
   * collate SQL_Latin1_General_CP1_CS_AS: case sensitive!
   */

   /* ISSUES 
    * Valid email checking
	* Password case sensitive comparison
	*/

	use [EVENet]
	go

/* 0. ADMIN SECTOR */

/* 0.1 Create a root user (admin) */
create proc createRoot
	@username varchar(32),
	@password varchar(64),
	@profilePicture varchar(256)
as begin
	insert into [User] (username, [password], profilePicture, userType) values
	(@username, @password, @profilePicture, 0)
	insert into [Admin] values (@username)
end
go

/* 0.2 Check if a user is an admin */
create function isAdmin(@username varchar(32))
	returns bit
as begin
	
	if exists (select * from [Admin] where username = @username) begin
		return 1
	end
	return 0
end
go



/* 0.3 Create location */
create proc createLocation
	@name nvarchar(32),
	@description nvarchar(1024),
	@address nvarchar(64),
	@long real,
	@lat real,
	@thumbnail varchar(256)
as begin
	insert into [Location] (name, description, address, longitude, latitude, thumbnail) values
	(@name, @description, @address, @long, @lat, @thumbnail)
end
go
/* END ADMIN SECTOR */

/* 1. ORGANIZATION TYPE SECTOR */
/* 1.1 Create a new organization sector */
create proc createType @name nvarchar(32), @currentUser varchar(32) as begin
	if ([dbo].isAdmin(@currentUser) = 1) begin
		insert into [Type] values (@name)
	end else begin
		raiserror('No permssion!', 18, 1);
	end
end
go

/* 1.2 Check is an organization type is existed */
create function isTypeExisted(@name varchar(32))
	returns bit
as begin
	if exists (select * from [User] where username = @name) begin
		return 1
	end
	return 0
end
go
/* 2. CORE SECTOR */
/* 2.0 Check if an user is existed */
create function isUserExisted(@username varchar(32)) 
	returns bit
as begin
	if exists (select * from [dbo].[User] where [username] = @username) begin
		return 1
	end
	return 0
end
go
/* 2.1 Create a base user */
create proc createUser
	@username varchar(32),
	@password varchar(64),
	@profilePicture varchar(256),
	@coverPicture varchar(256),
	@userType int
as begin
	if (@userType = 0) begin
		raiserror('No Permission!', 18, 0)
	end else begin	
		insert into [User] (username, [password], profilePicture, coverPicture, userType) values
		(@username, @password, @profilePicture, @coverPicture ,@userType)
	end
end
go


-- Set User's cover photo
create proc setCoverPictureUser
	@id varchar(32),
	@cover varchar(256)
as begin
	update [user]
		set	coverPicture = @cover
		where username = @id
end
go




/* 2.2 Check if users' aunthentication is valid */
create function [auth](@username varchar(32), @password varchar(64))
	returns bit
as begin
	declare @userPassword varchar(64) = (select [password] from [User] where [username] = @username)
	if (@userPassword COLLATE Latin1_General_CS_AS = @password COLLATE Latin1_General_CS_AS) begin
		return 1
	end
	return 0
end
go


/* 2.3 Create an individual */
create proc createIndividual
	@username varchar(32) ,
	@password varchar(64),
	@profilePicture varchar(256),
	@coverPicture varchar(256),
	@firstName nvarchar(16),
	@midName nvarchar(16),
	@lastName nvarchar(16),
	@dob date,
	@gender bit
as begin
	exec createUser @username , @password , @profilePicture, @coverPicture, 1

	insert into [Individual] values
	(@username, @firstName, @midName, @lastName, @dob, @gender)
end
go



/* 2.4 Create an organization */
create proc createOrganization
	@username varchar(32),
	@password varchar(64),
	@profilePicture varchar(256),
	@coverPicture varchar(256),
	@description nvarchar(1024),
	@type nvarchar(32),
	@phone varchar(16),
	@website varchar(256)
as begin
	if [dbo].isTypeExisted(@type) = 1 begin
		exec createUser @username, @password, @profilePicture, @coverPicture, 2
		insert into [Organization] values
		(@username, @description, @type, @phone, @website)
	end else begin
		raiserror('Type does not exist!', 18, 2)
	end
end
go




--	Set organization's information:
create proc setOrganization
	@id varchar(32),
	@description nvarchar(1024),
	@type nvarchar(32),
	@phone varchar(16),
	@website varchar(256)
as begin
	update Organization
		set	description = @description,
			[type] = @type,
			[phone] = @phone,
			website = @website
		where username = @id
end
go



/* #8 */
create proc getIndividual
	@id varchar(32)
as begin
	select *
		from Individual
		where username = @id
end
go

create proc setIndividual
	@id varchar(32),
	@firstName nvarchar(16),
	@midName nvarchar(16),
	@lastName nvarchar(16),
	@dob date,
	@gender bit
as begin
	update Individual
		set	firstName = @firstName,
			midName = @midName,
			lastName = @lastName,
			DOB = @dob,
			gender = @gender
		where username = @id
end
go


/* 2.5 Allows users to set profile pictures */

create proc setProfilePicture
	@username varchar(32), 
	@imageprofile varchar(256) 
as begin
	update [User]
	set profilePicture = @imageprofile
	where username = @username
end
go

/* 2.6 Allows users to set new password */
create proc setPassword
	@username varchar(32),
	@oldPassword varchar(64),	
	@newPassword varchar(64)
as begin
	if [dbo].[auth](@username, @oldPassword) = 1 begin
		update [User]
		set [password] = @newPassword
		where username = @username
		return
	end else begin
		raiserror('Wrong old password!', 18, 3)
	end
end
go

/* FRIEND ZONE =)) */

/* 2.7 Follow a friend */
create proc follow(@this varchar(32), @friend varchar(32)) as begin
	insert into [UserUser] values
	(@this, @friend)
end
go

/* 2.8 Unfollow a friend */
create proc unfollow @this varchar(32), @friend varchar(32) as begin
	delete from [UserUser]
	where username1 = @this and username2 = @friend
end
go

/* 2.9 List all following accounts from an user */
create proc followingList @this varchar(32) as begin
	select pro.username, pro.profilePicture, pro.userType
	from UserUser rel join [User] pro on rel.username2 = pro.username
	where username1 = @this
end
go

/* 2.9.1 List all follower from an user */
create proc followerList @this varchar(32) as begin
	select pro.username, pro.profilePicture, pro.userType
	from UserUSer rel join [User] pro on rel.username1 = pro.username
	where username2 = @this
end
go

/* 2.10 Check if a person is following another  */
create function isFollowing(@this varchar(32), @that varchar(32))
	returns bit
as begin
	if exists (select * from UserUser where username1 = @this and username2 = @that) begin
		return 1
	end
	return 0
end
go

/* 2.11 Create an event */
create proc createEvent
	@beginTime datetime,
	@endTime datetime,
	@description nvarchar(1024),
	@thumbnail varchar(256),
	@title nvarchar(128),
	@location int,
	@currentUser varchar(32)
as begin
	insert into [Event] values
	(@beginTime, @endTime, @description,@thumbnail, @title, @location, @currentUser, null)
end
go
/* 2.12 Edit event location */
create proc editLocation
	@eventId int,
	@newLocation int
as begin
	update [Event]
	set location = @newLocation
	where id = @eventId
end
go

/* 2.12.1 Host invites someone : Please remember the notification! */
create proc invite 
	@eventId int,
	@username varchar(32) 
as begin
	insert into [UserEventAttendants] values
	(@username, @eventId, 0)
end
go

/* 2.12.2 disinvite an user */
create proc disinvite 
	@eventId int,
	@username varchar(32) 
as begin
	delete from [UserEventAttendants]
	where event = @eventId and username = @username
end
go

/* 2.12.3 List all invited people with parameter -1, 0, 1 */
create proc listInvitedPeople
	@eventId int,
	@status int
as begin
	select *
	from [UserEventAttendants] att join [User] pro on att.username = pro.username
	where att.event = @eventId and att.attend = @status
end
go

/* 2.12.4 List all event that an user is invited with parameter -1, 0, 1 */
create proc listInvitedEvents
	@user varchar(32),
	@status int
as begin
	select evnt.*
	from [UserEventAttendants] att join [Event] evnt on att.event = evnt.id
	where att.username = @user and att.attend = @status
end
go

/* 2.13 User add comment */
create proc addComennt
	@eventId int,
	@author varchar(32),
	@content nvarchar(1024)
as begin
	insert into [Comment] (eventId, author, content) values
	(@eventId, @author, @content)
end
go

/* 2.14 Get comments from a post */
create proc getComments
	@eventId int
as begin
	select content, eventId, author
	from Comment
	where eventId = @eventId
end
go

/* 2.14.1 Check if an user is the author of a comment */
create function isCommentAuthor(@username varchar(32), @commentId int)
	returns bit
as begin
	if exists (select * from Comment where id = @commentId and author = @username) begin
		return 1
	end
	return 0
end
go

/* 2.14.2 Check if an user is an event host */
create function isHost(@username varchar(32), @eventId int)
	returns bit
as begin
	if exists (select * from [Event] where username = @username and id = @eventId) begin
		return 1
	end
	return 0
end
go

/* 2.15 Delete a comment : host or author or admin */
create proc deleteComment
	@currentUser varchar(32),
	@commentId int
as begin
	declare @eventId int = (select id from Comment where id = @commentId)
	if dbo.isAdmin(@currentUser) = 1 
		or dbo.isCommentAuthor(@currentUser, @commentId) = 1 
		or dbo.isHost(@currentUser, @eventId) = 1 begin
		
		delete from [Comment]
		where id = @commentId
	end else begin
		raiserror('No permission', 18, 4);
	end
end
go

/* TAGS SECTOR */

/* 3.0 Check the availability of a tag */
create function isTagExisted(@tagName varchar(32))
	returns bit
as begin
	if exists (select * from [Tag] where id = @tagName) begin
		return 1
	end
	return 0
end
go

/* 3.0.1 Create a new tag */
create proc createTag
	@tagName varchar(32)
as begin
	insert into [Tag] (id, occurrence) values
	(@tagName, 0)
end
go

/* 3.0.2 Tags' occurence increment */
create proc increaseTagOccurence
	@tagName varchar(32)
as begin
	declare @cur int = (select occurrence from [Tag] where id = @tagName)
	update [Tag]
	set occurrence = @cur + 1
	where id = @tagName
end
go

/* 3.0.2.1 Decrease tags' occurence */
create proc decreaseTagOccurence
	@tagName varchar(32)
as begin
	declare @cur int = (select occurrence from [Tag] where id = @tagName)
	update [Tag]
	set occurrence = @cur - 1
	where id = @tagName
end
go

/* 3.0.3 Search tags */

/* 1.1 Attach tags */
create proc attachTag
	@tag varchar(32),
	@eventId int
as begin
	insert into [EventTag] values
	(@eventId, @tag)
	exec increaseTagOccurence @tag
end
go

/* 1.2 Detach tag */
create proc detachTag
	@tag varchar(32),
	@eventId int
as begin
	delete from [EventTag]
	where event = @eventId and tag = @tag
	exec decreaseTagOccurence @tag
end
go
/* EVENTS SECTOR */
/* 3.1 Search events by tags (get top n) */
create proc searchTopTags
	@tagName varchar(32),
	@n int
as begin
	select * from Tag
	where id like '%' + @tagName + '%'
	order by occurrence desc
end
go

/* Users sectors */
/* 4.1 Search users by interest */

/* 4.2 Respond to an invitation : Notification here!!*/
create proc respondInvitation
	@user varchar(32),
	@event int,
	@decision int
as begin
	update [UserEventAttendants]
	set attend = @decision
	where username = @user and event = @event
end
go

/* Notification Area */
/* 1. Event Comment Notification */
create trigger tr_EventComment
	on [Comment]
	for insert, update
as begin
	declare @sender varchar(32), @receiver varchar(32), @eventId int, @commentId int
	select	@sender = author, @eventId = eventId, @commentId = id
	from inserted

	if @receiver != @sender begin

		set @receiver = (	select username
							from [Event] evnt join [Comment] cmt on evnt.id = cmt.eventId
							where evnt.id = @eventId)
		insert into [Notification] (receiver, sender, eventId, typeInfo) values
		(@receiver, @sender, @eventId, 0)				
	end
end
go


/* 2. User Invite Notification*/
create trigger userInviteUser
on [UserEventAttendants]
for insert, update
as
begin
	declare @username nvarchar(32) , @eventId int
	select @username = username, @eventId = event from inserted
	declare @sender varchar(32)
	set @sender = (select e.username from [Event] e where e.id = @eventId)
	insert into [Notification](receiver, sender, eventId, typeInfo)
	values(@username, @sender, @eventId, 1)
end
go

