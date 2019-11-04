<# 
    Food2Fork API Meal Planning

    2 main URLs:

    Search that returns 30 results
    https://www.food2fork.com/api/search?key=YOUR_API_KEY&q=ingredients,comma,separated&page=2
        page provides additional results - can change number

    Search for a specific recipe based on IP
    https://www.food2fork.com/api/get?key=YOUR_API_KEY&rId=35382
        

    Key:

    See below for proper searching
    PS C:\Users\bcrump> $string = "chicken breast"
    PS C:\Users\bcrump> [uri]::EscapeDataString($string)
    chicken%20breast

#>


# Create ingredients variables to search for

    Write-Host "Enter a protein to find recipes for (Default:Chicken Breast): "
    $FirstProtein = Read-Host

    if($FirstProtein -eq "")
        {
            $FirstProtein = "Chicken Breast"
        }
    
    Write-Host "Enter another protein to find recipes for (Default:Pork): "
    $SecondProtein = Read-Host

    if($SecondProtein -eq "")
        {
            $SecondProtein = "Pork"
        }

    Write-Host "Enter the last protein to find recipes for (Default:Ground Beef): "
    $ThirdProtein = Read-Host
    
    if($ThirdProtein -eq "")
        {
            $ThirdProtein = "Ground Beef"
        }
    


# GET request for recipes based on the ingredients provided


    # Generate random number for page results in the API
    $FirstPageNumber = Get-Random -Minimum 1 -Maximum 3
    $SecondPageNumber = Get-Random -Minimum 1 -Maximum 3
    $ThirdPageNumber = Get-Random -Minimum 1 -Maximum 3

    #Set API Key
    $ApiKey = "795572ecff1572c54c29ab28fb2ff29e"

    # Obtain recipes via an API call with the defined ingredients and random page number
    $FirstSetRecipes = Invoke-RestMethod "https://www.food2fork.com/api/search?key=$ApiKey&q=$FirstProtein&page=$FirstPageNumber"
    $SecondSetRecipes = Invoke-RestMethod "https://www.food2fork.com/api/search?key=$ApiKey&q=$SecondProtein&page=$SecondPageNumber"
    $ThirdSetRecipes = Invoke-RestMethod "https://www.food2fork.com/api/search?key=$ApiKey&q=$ThirdProtein&page=$ThirdPageNumber"


# Randomly pick 10 recipes

$RecipeArray = @()
$RandomRecipe = Get-Random -InputObject(0..29) -count 3
$i = 0

do{

    $RecipeArray += $FirstSetRecipes.recipes[$RandomRecipe[$i]]
    $RecipeArray += $SecondSetRecipes.recipes[$RandomRecipe[$i]]
    $RecipeArray += $ThirdSetRecipes.recipes[$RandomRecipe[$i]]
    $i++

}while($i -le 2)


# Format recipes and send in email

$RecipeArray