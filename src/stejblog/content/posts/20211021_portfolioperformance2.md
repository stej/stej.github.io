---
title: "Computing portfolio performance again"
date: 2021-10-21T18:45:52+02:00
draft: false
description: Revisited previous post about computing performance...
---

Last time I posted some thoughts about how to compute your gains/loses. It worked well for some samples, but failed for others. Problems were caused in situations when there were some big gains.

Let's have a sample: 
```
#   12                                                               12 /------------------------------------------------------------
#                                                                      /     |                            |                         |\
#   10                    10      ------------------------------------/      |                            |                         | \ 
#                               /              |                             |                            |                         |  \
#   8           8 -------------/               |                             |                            |                    8    |   \ ----------------------                 
#               /                              |                             |                            |                         |                           |\               
#              /              |                |                             |                            |                         |                           | \              
#   5 --------/               |                |                             |                            |                         |                        5  |  \-----------
#             |               |                |                             |                            |                         |                           |              
#             |               |                |                             |                            |                         |                           |              
#             |               |                |                             |                            |                         |                           |              
# BUY in $    1k             1k               1k                            0k                            2k                       5k                          0k              
# SELL in $   0k             0k               0k                            2k                            0k                       0                           0k
# COINS       1k/5 =     200C + 1k/8C      325C + 1k/10 C            425C - 2k/12C =                258c + 2K/12 =           425C + 5k/12 =                    841C               
# I HAVE      = 200C        = 325C             = 425C                      = 258C                        425C                     841C                                    
# GAINS %
# (LOSES)   0        325*8(gained)/          425*10/3000*100-100   (2000+258*12)/3000*100-100   (2000+425*12)/5000*100-100 (2000+841*12)/10000*100-100     (2000+841*8)/10k*100-100
#                  2000(spent $)*100-100=     = 41.6%                    = 69.87%                 = 42%                       =20.9%                          =-12.7%
#                         30%                                                                                                                           
```

The idea behind the formula is: *take all earned money so far + current value of the coins I hold now and divide this sum by all the money I have spent so far*

The formula is simple:
```
( <count of coins I have>*<price per coin> 
  + <how much I earned from sold coins in $>
) / 
  <how much I spent for the coins so far in $>
```

So for example for the 4th trade the price is **12$**. I bougth coins for **3k$** so far (1k when the price was 5$, 1k at price 8$ and 1k at 10$). I sold coins for **2k$** so far (now at price 12$) - this is what I gained. 
So the formula is simply
```
    $ratio = (2000 (= money from "Sell" trades) + 425*12 (current price of the coins I hold)) / 5000 (= money from all "Buy" trades)
    $percentageGain = $ratio * 100 - 100
```

To get the percentages just `*100 - 100` to get proper numbers.
That's it. Simple.