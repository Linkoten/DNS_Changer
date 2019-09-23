#------------------------Initialisation----------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#------------------------------------------------------------

#Functions--------------------------------------------------------------------------------

#Function to create FormLabel
Function CreateFormLabel
{
    param([int]$locationx, [int]$locationy, [int]$sizex, [int]$sizey, [string]$text)

    $FormLabel = New-Object System.Windows.Forms.Label
    $FormLabel.Location = New-Object System.Drawing.Point($locationx, $locationy)
    $FormLabel.Size = New-Object System.Drawing.Size($sizex, $sizey)
    $FormLabel.Text = $text
    return $FormLabel
    
}

#Function to create ListBox
Function CreateListBox
{
    param([int]$locationx, [int]$locationy, [int]$sizex, [int]$sizey, [int]$height)

    $ListBox = New-Object System.Windows.Forms.ListBox
    $ListBox.Location = New-Object System.Drawing.Point($locationx,$locationy)
    $ListBox.Size = New-Object System.Drawing.Size($sizex,$sizey)
    $ListBox.Height = $height
    $ListBox.SelectionMode = 'One'
    return $ListBox
}

#Function to create Buttons
Function CreateButton
{
    param([int]$locationx, [int]$locationy, [int]$sizex, [int]$sizey, [int]$height, [string]$text)
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point($locationx,$locationy)
    $Button.Size = New-Object System.Drawing.Size($sizex,$sizey)
    $Button.Height = $height
    $Button.Text = $text
    return $Button
}

#Function to create TextBox
Function CreateTextBox
{
    param([int]$locationx, [int]$locationy, [int]$sizex, [int]$sizey, [int]$maxLenght)
    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Location = New-Object System.Drawing.Point($locationx,$locationy)
    $TextBox.Size = New-Object System.Drawing.Size($sizex,$sizey)
    $TextBox.MaxLength = $maxLenght
    return $TextBox
}

#Function to Create GroupBox
Function CreateGroupBox
{
    param([int]$locationx, [int]$locationy, [int]$width, [int]$height, [string]$text)
    $GroupBox = New-Object System.Windows.Forms.GroupBox
    $GroupBox.Location = New-Object System.Drawing.Point($locationx,$locationy)
    $GroupBox.Width = $width
    $GroupBox.Height = $height
    $GroupBox.Text = $text
    return $GroupBox
}

#Function to list all items in ListBox
Function ListDNS
{
    param([hashtable]$hashtable, $listBox)
    foreach ($item in $hashtable.keys)
    {
        [void] $listbox.Items.Add($item)
    }
    $listbox.SelectedIndex = '0'
}

#Function to activate or not TextBox
Function SwitchTextBox
{
    param($listbox, $textbox)
    foreach ($listbox in $listbox.SelectedItems)
    {
        if ($listbox -eq 'Custom DNS')
        {
            $textbox.Enabled = $true
        }
        else
        {
            $textbox.Enabled = $false
            $textbox.Text = ''
            $Button_ActiveDNS.Enabled = $true
            $Button_CreateBatch.Enabled = $true
            

        }
    }
 }

 #Function to add DNS with selection
 Function SelectDNS
 {
    param([hashtable]$hashtable, $listbox, $textbox)
    if($listbox.SelectedItem -eq 'Custom DNS')
    {
        if($textbox.Text -match $Regex_IPv4){
            $DNS = $textbox.Text
        }
    }
    else
    {
        $DNS = $hashtable[$listbox.SelectedItem]
    }
    return $DNS
 }

Function OnlyNumeric_ValidIP
{
    param($textbox)
    $textbox.Text = $textbox.Text -replace '[^0123456789.]'
    if($textbox.Text -match $Regex_IPv4)
    {
        $textbox.ForeColor = 'green'
        $Button_ActiveDNS.Enabled = $true
        $Button_CreateBatch.Enabled = $true
    }
    else
    {
        $textbox.ForeColor = 'red'
        $Button_ActiveDNS.Enabled = $false
        $Button_CreateBatch.Enabled = $false
    }
}

