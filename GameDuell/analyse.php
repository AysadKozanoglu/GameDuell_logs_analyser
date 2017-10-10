<?
############################################
#
#
#	PHP Logical Analytic Script v0.1
#		developed by
#
#	      Aysad Kozanoglu
#
#        email: aysadkozanoglu@gmail.com
#
#     license: GNU GENERAL PUBLIC LICENSE
# 
# license link:   
# http://www.gnu.org/licenses/old-licenses/gpl-1.0.txt
# 
# description:
# This script reads big Logfile from Unix 
# STDIN DATA STREAMS line by line and split it 
# in array given \t seperator
#
# The values in array are calculated immediately 
# and not buffered in Memory
# 
# So it can handle Big Logfiles (up to 1GB) and analyse
# the values.
#
# The script is  MEMORY FRIENDLY and can handle 
# big files
# 
# This script is automatically called by start.sh 
#
# so start ./start.sh from your command line
# and follow the steps 
# 
############################################


@ini_set("memory_limit",'64M');
error_reporting(E_ERROR | E_PARSE);
Class StreamLineHandleClass{

	VAR $LineSize;
	VAR $StreamHandle;
 	VAR $QueryStreamLine;
	VAR $SplitInArray;
	VAR $Results;
	VAR $CounterStatus;
	VAR $TotalDays;

	function __construct() {
		$this->LineSize 	= 65535;
		$this->StreamHandle	= fopen("php://stdin","r");
		$this->CounterStatus	= FALSE;	
	}

	function GetQueryStreamLine() {
		$this->QueryStreamLine 	= fgets($this->StreamHandle,$this->LineSize);
		return $this->QueryStreamLine;
	}

	function DoSplitInArray() {
		$aData 	= explode("\t",$this->QueryStreamLine);
		if (count($aData)>15)
			$this->SplitInArray 	= explode("\t",$this->QueryStreamLine);
		else
			$this->SplitInArray	= "NODATA";	
	}

	function __destruct() {
		fclose($this->StreamHandle);
		echo "INFO: destroying the ".get_class($this)."\n";
				
	}
}

Class LogFileAnalyseExtendClass extends StreamLineHandleClass {

	function __construct() {
		parent::__construct(); 
	}
	private function CutOnlyDate() {
		$NoData	= "NODATA";
		if ($this->SplitInArray!="NODATA")
			return substr(trim($this->SplitInArray[1]),0,8);
		else
			return $NoData;
	}	
        function CalcTotalResultsByDate() {
		$date	= $this->CutOnlyDate();
		if($date!="NODATA" && $this->SplitInArray!="NODATA"){
			if (ctype_digit(trim($this->SplitInArray[3])))
				$this->Results[$date]["TRPT"]	= $this->Results[$date]["TRPT"]+trim($this->SplitInArray[3]);
			if (ctype_digit(trim($this->SplitInArray[4])))
				$this->Results[$date]["PTRPT"]	= $this->Results[$date]["PTRPT"]+trim($this->SplitInArray[4]);
			if(ctype_digit(trim($this->SplitInArray[14])))
				$this->Results[$date]["BRT"]	= $this->Results[$date]["BRT"]+trim($this->SplitInArray[14]);
			if(ctype_digit(trim($this->SplitInArray[15])))
				$this->Results[$date]["SBRT"]	= $this->Results[$date]["SBRT"]+trim($this->SplitInArray[15]);
			if(ctype_digit(trim($this->SplitInArray[16])))
				$this->Results[$date]["PRTS"]	= $this->Results[$date]["PRTS"]+trim($this->SplitInArray[16]);
			if(ctype_digit(trim($this->SplitInArray[17])))
				$this->Results[$date]["SDBRT"]	= $this->Results[$date]["SDBRT"]+trim($this->SplitInArray[17]);
			if(ctype_digit(trim($this->SplitInArray[18])))
				$this->Results[$date]["SSDBRT"]	= $this->Results[$date]["SSDBRT"]+trim($this->SplitInArray[18]);
			if(ctype_digit(trim($this->SplitInArray[19])))
				$this->Results[$date]["PSDBRTS"]= $this->Results[$date]["PSDBRTS"]+trim($this->SplitInArray[19]);
			if(ctype_digit(trim($this->SplitInArray[20])))
				$this->Results[$date]["ADBRT"]	= $this->Results[$date]["ADBRT"]+trim($this->SplitInArray[20]);
			if(ctype_digit(trim($this->SplitInArray[21])))
				$this->Results[$date]["SADBRT"]	= $this->Results[$date]["SADBRT"]+trim($this->SplitInArray[21]);
			if(ctype_digit(trim($this->SplitInArray[22])))
				$this->Results[$date]["PARTS"]	= $this->Results[$date]["PARTS"]+trim($this->SplitInArray[22]);
			if(ctype_digit(trim($this->SplitInArray[23])))
				$this->Results[$date]["LDBRT"]	= $this->Results[$date]["LDBRT"]+trim($this->SplitInArray[23]);
			if(ctype_digit(trim($this->SplitInArray[24])))
				$this->Results[$date]["SMDR"]	= $this->Results[$date]["SMDR"]+trim($this->SplitInArray[24]);
			if(ctype_digit(trim($this->SplitInArray[25])))
				$this->Results[$date]["SODBRT"]	= $this->Results[$date]["SODBRT"]+trim($this->SplitInArray[25]);
		
			if (!$this->CounterStatus){
				$this->Results[$date]["date"]      = $date;
				$this->Results[$date]["counter"]   = 1;
                        	$this->Results[$date]["TRPT"]      = 0;
                        	$this->Results[$date]["PTRPT"]     = 0;
                        	$this->Results[$date]["BRT"]       = 0;
                        	$this->Results[$date]["SBRT"]      = 0;
                        	$this->Results[$date]["PRTS"]      = 0;
                        	$this->Results[$date]["SDBRT"]     = 0;
                        	$this->Results[$date]["SSDBRT"]    = 0;
                        	$this->Results[$date]["PSDBRTS"]   = 0;
                        	$this->Results[$date]["ADBRT"]     = 0;
                        	$this->Results[$date]["SADBRT"]    = 0;
                        	$this->Results[$date]["PARTS"]     = 0;
                        	$this->Results[$date]["LDBRT"]     = 0;
                        	$this->Results[$date]["SMDR"]      = 0;
                        	$this->Results[$date]["SODBRT"]    = 0;				
				$this->CounterStatus		   = TRUE;
			}else{
				$this->Results[$date]["date"]      = $date;
				$this->Results[$date]["counter"]++;
			}
		}
        }											

 	function GetTotalDays() {
		$this->TotalDays	= count ($this->Results);
	}
	function __destruct() {
		parent::__destruct();
	}

}



