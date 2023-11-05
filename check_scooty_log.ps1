#log path
$logscooty="C:\BCE\Powershell_script\scooty_log\SCOOTY_20231001.txt"



############################################################################################################
# Initialize a variable with a collection of new segment
$var_new = Select-String -Pattern "new program segment detected" -Path $logscooty
$var_new_nb = $var_new.Count
Write-Host "var_new_nb:$var_new_nb"

# Loop through the collection of var_new
# Create an array list
[array]$arrayNew = @()

foreach ($item in $var_new) {
    
    # Add the object to the array list
    $myval = $item.Line.tostring()
    # $myval.GetType()
    # $myvalLen = $myval.Length
    $myvalbracketin = $myval.LastIndexOf('[')
    $myvalbracketout = $myval.LastIndexOf(']')
    $myvalext = $myval.Substring($myvalbracketin+1,($myvalbracketout-$myvalbracketin)-1)
    $arrayNew += $myvalext

}
# Display the array list
# $arrayNew




############################################################################################################
# Initialize a variable with a collection of add segment to Db
$var_add = Select-String -Pattern "Add segment to db" -Path $logscooty
$var_add_nb = $var_add.Count
Write-Host "var_add_nb:$var_add_nb"

# Loop through the collection of $var_add
# Create an array list
[array]$arrayAdd = @()

foreach ($item in $var_add) {
    
    # Add the object to the array list
    $myval = $item.Line.tostring()
    # $myval.GetType()
    # $myvalLen = $myval.Length
    $myvalbracketin = $myval.IndexOf('{')
    $myvalbracketout = $myval.LastIndexOf('}')

    $myvalext = $myval.Substring($myvalbracketin,($myvalbracketout-$myvalbracketin)+1)
    $arrayAdd += $myvalext | ConvertFrom-Json

}
# Display the array list
# $arrayAdd




############################################################################################################
# Initialize a variable with a collection of sent msg
#DestinationManager:	Sent message [08c252bb-60fa-4b9f-beb4-d2ec748b01c5] to Inserter TVI TELCO1
#$var_msg_sent = Select-String -Pattern "DestinationManager:	Sent message" -Path $logscooty
$var_msg_sent = Select-String -Pattern "to Inserter TVI TELCO1" -Path $logscooty
# 00:05:22.720	[INFO]	DestinationManager:	Sent message [08c252bb-60fa-4b9f-beb4-d2ec748b01c5] to Inserter TVI TELCO1 : FF FF 
# 00 54 00 00 40 00 00 00 02 02 05 16 12 03 01 04 00 02 1F 40 01 0B 00 1B 00 0D 16 DB 00 06 69 0F 06 38 35 37 38 31 39 10 00 00 
# 03 00 00 00 00 00 01 00 00 01 0B 00 1B 00 0D 16 DA 00 00 00 0F 06 38 35 37 38 31 38 11 00 00 00 00 00 00 00 00 01 00 00 
#Write-Host "var_msg_sent:$var_msg_sent"

$var_msg_nb = $var_msg_sent.Count
Write-Host "var_msg_nb:$var_msg_nb"


# Create an array list
[array]$customArray = @()

foreach ($item in $var_msg_sent) {
    
    # Add the object to the array list
    $myval = $item.Line.tostring()
    # $myval.GetType()
    
    $myvalLen = $myval.Length
    #Write-Host "myvalLen:$myvalLen"

    $myvalSep = $myval.IndexOf('TELCO1 :')
    #Write-Host "myvalSep:$myvalSep"

    $myvalext = $myval.Substring($myvalSep+9,$myvalLen-$myvalSep-9)
    #Write-Host "myvalext:$myvalext"

    # Extract the date using a regular expression
    $date = [regex]::Match($myval, '\d{2}:\d{2}:\d{2}.\d{3}').Value
    #Write-Host "date:$date"

    $myvalbracketin = $myval.LastIndexOf('[')
    $myvalbracketout = $myval.LastIndexOf(']')
    $myvalGuuid = $myval.Substring($myvalbracketin+1,($myvalbracketout-$myvalbracketin)-1)

    # Create an array containing the date and the hex data
    #$arraySent += @($date, $myvalext)


    # Create a custom object with properties for the date and the hex data
    $customObject = New-Object PSObject -Property @{

        Date = $date
        Guuid = $myvalGuuid
        HexData = $myvalext
        MessageNumber = ""
        MessageType = ""
        Eventid = ""
        StatusScooty = ""
        StatusEvertz = ""

        #add property here
    }

    # Create an array of custom objects
    $customArray += @($customObject)


}
# Display the array list
#$customArray

# Get the "Date" property from the first object in the array
#$firstDate = $customArray[0].Date
#Write-Host "firstDate:$firstDate"
#$firstGuuid = $customArray[0].Guuid
#Write-Host "firstGuuid:$firstGuuid"
#$firstHexData = $customArray[0].HexData
#Write-Host "firstHexData:$firstHexData"


# Add the "Housenumber" property to all objects in the array
#foreach ($obj in $customArray) {
#    $obj | Add-Member -MemberType NoteProperty -Name "Housenumber" -Value ""
#}

#$obj.AnotherValue = "New Value"
#$customArray[0].Housenumber = "JEREMY"

#$customArray
$j=0

foreach ($obj in $customArray) {
    
    $j+=1
    Write-Host "object index:$j"
    $curGuid = $obj.Guuid.ToString()
    $OtherGuid = Select-String -Pattern $curGuid -Path $logscooty
    Write-Host "OtherGuid:$OtherGuid"

    $nbOfGuid = $OtherGuid.Count
    Write-Host "nbOfGuid:$nbOfGuid"

    
    
    $i=0
    foreach ($item in $OtherGuid) {
        
        $i+=1

        # Add the object to the array list
        $myval = $item.Line.tostring()
        Write-Host "$i/$nbOfGuid - myval:$myval"

        if ( ($myval.IndexOf('{')) -ge 0 )
        {
            
            #init array
            [array]$arrayData = @()
            
            $myvalbracketin = $myval.IndexOf('{')
            $myvalbracketout = $myval.LastIndexOf('}')
            
            $myvalext = ""
            $myvalext = $myval.Substring($myvalbracketin,($myvalbracketout-$myvalbracketin)+1)
            Write-Host "$i/$nbOfGuid - myvalext:$myvalext"

            $arrayData += $myvalext | ConvertFrom-Json
            

            #get message number
            if($arrayData.MessageNumber)
            {
                if( $obj.MessageNumber -eq "" )
                {
                    $obj.MessageNumber = $arrayData.MessageNumber
                    $obj.MessageType = $arrayData.ShortContentSummary
                    
                }   
            }
            
            if($arrayData.EventId )
            {
                $obj.Eventid = $arrayData.EventId
            }

            #get status Sent but not scheduled
            if($arrayData.Status -eq "Sent")
            {
                $obj.StatusScooty = $arrayData.Status
            }

            #get status Acknowledged
            if($arrayData.Status -eq "Acknowledged")
            {
                $obj.StatusEvertz = $arrayData.Status
            }

        }
        else
        {
            #case preparing msg: nothing to do
            #case schedule msg : nothing to do
        }

        

        #case add segment to get housenumber etc
        

        #case update message in db to get scooty sent status


        #case update message in bd to get everty ack status


    }
}

#print result
$obj

#TODO find missing data

