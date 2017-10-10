
#!/bin/bash
 
#################################################################
#################################################################
#								#
#         StartAnalyse.sh 					#
#          script v0.1						#
#   								#
#   developed by: Aysad Kozanoglu				#
#          email: aysadkozanoglu@gmail.com			#
#             							#
#         Client: GameDuell 					#
#           task: Automated Logical Accesslog Analytic 		#
#								#
# What does this script do ?					#
#  this script is for user friendly handling 			#
#  the logfile to save it localy 				#
#  and start the  analyse.php script				#				
#								#
#  The really analytics of the log file will realised 		#
#  with php code in analyse.php in the same path		#
#  (start automaticly)						#
#								#
#################################################################
#################################################################

clear;
ScriptPath=$(readlink -f $0);
TmpPath=`dirname $ScriptPath`"/tmp/";
TmpFileName=`date +%s`;
TmpFileNameTar="$TmpFileName.tar";
TmpSubFolder=$TmpFileName;
PHPScript=`dirname $ScriptPath`"/analyse.php"
DefaultSleepTime=2;
 

#							    #
############# BEGINN OF FUNCTIONS DECLARATIONS ##############
#							    #

GameDuellWelcome() {
	echo "------------------------------------------------";
	echo "|        GameDuell LogFile(s) Analyser v1.0     |";
	echo "------------------------------------------------"
	echo -e
}

########################################
# 	 Function                      
#	   to find                          
# out the adress to  accesslog         
#       remote/local                   
########################################

AskFilePlace() {
	echo -e;  					                                          
	echo -e " Is the log file on localhost or RemoteHost ? ";   					   
	echo " 1 - localhost "; 			  
	echo " 2 - remotehost "; 			  
}

######################################### 
#        Function                       
#        for selecting                  
#   	  fileformat                    
#########################################

AskFileFormat() {
	echo -e;					  
	echo -e " Which fileFormat has the Logfile ? ";	  
	echo -e;					  
	echo " 1 - .log file format ";			  
	echo " 2 - .tar.bz2 format ";			   	
}

#########################################
#        Function                       
#          to find                       
#         File link                     
#########################################

AskFilePath() {
	echo -e; 
	echo "file Path e.g. /srv/www/access.log or http://domain.com/access.log";
	echo -e;
	if [ $AnswerFilePlace == 1 ]
		then 
			echo "localhost file:";
		else
			echo "RemoteHost FileLink:";
	fi
}

########################################
#          Funtion                      
#        to set fileending             
########################################

SetFileEnding() {
	case $AnswerFileFormat in
		1)	
			echo "INFO: Setting Fileending .log ";
			TmpFileName="$TmpFileName.log";;
		2)	
			echo "INFO: Setting fileending .tar.bz2"
			TmpFileName="$TmpFileName.tar.bz2";;
	esac
}

########################################
#           funtion                    
#      to clearing tmp folder before   
#       getting new logfile            
########################################