Function Get_Actual_DNS
{
    $DNS = ((Get-NetIPConfiguration).DNSServer)
    $IPv4_DNS = $DNS.ServerAddresses
    [array]$results = $IPv4_DNS -match $Regex_IPv4
    return $results
}


#Init Variable
[hashtable]$HashDNS_1 = [ordered]@{'OpenDNS' = '208.67.222.222'; 'CloudflareDNS' = '1.1.1.1'; 'Google DNS' = '8.8.8.8'; 'Norton DNS' = '199.85.126.20'; 'Custom DNS' = ''}
[hashtable]$HashDNS_2 = [ordered]@{'OpenDNS' = '208.67.220.220'; 'CloudflareDNS' = '1.0.0.1'; 'Google DNS' = '8.8.4.4'; 'Norton DNS' = '199.85.127.10'; 'Custom DNS' = ''}
$Regex_IPv4 = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"




#------------------------main form--------------------------------#
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Fast DNS Changer'
$main_form.AutoSize = $true
$main_form.FormBorderStyle = 'Fixed3D'
$main_form.MaximizeBox = $false
#$main_form.BackColor = 'C0C0C0'


#Init Group Box
$GroupBoxChange_DNS = CreateGroupBox '8' '8' '550' '180' 'Change DNS'
$GroupBoxInformation = CreateGroupBox '8' '200' '550' '80' 'Informations'



#Init all the FormLabel
$FormLabel_PrimaryDNS = CreateFormLabel '14' '25' '100' '20' 'Primary DNS'
$FormLabel_SecondaryDNS = CreateFormLabel '175' '25' '100' '20' 'Secondary DNS'
$FormLabel_PersoDNS1 = CreateFormLabel '13' '125' '100' '20' 'Custom DNS 1'
$FormLabel_PersoDNS2 = CreateFormLabel '173' '125' '100' '20' 'Custom DNS2'

[array]$Actual_DNS = Get_Actual_DNS
$FormLabel_Information_1 = CreateFormLabel '10' '220' '300' '20' $Actual_DNS[0]
$FormLabel_Information_2 = CreateFormLabel '10' '250' '100' '20' $Actual_DNS[1]



#Init all the list box and contents
$ListBox_PrimaryDNS = CreateListBox '15' '45' '150' '20' '80'
ListDNS $HashDNS_1 $ListBox_PrimaryDNS

$ListBox_SecondaryDNS = CreateListBox '175' '45' '150' '20' '80'
ListDNS $HashDNS_2 $ListBox_SecondaryDNS

#Init Buttons
$Button_ActiveDNS = CreateButton '345' '45' '200' '20' '45' 'Change DNS'
$Button_CreateBatch = CreateButton '345' '145' '200' '20' '20' 'Create a Batch script'
$Button_AutomaticDNS = CreateButton '345' '96' '200' '20' '20' 'Reset to Automatic DNS'

#Init TextBox
$TextBox_PersoDNS1 = CreateTextBox '15' '145' '100' '20' '15'
$TextBox_PersoDNS2 = CreateTextBox '175' '145' '100' '20' '15' 

$TextBox_PersoDNS1.Enabled = $false
$TextBox_PersoDNS2.Enabled = $false


#If text change check if it's an IP and only numeric
$TextBox_PersoDNS1.Add_TextChanged({ OnlyNumeric_ValidIP $TextBox_PersoDNS1 })
$TextBox_PersoDNS2.Add_TextChanged({ OnlyNumeric_ValidIP $TextBox_PersoDNS2 })

#Function to activate or not custom DNS TextBox
$ListBox_PrimaryDNS.Add_Click({
    $Button_ActiveDNS.BackColor = ''
    $Button_CreateBatch.BackColor = ''
    $Button_AutomaticDNS.BackColor = ''
    SwitchTextBox $ListBox_PrimaryDNS $TextBox_PersoDNS1})
