# TODO: Refactor to advanced function
# This function aggregates reviews for games "written by me" in a particular format
# A similar algorithm is also used on my website for showing review written by me

function Get-GameReview {
    param (
        [Parameter(Mandatory)][string]$FilePath,
        [switch]$All,
        [string]$Game
    )
    
    if (![System.IO.Path]::IsPathRooted($FilePath))
    {
        $path = Resolve-Path $FilePath | Select-Object -ExpandProperty Path
        if (!$path)
        {
            Write-Error "Cannot resolve path. Check your path $FilePath"
            exit 1
        }
    }

    $game_reviews = Get-AllReviews $path

    if ($All)
    {
        foreach($game in $game_reviews.Keys)
        {
            Write-Host "${game}:"
            foreach($reviewType in $game_reviews.$game.Keys)
            {
                Write-Host "${reviewType}:"
                foreach($review in $game_reviews.$game.$reviewType)
                {
                    Write-Host $review
                }
                Write-Host ""
            }

            Write-Host "==="
        }
    }
}

function Get-AllReviews {
    param(
        [Parameter(Mandatory)][string]$FilePath
    )

    $game_reviews = @{}
    $start_regex = "(.+):$"

    foreach($line in [System.IO.File]::ReadLines($FilePath))
    {
        $line = $line.Trim()
        if (!$line) # if line is empty
        {
            continue
        }

        if ($line -match $start_regex) # game name
        {
            $game_name = [regex]::Matches($line, $start_regex).Groups[1].Value
            $review_table = @{
                Keys = @("Positive", "Controversial", "Negative")
                Positive = [System.Collections.Generic.List[string]]::new()
                Controversial = [System.Collections.Generic.List[string]]::new()
                Negative = [System.Collections.Generic.List[string]]::new()
            }
            $reviewObj = [PSCustomObject]$review_table
            $game_reviews.Add($game_name, $reviewObj)
            continue
        }

        if (!$game_name) # if game name is not set
        {
            continue
        }
        else
        {
            $operator = $line[0]
            $line = $line.Substring(1).Trim()
            if ($operator -eq "+") # positive
            {
                $sentiment = "Positive"
            }
            elseif ($operator -eq "-") # negative
            {
                $sentiment = "Negative"
            }
            else # controversial
            {
                $sentiment = "Controversial"
            }

            $game_reviews.$game_name.$sentiment.Add($line)
        }
    }

    return $game_reviews
}

function Get-ReviewRating {
    param(
        [Parameter(Mandatory)][hashtable]$game_reviews
    )
    
    # TODO:
}

function Get-ReviewFromFile {
    param (
        [Parameter(Mandatory)][string]$FilePath
    )
    # TODO:
    Write-Host $Game
}

Export-ModuleMember -Function Get-GameReview