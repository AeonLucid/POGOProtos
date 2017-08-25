Param (

  [Parameter(Mandatory=$true)]
    [String] $SourceFolder,
  [Parameter(Mandatory=$true)]
    [String] $ProtoIndexFile,
  [Parameter(Mandatory=$true)]
    [String] $ProtoTypeFile,
  [Parameter(Mandatory=$true)]
    [String] $ProtoImportFile
)


function GetFiles($path = $pwd, [string[]]$exclude)
{
    foreach ($item in Get-ChildItem $path)
    {
        if ($exclude | Where {$item -like $_}) { continue }

        $item
        if (Test-Path $item.FullName -PathType Container)
        {
            GetFiles $item.FullName $exclude
        }
    }
} 


$EnumPattern = [RegEx] '^enum '
$MessagePattern = [RegEx] '^message '
$ImportPattern = [RegEx] '^import '


#MAIN PROGRAMM
$SourceFiles = GetFiles($SourceFolder)

#Create output files
New-Item $ProtoIndexFile -type file -force
New-Item $ProtoTypeFile -type file -force
New-Item $ProtoImportFile -type file -force
New-Item $MissingFile -type file -force

ForEach ($File in $SourceFiles) {
    #echo "Opening:" $File.FullName
    
    If ( ([IO.FileInfo]"$($File.FullName)").Attributes -match 'Directory') {
        #This is a folder, so skip this loop
        Continue
    }
    
    $ProtoData = Get-Content -Path "$($File.FullName)"

    $InMessageFile = 0;

    ForEach ($ProtoLine in $ProtoData) {

        If ($ProtoLine -match $ImportPattern) {  
            #We found an import line. Make sure that we store the imports.
            Add-Content -Path "$ProtoImportFile" -Value $File.FullName
            echo $File.FullName
            Add-Content -Path "$ProtoImportFile" -Value $ProtoLine
            echo $ProtoLine
        }

        If ($ProtoLine -match $EnumPattern -or $ProtoLine -match $MessagePattern) {  
            #enum or message line found
            If ($ProtoLine -match $MessagePattern) {  
                $InMessageFile = 1;
            }
            
            #Remove the { at the end
            if ($ProtoLine.contains("{") ) {
                $ProtoLine=$ProtoLine.Substring(0,$ProtoLine.Length-2)
            }
            else {}
            
            Add-Content -Path "$ProtoIndexFile" -Value $ProtoLine
            echo $ProtoLine
            Add-Content -Path "$ProtoIndexFile" -Value $File.FullName
            echo $File.FullName
        }
        Else {
            #Parse the rest of the message file to detect all types
            if ($InMessageFile -eq 1) {
                If ($ProtoLine -match [RegEx] '.*\.POGOProtos\.' ) {  
                    #We found a dedicated type. Store its declaration
                    
                    #Split the parts
                    $option = [System.StringSplitOptions]::RemoveEmptyEntries
                    $FullType = $ProtoLine.Split(" ",2,$option)
                    $FullType = $FullType[0].Trim()

                    $ShortType = $FullType;
                    $ShortType = $ShortType.Split("\.")
                    $ShortType = $ShortType[-1]

                    #If name is "repeated", we need to use the second part
                    if ($ShortType -eq "repeated") {
                    
                        $FullType = $ProtoLine.Split(" ",3,$option)
                        $FullType = "repeated " + $FullType[1].Trim()

                        $ShortType = $FullType;
                        $ShortType = $ShortType.Split("\.")
                        $ShortType = "repeated " + $ShortType[-1]
                    }
                    else {
                    
                    }

                    
                    Add-Content -Path "$ProtoTypeFile" -Value $File.FullName
                    Add-Content -Path "$ProtoTypeFile" -Value $ShortType
                    Add-Content -Path "$ProtoTypeFile" -Value $FullType
                    echo "TypeDB- Source type " $ShortType "## to ##" $FullType
                }
            }
            
          
        } 
      
    }  #End ForEach


<#  
If ($Line -match $FNPattern) {  
    $FN = $Line.Trim() | ForEach-Object {$_.Substring(3,($_.Length-6))}  
    $CurrentFN = $OutPath + "$($FN.trim())" + ".txt" 
  }
  Else {
    If ($StripBlankLines.IsPresent -and ($Line.Trim().Length -eq 0)) {
    }
    Else {
      Add-Content -Path "$CurrentFN" -Value $Line
    }
  } 
#>

}  #End ForEach



