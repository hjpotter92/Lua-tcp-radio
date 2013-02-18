local socket = require "socket"

function HTMLTable( sContent, sPattern )
	local sReturn = ""
	local iStart, iEnd = sContent:find( sPattern )
	if not ( iStart or iEnd ) then
		return sReturn
	end
	local iStart, iEnd = sContent:find( "<b>", iEnd )
	if not ( iStart or iEnd ) then
		return sReturn
	end
	local iStart, iEnd2 = sContent:find( "</b>", iEnd )
	if not ( iStart or iEnd ) then
		return sReturn
	end
	sReturn = sContent:sub( iEnd+1, iStart - 1 )
	return sReturn:gsub( "<B>", "" )
end

function RadioTest( sHost, iPort )
	iPort = tonumber( iPort )
	if type( iPort ) ~= "number" then
		print( "Port specification error." )
		return ""
	end
	local sReturn = "Online"
	local tcp, ERR = socket.tcp()
	if not tcp then
		print( ERR )
		sReturn = "Failed"
		return sReturn
	end
	tcp:settimeout( 1 )
	local uResult, ERR = tcp:connect( sHost, iPort )
	if not uResult then
		print( ERR )
		sReturn = "Offline"
		return sReturn
	else
		tcp:settimeout(1)
		tcp:send("GET /index.html HTTP/1.0\r\nUser-Agent: Mozilla/5.0 \r\n\r\n")
		tcp:settimeout(1)
		local sHTML = tcp:receive( "*a" )
		tcp:close()
		if not sHTML then return sReturn end
		sReturn = "Online %s - Current Song: %s"
		return sReturn:format( HTMLTable(sHTML, "Stream Status:"), HTMLTable(sHTML, "Current Song:") )
	end
end
