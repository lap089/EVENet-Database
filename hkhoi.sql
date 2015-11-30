/* NOTE:
 * userType: 0: Admin, 1: Individual, 2: Organization
 * gender: 0: Female, 1: Male
 */

 /* ERRORS:
  * createUser: No permission 18, 0 -> occurs when an user tries to create an admin
  * createType: No permission 18, 1 -> occurs when an user tries to create an organization type
  */

  /* PERSONAL NOTE:
   * collate SQL_Latin1_General_CP1_CS_AS: case sensitive!
   */

   /* ISSUES 
    * Valid email checking
	* Password case sensitive comparson
	*/

/* 0. WARNING: System, Admin uses uses only */
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

create function isAdmin(@username varchar(32))
	returns bit
as begin
	
	if exists (select * from [Admin] where username = @username) begin
		return 1
	end
	return 0
end
go

/* 2. Organization Type */
create proc createType @name nvarchar(32), @currentUser varchar(32) as begin
	if ([dbo].isAdmin(@currentUser) = 1) begin
		insert into [Type] values (@name)
	end else begin
		raiserror('No permssion!', 18, 1);
	end
end
go

create function isTypeExisted(@name nvarchar(32))
	returns bit
as begin
	if exists (select * from [Type] where name = @name) begin
		return 1
	end
	return 0
end
go

/* 1. Create a new user - Guest */
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
/* Support 1.1 */
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

/* Support 1.2 */
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

create proc setProfilePicture
	@username varchar(32), 
	@image image 
as begin
	update [User]
	set profilePicture = @image
	where username = @username
end
go

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
/* TESTING AREA */

exec setPassword 'hkhoi@apcs.vn', 'HOANGKHOI', 'hoangkhoi'