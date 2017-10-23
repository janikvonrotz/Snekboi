#
# config
#
$screenWidth = 20
$screenHeight = 10
$backgroundCharacter = " "
$foodCharacter = "O"
$playerCharacter = "X"
$speed = 500
$LastKey = "UpArrow"

# prepare game
$body = @()
$history = @()
$Foodx = $null
$Foody = $null
$screenWidth = ($screenWidth-1)
$screenHeight = ($screenHeight-1)
$body += @{
    x = [int]($screenWidth/2)
    y = [int]($screenHeight/2)
}
$body += @{
    x = 8
    y = 9
}

while($true) {
    
    #
    # set screen background
    #
    $screen = New-Object 'object[,]' ($screenWidth+1),($screenHeight+1)
    0..$screenWidth | % {
        $x = $_

        0..$screenHeight | % {
            $y = $_

            $screen[$x,$y] = $backgroundCharacter
        }
    }

    # wait for next frame
    Start-Sleep -Milliseconds $speed

    # store key press for evaluation in next frame
    if ([console]::KeyAvailable) {
        $key = [System.Console]::ReadKey() 
        $LastKey = $key.key
    }

    #
    # reset snake position if out of window
    #
    $body | % {
        $index = $body.IndexOf($_)

        if($_.y -gt $screenHeight) {
            $body[$index].y = 0
        }
        if($_.y -eq -1) {
            $body[$index].y = $screenHeight-1
        }
        if($_.x -gt $screenWidth) {
            $body[$index].x = 0
        }
        if($_.x -eq -1) {
            $body[$index].x = $screenWidth-1
        }
    }

    #
    # move body parts
    #
    $($body.Length -1)..0 | % {
        
        if($_ -ne 0) {
            $body[$_].x = $body[$_-1].x
            $body[$_].y = $body[$_-1].y
        }
    }

    # auto move snake
    switch($LastKey) {

        "UpArrow" {
            $body[0].y++
        }
        "DownArrow" {
            $body[0].y--
        }
        "RightArrow" {
            $body[0].x++
        }
        "LeftArrow" {
            $body[0].x--
        }
    }

    # eating Food
    if($Foodx -eq $body[0].x -and $Foody -eq $body[0].y) {

        # push new body part to temp history
        $newBodyPart = @{
            x = $Foodx
            y = $Foody
        }

        $Foody = $null
        $Foodx = $null
    }

    # add body part if snake has moved over food
    if($newBodyPart) {
        $snakeOnBodyPart = $body | Where-Object {$_.x -eq $newBodyPart.x -and $_.y -eq $newBodyPart.y}
        if(-not $snakeOnBodyPart) {
            $body += $newBodyPart
        }
    }

    # generate random foot if eaten
    if(-not $Foodx) {
        $Foodx = Get-Random -Minimum 0 -Maximum ($screenWidth)
        $Foody = Get-Random -Minimum 0 -Maximum ($screenHeight)
    }
    $screen[$Foodx,$Foody] = $foodCharacter
    
    # set body parts
    $body | % {
        $screen[$_.x,$_.y] = $playerCharacter
    }

    #
    # draw the screen
    #
    $screen = $screenHeight..0 | % {
        $y = $_

        $output = ""

        # if first line add border
        if($y -eq $screenHeight) {
            $output += "$("--" * ($screenWidth  + 2))`n"
        }

        $line = $null
        0..$screenWidth | % {
            $x = $_

            $line += " $($screen[$x,$y])"
        }
        $output += "|$($line)|`n"

        # if first line add border
        if($y -eq 0) {
            $output += " -" * ($screenWidth  + 2)
        }

        return $output
    }

    Clear-Host
    Write-Host $screen
    Write-Host "Player position: $($body[0].x) / $($body[0].y)"
    Write-Host "The field size is: $screenWidth / $screenHeight"
    Write-Host "Body length is: $($body.Length)"
    Write-Host "History content:"
    $body | % {
        $index = $body.IndexOf($_)
        Write-Host "$($index): $($_.x) / $($_.y)"
    }
}