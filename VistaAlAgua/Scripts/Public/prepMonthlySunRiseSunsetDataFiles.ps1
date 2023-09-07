

<# 

    prepMonthlySunRiseSunsetDataFiles.ps1

    12/16/2022

    Jss

    .NOTES 
    =========================================================================== 
     Created with: 
     Created on: 4/10/2019 10:03 AM 
     Created by: 
     Organization: 
     Filename:
    =========================================================================== 
    .DESCRIPTION 
     Demostration of Begin, Process, and End input methods work in advanced powershell functions. 
     Fahrenheit =Celsius*9/5+32
#>

param([parameter()] [int] $monthsToLoad = 1,
        [string]$AsofDateToUse = '',
        [int] $sleepBetweenCalls = 2,
        [bool] $rebuildFiles = $false,
        [bool] $showDailyDetail = $false,
        [bool] $showOutputData = $true,
        [bool] $showDebugData = $true,
        [bool] $IsTest = $false,
        [bool] $saveOutput = $true,
        [int] $displayEveryNRows = 1500

    )
<#

Ours is a very simple REST api, you only have to do a GET request to https://api.sunrise-sunset.org/json.
Parameters

    lat (float): Latitude in decimal degrees. Required.
    lng (float): Longitude in decimal degrees. Required.
    date (string): Date in YYYY-MM-DD format. Also accepts other date formats and even relative date formats. If not present, date defaults to current date. Optional.
    callback (string): Callback function name for JSONP response. Optional.
    formatted (integer): 0 or 1 (1 is default). Time values in response will be expressed following ISO 8601 and day_length will be expressed in seconds. Optional.


{
      "results":
      {
        "sunrise":"7:27:02 AM",
        "sunset":"5:05:55 PM",
        "solar_noon":"12:16:28 PM",
        "day_length":"9:38:53",
        "civil_twilight_begin":"6:58:14 AM",
        "civil_twilight_end":"5:34:43 PM",
        "nautical_twilight_begin":"6:25:47 AM",
        "nautical_twilight_end":"6:07:10 PM",
        "astronomical_twilight_begin":"5:54:14 AM",
        "astronomical_twilight_end":"6:38:43 PM"
      },
       "status":"OK"
    }

        https://api.sunrise-sunset.org/json?lat=36.7201600&lng=-4.4203400&date=today

        https://api.sunrise-sunset.org/json?lat=36.7201600&lng=-4.4203400&date=2022-12-12

        https://api.sunrise-sunset.org/json?lat=36.7201600&lng=-4.4203400&formatted=0


    "Headers" = @{
        "Content-Type" = 'application/x-www-form-urlencoded'
        
    }
#>
$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
# [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues["Set-Content:Encoding"] = "UTF8"
$PSDefaultParameterValues["Add-Content:Encoding"] = "UTF8"
$PSDefaultParameterValues["Get-Content:Encoding"] = "UTF8"

# UTF8Encoding
$FileEncoding = "Default"
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
. 'C:\Users\johns\Tools\PSScripts\PSIncludeFiles\includeUtilities.ps1'

. 'C:\Users\johns\Tools\PSScripts\PSIncludeFiles\includeWWParityVars.ps1'
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
Import-Module ListUtils -Force
Import-Module DateUtils -Force
Import-Module PathUtils -Force
Import-Module FormatUtils -Force
Import-Module RawFileUtils -Force
Import-Module FileHeaderUtils -Force

Import-Module SkyWeatherUtils -Force
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------

$SkyWeatherArchivePath = Get-PathForName -pathName "SkyWeatherArchivePath"

# -------------------------------------------------------------------
<#
$outputHash["FileStub"] = $sunriseFileBase
$outputHash["FileExt"] = $sunriseFileOutfileSuffix 
$outputHash["FileDateIdx"] = $sunriseFileDateIdx
$outputHash["FileBasePath"] = $SkyWeatherReferenceSunRiseSetPath

