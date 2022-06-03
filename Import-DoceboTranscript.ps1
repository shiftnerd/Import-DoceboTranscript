#CSV scrubbing required before this will work
#Dates must be in the following format: YYYY-MM-DD HH:MM:SS Example:2022-03-18 23:01:21
#Valid status codes include "completed" or "subscribed". Completion date should not be set for user with status of "subscribed"
#Make sure to update $Url and to specify the bearer token when running the function.

function Import-DoceboTranscript {
    param (
        [Parameter(Mandatory,HelpMessage='Enter the bearer token!')] [string[]] $bearer_token,
        [Parameter(Mandatory,HelpMessage='Enter the course code!')] [string[]] $CourseCode,
        [Parameter(Mandatory,HelpMessage='Enter the course code!')] [string[]] $ImportPath,
        $Url = "https://UPDATEURLHERE.docebosaas.com/learn/v1/enrollment/batch"
    )
    $APIHeaders = @{Authorization = "Bearer $bearer_token"}
    $CSVHeaders = "USERNAME","LASTNAME","FIRSTNAME","DATEENROLLED","DATECOMPLETED","STATUS","SCORE"

    Import-CSV -Path "$ImportPath" -Header $CSVHeaders | ForEach-Object {

        $BodyJSON = @"
        {
            "items": [
        {
          "course_code": "$CourseCode",
          "username": "$($_.USERNAME)",
          "status": "$($_.STATUS)",
          "score": "$($_.SCORE)",
          "enrollment_date": "$($_.DATEENROLLED)",
          "completion_date": "$($_.DATECOMPLETED)"
        }
      ],
      "options": {
      },
      "trigger_gamification": false
        }
"@
    $result = Invoke-RestMethod -Method 'Post' -Uri $url -Headers $APIHeaders -Body $BodyJSON
    
    #Change this to Write-Verbose later, but for now print it out during testing.
    Write-Output "Course ID:"
    Write-Output $result.data.course_id
    Write-Output "User ID:"
    Write-Output $result.data.user_id
    Write-Output "Message:"
    Write-Output $result.data.message
    }
}
Import-DoceboTranscript -bearer_token "INSERTBEARERTOKENHERE" -CourseCode "NET4 - ALL" -ImportPath ".\TestTranscriptTransfer.csv"
