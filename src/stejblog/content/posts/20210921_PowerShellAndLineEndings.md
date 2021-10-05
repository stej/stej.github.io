---
title: "PowerShell and `r`n"
date: 2021-09-21T21:39:38+02:00
draft: true
---

In short:

- `CR` is the escape character `\r` (carriage return, `0x0D`, 13 in decimal)
- `LF` is the escape character `\n` (line feed, `0x0A`, 10 in decimal)

First let's make two files for testing. One file with `CRLF` and one with `LF`.

```PowerShell
mkdir c:\temp\ -EA SilentlyContinue
cd c:\temp
([byte[]][char[]]"some") + ([byte[]] (13,10)) + ([byte[]][char[]]"testing") | Set-Content fileCrLf.txt -asByte
([byte[]][char[]]"some") + [byte]10 + ([byte[]][char[]]"testing") | Set-Content fileLf.txt -asByte
```

Is there any difference when reading the file? No. PowerShell can read the files no matter the line endings.

```PowerShell
PS> $crlf = Get-Content fileCrLf.txt
PS> $lf = Get-Content fileLf.txt

PS> $hexCrLf = [Convert]::ToHexString(([byte[]] [char[]] ($crlf -join '|'))) 
PS> $hexLf = [Convert]::ToHexString(([byte[]] [char[]] ($lf -join '|')))
PS> $hexCrLf -eq $hexLf
# true
```

And what about reading raw? Of course the bytes are left as they are.

```PowerShell
PS> $crlf = Get-Content fileCrLf.txt -raw
PS> $lf = Get-Content fileLf.txt -raw

PS> $hexCrLf = [Convert]::ToHexString(([byte[]] [char[]] $crlf))
PS> $hexLf = [Convert]::ToHexString(([byte[]] [char[]] $lf))
PS> $hexCrLf -eq $hexLf
# false

PS> $hexCrLf
# 736F6D650D0A74657374696E67
#       --^^  extra chars here
PS> $hexLf
# 736F6D650A74657374696E67
```

## Special chars
First prepare some testing data:

```PowerShell
PS> [int[]][char[]]"`r`n"
# 13
# 10

PS> "some`ntesting" | Set-Content fileN.txt
PS> "some`r`ntesting" | Set-Content fileRN.txt
```

Now what is produced when a string is construected with some escape sequence?

```PowerShell
PS> Format-Hex fileN.txt
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65 0A 74 65 73 74 69 6E 67 0D 0A       some�testing��

PS> Format-Hex fileRN.txt
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65 0D 0A 74 65 73 74 69 6E 67 0D 0A    some��testing��
```

That means that if you make a content of the file manually, use ``"`r`n" ``. That's when speaking about Windows, because `Set-Content` uses `CRLF`. So - be nice and produce files with consistent line endings. 

If you need to know proper line endings no matter whether you are on Windows or Linux, just use `[Environment]::NewLine`
```PowerShell
# Linux:
PS> [int[]][char[]] [Environment]::NewLine
# 10

# Windows:
PS> [int[]][char[]] [Environment]::NewLine
# 13
# 10
```

### .NET `\n`

PowerShell runs on .NET, right. But that escape character `\n` doesn't work here. When coding in PowerShell, just replace that with backtick -- ` ``n``.

*Note: `.Split()` here is just a method on `String`

```PowerShell
PS> (Get-Content fileRN.txt -raw).Split("\r\n") | Format-Hex
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65 0D 0A 74 65 73 74 69 6E 67 0D 0A    some��testing��

PS> (Get-Content fileRN.txt -raw).Split("`r`n") | Format-Hex
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65                                     some
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 74 65 73 74 69 6E 67                            testing
```


## Regexes, yeeeeea 

*Operator `-split` uses regexes under the hood. Don't forget that.*

No magic here. Works as expected. That `` `n`` is just a one concrete char. That's it.

```PowerShell
PS> (Get-Content fileRN.txt -raw) -split "`r`n" | Format-Hex
#           Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65                                     some
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 74 65 73 74 69 6E 67                            testing

PS> (Get-Content fileRN.txt -raw) -split "`n" | Format-Hex
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65 0D                                  some�        # that `r is still there
#         Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 74 65 73 74 69 6E 67 0D                         testing�     # that `r is still there
```

The same applies for `\r\n` used as regex literals. They just work.

```PowerShell
PS> (Get-Content fileRN.txt -raw) -split "\r\n" | Format-Hex
#          Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65                                     some
#         Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 74 65 73 74 69 6E 67                            testing

PS> (Get-Content fileRN.txt -raw) -split "\n" | Format-Hex
#           Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 73 6F 6D 65 0D                                  some�         # that \r is still there
#         Offset Bytes                                           Ascii
#                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
#          ------ ----------------------------------------------- -----
#0000000000000000 74 65 73 74 69 6E 67 0D                         testing�      # that \r is still there
```