# SunriseSunset_2022.tsv
$outputFileStub = "SunriseSunset"
$outputFileExt = "tsv"
$outputFileDateIdx = 3

#>
# -------------------------------------------------------------------

# -------------------------------------------------------------------
$sunriseSunsetFileParts = Get-SunriseSunsetFileParts
# -------------------------------------------------------------------

# SunriseSunset_2022.tsv
$outputFileStub = $sunriseSunsetFileParts["FileStub"]
$outputFileExt = $sunriseSunsetFileParts["FileExt"]
$outputFileDateIdx = $sunriseSunsetFileParts["FileDateIdx"]
# -------------------------------------------------------------------
$outputDataPathBase = $sunriseSunsetFileParts["FileBasePath"]

$DisplayLeaf = Get-DisplayLeafPath -basePath $outputDataPathBase -levelsToShow 3

# -------------------------------------------------------------------
if (!(Test-Path $outputDataPathBase))
    {
        Write-Verbose "Creating path $DisplayLeaf"
        $temp = mkdir $outputDataPathBase
        # Invoke-Item $goalArchivePath
    }
# -------------------------------------------------------------------
# -------------------------------------------------------------------

<#
$outputHash["Lat"] = $CasaAlAguaLat
$outputHash["Lon"] = $CasaAlAguaLon

$CasaAlAguaLat = 30.281009
$CasaAlAguaLon = -87.729949
#>

$CasaAlAguaLatLonDtls = Get-CasaAlAguaLatLon

$CasaAlAguaLat = $CasaAlAguaLatLonDtls["Lat"] 
$CasaAlAguaLon = $CasaAlAguaLatLonDtls["Lon"] 

<#
30.28200	
-87.73200
#>
# -------------------------------------------------------------------
# -------------------------------------------------------------------

# Get the Local TZ from the system
$strCurrentTimeZone = Get-LocalTimeZoneName  

# -------------------------------------------------------------------
Write-Host " -----------------------------------------"
$strCurrentTimeZone 
$autz = [System.TimeZoneInfo]::GetSystemTimeZones() |
    Where-Object { $_.Id -eq $strCurrentTimeZone  }


$intz = [System.TimeZoneInfo]::GetSystemTimeZones() |
    Where-Object { $_.Id -eq "UTC"  }

<#
[datetime]$utcSunsetDate = $Result.results.sunset
$localSunsetDate = $utcSunsetDate.ToLocalTime()

$localSunsetDate

#>
# 
<#
$InputCols = @("astronomical_twilight_begin"
                            , "nautical_twilight_begin"
                            , "civil_twilight_begin"
                            , "sunrise"
                            , "sunset"
                            , "civil_twilight_end"
                            , "nautical_twilight_end"
                            , "astronomical_twilight_end"
                            , "solar_noon"
                            , "day_length"
    )
#>

$InputCols = Get-SunriseSunsetRawInputCols

<#
$InputColDetails = @{"astronomical_twilight_begin" = @{"DataType" = "DateTime";
                                                        };
                        "nautical_twilight_begin" = @{"DataType" = "DateTime";
                                                        };
                        "civil_twilight_begin" = @{"DataType" = "DateTime";
                                                        };
                        "sunrise" = @{"DataType" = "DateTime";
                                                        };
                        "sunset" = @{"DataType" = "DateTime";
                                                        };
                        "civil_twilight_end" = @{"DataType" = "DateTime";
                                                        };
                        "nautical_twilight_end" = @{"DataType" = "DateTime";
                                                        };
                        "astronomical_twilight_end" = @{"DataType" = "DateTime";
                                                        };
                        "solar_noon" = @{"DataType" = "DateTime";
                                                        };
                        "day_length" = @{"DataType" = "IntSecs";
                                                        };

                    }

#>

$InputColDetails = Get-SunriseSunsetRawInputColDtls

