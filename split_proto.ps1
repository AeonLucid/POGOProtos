Param (

  [Parameter(Mandatory=$true)]
    [String] $Sourcefile,
  [Parameter(Mandatory=$true)]
    [String] $SrcFolder,
  [Parameter(Mandatory=$true)]
    [String] $ProtoIndexFile,
  [Parameter(Mandatory=$true)]
    [String] $ProtoTypeFile,
  [Parameter(Mandatory=$true)]
    [String] $ProtoImportFile,
  [Parameter(Mandatory=$true)]
    [String] $OutPath,
  [Parameter(Mandatory=$true)]
    [String] $MissingFile,
  [Parameter(Mandatory=$false)]
    [Switch] $StripBlankLines
)

$EnumPattern = [RegEx] '^enum '
$MessagePattern = [RegEx] '^message '
$EnumInMSGPattern = [RegEx] '^	enum '
$EnumInMSGPatternEND = [RegEx] '^	}'

$typeLookupTable = @{
'PokemonInfo' = 'BattlePokemonInfo' 
'ActionType' = 'BattleActionType' 
'PokemonFortProto' = 'FortData'
'HoloPokemonId' = 'PokemonId'
'HoloBadgeType' = 'BadgeType'
'HoloItemType' = 'ItemType'
'FortDetailsOutProto' = 'FortDetailsResponse'
'CaptureScoreProto' = 'CaptureAward'
'HoloPokemonFamilyId' = 'PokemonFamilyId'
'ClientPlayerProto' = 'PlayerData'
'SfidaGlobalSettingsProto' = 'SfidaSettings'
'NewsSettingProto' = 'NewsSettings'
'HoloItemCategory' = 'ItemCategory'
'HoloPokemonMove' = 'PokemonMove'
'HoloPokemonType' = 'PokemonType'
'PokemonCameraAttributesProto' = 'CameraAttributes'
'PokemonEncounterAttributesProto' = 'EncounterAttributes'
'PokemonStatsAttributesProto' = 'StatsAttributes'
'HoloPokemonClass' = 'PokemonRarity'

}

$typeCorrectionsTable = @{
'repeated PokemonInfo' = 'repeated .POGOProtos.Data.Battle.BattlePokemonInfo'
'repeated ClientMapCellProto' = 'repeated .POGOProtos.Map.MapCell'
'repeated Item' = 'repeated .POGOProtos.Inventory.Item.ItemId' 
'repeated HoloBadgeType' = 'repeated .POGOProtos.Enums.GymBadgeType'
'State state = 1;' = '.POGOProtos.Data.Battle.BattleState state = 1;'
'Team team' = '.POGOProtos.Enums.TeamColor team'
'	Item item' = '	.POGOProtos.Inventory.Item.ItemId item'
'Item food_item' = '.POGOProtos.Inventory.Item.ItemId food_item'
'bytes item' = '.POGOProtos.Inventory.InventoryItemData  item'
'InventoryUpgradeProto ' = '.POGOProtos.Inventory.InventoryUpgrade '
'Item modifier_type' = '.POGOProtos.Inventory.Item.ItemId modifier_type'
'int32 pokedex_id' = '.POGOProtos.Enums.PokemonId pokedex_id'
'int32 pokedex_number' = '.POGOProtos.Enums.PokemonId pokedex_number'
'Item evolution_item_requirement' = '.POGOProtos.Inventory.Item.ItemId evolution_item_requirement'
'repeated .POGOProtos.Enums.GymBadgeType awarded_badges = 2;' = 'repeated .POGOProtos.Enums.BadgeType awarded_badges = 2;'
'.POGOProtos.Networking.Responses.CheckCodenameAvailableResponse.Status status = 1;' = 'Status status = 1;'
'Item active_item = 3;' = '.POGOProtos.Inventory.Item.ItemId active_item = 3;'
'.POGOProtos.Networking.Responses.DownloadRemoteConfigVersionResponse.Result' = 'Result'
'.POGOProtos.Data.Logs.BuddyPokemonLogEntry.Result'  = 'Result'
'bytes values' = '.POGOProtos.Settings.GlobalSettings values'
'.POGOProtos.Networking.Responses.SetAvatarResponse.Status status = 3;' = 'Status status = 3;'
'Item active_item' = '.POGOProtos.Inventory.Item.ItemId active_item'
'HoloItemEffect' = '.POGOProtos.Enums.ItemEffect'
'ClientFortModifierProto' = '.POGOProtos.Map.Fort.FortModifier'
'repeated AwardItemProto' = 'repeated .POGOProtos.Inventory.Item.ItemAward'
'int32 pokemon_type_id' = '.POGOProtos.Enums.PokemonId pokemon_type_id'
'.POGOProtos.Networking.Responses.SetAvatarResponse.Status' = 'Status'
'repeated HoloPokemonType' = 'repeated .POGOProtos.Enums.PokemonType'
'Item unique_id = 1;' = '.POGOProtos.Inventory.Item.ItemId unique_id = 1;'
'int32 pokeball = 2;' = '.POGOProtos.Inventory.Item.ItemId pokeball = 2;'
'.POGOProtos.Networking.Responses.NicknamePokemonResponse.Result' = 'Result'
'int32 pokedex_type_id' = '.POGOProtos.Enums.PokemonId'
'repeated TutorialCompletion' = 'repeated .POGOProtos.Enums.TutorialState'
'int32 pokedex_entry_number' = '.POGOProtos.Enums.PokemonId'
'repeated HoloPokemonMove' = 'repeated .POGOProtos.Enums.PokemonMove'
'repeated HoloPokemonId' = 'repeated .POGOProtos.Enums.PokemonId'
'Item incense_type' = '.POGOProtos.Inventory.Item.ItemId incense_type'
}