ClearingTmpFolder() {
        echo "INFO: Clearing tmp folder in the scriptfolder.."
	echo "folder: "$TmpPath
        rm -Rf tmp/*

}

#######################################
#                 Funtion                
#         to get Remote               
#    Logfile to tmp folder            
#######################################

GetRemoteFile() {
        echo -e;
        echo -e "INFO: Downloading Remote Logfile. wait...";
        wget -O $TmpPath$TmpFileName $AnswerFilePath
        echo -e
        echo "SUCCESS: remote file downloaded to: $TmpPath$TmpFileName";	

}

#########################################
#	 function                       
#      to  check  the Remote file       
#		with wget               
#########################################

CheckRemoteFile() {
	CheckRemoteFileStatus=`wget --spider $AnswerFilePath 2>&1 | grep -c "awaiting response... 200 OK"`;
}

########################################
#	   function to                 
#        copy the locale log file      
#         to tmp folder                
########################################

GetLocalFile() {
	echo -e "INFO: Local File FOUND...";
        echo -e "INFO: Start to copy the logfile... ";
        cp -v $AnswerFilePath $TmpPath$TmpFileName              # copy logfile to protect the orginalfile
        echo "SUCCESS: copy DONE."

}

#########################################
#	 function                       
#	to decompress the               
#           bz2 file                    
######################################### 

bz2FileHandling(){
	echo -e
	echo "INFO: extracting bz2 file to .tar. wait ...";
	bunzip2 $TmpPath$TmpFileName;
	echo -e 
	echo "INFO: extracting tar file. wait...";
	tar xfv $TmpPath$TmpFileNameTar -C $TmpPath$TmpSubFolder

}

#########################################
#        function
#       to move localefile 
#          to tmp subfolder 
#########################################

LocalFileHandling() {
	echo "INFO: moving the locale File to tmp SubFolder";
	mv  -v $TmpPath$TmpFileName $TmpPath$TmpSubFolder/
}

#########################################
#	 function                       
# to create Subfolder in tmpfolder      
#  for extracting the .tar file         
#########################################

CreateSubFolderTmp() {
	echo -e 
	echo "INFO: Creating Subfolder for extrating file";
	echo "INFO: path-> "$TmpPath$TmpSubFolder;
	mkdir $TmpPath$TmpSubFolder
}

#########################################
#          function                       
#   to wait between the status messages 
#########################################

StartSleep() {
	sleep $DefaultSleepTime;
}

#########################################
#       funtion to 
#       Find PHP Interpreter
#########################################

FindPHPInterpreter() {
	PHPInterpreter=`whereis "php" | awk '{ print $2 }'`;
	if [ $PHPInterpreter != "" ]
		then
                        echo "INFO: PHP Interpreter found: "$PHPInterpreter;
                        PHPInterpreterStatus=1;
		else
                        echo "ERROR: PHP Interpreter not found";
                        PHPInterpreterStatus=0;			
	fi
}


#########################################
#      function to 
#   ask manually php interpreter path
#########################################

AskPHPInterpreter() {
	echo "Give the path to PHP Interpreter e.g. /opt/php/bin/php:";
}

#########################################
#      function to 
#   start PHP analyse Code 
# fetching the lines and replacing 
# the seperator \t with " " for friendly
# array  handling  the values 
#########################################

StartPHPAnalyse() {
	cat $TmpPath$TmpSubFolder/* | $PHPInterpreter -q $PHPScript
}

#########################################
#      function to
#   start get general informations 
#    analyse the  logfile
#########################################

GetGeneralInfo() {
	TotalLogFiles=`ls -1 $TmpPath$TmpSubFolder/ | wc -l`
	if [ $TotalLogFiles != 1 ]
		then
			TotalLogFileLines=`wc -l $TmpPath$TmpSubFolder/* | grep total | awk '{ print $1 }'`
		else
			TotalLogFileLines=`wc -l $TmpPath$TmpSubFolder/* | awk '{ print $1 }'`
	fi
	TotalErrors=`expand $TmpPath$TmpSubFolder/* | grep -c "ERROR"`
	TotalInfo=`expand $TmpPath$TmpSubFolder/* | grep -c "INFO"`
	TotalAnother=`expr $TotalErrors + $TotalInfo`;
	TotalAnother=`expr $TotalLogFileLines - $TotalAnother`;
}

#                                                #
############### END OF FUNCTIONS ################# 
#                                                #


##########################################
# Welcome Info
##########################################
GameDuellWelcome;

##########################################
# Ask  for local or remote               
##########################################
 
until [[ "$AnswerFilePlace" = "1" || "$AnswerFilePlace" = "2" ]]
do
	AskFilePlace;
	read AnswerFilePlace;
done

###########################################
# Ask for FileFormat                      
###########################################

until [[ "$AnswerFileFormat" = "1" || "$AnswerFileFormat" = "2" ]]
do
	AskFileFormat;
	read AnswerFileFormat;
done

############################################
#   setting file ending                    
############################################

SetFileEnding;

############################################
#      Handling the Inputs                 	                   
#   handling the source file               
############################################
 
until [[ "$FilePathStatus" ]]
do
	until [[ "$AnswerFilePath" ]]
	do				
		AskFilePath;		
		read AnswerFilePath;	
	done

	echo -e "INFO: Check if file exist:"  $AnswerFilePath;
	StartSleep;

	case $AnswerFilePlace in
	1)	
		if [ -f $AnswerFilePath ] 
			then
				ClearingTmpFolder;				
				GetLocalFile;
				FilePathStatus=1;
			else
				AnswerFilePath="";
				echo -e "ERROR: File does not exist";StartSleep; 
		fi ;;
	2)	
		CheckRemoteFile;
		case $CheckRemoteFileStatus in
		1)
			echo "INFO: remote file found";
			ClearingTmpFolder;StartSleep;
			GetRemoteFile;
			break;;
		0)
			echo "ERROR: remote file does NOT exist";StartSleep; 
			AnswerFilePath="";;
		esac	
	esac
done

########################################
# extrating the tar.bz2 > .tar > file  
########################################
CreateSubFolderTmp;
case $AnswerFileFormat in
	2)
		bz2FileHandling;;
	1)	
		LocalFileHandling;;
esac	
StartSleep;StartSleep;
clear; 
########################################
#    Start  Analyse Code 
########################################
echo -e
echo " ---------------------------------------------";
echo "|     Starting General analysing               |";
echo "|   Total lines, errors, info of LogFile(s)    |";
echo " ---------------------------------------------";
echo -e
echo "STATUS: get  informations. PLEASE WAIT...";
echo "INFO: source-> $TmpPath$TmpSubFolder/";
echo -e
GetGeneralInfo;
echo "GENERAL STATISTIK INFORMATIONs of LogFile(s) before starting  php  Analyser Code";
echo "---------------------------------------------------------------------------------";
echo -e
echo "Total of Logfiles        : " $TotalLogFiles;
echo "Total of Lines to analyse: " $TotalLogFileLines;
echo "Total of ERROR Lines     : " $TotalErrors;
echo "Total of INFO Lines      : " $TotalInfo;
echo "Total of Another Lines   : " $TotalAnother;
echo -e 
echo -e "please \033[32mENTER\033[0m to beginn detailed logical PHP Analysing process OR leave CTRL^C";
read WaitToEnter;


########################################
#    find the  PHP Interpreter
#    to start the PHP analyse Code
########################################


echo "INFO: searching PHP interpreter.. ";
FindPHPInterpreter;
if [ $PHPInterpreterStatus == 0 ]
        then
                until [[ "$PHPInterpreterFound" ]]
                do
                        AskPHPInterpreter;
                        read PHPInterpreter;
                        if [ -f $PHPInterpreter ]
                                then
                                        echo "INFO: PHP Interpreter found:" $PHPInterpreter;StartSleep;
                                        PHPInterpreterFound=1;
                                        break;
                                else
                                        echo "ERROR: PHP Interpreter not found: "$PHPInterpreter;
                        fi
                done
fi

########################################
#    Start the Log  analyser PHP Code
########################################
echo -e;
echo -e "\033[32mSTART:\033[0m Log Analyser PHP Code. PLEASE WAIT... ";
StartPHPAnalyse;
ClearingTmpFolder;
echo -e
echo -e "\033[41mFINISH\033[0m..";
echo -e
exit;