<#
$outputHeaderCols = @("CurrentDate"
                        , "SunriseLocalTime"
                        , "SolarNoonLocalTime"
                        , "SunsetLocalTime"
                        , "DayLengthSecs"
                        , "astronomical_twilight_begin"
                        , "nautical_twilight_begin"
                        , "civil_twilight_begin"
                        , "civil_twilight_end"
                        , "nautical_twilight_end"
                        , "astronomical_twilight_end"
                        , "DayLengthFmt"
                        , 'LocalTimeZone'
                        , "Latitude"
                        , "Longitude"
                        , "Notes"

                    )
#>

$outputHeaderCols = Get-SunriseSunsetRawOutputCols

<#
$OutputColDetails = @{"astronomical_twilight_begin" = @{"InputCol" = "astronomical_twilight_begin";
                                                        };
                        "nautical_twilight_begin" = @{"InputCol" = "nautical_twilight_begin";
                                                        };
                        "civil_twilight_begin" = @{"InputCol" = "civil_twilight_begin";
                                                        };
                        "SunriseLocalTime" = @{"InputCol" = "sunrise";
                                                        };
                        "SunsetLocalTime" = @{"InputCol" = "sunset";
                                                        };
                        "civil_twilight_end" = @{"InputCol" = "civil_twilight_end";
                                                        };
                        "nautical_twilight_end" = @{"InputCol" = "nautical_twilight_end";
                                                        };
                        "astronomical_twilight_end" = @{"InputCol" = "astronomical_twilight_end";
                                                        };
                        "SolarNoonLocalTime" = @{"InputCol" = "solar_noon";
                                                        };
                        "DayLengthSecs" = @{"InputCol" = "day_length";
                                                        };
                        # 
                        "CurrentDate" = @{"InputCol" = "[derived]";
                                                        };
                        "LocalTimeZone" = @{"InputCol" = "[derived]";
                                                        };
                        "Latitude" = @{"InputCol" = "[derived]";
                                                        };
                        "Longitude" = @{"InputCol" = "[derived]";
                                                        };
                        "Notes" = @{"InputCol" = "[derived]";
                                                        };
                        "DayLengthFmt" = @{"InputCol" = "[derived]";
                                                        };
                    }

#>

$OutputColDetails = Get-SunriseSunsetRawOutputColDtls -ShowDetails $true

# --------------------------------------------------------------- 
$outputHeaderString = ""
foreach ($headerCol in $outputHeaderCols)
    {
        $outputHeaderString  = Push-DelimList -baseString  $outputHeaderString  -newValue $headerCol -separator $OutputSeparatorString -defaultValue ""
    }
# ---------------------------------------------------------------


<#
$uri = "https://api.sunrise-sunset.org/json"
#>

$uri = Get-SunriseSunsetUri -ShowDetail $true

# Static across days
$queryStringSub = "lat"
$queryStringSub += "="
$queryStringSub += $CasaAlAguaLat
#
$queryStringSub += "&"
$queryStringSub += "lng"
$queryStringSub += "="
$queryStringSub += $CasaAlAguaLon
#
$queryStringSub += "&"
$queryStringSub += "formatted"
$queryStringSub += "="
$queryStringSub += 0
# ---------------------------------------------------------------
#
# [string]$AsofDateToUse = '' # "11/01/2019"  # Null to default to the end of the prior month:

# ----------------------------------------------------------------------------------------------
$AsOfDate = Get-DateTimeFromDateString -dateToParse $AsofDateToUse 
# ----------------------------------------------------------------------------------------------
Write-Host "Processing data starting  $($AsOfDate.ToString('MM/dd/yyyy')) for $monthsToLoad months"
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------



