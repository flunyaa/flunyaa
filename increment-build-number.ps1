param(
    [string]$add = "build"
)

$content = Get-Content "pubspec.yaml"
# Get version of project
$version_regex = [regex] 'version: (?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\+(?<build>\d+)'
$version_match = $version_regex.Match($content)

$major = [int] $version_match.Groups['major'].Value
$minor = [int] $version_match.Groups['minor'].Value
$patch = [int] $version_match.Groups['patch'].Value
$build = [int] $version_match.Groups['build'].Value

Write-Output "旧版本：$major.$minor.$patch+$build"
$old_version = "version: $major.$minor.$patch+$build"

switch ($add) {
    "build" { $build++ }
    "patch" { $patch++; $build++ }
    "minor" { $minor++; $build++ }
    "major" { $major++; $build++ }
    Default { $build++ }
}

$new_version = "version: $major.$minor.$patch+$build"
Write-Output "新版本：$major.$minor.$patch+$build"

$new_content = $content -Replace [regex]::Escape($old_version), $new_version

Write-Output $new_content | Out-File "pubspec.yaml"
