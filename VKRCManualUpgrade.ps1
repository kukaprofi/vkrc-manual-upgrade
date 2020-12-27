# set this variable to the absolute KUKA.WorkVisual for VSS v.6.0 path
$WorkVisualPath = "C:\Program Files (x86)\KUKA\WorkVisual 6.0"

$SRCFilePath = $args[0]
if ( ![System.IO.File]::Exists($SRCFilePath) ) {
  Write-Host "File" $SRCFilePath "NOT exists"
  exit 1
}

try {
  [Reflection.Assembly]::LoadFile($WorkVisualPath + "\KukaRoboter.Common.XmlResources.dll")
  [Reflection.Assembly]::LoadFile($WorkVisualPath + "\KukaRoboter.Common.XmlResources.XmlSerializers.dll")
  [Reflection.Assembly]::LoadFile($WorkVisualPath + "\KukaRoboter.LegacyKrcServiceLib.dll")
  [Reflection.Assembly]::LoadFile($WorkVisualPath + "\VWParser.dll")
  [Reflection.Assembly]::LoadFile($WorkVisualPath + "\VWCodeGenerator.dll")
  
  $instance = new-object KUKARoboter.VWCodeGenerator.VWKrlGenerator
  $moduleName = (Get-Item $SRCFilePath).Basename

  $srcFileStreamInPath  = $SRCFilePath
  $srcFileStreamOutPath = (Get-Item $SRCFilePath).DirectoryName + "\@" + $moduleName + ".src"

  $srcFileStreamIn  = new-object System.IO.FileStream($srcFileStreamInPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read )
  $srcFileStreamOut = new-object System.IO.FileStream($srcFileStreamOutPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write )
  
  if ( $moduleName -match "(FOLGE|UP)\d+" ) {
    $datFileStreamInPath  = (Get-Item $SRCFilePath).DirectoryName + "\" + $moduleName + ".dat"    
    $datFileStreamOutPath = (Get-Item $SRCFilePath).DirectoryName + "\@" + $moduleName + ".dat"

    $datFileStreamIn  = new-object System.IO.FileStream($datFileStreamInPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read )
    $datFileStreamOut = new-object System.IO.FileStream($datFileStreamOutPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write )

    $instance.GenerateCode( $moduleName, $srcFileStreamIn, $datFileStreamIn, $srcFileStreamOut, $datFileStreamOut )
  
    $datFileStreamIn.close()
    $datFileStreamOut.close()

    Move-Item $datFileStreamOutPath $datFileStreamInPath -force

  } else {
    $instance.GenerateCode( $moduleName, $srcFileStreamIn, $srcFileStreamOut )
  }

  $srcFileStreamIn.close()
  $srcFileStreamOut.close()
  
  Move-Item $srcFileStreamOutPath $srcFileStreamInPath -force
  
} catch {
  exit 2
}

Write-Host "Finished"
exit 0