$ListBox_SecondaryDNS.Add_Click({ 
$Button_ActiveDNS.BackColor = ''
    $Button_CreateBatch.BackColor = ''
    $Button_AutomaticDNS.BackColor = ''
    SwitchTextBox $ListBox_SecondaryDNS $TextBox_PersoDNS2})





$Button_ActiveDNS.Add_Click({
    $PrimaryDNS = SelectDNS $HashDNS_1 $ListBox_PrimaryDNS $TextBox_PersoDNS1
    $SecondaryDNS = SelectDNS $HashDNS_2 $ListBox_SecondaryDNS $TextBox_PersoDNS2
    $II = (Get-NetIPConfiguration).InterfaceIndex
    Set-DnsClientServerAddress -InterfaceIndex $II -ServerAddress $PrimaryDNS, $SecondaryDNS
    $test = Get_Actual_DNS
    $FormLabel_Information_1.Text = $test[0]
    $FormLabel_Information_2.Text = $test[1]

    if(($test[0] -eq $PrimaryDNS) -and ($test[1] -eq $SecondaryDNS)){
        $Button_ActiveDNS.BackColor = 'green'
        }
    else{
        $Button_ActiveDNS.BackColor = 'red'
      }

})




$Button_AutomaticDNS.Add_Click({
    $II = (Get-NetIPConfiguration).InterfaceIndex
    
    Set-DnsClientServerAddress -InterfaceIndex $II -ResetServerAddress
    $Acutal_DNS = Get_Actual_DNS
    $FormLabel_Information_1.Text = $Actual_DNS[0]
    $FormLabel_Information_2.Text = ''
    $Button_AutomaticDNS.BackColor = 'green'
})



$Button_CreateBatch.Add_Click({
    $SaveChooser = New-Object System.Windows.Forms.SaveFileDialog
    $SaveChooser.filename = "Fast_DNS_Changer"
    $SaveChooser.Filter = "Batch script (*.bat)|*.bat"
    $SaveChooser.DefaultExt = "bat"
    $SaveChooser.AddExtension = $true
    $Choise_in_SaveFile = $SaveChooser.showDialog()
    if($Choise_in_SaveFile -eq 'OK'){
        $PrimaryDNS = $HashDNS_1[$ListBox_PrimaryDNS.SelectedItem]
        $SecondaryDNS = $HashDNS_2[$ListBox_SecondaryDNS.SelectedItem]
        $Directory = $SaveChooser.filename
        $ConnectionID = get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2" | select netconnectionid
        $CI = $ConnectionID.netconnectionid
        $File = "netsh interface ip set dns name='$CI' source=static address='$PrimaryDNS'`r`nnetsh interface ip add dns name='$CI' addr='$SecondaryDNS' index=2" > "$Directory"
        }
})



$main_form.Controls.Add($FormLabel_PrimaryDNS)
$main_form.Controls.Add($FormLabel_SecondaryDNS)
$main_form.Controls.Add($FormLabel_PersoDNS1)
$main_form.Controls.Add($FormLabel_PersoDNS2)
$main_form.Controls.Add($FormLabel_Information_1)
$main_form.Controls.Add($FormLabel_Information_2)

$main_form.Controls.Add($ListBox_PrimaryDNS)
$main_form.Controls.Add($ListBox_SecondaryDNS)

$main_form.Controls.Add($Button_ActiveDNS)
$main_form.Controls.Add($Button_CreateBatch)
$main_form.Controls.Add($Button_AutomaticDNS)

$main_form.Controls.Add($TextBox_PersoDNS1)
$main_form.Controls.Add($TextBox_PersoDNS2)
$main_form.Controls.Add($GroupBoxChange_DNS)
$main_form.Controls.Add($GroupBoxInformation)


[void]$main_form.ShowDialog()
