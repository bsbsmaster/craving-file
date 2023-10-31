#!/bin/bash
#ANALYZER PROJECT  

################################################################################################################################################################################

#this function will check if u are root
function checkroot()
{
# Check if the current user is root		
if [ "$(whoami)" != "root" ] 
then
#if not will  tell u
echo "@@@@@@@@@@@@@@@@@@This script must be run as root.@@@@@@@@@@@@@@@@@@@@@@"
exit 1 
else 
#if u are root he u will use the script
echo ""
echo "      =========== Welcome : $(whoami)  ==============             "               
fi
}
checkroot

#############################################################################################################################################################################################

#the script will tell the user everythink he need
function telluser()
{
#echo for the user about the folder
echo ""
echo "the folder / file need to be in this loction : $(pwd) "
echo "  "
#echo for the user about the volatility tool and about the folder
echo "the tool volatility_2.6_lin64_standalone  need  to be in this loction : $(pwd)"                        
echo "" 
echo "all the file will be $(pwd) and inside report.zip u will see the extraced file "
echo ""
echo "if u want to analyze a memory file the extension file  need to be  ".dmp" ".raw" ".vmem" ".mem" (only if u  pick a folder to analyz) "
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo "                                                               "
}
telluser

#############################################################################################################################################################################################

#this function will make folders
function folders()
{
#vrible folder
fo="report/extract/formost"
#check if the folder exist 
if [ ! -d "$fo" ]
then
#create a multi directorys  to save every think 
sudo mkdir  -p "$fo"
sudo mkdir -p report/extract/registry/dumpregistry
sudo mkdir -p report/extract/vol
#give permission to all the folders
sudo chmod -R 777 report/extract/registry/dumpregistry
sudo chmod -R 777  report
sudo chmod -R 777  report/extract/vol
sudo chmod -R 777  report/extract/
sudo chmod -R 777  report/extract/*

fi
}
folders

#############################################################################################################################################################################################

#this function will make varibles
function variablepac()
{
#variable all the needit tools
pac=("libimage-exiftool-perl" "bulk-extractor" "binwalk" "foremost" "binutils" )
}
variablepac

#############################################################################################################################################################################################

#this function will cheack the packs and install them if not installed
function checkingpacks()
{
#checking the packs if installed
 for packs in "${pac[@]}" 
 do
# checking apps
if  ! sudo dpkg -s "$packs" &>>$(pwd)/report/outputterminal.txt
#if he didnt find everythink he will dolowand everythink:
then 
#he will save the time when the update start   
echo "(# update and upgarde : $(date))" 
# Checking for update and upgrade
sudo apt-get update -y &>>$(pwd)/report/outputterminal.txt
sudo apt-get dist-upgrade -y &>>$(pwd)/report/outputterminal.txt
echo ""
#he will save the time when the pc start to install  packs
echo "(# $packs is installing: $(date))" 
#start installing
sudo apt-get install "$packs" -y &>>$(pwd)/report/outputterminal.txt
echo ""
fi
#checking for volatilay if not instal
 if [ ! -f "$(pwd)/volatility_2.6_lin64_standalone" ] &>>$(pwd)/report/outputterminal.txt
  then
#he will save the time when the pc start to updateand upgarde
echo "(# update and upgarde : $(date))"
echo "" 
# Checking for update and upgrade
sudo apt-get update -y &>>$(pwd)/report/outputterminal.txt
sudo apt-get dist-upgrade -y &>>$(pwd)/report/outputterminal.txt
#he will save the time when the pc start install volatilityfoundation
echo "(# volatilityfoundation is installing: $(date))" 
echo ""
#Installing from url  
sudo wget -nc http://downloads.volatilityfoundation.org/releases/2.6/volatility_2.6_lin64_standalone.zip  &>>$(pwd)/report/outputterminal.txt
#extract the file 
unzip -j -o volatility_2.6_lin64_standalone.zip &>>$(pwd)/report/outputterminal.txt
#give acess for the user to acess the file
sudo chmod -R 777 volatility_2.6_lin64_standalone &>>$(pwd)/report/outputterminal.txt
fi
done 
# all the apps needit in ur pc
echo "(#  all the  packs checked : $(date))" 
echo "                                                               "
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo "                                                               "
}
checkingpacks

#############################################################################################################################################################################################

#this function will make the user input folder or file
function input()
{
#input for the user to speficy filename
read -p "#  Sepify Filename or a Folder:  " filename
echo "                          "
#echo will tell the time when the  user  specify a $filename	
echo "( # the user  specifyed  $filename : $(date) )" 
echo " "
}
input

#############################################################################################################################################################################################

#check if the file exist if not exit 
function findfolder()
{
#rec start
echo "( # start scan  $filename if exist : $(date) )" 
echo ""
#there is bug if u enter nothing  it will cotine continues  so i fixit by this 
if [ -z $filename ]
then
echo "# u didnt enter anythink"
exit
else
if [ -e  $filename  ]
then
echo "# the script found  the file " 
echo ""
echo "( # end scan  $filename if exist : $(date) )" 
echo ""
else
if [ -d "$filename" ]
then 
echo "# the script found  the file "
echo ""
echo "( # end scan  $filename if exist : $(date) )" 
else
echo "#  sorry didnt find the folder pls  check the file and where is he  and  putit in $(pwd)"
exit
fi 
fi
fi
echo "                                                               "
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo "                                                               "
}
findfolder

#############################################################################################################################################################################################

#this function will extract data folder and check if the input is folder 
function file()
{
#will check if the input is folder
if [ -d "$filename" ]
then
#if he exist he will tell u
echo "(          @@@@@@@@@@@@the $filename is a folder @@@@@@@@@@@@@                   )"
echo ""

#############################################################################################################################################################################################

#this function will extract data
function extract()
{
#echo will tell the time the tools start 
echo "( # start to extract data  : $(date) )" 
#start exctract data from the file  with multi tools 
echo "                          "
echo "(binwalk extracting : $(date) )" 
sudo binwalk -q --run-as=root --dd ".*" $filename -C $(pwd)/report/extract/binwalk.extracted 
#secound bulkextractor 
echo "                          "
echo "(bulk_extractor extracting : $(date))"
echo "                          "
bulk_extractor -R "$filename" -o $(pwd)/report/extract/bulk &>> $(pwd)/report/outputterminal.txt  
#third foremost 
echo "(foremsost extracting : $(date))"
echo "                          "
foremost  -Q -t all  -i "$filename" -o $(pwd)/report/extract/formost  &>> $(pwd)/report/outputterminal.txt 
#fix bug
sudo chmod -R 777  report/extract/formost/*
#four  strings 
#need to do for to acess all the folder
echo "                          "
echo "(strings extracting  : $(date))"
for xxx in $filename/*
do
if [ -f "$xxx" ]
then
strings -a "$xxx" > $(pwd)/report/extract/strings.txt
fi
done
#five exiftool 
echo "(exiftool extracting  : $(date))"
echo "                          "
exiftool $filename > $(pwd)/report/extract/exiftool.txt 
#echo will tell the time the tools end it 
echo "( # end  extracted data  : $(date) )" 
echo  ""
#vribles to tell how may files  
bin=$(find "$(pwd)/report/extract/binwalk.extracted" -type f | wc -l) &>> $(pwd)/report/outputterminal.txt 
bulk=$(find "$(pwd)/report/extract/bulk" -type f | wc -l) &>> $(pwd)/report/outputterminal.txt 
fores=$(find "$(pwd)/report/extract/formost" -type f | wc -l) &>> $(pwd)/report/outputterminal.txt 
string=$(grep -c "" "$(pwd)/report/extract/strings.txt") &>> $(pwd)/report/outputterminal.txt 
exif=$(grep -c "" "$(pwd)/report/extract/exiftool.txt") &>> $(pwd)/report/outputterminal.txt 
#echo files
echo "(Binwalk extracted $bin files.)" &&   echo "(Exiftool extracted  $exif files.)" &&   echo "(Bulk Extractor extracted $bulk files.)" &&
echo "(Foremost extracted $fores files.)" &&   echo "(Strings extracted  $string files.)"
echo "                                                               "
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo "                                                               "
}
extract

##################################################################################################################################################

#this function will give vribles for the network function
function variablenetworkfolder()
{
#variable serching  for network pack
com=$(sudo find "$(pwd)/report/extract/" -name "packets.pcap") &>>$(pwd)/report/outputterminal.txt
#variable to tell where is  network pack and zie the netowrk
siz=$(ls -qsh "$com")  &>>$(pwd)/report/outputterminal.txt
}
variablenetworkfolder

#############################################################################################################################################################################################

#this function will tell u where and zie  the network file if it found
function exctractnetworkfolder()
{
#the start time of the searching
echo "( # start to seraching for file network   : $(date) )" 
echo ""
#he will cheack for the file network  if he exist
if  [ ! -f "$com" ]  
then 
#if he didnt find he will tell the use he didnt find
echo "# didnt find any network file "
#end of the time searching 
echo ""
echo "( # end of seraching for file network  end  : $(date) )" 
else 
#if he found he will tell u the every think about like size location and  what premsion he have 
echo "# there is a network file :
#size# ____________#filepath#
$siz "
#the end time of the searching
echo ""
echo "( # end of seraching for file network   : $(date) )"
fi
echo "                                                               "
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo "                                                               "
}
exctractnetworkfolder


#############################################################################################################################################################################################

#this function will tell u if there any human redable file and the zie 
function reads()
{
#rec time start to find the data 
echo "( # start   scaning for file that have human-readble : $(date) )"
#this code will tell u all the need file and the size
find "$(pwd)/report" -type f \( -name "binwalk.txt" -o -name "exiftool.txt" -o -name "strings.txt" -o -name "telephone.txt" -o -name "ccn.txt" -o -name "email.txt" -o -name "email_domain_histogram.txt" -o -name "vcard.txt" -o -name "ip.txt" -o -name "*.exe" -o -name "*.gif" -o -name "*.png" -o -name "*.doc" -o -name "*.jpg" -o -name "*.mp4" -o -name "*.pdf" -o -name "*.zip" \) -exec ls -sh {} \;  &>> $(pwd)/report/extract/human.txt
echo ""
echo  "# all the files path and size : $(pwd)/report/extract/human.txt"
echo ""
echo  "( # end of  scaning for file that have human-readble : $(date) )" 
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
}
reads

#############################################################################################################################################################################################

#this function will scan for a file 
function scan()
{
x=$(find "$filename" -type f \( -name "*.dmp" -o -name "*.raw" -o -name "*.vmem" -o -name "*.mem" \) -exec basename {} \;)
for f in $x
 do
profile=$(./volatility_2.6_lin64_standalone -f $f  imageinfo 2>&1  | grep "Suggested Profile" 2>&1  | awk '{print $4}'| sed 's/,$//')  

#############################################################################################################################################################################################

#check if u can run vol
function prof()
{
 if [ "$profile" = "No" ]  
then
echo '# u cant run the vol in this file '
echo ""

#############################################################################################################################################################################################

#this function will zip the files
function zip()
{
#rec start
echo "(  start ziping folders : $(date) )" 	
#start ziping the folder
sudo zip -r $(pwd)/report/extract.zip report/extract/ &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo rm -rf report/extract &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo zip -r $(pwd)/report.zip  report/  &>>$(pwd)/re
sleep 2
sudo rm -rf report &>>$(pwd)/report/outputterminal.txt
#rec end
echo ""
echo "(  end ziping folders : $(date) )" 
echo ""
echo "      =========== Goodbye : $(whoami)  ==============             "
exit	 
}
zip
fi
}
prof
done
}
scan

#############################################################################################################################################################################################

#this function will scan the file if he have connections
function networkconnections()
{
#start rec
echo "( # start network  volatility : $(date) )" 
echo ""
#variable to scan netowrk
kss=$(./volatility_2.6_lin64_standalone -f $f --profile="$profile"  connections 2>&1 | awk '{print $1}' )
#if netscan didnt work
if [[ "$kss" == ERROR ]]
#will use another way 
then 
echo "This command does not support the profile : we will try another way"
./volatility_2.6_lin64_standalone -f "$f" --profile="$profile" netscan &>>$(pwd)/report/extract/vol/networkvol.txt
echo ""
echo "all the data saved in $(pwd)/report/vol/networkvol.txt"
echo ""
echo "( # end network  volatility : $(date) )"
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
else 
./volatility_2.6_lin64_standalone -f $f --profile="$profile"  connections &>>$(pwd)/report/extract/vol/networkvol.txt
echo "all the data saved in $(pwd)/report/vol/networkvol.txt"
echo ""
echo "( # end network  volatility : $(date) )"
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
 fi
}
networkconnections


#############################################################################################################################################################################################

#this function will scan  file taskmanger
function pslist()
{
#start rec time for vol 
echo "( # start taskmanger  volatility : $(date) )" 
#display the running processes
./volatility_2.6_lin64_standalone -f $f --profile=$profile pslist &>>$(pwd)/report/extract/vol/pslistvol.txt
#end time 
echo ""
echo " all the data saved in $(pwd)/report/extract/vol/pslistvol.txt "
echo ""
echo "( # end taskmanger volatility : $(date) )"
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
}
pslist

############################################################################################################################################################################################

#scan and extract reg
function registry()
{
#start rec
echo "( # start tool vol to extract registrt: $(date) )" 
echo "                                                               "
#start extrackting data 
./volatility_2.6_lin64_standalone -f "$f" --profile="$profile" dumpregistry -D "$(pwd)/report/extract/registry/dumpregistry" &>> "$(pwd)/report/outputterminal.txt"
#start extrackting data passwords
./volatility_2.6_lin64_standalone -f "$f" --profile="$profile" hashdump > "$(pwd)/report/extract/registry/hashdump.txt" 2>> "$(pwd)/report/outputterminal.txt"
echo "the registrt saved in $(pwd)/report/registry"
#end rec
echo "                                                               "
echo "( # end tool vol to extract registrt: $(date) )" 
}
registry

#############################################################################################################################################################################################

#this function will zip the files
  function zip2()
{
#rec start
echo ""
echo "(#  start ziping folders : $(date) )" 	
echo ""
#start ziping the folder
sudo zip -r $(pwd)/report/extract.zip report/extract/ &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo rm -rf report/extract &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo zip -r $(pwd)/report.zip  report/  &>>$(pwd)/report/outputterminal.txt
sleep  2
sudo rm -rf report &>>$(pwd)/report/outputterminal.txt
echo ""
echo "the zip file $(pwd)/report.zip"
#rec end
echo ""
echo "(#  end ziping folders : $(date) )" 
echo ""
echo ""
echo "      =========== Goodbye : $(whoami)  ==============             "	
exit 
}
zip2



#===========================================================================for file ( not folder )=========================================================================================



#else function  file
else
function file2()
{
echo ""
echo "(     ==============  the $filename is a file  ==============           )"
echo ""
}
file2

#############################################################################################################################################################################################

#if the file exist will satrt extract data
function extract2()
{
#echo will tell the time the tools start 
echo "( # start to extract data  : $(date) )" 
#start exctract data from the file  with multi tools 
echo "                          "
echo "(binwalk extracting : $(date) )" 
sudo binwalk -q --run-as=root --dd ".*" $filename -C $(pwd)/report/extract/binwalk.extracted
#secound bulkextractor 
echo "                          "
echo "(bulk_extractor extracting : $(date))"
echo "                          "
bulk_extractor $filename -o $(pwd)/report/extract/bulk &>> $(pwd)/report/outputterminal.txt  
#third foremost 
echo "(foremsost extracting : $(date))"
echo "                          "
foremost  -Q -t all    "$filename" -o $(pwd)/report/extract/formost  &>> $(pwd)/report/outputterminal.txt 
#acess to folder
sudo chmod -R 777 report/extract/formost/*
#four  strings 
echo "(strings extracting  : $(date))"
echo "                          "
strings $filename > $(pwd)/report/extract/strings.txt
#five exiftool 
echo "(exiftool extracting  : $(date))"
echo "                          "
exiftool $filename > $(pwd)/report/extract/exiftool.txt 
#echo will tell the time the tools end it
echo "( # end  extracted data  : $(date) )" 
echo ""
#vribles to tell how may files 
bin=$(find "$(pwd)/report/extract/binwalk.extracted" -type f | wc -l)
bulk=$(find "$(pwd)/report/extract/bulk" -type f | wc -l)
fores=$(find "$(pwd)/report/extract/formost" -type f | wc -l)
string=$(grep -c "" "$(pwd)/report/extract/strings.txt")
exif=$(grep -c "" "$(pwd)/report/extract/exiftool.txt")
#echo files
echo "(Binwalk extracted $bin files.)" &&   echo "(Exiftool extracted  $exif files.)" &&   echo "(Bulk Extractor extracted $bulk files.)" &&
echo echo "(Foremost extracted $fores files.)" &&   echo "(Strings extracted  $string files.)"
#echo every one 
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo "" 
}
extract2

#############################################################################################################################################################################################

#this function will give vribles for the network function
function variablenetworkfolder2()
{
#variable serching  for network pack
com=$(sudo find "$(pwd)/report/extract/" -name "packets.pcap") &>>$(pwd)/report/outputterminal.txt
#variable to tell where is  network pack and zie the netowrk
siz=$(ls -qsh "$com")  &>>$(pwd)/report/outputterminal.txt
}
variablenetworkfolder2

#############################################################################################################################################################################################

#this function will tell u where and zie  the network file if it found
function exctractnetworkfolder2()
{
#the start time of the searching
echo "( # start to seraching for file network   : $(date) )" 
echo ""
#he will cheack for the file network  if he exist
if  [ ! -f "$com" ]  
then 
#if he didnt find he will tell the use he didnt find
echo "# didnt find any network file "
#end of the time searching 
echo ""
echo "( # end of seraching for file network  end  : $(date) )" 
else 
#if he found he will tell u the every think about like size location and  what premsion he have 
echo "# there is a network file :
#size# ____________#filepath#
$siz "
#the end time of the searching
echo ""
echo "( # end of seraching for file network   : $(date) )"
fi
echo "                                                               "
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo "                                                               "
}
exctractnetworkfolder2

#############################################################################################################################################################################################

#this function will tell u if there any human redable file and the zie 
function reads2()
{
#rec time start to find the data 
echo "( # start   scaning for file that have human-readble : $(date) )"
#this code will tell u all the need file and the size
find "$(pwd)/report" -type f \( -name "binwalk.txt" -o -name "exiftool.txt" -o -name "strings.txt" -o -name "telephone.txt" -o -name "ccn.txt" -o -name "email.txt" -o -name "email_domain_histogram.txt" -o -name "vcard.txt" -o -name "ip.txt" -o -name "*.exe" -o -name "*.gif" -o -name "*.png" -o -name "*.doc" -o -name "*.jpg" -o -name "*.mp4" -o -name "*.pdf" -o -name "*.zip" \) -exec ls -sh {} \;  &>> $(pwd)/report/extract/human.txt
echo ""
echo  "# all the files path and size : $(pwd)/report/extract/human.txt"
echo ""
echo  "( # end of  scaning for file that have human-readble : $(date) )" 
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
}
reads2

#############################################################################################################################################################################################

#check if u can run vol
function prof2()
{
profile=$(./volatility_2.6_lin64_standalone -f $filename  imageinfo  2>&1 | grep "Suggested Profile" | awk '{print $4}'| sed 's/,$//')  
if [ "$profile" = "No" ]  
then
echo '# u cant run the vol in this file '
echo ""

#############################################################################################################################################################################################

#this function will zip the files
function zip3()
{
#rec start
echo "(  start ziping folders : $(date) )" 	
#start ziping the folder
sudo zip -r $(pwd)/report/extract.zip report/extract/ &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo rm -rf report/extract &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo zip -r $(pwd)/report.zip  report/  &>>$(pwd)/re
sleep 2
sudo rm -rf report &>>$(pwd)/report/outputterminal.txt
#rec end
echo ""
echo "(  end ziping folders : $(date) )" 
echo ""
echo "      =========== Goodbye : $(whoami)  ==============             "
exit	 
}
zip3
fi
}
prof2

#############################################################################################################################################################################################

#scan for process
function pslist2()
{
 #start rec for useing vol tool
echo "( # start pslist  volatility : $(date) )" 
echo ""
#display the running processes
./volatility_2.6_lin64_standalone -f $filename --profile=$profile pslist &>>$(pwd)/report/extract/vol/pslistvol.txt
#end rec 
echo " all the data saved in $(pwd)/report/extract/vol/pslistvol.txt "
echo ""
echo "( # end pslist  volatility : $(date) )" 
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
}
pslist2

#############################################################################################################################################################################################

#this function will scan the file if he have connections
function networkconnections2()
{
#start rec
echo "( # start network  volatility : $(date) )" 
echo ""
#variable to scan netowrk
kss=$(./volatility_2.6_lin64_standalone -f $f --profile="$profile"  connections 2>&1 | awk '{print $1}' )
#if netscan didnt work
if [[ "$kss" == ERROR ]]
#will use another way 
then 
echo "This command does not support the profile : we will try another way"
./volatility_2.6_lin64_standalone -f "$f" --profile="$profile" netscan &>>$(pwd)/report/extract/vol/networkvol.txt
echo ""
echo "all the data saved in $(pwd)/report/vol/networkvol.txt"
echo ""
echo "( # end network  volatility : $(date) )"
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
else 
./volatility_2.6_lin64_standalone -f $f --profile="$profile"  connections  &>>$(pwd)/report/extract/vol/networkvol.txt
echo "all the data saved in $(pwd)/report/vol/networkvol.txt"
echo ""
echo "( # end network  volatility : $(date) )"
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
 fi
}
networkconnections2

#############################################################################################################################################################################################

#scan and extract reg
function registry2()
{
#start rec
echo "( # start tool vol to extract registrt: $(date) )" 
echo "                                                               "
#start extrackting data 
./volatility_2.6_lin64_standalone -f "$filename" --profile="$profile" dumpregistry -D $(pwd)/report/extract/registry/dumpregistry &>> $(pwd)/report/outputterminal.txt
#start extrackting data passwords
./volatility_2.6_lin64_standalone -f "$filename" --profile="$profile" hashdump > "$(pwd)/report/extract/registry/hashdump.txt" 2>> "$(pwd)/report/outputterminal.txt"
echo "all the registry in $(pwd)/report/extract/registry "
echo "                                                               "
#end rec
echo "( # start tool vol to extract registrt: $(date) )" 
echo ""
echo "             @@@@@@@@@@@@@@@done@@@@@@@@@@@@@@@@@              "
echo ""
}
registry2

fi
}
file

#############################################################################################################################################################################################

#this function will zip the files
function zip4()
{
#rec start
echo "(#  start ziping folders : $(date) )" 	
echo ""
#start ziping the folder
sudo zip -r $(pwd)/report/extract.zip report/extract/ &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo rm -rf report/extract &>>$(pwd)/report/outputterminal.txt
sleep 2
sudo zip -r $(pwd)/report.zip  report/  &>>$(pwd)/report/outputterminal.txt
sleep  2
sudo rm -rf report &>>$(pwd)/report/outputterminal.txt
echo ""
echo "the zip file in $(pwd)/report.zip"
#rec end
echo ""
echo "(#  end ziping folders : $(date) )"
echo ""
echo "      =========== Goodbye : $(whoami)  ==============             "
 	
}
zip4           


