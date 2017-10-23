#
# config
#
$screenWidth = 15
$screenHeight = 10
$backgroundCharacter = " "
$foodCharacter = "O"
$playerCharacter = "X"
$speed = 200
$LastKey = "UpArrow"
$GameState = "Running"
$Debug = $false

# prepare game
$body = @()
$newBodyParts = @()
$history = @()
$Food = @{ x = $null; y = $null }
$screenWidth = ($screenWidth-1)
$screenHeight = ($screenHeight-1)
$body += @{
    x = [int]($screenWidth/2)
    y = [int]($screenHeight/2)
}

while($GameState -eq "Running") {
    
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

    #
    # Check if moved over body part
    #
    if($body.Length -gt 1) {
        $head = $body[0]
        $snakeHeadOnBodyPart = $body[1..$($body.Length-1)] | Where-Object {$_.x -eq $head.x -and $_.y -eq $head.y}
        if($snakeHeadOnBodyPart) {
            $GameState = "Failed"
        }
    }
    #>

    #
    # reset snake position if out of window
    #
    $body | % {
        $index = $body.IndexOf($_)

        if($_.y -gt $screenHeight) {
            $body[$index].y = 0
        }
        if($_.y -eq -1) {
            $body[$index].y = $screenHeight
        }
        if($_.x -gt $screenWidth) {
            $body[$index].x = 0
        }
        if($_.x -eq -1) {
            $body[$index].x = $screenWidth
        }
    }

    # add body part if snake has moved over food
    if($newBodyParts) {
        $newBodyParts | %{
            $newBodyPart = $_
            $snakeOnNewBodyPart = $body | Where-Object {$_.x -eq $newBodyPart.x -and $_.y -eq $newBodyPart.y}
            if(-not $snakeOnNewBodyPart) {
                $body += $newBodyPart
            }
        }
    }

    # eating Food
    if($Food.x -eq $body[0].x -and $Food.y -eq $body[0].y) {

        # push new body part to temp history
        $newBodyParts += @{
            x = $Food.x
            y = $Food.y
        }

        $Food.x = $null
    }

    # generate random foot if eaten
    while(-not $Food.x) {
        $Food.x = Get-Random -Minimum 0 -Maximum ($screenWidth)
        $Food.y = Get-Random -Minimum 0 -Maximum ($screenHeight)

        # if food is placed in body reset
        $foodOnBodyPart = $body | Where-Object {$_.x -eq $Food.x -and $_.y -eq $Food.y}
        if($foodOnBodyPart) {
            $Food.x = $null
        }
    }
    $screen[$Food.x,$Food.y] = $foodCharacter
    
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
            $output += "+$("-" * ($screenWidth  + 1))+`n"
        }

        $line = $null
        0..$screenWidth | % {
            $x = $_

            $line += "$($screen[$x,$y])"
        }
        $output += "|$($line)|"

        # if first line add border
        if($y -eq 0) {
            $output += "`n+$("-" * ($screenWidth  + 1))+"
        }

        return $output
    }

    Clear-Host
    $screen | %{Write-Host $_}
    Write-Host "Player position: $($body[0].x) / $($body[0].y)"
    Write-Host "The field size is: $screenWidth / $screenHeight"
    Write-Host "Body length is: $($body.Length)"
    if($Debug) {
        Write-Host "Body content:"
        $body | % {
            $index = $body.IndexOf($_)
            Write-Host "$($index): $($_.x) / $($_.y)"
        }
    }
}
Write-Warning "Gamestate: $GameState"