$oSTDIN	= new LogFileAnalyseExtendClass();
echo "\n\nProcess bar(|=|->25000lines) : |";
$i=0;
$ShowProcessBarEvery = 25000;
while ( $oSTDIN->GetQueryStreamLine() ) {
	$oSTDIN->DoSplitInArray();
        $oSTDIN->CalcTotalResultsByDate();
	if($i==$ShowProcessBarEvery){
		echo "=|";
		$i=0;
	}else
		$i++;
}
echo "-->100%";
echo "\n\n";
echo " -----------------------------------------------------\n";
echo "|AVERAGE per Day -  Request processing time in ms     |\n";
echo " -----------------------------------------------------\n";

$totalSecondOfDay	= 60*60*24; # 86400
$i = 1;
$AverageProcessTotal = 0;
$AverageRequestTotal = 0;
Foreach ($oSTDIN->Results  as $aKey){
	$AverageProcess  = $aKey[TRPT]/$aKey[counter];
	$AverageRequest	 = $aKey[counter]/$totalSecondOfDay;
	echo $i.". DAY(format:YMD): ".$aKey[date]."  |  ";
	echo "Average processTime: ".round($AverageProcess,2)." ms/Request  |  ";
	echo "Average Request: ".ceil($AverageRequest)." Request(s)/Second  |  ";
	echo "Total Requests of day: ".$aKey[counter]; 
	echo "\n";
	$AverageProcessTotal = $AverageProcessTotal+round($AverageProcess,3);
	$AverageRequestTotal = $AverageRequestTotal+ceil($AverageRequest);
	$i++;
}

echo "\n";

$oSTDIN->GetTotalDays();

echo "\n\nTotal Day(s): ".$oSTDIN->TotalDays."  |  ";
echo "Average ProcessTime of ".$oSTDIN->TotalDays." day(s): ".round($AverageProcessTotal/$oSTDIN->TotalDays,2)." ms/request  |  ";
echo "Average Request(s) of ".$oSTDIN->TotalDays." day(s): ".round($AverageRequestTotal/$oSTDIN->TotalDays,2)." Request(s)/second";
echo "\n----------------------------------------------------------------------------------------------------------------------------\n";
echo"\n\n";
echo "sequence to Cleaning Up:\n";

unset ( $oSTDIN );

die("END OF analytic\n\n");

?>
