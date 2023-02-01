function CheckInternetStatus
{
    while (!(test-connection 8.8.8.8 -Count 1 -quiet)) #Ping Google et recommence jusqu'a ce qu'il y est internet
    {
    $lblOutput.Text += "Une fois la connexion établie l'installation va débuter`r`n"
    start-sleep 5
    }
}