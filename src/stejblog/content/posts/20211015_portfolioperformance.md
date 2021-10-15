---
title: "Naive thoughts about computing portfolio performance"
date: 2021-10-15T20:30:31+02:00
draft: false
description: How to check whether I'm in red or green numbers?
---

This was a question that I wanted to post on reddit. However, I didn't have enough reputation, so the post was deleted. So I'll repost here...

*Background - I have some coins in my portfolio. I bought some, I sold some and now I don't know whether my decisions were good or bad. Or whatever. What is my percentage gain?*

Let's say you have a coin XYZ. You buy and sell regularly and you would like to know whether you have gained something or lost (in percentage). How would you count that?

My calculations look pretty simple. Let's say I have a table (hour by hour) with my trades (buy/sell) and the price of XYZ coin. Simple sample:

![Simple sample](/images/20211015_simple1.png)

Row 1: I buy at 00:00:00 **100** coins, the coin price is **10**, total spent is **1000$** and percentage gain **0** (I just bought that).

Row 2: Hour later the price is **12**. I have spent still **1000$** so far and I still have **100** XYZ coins. If I would buy now, when the price is **12** instead of when the price was **10**, I would get **83.3** coins.
But I have **100** coins, not **83.3**, so I'm fine. I'm in green numbers obviously. My percentage gain is **20%** (computed like 100/83.3*100 - 100).

Row 3: the same.

Row 4: the same principle. I spent another **1000$**. Now I have 100+1000/15 = **166.6** XYZ coins. But if I would spend all the money now (all money is **2000$**), I would get 2000/15=**133.3** XYZ coins. But I have **166.6**. So my gain in % is 166.6/133.3*100 - 100 = **24.9%**.

So I bought at rows 1, 4, 15, for prices **10**, **15**, **15**.

The principle is clear and works also when I'm in red numbers (see row 17, the price dropped to **10**). I would get **300** XYZ coins for all the money spent so far (**3000$**), but I have only **233.2** XYZ coins. That means I lost 233.2/300*100 - 100 = **-22%**.

That would work fine if I don't sell anything.

------

Now let's suppose you are pretty good and you buy low and sell high.

Something like this:

![Simple sample](/images/20211015_simple2.png)

You buy **100** XYZ coins for 1000$**. Then wait and hodl.

At row 11 you decide to sell the XYZ coins for **2000$**. That means that you got **2000$**, but you have still **20** XYZ coins in your wallet.

Now the math is screwed up. You see that your gain at row 11 is **-150%**, which is nonsense. You are not in red numbers. In fact, you are totally green. You gained a lot of money and you still have some XYZ coins in your pocket.
How would you express that so that the numbers are comparable?

I have some coins where I buy/sell often, and some which I basically only hodl and I would like to compare the performance.

-- thanks, if you got here. I know this is long post ;)


(btw. I use Julia for the computations, it's a lot of fun)