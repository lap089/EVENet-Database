/* NOTE:
 * userType: 0: Admin, 1: Individual, 2: Organization
 * gender: 0: Female, 1: Male
 */

 /* ERRORS:
  * createUser: No permission 18, 0 -> occurs when an user tries to create an admin
  * createType: No permission 18, 1 -> occurs when an user tries to create an organization type
  * 
  */

  /* PERSONAL NOTE:
   * collate SQL_Latin1_General_CP1_CS_AS: case sensitive!
   */

   /* ISSUES 
    * Valid email checking
	* Password case sensitive comparison
	*/

/* 0. ADMIN SECTOR */
/* 0.1 Create a root user (admin) */
create proc createRoot
	@username varchar(32),
	@password varchar(64),
	@profilePicture image
as begin
	insert into [User] (username, [password], profilePicture, userType) values
	(@username, @password, @profilePicture, 0)
	insert into [Admin] values (@username)
end
go
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
/* 2. USERS SECTOR */
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
	@profilePicture image,
	@userType int
as begin
	if (@userType = 0) begin
		raiserror('No Permission!', 18, 0)
	end else begin	
		insert into [User] (username, [password], profilePicture, userType) values
		(@username, @password, @profilePicture, @userType)
	end
end
go

/* 2.2 Check if users' aunthentication is valid */
create function [auth](@username varchar(32), @password varchar(64))
	returns bit
as begin
	declare @userPassword varchar(64) = (select [password] from [User] where [username] = @username)
	if (@userPassword = @password) begin
		return 1
	end
	return 0
end
go
/* 2.3 Create an individual */
create proc createIndividual
	@username varchar(32),
	@password varchar(64),
	@profilePicture image,

	@firstName nvarchar(16),
	@midName nvarchar(16),
	@lastName nvarchar(16),
	@dob date,
	@gender bit
as begin
	exec createUser @username, @password, @profilePicture, 1

	insert into [Individual] values
	(@username, @firstName, @midName, @lastName, @dob, @gender)
end
go

/* 2.4 Create an organization */
create proc createOrganization
	@username varchar(32),
	@password varchar(64),
	@profilePicture image,

	@description nvarchar(1024),
	@type nvarchar(32),
	@phone varchar(16),
	@website varchar(256)
as begin
	if [dbo].isTypeExisted(@type) = 1 begin
		exec createUser @username, @password, @profilePicture, 2
		insert into [Organization] values
		(@username, @description, @type, @phone, @website)
	end else begin
		raiserror('Type does not exist!', 18, 2)
	end
end
go

/* 2.5 Allows users to set profile pictures */

create proc setProfilePicture
	@username varchar(32), 
	@image image 
as begin
	update [User]
	set profilePicture = @image
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