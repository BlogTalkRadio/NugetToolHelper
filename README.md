NugetToolHelper
===============

Simplifies using tools in other nuget packages.

This package adds a powershell script to projects that can be used to find and invoke tools in other nuget packages.

Usage
--------

``` powershell
.\NugetTool.ps1 run <packageName> <toolName> <parameters>
``` 

- ```packageName``` the name of the nuget package (folder inside /packages)
- ```toolName``` the name (without extension) of a .exe or .ps file inside the package /tools, if it matchs the package name you can use ```_```
- ```parameters``` all remaining command line parameters will be forwared to the invoked tool

Here's an example invoking [CFT](https://github.com/blogtalkradio/cft)

```
.\NugetTool.ps1 run cft _ /configurationFile=environment_name.tmp /configurationEnv=ENVIRONMENT_NAME /configurationDefault=Local
```