Write-Host ""
Write-Host " -----------------------------------------"
:monthCheckLoop for ($curMonthCount = 0; $curMonthCount -le $monthsToLoad; $curMonthCount++)
    {
        $currentMonth = $AsOfDate.AddMonths($curMonthCount).Month

        if ($curMonthCount -eq 0)
            {
                # first Month processed:  Use AsOfDate Day)
                # $startDay = $AsOfDate.Day
                # Always produce full months
                $startDay = 1
            }
        else
            {
                # Subsequent months: Start with 1
                $startDay = 1
            }

        $currentYear = $($AsOfDate.AddMonths($curMonthCount)).AddDays(- $startDay  + 1).Year
        $daysInCurMonth = [datetime]::DaysInMonth($currentYear, $currentMonth)
        $monthAbrev = [cultureInfo]::CurrentCulture.DateTimeFormat.AbbreviatedMonthNames[$currentMonth-1]

        $currentMonthDate = [datetime]::new($currentYear, $currentMonth, 1)

        # Get output path for the month:
        #
        # $outputDataPathBase = $SkyWeatherReferenceSunRiseSetPath
        # Build the output path for the proceessing date
        $outputDataPath = Get-YearMonthArchivePathForDate -basePath $outputDataPathBase -archiveDate $currentMonthDate
        $DisplayLeaf = Get-DisplayLeafPath -basePath $outputDataPath -levelsToShow 3
        # ----------------------------------------------------------------------------------------------
        if (!(Test-Path $outputDataPath))
            {
                Write-Host "Creating  output path ..\$DisplayLeaf"
                $temp = mkdir $outputDataPath
                # Invoke-Item $goalArchivePath
            }
        # ----------------------------------------------------------------------------------------------
        # Build file mask to check:
        $fileYearMonthDay = $($currentMonthDate.ToString('yyyyMMdd'))
        # ----------------------------------------------------------------------------------------------
        $fileAsOfYearMonthDay  = $($AsOfDate.ToString('yyyyMMdd'))
        # ----------------------------------------------------------------------------------------------
        $candidateFileName = $null

        $candidate_file_stub = $outputFileStub     # "ProgramExceptionWeblabMapping" 
        $candidate_file_stub = Push-DelimList -baseString $candidate_file_stub -newValue $fileYearMonthDay -separator "_"
        $candidate_file_stub = Push-DelimList -baseString $candidate_file_stub -newValue $fileAsOfYearMonthDay -separator "_"
        $candidate_file_stub += "."
        $candidate_file_stub += $outputFileExt  # "tsv"

        # File to save
        $qualifiedSkyWeatherSunriseDataFile = Join-Path -Path $outputDataPath -ChildPath $candidate_file_stub

        # Check for any prior file:
        $SkyWeatherRawDataFileMask = $outputFileStub     # "ProgramExceptionWeblabMapping" 
        $SkyWeatherRawDataFileMask = Push-DelimList -baseString $SkyWeatherRawDataFileMask -newValue $fileYearMonthDay -separator "_"
        $SkyWeatherRawDataFileMask = Push-DelimList -baseString $SkyWeatherRawDataFileMask -newValue "*" -separator "_"
        $SkyWeatherRawDataFileMask += "."
        $SkyWeatherRawDataFileMask += $outputFileExt  # "tsv"

        $fileAlreadyExists = $false

        if (Test-Path $qualifiedSkyWeatherSunriseDataFile)
            {
                $fileAlreadyExists = $true
            }

        if (-not $fileAlreadyExists)
            {
                $candidateFileName = Get-MostRecentFileForMask -fileMaskToCheck $SkyWeatherRawDataFileMask `
                                    -pathToCheck $outputDataPath -processMode FileDate `
                                    -dateIndex $outputFileDateIdx -limitDate $($AsOfDate.AddDays(1))

                $matchedTitle = [regex]::Match($candidateFileName,"($outputFileStub_(19|20[\d]{2,2}\d{4})_(\d{8})\.$outputFileExt)")
         
                if ($matchedTitle.Success)
                    {
                        $fileAlreadyExists = $true
                    }
            }


        if ($fileAlreadyExists -and -not $rebuildFiles)
            {
                # File exists - no rebuild flag:  Skip
                Write-Host "    Debug:  ($curMonthCount) Abv<$monthAbrev> Y<$currentYear>M<$currentMonth>D<$startDay>DiM<$daysInCurMonth>"
                Write-Host "            File exists.  ($candidate_file_stub<<$candidateFileName>> ..\$DisplayLeaf) Skipping"
                Write-Host ""
                continue monthCheckLoop;
            }

        Write-Host ""
        Write-Host "    Debug:  ($curMonthCount) Abrev<$monthAbrev> Y<$currentYear>M<$currentMonth>D<$startDay>DiM<$daysInCurMonth>"
        Write-Host "            File does not exist.  ($candidate_file_stub ..\$DisplayLeaf) Create file  ."

        $dayCount = 0

        # $currentMonthDate = [datetime]::new($currentYear, $currentMonth, 1)
        $outputFileDate = $currentMonthDate

        # Create temp file for output capture:
        $TempFile = New-TemporaryFile

        # Add header: $outHeader
        Add-Content -Path $($TempFile.FullName) -Value $outputHeaderString -Encoding Default

        Write-Host ""
        Write-Host ""
        Write-Host "      $monthAbrev-$currentYear"
        Write-Host " -----------------------------------------"
        for ($curDay = $startDay; $curDay -le $daysInCurMonth; $curDay++)
            {
                $dayCount++
                $dateToCheck = [datetime]::new($currentYear,$currentMonth,$curDay)

                if ($showDailyDetail)
                    {
                        Write-Host " $($dayCount.ToString().PadLeft(3))) $("Current date to check".PadRight($labelPad,'.')): $($dateToCheck.ToString('yyyy-MM-dd'))"
                        Write-Host " -----------------------------------------"
                        Write-Host ""
                    }

                $dateToCheckStr = $($dateToCheck.ToString('yyyy-MM-dd'))
                #
                $queryString = $queryStringSub
                $queryString += "&"
                $queryString += "date"
                $queryString += "="
                $queryString += $dateToCheckStr
                #
                #
                $fullUriQuery = $uri + "?" + $queryString
                <#
                Write-Host ""
                Write-Host " -----------------------------------------"
                Write-Host "   Query String: $queryString"
                Write-Host "   Full Query String: $fullUriQuery"
                Write-Host ""
                Write-Host ""
                #>

                $Result = Invoke-RestMethod -Uri $fullUriQuery  -Method Get

                $localSunriseTime = $null
                $localSunsetTime = $null

                $labelPad = 28

                # Write-Host " "
                # Write-Host "      $dateToCheckStr"
                # Write-Host " -----------------------------------------"

                $dateOutputFormat = "s"
                $utcOffset = $autz.BaseUtcOffset

                $fieldCount = 0

                $outputRow = ""

                foreach ($outputHeaderCol in $outputHeaderCols)
                    {
                        $fieldCount++

                        $sunriseSunsetField = $null
                        $fieldDateTimeOffsetValue = $null

                        $outputVal = ""

                        $sunriseSunsetField  = $OutputColDetails[$outputHeaderCol]["InputCol"]

                        if ($sunriseSunsetField -ne "[derived]")
                            {
                                # Valid input data field
                                $fieldDateTimeOffsetValue = $Result.results.$sunriseSunsetField

                                # Write-Host ""
                                # Write-Host "      Debug:  ($outputHeaderCol)<$sunriseSunsetField> "
                                $fieldDataType = $InputColDetails[$sunriseSunsetField]["DataType"]

                                if ($fieldDataType -eq "DateTime")
                                    {
                                        ($dateTimeString, $tzOffset) = $fieldDateTimeOffsetValue.Split("+")
                                        $LocalTime = [System.TimeZoneInfo]::ConvertTime($dateTimeString , $intz, $autz)

                                        if ($sunriseSunsetField -eq "sunrise")
                                            {
                                                $localSunriseTime = $LocalTime 
                                            }
                                        elseif ($sunriseSunsetField -eq "sunset")
                                            {
                                                $localSunsetTime = $LocalTime 
                                            }

                                        $outputVal = $($LocalTime.ToString($dateOutputFormat))
                                        $outputVal += " "
                                        $outputVal += $utcOffset
                                        # [datetime]::SpecifyKind(
                                        
                                        if ($showDebugData)
                                            {
                                                Write-Host " $($fieldCount.ToString().PadLeft(3))) $($sunriseSunsetField.PadRight($labelPad,'.')): Raw: ($fieldDateTimeOffsetValue) $dateTimeString Local: $outputVal ($utcOffset)"
                                            }
                                    }
                                elseif ($fieldDataType -eq "IntSecs")
                                    {

                                        $rawMinutes = [math]::Floor($fieldDateTimeOffsetValue/60)
                                        $rawSeconds = $fieldDateTimeOffsetValue % 60
                                        $rawHours  = [math]::Floor($rawMinutes/60)

                                        $elapsedMinutes = $rawMinutes % 60

                                        $calCSecsFromHours = $rawHours*3600
                                        $calcSessFromMinutes = $elapsedMinutes*60

                                        if ($showDebugData)
                                            {
                                                Write-Host ""
                                                Write-Host "      Debug:  ($fieldDateTimeOffsetValue) H<$rawHours>M<$rawMinutes>S<$rawSeconds>"
                                                Write-Host "      Debug:  ($fieldDateTimeOffsetValue) H<$rawHours>M<$elapsedMinutes>S<$rawSeconds>"
                                                Write-Host "      Debug:  ($fieldDateTimeOffsetValue) H<$calCSecsFromHours>M<$calcSessFromMinutes>S<$rawSeconds>"
                                                Write-Host ""
                                            }

                                        $elapsedSecondsStr = $($rawSeconds.ToString().PadLeft(2,'0'))
                                        $elapsedsMinutesStr = $($elapsedMinutes.ToString().PadLeft(2,'0'))
                                        $elapsedHoursStr = $($rawHours.ToString().PadLeft(2,'0'))

                                        $elapsedString = $elapsedHoursStr
                                        $elapsedString += ":"
                                        $elapsedString += $elapsedsMinutesStr
                                        $elapsedString += ":"
                                        $elapsedString += $elapsedSecondsStr

                                        if ($showDebugData)
                                            {
                                                Write-Host " $($fieldCount.ToString().PadLeft(3))) $($sunriseSunsetField.PadRight($labelPad,'.')): (Raw Seconds) $($fieldDateTimeOffsetValue.ToString('N0').PadLeft(8)) $elapsedString"
                                            }
                                        $outputVal = $($fieldDateTimeOffsetValue.ToString())
                                    }
                                }
                        else
                            {
                                # Get the derived file value:
                                if ($outputHeaderCol -eq "CurrentDate")
                                    {
                                        $outputVal = $($dateToCheck.ToString('yyyy-MM-dd'))
                                    }
                                elseif ($outputHeaderCol -eq "LocalTimeZone")
                                    {
                                        $outputVal = $strCurrentTimeZone
                                    }
                                elseif ($outputHeaderCol -eq "Latitude")
                                    {
                                        $outputVal = $CasaAlAguaLat 
                                    }
                                elseif ($outputHeaderCol -eq "Longitude")
                                    {
                                        $outputVal = $CasaAlAguaLon
                                    }
                                elseif ($outputHeaderCol -eq "DayLengthFmt")
                                    {
                                        $outputVal = $elapsedString
                                    }
                                elseif ($outputHeaderCol -eq "Notes")
                                    {

                                    }
                            }

                        $outputRow  = Push-DelimList -baseString  $outputRow -newValue $outputVal -separator $OutputSeparatorString -defaultValue ""
                    }

                Add-Content -Path $($TempFile.FullName) -Value $outputRow -Encoding Default

                # Calculate the delta: Get-FormattedTimeString
                $sunriseSunsetField = "CalculatedDayLength"
                $localDayLengthString = Get-FormattedTimeString -startTimestamp $localSunriseTime -currentDate $localSunsetTime -inclHours $true
                $rawSeconds = $($localSunsetTime-$localSunriseTime).TotalSeconds
                $fieldCount++
                
                if ($showDebugData)
                    {
                        Write-Host " $($fieldCount.ToString().PadLeft(3))) $($sunriseSunsetField.PadRight($labelPad,'.')): (Raw Seconds) $($rawSeconds.ToString('N0').PadLeft(8)) $localDayLengthString"
                        Write-Host " -----------------------------------------"
                    }

                Start-Sleep -Seconds $sleepBetweenCalls

                # Write-Host " -----------------------------------------"

            }

        Write-Host " -----------------------------------------"
        Write-Host ""

        # Start notepad++ $($TempFile.FullName)

         # Save the output
        # =======================================================================================]
        if ($saveOutput)
            {
                Write-Host ""
                Write-Host ""

                $fileYearMonthDay = $($outputFileDate.ToString('yyyyMMdd'))
                # ----------------------------------------------------------------------------------------------
                # ----------------------------------------------------------------------------------------------
                $fileAsOfYearMonthDay  = $($AsOfDate.ToString('yyyyMMdd'))
                # ----------------------------------------------------------------------------------------------
                # Build archive path for the process date
                $ArchivePath = Get-YearMonthArchivePathForDate -basePath $SkyWeatherArchivePath -archiveDate $AsOfDate
                $ArchiveDisplayLeaf = Get-DisplayLeafPath -basePath $ArchivePath -levelsToShow 4
                # ----------------------------------------------------------------------------------------------
                if (!(Test-Path $ArchivePath))
                    {
                        Write-Host "Creating  archive path ..\$ArchiveDisplayLeaf"
                        $temp = mkdir $ArchivePath
                        # Invoke-Item $goalArchivePath
                    }
                # =======================================================================================]
                if ($dayCount -gt 0)
                    {
                        <#
                        # SunriseSunset_2022.tsv
                        $outputFileStub = "SunriseSunset"
                        $outputFileExt = "tsv"
                        $outputFileDateIdx = 3
                        #>
                                        
                        $candidate_file_stub = $outputFileStub     # "ProgramExceptionWeblabMapping" 
                        $candidate_file_stub = Push-DelimList -baseString $candidate_file_stub -newValue $fileYearMonthDay -separator "_"
                        $candidate_file_stub = Push-DelimList -baseString $candidate_file_stub -newValue $fileAsOfYearMonthDay -separator "_"
                        $candidate_file_stub += "."
                        $candidate_file_stub += $outputFileExt  # "tsv"

                        # File to save
                        $qualifiedSkyWeatherSunriseDataFile = Join-Path -Path $outputDataPath -ChildPath $candidate_file_stub


                        # Check for any prior file:
                        $SkyWeatherRawDataFileMask = $outputFileStub     # "ProgramExceptionWeblabMapping" 
                        $SkyWeatherRawDataFileMask = Push-DelimList -baseString $SkyWeatherRawDataFileMask -newValue $fileYearMonthDay -separator "_"
                        $SkyWeatherRawDataFileMask = Push-DelimList -baseString $SkyWeatherRawDataFileMask -newValue "*" -separator "_"
                        $SkyWeatherRawDataFileMask += "."
                        $SkyWeatherRawDataFileMask += $outputFileExt  # "tsv"

                        $fileIsSaved = $false
                        # Save the valid data
                        $fileIsSaved = Save-FileWithArchiveOfPriorVersion -sourceDataPath $outputDataPath `
                                                                            -targetDataPath $outputDataPath `
                                                                            -baseArchivePath $ArchivePath `
                                                                            -fileToSave $($TempFile.FullName) `
                                                                            -OutputfileName  $candidate_file_stub `
                                                                            -fileMaskForArchive $SkyWeatherRawDataFileMask `
                                                                            -isTest $IsTest `
                                                                            -showOutputData $showOutputData

                        if ($fileIsSaved)
                            {
                                $FileSavedCount++
                            }
                        # =======================================================================================]
                                        
                    }
                else
                    {
                        # Nothing to save:  Call it good.
                        $FileSavedCount++
                    }

                # =======================================================================================]
            }
            
        Write-Host ""
        # =======================================================================================]
    }

# -----------------------------------------
# -----------------------------------------
# Get-YearMonthArchivePathForDate

[System.GC]::Collect()
   
return



# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6Rz1WsqFa7P37NwG7klMpWMg
# 2rOgggNCMIIDPjCCAiqgAwIBAgIQhCOQP8Pn1aFKSDkrNekzfTAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjEwMTcxMjM4MTFaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM4Tgcm9
# 04COaiqLHbuyr69hQVYmi1zKW1RFxBSSLlykI1bV0OgIfHWiwR48TWZMt5Bd7rSk
# DmrzeTwM/6neHdV9Q3VbpJ+GkuS4LbooSvJdpWmhv0rZHGadvlIzs0GFZRqhrvBn
# szbZSo6vSb6p0JydoODRtVnblZq/Llhi0DH7Adgpavb2ULIHDAPm+kv+1FI7L2Um
# nEGtvCanY0K7tHQ/42WPEXUvfJ+xYeTZ2XN/2Szvykx7G6S9ynu4IdOWpdMBj1NE
# esXp2H0dp8IWvR4w/A0YkAWqlHdllvd4/LKJN211Ds2K8dMUo9Y1zc1ERkCl9Ft6
# KSr1QtTYNL56bi0CAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQUYwHu01WTiEoMwBBx4E6MKEuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQCPscL8MHT4dCIM1DSPah7jAJBgUrDgMC
# HQUAA4IBAQDT7nQNHR5gm190n2lhNAPFFksIfc8LJg3FKAOy3qK3py52bASlHIgw
# PAfkzBjf7iiC8j4iG38RCrXEOKmOd+CCDEqB6Z6RXm+XSHTnrLt2NKBhiWloMNBe
# KadX7dUoSxq0qc1jg9fZhu1tJJgDbcumk6j5L+4AU8cHBy2Zb1CVQjFnvqUvv0eE
# LA+JNzRyW4O62QqWnYr5C0uY75n3UOH4jlXCAAwKqAh5vSOdNUbDKZO+jSLPvI+P
# 4z32Q2k2HAzkTiQg6ASFtEL2fjmGRDrcPSKuGgqfLlw5+7b73OZtZKIPeCZbskGd
# 3IJg9o25g+l0ygGFZ7XLiUIGvpjbfY92MYIB4TCCAd0CAQEwQDAsMSowKAYDVQQD
# EyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCEIQjkD/D59WhSkg5
# KzXpM30wCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFEbnD4ZGM3O9lDnyQ299ipc1oKnvMA0GCSqG
# SIb3DQEBAQUABIIBAAoqajanX/udBQ/ktpXXjcOn97kY7o6wrfZq0dDGBFJT3YGr
# Q24UfwNk7p4M1oPs7RHt1ykGm5SrcXWm+0Hymn1HdvuC3PtEeQjwT2P8gppO1IMB
# tMo6UQcLwjc9HT+5ueCklZFpr7yx0BzKxO6I/V4NQ7jNhToFkfHXmAKlOSRAdMl4
# OuYuhoNVKtPajWarCP5h/UNkmrrpwam3DXpH4KDk4l04exVZnfxki9Pdb3NMmz+g
# JqDvtJbIe1QFX2Hn/zgzdw4GPChZzgKYN7dbyOlecf5+bYSg9iltsUU2PuJyKfsK
# 90+C+Dux4OH/HfsZ8BcXpWVtEgO1ccAKiM6KJmk=
# SIG # End signature block
