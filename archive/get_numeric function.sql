
create function [get_numeric] (@InputString nvarchar(max)) 
	returns nvarchar(10) 
	as 
	begin 
		while Patindex('%[^0-9]%', @InputString) <> 0  begin 
			set @InputString = Stuff(@InputString, Patindex('%[^0-9]%', @InputString),1, '') 
		end 
		return @InputString 
	end