$lookupTable = @{
'enum Item' = 'enum ItemId' 
'enum HoloActivityType' = 'enum ActivityType' 
'enum TutorialCompletion' = 'enum TutorialState' 
'message AwardItemProto' = 'message ItemAward' 
'message FortDeployProto' = 'message FortDeployPokemonMessage' 
'message FortDeployOutProto' = 'message FortDeployPokemonResponse' 
'message UseIncenseActionProto' = 'message UseIncenseMessage' 
'message UseIncenseActionOutProto' = 'message UseIncenseResponse' 
'message PokemonInfo' = 'message BattlePokemonInfo' 
'message CodenameResultProto' = 'message CheckCodenameAvailableResponse' 
'message AvatarCustomizationProto' = 'message AvatarCustomizationSettings' 
}

#Clear the files
New-Item $MissingFile -type file -force

$SourceData = Get-Content -Path "$($Sourcefile)"

if (Test-Path $ProtoIndexFile) {}
else {
    write-host "ProtoIndexFile is not generated. Run split_discover_protos first!" -foregroundcolor "red"
    exit
}

$writing=0
$InMessageFile = 0;


ForEach ($ProtoLine in $SourceData) {
     
    if($writing -eq 0) {
        ###### READING MODE #########
      $OrigLine = $ProtoLine
      If ($ProtoLine -match $EnumPattern -or $ProtoLine -match $MessagePattern) {  
        #enum or message line found
        
        echo "We found" $ProtoLine
        If ($ProtoLine -match $MessagePattern) {  
            $InMessageFile = 1;
        }
        else {
            $InMessageFile = 0;
        }

        #Remove the { at the end
        if ($ProtoLine.contains("{") ) {
            $ProtoLine=$ProtoLine.Substring(0,$ProtoLine.Length-2)
        }
        else {}

        
        #Use above mapping table to match actual protos files on disk
        $lookupTable.GetEnumerator() | ForEach-Object {
            if ($ProtoLine -eq $_.Key)
            {
                $ProtoLine = $ProtoLine -replace $_.Key, $_.Value
            }
        }

        #Do some smart renaming here, since the protos files has it own logic
        
        If ($ProtoLine -match $EnumPattern) {  
            #Message name conversion from HoloPokemonType -> PokemonType
            $ProtoLine =  $ProtoLine -replace "HoloPokemon", "Pokemon"

            #Message name conversion from HoloPokemonType -> PokemonType
            $ProtoLine =  $ProtoLine -replace "HoloItem", "Item"

        }

      
      
        #Find the location of this element in database file
        $ProtoDB = Get-Content -Path "$($ProtoIndexFile)"
        $ProtoFile = "";
        $ProtoFileFound = 0;
        $ProtoMissing = 1;
        
        ForEach ($ProtoDBLine in $ProtoDB) {
          If ($ProtoFileFound -eq 1) {  
            #We found the correct file to update
                $ProtoFile = $ProtoDBLine;
                $ProtoMissing = 0;
                break
          }Else {}
          If ($ProtoDBLine -eq $ProtoLine) {  
            #We found the correct file to update
                $ProtoFileFound = 1;
          }Else {}
          
        }  #End ForEach

        if ($ProtoFileFound -eq 0) {
            #If we didn't find it in the first run, we can try different message conversion  now

            #Message name conversion from GymDisplayMessage -> GymDisplay
            $ProtoLine =  $ProtoLine -creplace "Message", ""
            
            #Find the location of this element in database file
            $ProtoDB = Get-Content -Path "$($ProtoIndexFile)"
            $ProtoFile = "";
            $ProtoFileFound = 0;
            
            ForEach ($ProtoDBLine in $ProtoDB) {
              If ($ProtoFileFound -eq 1) {  
                #We found the correct file to update
                    $ProtoFile = $ProtoDBLine;
                    $ProtoMissing = 0;
                    break
              }Else {}
              If ($ProtoDBLine -eq $ProtoLine) {  
                #We found the correct file to update
                    $ProtoFileFound = 1;
              }Else {}
              
            }  #End ForEach
            
        }
        else {}

        
        if ($ProtoFileFound -eq 0) {
            #If we didn't find it in the first run, we can try different message conversion  now
            If ($ProtoLine -match $MessagePattern) {  
                #Message name conversion from CollectDailyBonusOutProto -> GymDeployMessage
                $ProtoLine =  $ProtoLine -replace "OutProto", "Response"

                #Message name conversion from CollectDailyBonusOutProto -> GymDeployMessage
                $ProtoLine =  $ProtoLine -replace "RequestProto", "Message"

                #Message name conversion from GymDeployProto -> GymDeployMessage
                $ProtoLine =  $ProtoLine -replace "Proto", "Message"
            }

            #Find the location of this element in database file
            $ProtoDB = Get-Content -Path "$($ProtoIndexFile)"
            $ProtoFile = "";
            $ProtoFileFound = 0;
            
            ForEach ($ProtoDBLine in $ProtoDB) {
              If ($ProtoFileFound -eq 1) {  
                #We found the correct file to update
                    $ProtoFile = $ProtoDBLine;
                    $ProtoMissing = 0;
                    break
              }Else {}
              If ($ProtoDBLine -eq $ProtoLine) {  
                #We found the correct file to update
                    $ProtoFileFound = 1;
              }Else {}
              
            }  #End ForEach
            
        }
        else {}        
        


        if ($ProtoFileFound -eq 0) {
            #If we didn't find it in the first run, we can try different message conversion  now

            #Message name conversion from GymDisplayMessage -> GymDisplay
            $ProtoLine =  $ProtoLine -creplace "Message", ""
            
            #Find the location of this element in database file
            $ProtoDB = Get-Content -Path "$($ProtoIndexFile)"
            $ProtoFile = "";
            $ProtoFileFound = 0;
            
            ForEach ($ProtoDBLine in $ProtoDB) {
              If ($ProtoFileFound -eq 1) {  
                #We found the correct file to update
                    $ProtoFile = $ProtoDBLine;
                    $ProtoMissing = 0;
                    break
              }Else {}
              If ($ProtoDBLine -eq $ProtoLine) {  
                #We found the correct file to update
                    $ProtoFileFound = 1;
              }Else {}
              
            }  #End ForEach
            
        }
        else {}

        #USE LAST
        if ($ProtoFileFound -eq 0) {
            #If we didn't find it in the 2nd run, we can try different message conversion  now

            #Message name conversion from AssetDigestRequest -> GetAssetDigestMessage
            $ProtoLine =  $ProtoLine -creplace "Request", "Message"
            $ProtoLine =  $ProtoLine -creplace "message ", "message Get"
            
            #Find the location of this element in database file
            $ProtoDB = Get-Content -Path "$($ProtoIndexFile)"
            $ProtoFile = "";
            $ProtoFileFound = 0;
            
            ForEach ($ProtoDBLine in $ProtoDB) {
              If ($ProtoFileFound -eq 1) {  
                #We found the correct file to update
                    $ProtoFile = $ProtoDBLine;
                    $ProtoMissing = 0;
                    break
              }Else {}
              If ($ProtoDBLine -eq $ProtoLine) {  
                #We found the correct file to update
                    $ProtoFileFound = 1;
              }Else {}
              
            }  #End ForEach
            
        }
        else {}


        
        if ($ProtoLine -eq "NOT FOUND") {
            #We know this is not here, so skip
        }
        Else {
            echo "We think the file is:" $ProtoLine
            if ($ProtoFileFound -eq 0) {
                write-host "Did not find:" $OrigLine " - Skipping"
                if ($ProtoMissing -eq 1) {
                    Add-Content -Path "$MissingFile" -Value "$($OrigLine)-->$($ProtoLine)" 
                } else {}
                

                
                #This command writes the output for table above
                #write-host "'$($OrigLine)' = 'NOT FOUND'" -foregroundcolor "red"
            }
            else {
                write-host "Let's write " $ProtoLine "to " $ProtoFile "`r`n"
                
                #Generate output file name 
                #E:\Projecten\GIT Repos\POGOProtos\goedzo\src\POGOProtos\Map\Fort\FortType.proto
                
                #echo $ProtoFile
                #echo $SrcFolder
                #echo $OutPath
                $Outfile = $ProtoFile
                $Outfile = $Outfile -creplace [Regex]::Escape($SrcFolder), $OutPath
                
                
                #Create output file
                New-Item $OutFile -type file -force
                #Add-Content -Path "$OutFile" -Value "syntax = ""proto3"";" 
                [System.IO.File]::AppendAllText($OutFile,"syntax = ""proto3"";`n")
                
                
                #Determine Package
                #POGOProtos\Map\Fort\FortType.proto ->
                #package POGOProtos.Map.Fort;
                $Package = $ProtoFile -replace [Regex]::Escape($SrcFolder),""
                $Package = $Package.Substring(0, $Package.lastIndexOf('\'))
                $Package = $Package.Substring(1, $Package.Length-1)
                $Package = $Package -creplace "\\","."
                $Package = "package $($Package);"
                
                #Add-Content -Path "$OutFile" -Value $Package 
                [System.IO.File]::AppendAllText($OutFile,"$($Package)`n")


                #Write imports if in message
                if ($InMessageFile -eq 1) {
                    #We need to copy the imports from sources
                    

                    #Find the location of this element in database file
                    $ProtoImportDB = Get-Content -Path "$($ProtoImportFile)"
                    $ProtoFileFound = 0;
                    $First = 0;
                    
                    ForEach ($ProtoDBLine in $ProtoImportDB) {
                      If ($ProtoFileFound -eq 1) {  
                            #Write this line to destination
                            if ($First -eq 0) {
                                #Add an extra empty line for readibility
                                #Add-Content -Path "$OutFile" -Value "" 
                                [System.IO.File]::AppendAllText($OutFile,"`n")

                                $First = 1;
                            }
                            #Add-Content -Path "$OutFile" -Value $ProtoDBLine 
                            [System.IO.File]::AppendAllText($OutFile,"$($ProtoDBLine)`n")
                            $ProtoFileFound = 0;
                      }Else {}
                      If ($ProtoDBLine -eq $ProtoFile) {  
                        #We found the correct file to update
                            $ProtoFileFound = 1;
                      }Else {}
                      
                    }  #End ForEach

                
                }

                #Write an empty line
                #Add-Content -Path "$OutFile" -Value "" 
                [System.IO.File]::AppendAllText($OutFile,"`n")
                
                #Write message or enum line

                #Check if { is present
                if ($ProtoLine.contains("{") ) {
                }
                else {
                    $ProtoLine="$($ProtoLine) {"
                }

                
                #Add-Content -Path "$OutFile" -Value $ProtoLine 
                [System.IO.File]::AppendAllText($OutFile,"$($ProtoLine)`n")

                $writing=1
                

                
            }
        }
        
        
        
        } Else {}
    } 
    else {
        #Update types if in message
        
        
        if ($InMessageFile -eq 1) {
            #Find this type in types db
            $option = [System.StringSplitOptions]::RemoveEmptyEntries
            $ShortType = $ProtoLine.Split(" ",2,$option)

            #Check if we have an enum here. Must ignore until }
            #If this cannot be split, this is probably an enum or something else.
            if (!$ShortType[0] -or $ProtoLine -match $EnumInMSGPattern) {
                #Don't write anything now
                
                #Write Inline Enums, just to be safe
                #$ShortType="####IGNORE####";
                #$SkipWriting = 1
            }
            else {
                
                $ShortType = $ShortType[0].Trim()

                if ($ShortType -eq "repeated") {
                    #Find the repeated tag
                    $ShortType = $ProtoLine.Split(" ",3,$option)
                    $ShortType = "repeated " + $ShortType[1].Trim()
                }
                
                echo "Found type" $ShortType "searching to replace"
                
                #Use above mapping table to match actual protos files on disk
                $typeLookupTable.GetEnumerator() | ForEach-Object {
                    if ($ShortType -eq $_.Key)
                    {
                        $ShortType = $ShortType -replace $_.Key, $_.Value
                        echo "line =" $ProtoLine
                        $ProtoLine = $ProtoLine  -replace $_.Key, $_.Value
                        echo "replaced line =" $ProtoLine
                    }
                }
            }

            if ($ShortType -ne "{") {
                $TypeFound = 0;
                
                #Find the location of this element in database file
                $TypeImportDB = Get-Content -Path "$($ProtoTypeFile)"
                ForEach ($TypeDBLine in $TypeImportDB) {

                  If ($TypeFound -eq 1) {  
                        #Replace with new type
                        $ProtoLine = $ProtoLine.Replace($ShortType,$TypeDBLine)
                        
                        #Check first if file is here
                        echo "FOUND TYPE BY EXACT FILE 1"
                        echo "ShortType: $($ShortType)"
                        echo "TypeDBLine: $($TypeDBLine)"
                        break
                  }Else {}
                  
                  If ($TypeDBLine -eq $ProtoFile) {  
                    #We found the correct file to update
                        $TypeFound = 3;
                  }Else {}

                  If ($TypeDBLine -eq $ShortType -and $TypeFound -eq 3) {  
                    #We found the correct file to update
                        $TypeFound = 1;
                  }Else {}
                  
                }  #End ForEach

                if ($TypeFound -eq 3) {
                    #Seems that we missed the type
                    $TypeFound = 0;
                }


                
                #Do it again in case the type was not found in this specific file
                $TypeImportDB = Get-Content -Path "$($ProtoTypeFile)"
                if ($TypeFound -eq 0) {
                    ForEach ($TypeDBLine in $TypeImportDB) {
                      If ($TypeFound -eq 1) {  
                            #Replace with new type
                            $ProtoLine = $ProtoLine.Replace($ShortType,$TypeDBLine)
                            break
                      }Else {}
                      If ($TypeDBLine -eq $ShortType) {  
                        #We found the correct file to update
                            $TypeFound = 1;
                      }Else {}
                      
                    }  #End ForEach
                }
                else {}
                
                
                
                #It can happen that a type name conversion was done here: PlayerRaidInfoProto -> PlayerRaidInfo, so check again without the "Proto" part
                if ($TypeFound -eq 0) {
                    $CorrectedType = $ShortType.Replace("Proto","")


                    #Find the location of this element in database file
                    $TypeImportDB = Get-Content -Path "$($ProtoTypeFile)"
                    ForEach ($TypeDBLine in $TypeImportDB) {

                      If ($TypeFound -eq 1) {  
                            #Replace with new type
                            $ProtoLine = $ProtoLine.Replace($ShortType,$TypeDBLine)
                            
                            #Check first if file is here
                            echo "FOUND TYPE BY EXACT FILE 2"
                            echo "ShortType: $($ShortType)"
                            echo "TypeDBLine: $($TypeDBLine)"
                            break
                      }Else {}
                      
                      If ($TypeDBLine -eq $ProtoFile) {  
                        #We found the correct file to update
                            $TypeFound = 3;
                      }Else {}

                      If ($TypeDBLine -eq $ShortType -and $TypeFound -eq 3) {  
                        #We found the correct file to update
                            $TypeFound = 1;
                      }Else {}
                      
                    }  #End ForEach

                    if ($TypeFound -eq 3) {
                        #Seems that we missed the type
                        $TypeFound = 0;
                    }
                    

                    $TypeImportDB = Get-Content -Path "$($ProtoTypeFile)"
                    ForEach ($TypeDBLine in $TypeImportDB) {
                      If ($TypeFound -eq 1) {  
                            #Replace with new type
                            $ProtoLine = $ProtoLine.Replace($ShortType,$TypeDBLine)
                            break
                      }Else {}
                      If ($TypeDBLine -eq $CorrectedType) {  
                        #We found the correct file to update
                            $TypeFound = 1;
                      }Else {}
                      
                    }  #End ForEach
                }

                #It can happen that a type name conversion was done here: PokemonProto -> PokemonData, so check again with the "Data" part
                if ($TypeFound -eq 0) {
                    $CorrectedType = $ShortType.Replace("Proto","Data")
                    echo "finding new correction:" $CorrectedType


                    #Find the location of this element in database file
                    $TypeImportDB2 = Get-Content -Path "$($ProtoTypeFile)"
                    ForEach ($TypeDBLine in $TypeImportDB2) {

                      If ($TypeFound -eq 1) {  
                            #Replace with new type
                            $ProtoLine = $ProtoLine.Replace($ShortType,$TypeDBLine)
                            
                            #Check first if file is here
                            echo "FOUND TYPE BY EXACT FILE 3"
                            echo "ShortType: $($ShortType)"
                            echo "TypeDBLine: $($TypeDBLine)"
                            break
                      }Else {}
                      
                      If ($TypeDBLine -eq $ProtoFile) {  
                        #We found the correct file to update
                            $TypeFound = 3;
                      }Else {}

                      If ($TypeDBLine -eq $ShortType -and $TypeFound -eq 3) {  
                        #We found the correct file to update
                            $TypeFound = 1;
                      }Else {}
                      
                    }  #End ForEach

                    if ($TypeFound -eq 3) {
                        #Seems that we missed the type
                        $TypeFound = 0;
                    }


                    $TypeImportDB2 = Get-Content -Path "$($ProtoTypeFile)"
                    ForEach ($TypeDBLine in $TypeImportDB2) {
                      If ($TypeFound -eq 1) {  
                            #Replace with new type
                            $ProtoLine = $ProtoLine.Replace($ShortType,$TypeDBLine)
                            echo "Found and correcting to:" $TypeDBLine
                            break
                      }Else {}
                      If ($TypeDBLine -eq $CorrectedType) {  
                        #We found the correct file to update
                            $TypeFound = 1;
                      }Else {}
                      
                    }  #End ForEach
                }

                
            }
        }

        if ($ShortType -eq "####IGNORE####" -or $SkipWriting -eq 1 ) {
            #Enums etc inside protos are ignored and not written
        }
        else {
            #Apply some last minute corrections
            $typeCorrectionsTable.GetEnumerator() | ForEach-Object {
                if ($ProtoLine -like "*$($_.Key)*")
                {
                    $ProtoLine = $ProtoLine  -replace $_.Key, $_.Value
                }
            }
            #Add-Content -Path "$OutFile" -Value $ProtoLine 
            
            #If we find a single { it means that is was originally on the next line. Since we already written it, we can ignore it here.
            if ($ProtoLine -eq "{") {
            }
            else {
                [System.IO.File]::AppendAllText($OutFile,"$($ProtoLine)`n")
            }
        }

        #Check is the in message type enums has been closed. This is at the end, to avoid writing the closing from enum "}" to disk
        if ($SkipWriting -eq 1 -and $ProtoLine -match $EnumInMSGPatternEND) {
            $SkipWriting = 0;
        }
        
        
        ###### WRITING MODE #########
        if ($ProtoLine -eq "}") {
                $writing=0
        }
    }
}  #End ForEach