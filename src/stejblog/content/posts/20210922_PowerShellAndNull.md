---
title: PowerShell and some $null-s and emptiness
date: 2021-09-22T16:54:23+02:00
description: Dealing with nulls in PowerShell is quite tricky sometimes.
draft: false

---


Dealing with `$null`s in PowerShell is quite tricky sometimes. Or better - it was. Has that changed?

Let's create some a helper function first that can describe the passed object. Simple, but good enough for this blog post.

```
function dumpobj {
    param($obj)
    function dumpit {
        param($o, $indent)
        if ($null -eq $o) {
            Write-Host ("  " * $indent) 'null'
        } elseif ($o -is [array]) {
            Write-Host ("  " * $indent) 'Array: count=' $o.Count
            for ($i = 0; $i -lt $o.Count; $i++) {
                dumpit $o[$i] ($indent+1)
            }
        } elseif ($o -is [int] -or $o -is [int64] -or $o -is [uint] -or $o -is [uint64]) {
            Write-Host ("  " * $indent) "$($o.GetType().Name):" $o
        }
    }
    dumpit $obj 0
}
dumpobj 1           # Int32: 1
dumpobj 1,2         # Array: count= 2
                    #    Int32: 1
                    #    Int32: 2
dumpobj $null       # null
dumpobj 1,$null     # Array: count= 2
                    #    Int32: 1
                    #    null
dumpobj (,$null)    # Array: count= 1
                    #    null
```

If we don't return anything, we basically return `$null`. Not empty array, or some *default*. Just `$null`.

```
function returnIfBig { 
    param($num) 
    if ($num -ge 1000) { 
        $num
    }
}
$containsNothing = returnIfBig 10
$containsNumber = returnIfBig 1000

dumpobj $containsNothing   # null
dumpobj $containsNumber    # Int32: 1000
```

Note that it's pretty tricky when we try to return at least something! We return empty array, but ... nothing is returned in fact. Still `$null`.

```
function returnEmptyArray { @() }
$ea = returnEmptyArray
dumpobj $ea                 # null !
```

That's retarted behaviour, indeed. If we really want to return empty array, we have to wrap that like this:

```
function returnEmptyArray { ,@() }
$ea = returnEmptyArray
dumpobj $ea                 # Array: count= 0
```

This behaviour was pretty bad *in the past*. 

If you wanted to return something and then iterate via e.g. `ForEach-Object`. If you just 
stored the result in a variable and maybe later wanted to ensure that it's an array by wrapping in `@( ..... )`, you sometimes
got just an array that was equal to `@($null)`. And later If you iterated over that array, there was one iteration with value equal to `$null`. 
Not fun. 

So where we are now... ?

```
function returnEmptyArray { @() } 
$ea = returnEmptyArray                      # null
$big        = $ea | ? { $_ -gt 100 }        # null
$bigInArray = @($ea | ? { $_ -gt 100 })     # Array: count= 0
$bigWrapped = @($big)                       # Array: count= 0
$bigInArrayWrapped = @($bigInArray)         # Array: count= 0

$ea  | % { throw "I'm in" }                 # doesn't throw, that's OK
$big | % { throw "I'm in" }                 # doesn't throw, that's OK
$bigInArray | % { throw "I'm in" }          # doesn't throw, that's OK
$bigWrapped | % { throw "I'm in" }          # doesn't throw, that's OK
$bigInArrayWrapped | % { throw "I'm in" }   # doesn't throw, that's OK
```

It looks like the behaviour from the past is fixed already. Or maybe I don't remember the gotcha case anymore 😁

But still. PowerShell handles `$null`s with magic sometimes:

```
$ea = returnEmptyArray
$null -eq $ea                   # true

$arrayFromEA = @($ea)           # null
$arrayFromReallNull = @($null)  # Array: count= 1
                                #   null
```

Obviously if we make an array from variable that is equal to `$null`, `$null` is returned.
Also note that iterating over that is different:

```
$arrayFromEA | % { throw "I'm in" }         # doesn't throw, that's OK
$arrayFromReallNull | % { throw "I'm in" }  # DOES throw !
```