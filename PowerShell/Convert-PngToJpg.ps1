Param(
	[String]$SourceFile
  , [String]$DestinationFile
)
Add-Type -AssemblyName System.Drawing
$Image = [Drawing.Image]::FromFile($SourceFile)
$Image.Save($DestinationFile, [System.Drawing.Imaging.ImageFormat]::Jpeg)
