# 接收参数
param(
    [string]$add = "build"
)

# 从 pubspec.yaml 中读取版本号
$content = Get-Content "pubspec.yaml"
$version_regex = [regex] 'version: (?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\+(?<build>\d+)'
$version_match = $version_regex.Match($content)

# 拆分版本号
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

# 组合新版本号
$new_version = "version: $major.$minor.$patch+$build"
Write-Output "新版本：$major.$minor.$patch+$build"

# 替换 pubspec.yaml 中的版本号
$new_content = $content -Replace [regex]::Escape($old_version), $new_version
Write-Output $new_content | Out-File "pubspec.yaml"

# 生成具有项目名称和版本号字段的 package.json
$package_json = @"
{
    "name": "Flunyaa",
    "version": "$major.$minor.$patch+$build"
}
"@.Trim()

# 写入 package.json
Write-Output $package_json | Out-File "package.json"

# 使用 conventional-changelog 生成 changelog
npx conventional-changelog-cli -o "changelog/v$major.$minor.$patch+$build.md"

# 删除 package.json
Remove-Item "package.json"

# 提交修改
git add .

# 提交信息
$commit_message = "chore: 更改构建版本至 $major.$minor.$patch+$build"
git commit -m $commit_message

# 推送到远程仓库
git push
