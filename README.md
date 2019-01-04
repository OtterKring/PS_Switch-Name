<center><a href="https://otterkring.github.io/MainPage" style="font-size:75%;">return to MainPage</a></center>

# PS_Switch-Name
Reverse word order of names (or any space separated string)

Loosly based on my previously published [technique for splitting plain-text tables to columns](https://app.graphitedocs.com/shared/docs/otterkring.id.blockstack-1536042463922).

## Why ...

While the function is relatively small it evolved from a sudden need:

The usernames in the Active Directory I work with are saved like "lastname firstname". But whenever I get a list of users from some other department, I get it as plain text "firstname lastname" list with some request like "Please give group X access to these mailboxes."

Dang! While I didn't care when it was only like 4 names, recently it was a list of 12, and I just didn't want to type those names again. Of course, I did not have to completely reverse the name but also e.g. just take the last name and match it like:

`Get-Clipboard | ?{($_ -split ' +')[-1]} | %{ ... and use $_ in the filter }`

However, this doesn't only get you "John Smith", but "Elisabeth Smithers" and "Holger Smithansen", too. So matching the whole name narrows down my results a lot better.

## First approach: console one-liner

First let's get the data from the clipboard and immediately remove all empty lines because experience tells me, the clipboard always has at least one empty line at the end:

`Get-Clipboard | ?{$_}`

Now we can take each single string object, split it at the spaces (if there are more than one for what reason ever) and put firstname and lastname together again in reverse order:

`Get-Clipboard | ?{$_} | %{"$(($_ -split ' +')[-1]) $(($_ -split ' +')[0])"}`

The `-split` operator uses regular expressions, so I can use `' +'` as the expression, which means "one or more spaces". The result of the split operation is an array, of which `[-1]` is the last element and `[0]` is the first. The array extractions are enclosed in `$(...)` to treat them as variables we can join in a string.

Hurray! Our names are reversed.

## Making it a function

"Nice!" I thought. If it's that easy, why not make it a funcion? This might come in handy more often.

Ok, that means we need:
* pipeline support, because we cannot assume to always get our data from the clipboard
* error avoiding ... or error handling if you can't avoid them in advance
* performance, because you never know, how often your function will be used
* people might have more names than one, so we can't just use first- and lastname. We cannot predict how the names should be ordered, so just reverse the whole word order.

### Pipeline support

We only get pipeline support when using and advanced function, but we only need a small bit for our needs:

* The variable definition with pipeline support `[Parameter(ValueFromPipeline)]$Variable`
* a `process {...}` block to work through the piped items

### Error avoiding

Hands down: I HATE error handling! It requires additional unproductive code of which you do not really know what is happening in the background for events you do not know why they are happening. It is preparing for the unexpected, more work and reduces performance. So whenever I can, I try to avoid errors from happening instead of using error handling code like `try {} catch {}` or the like.

Fortunately in this case we can completely omit error handling and go for avoidance, because we do not access any other systems, use precoded cmdlets, etc.

First lets make sure we only get strings into our function. By predefining our parameter as `[string]` our function does that for us. It tries to make a string what is possible and breaks if it can't. Problem back at the user's hands:

    [Parameter(ValueFromPipeline)]
    [string]$Variable


We already ignored empty lines in our one-liner above. The `?{$_}` translates in the function to:

    if ($Variable -match '\w+ +\w+') {
        # do something
    }

However, while I only checked for empty lines bevor I now use a `-match` with the regular expression `'\w+ +\w+'`, which means "one or more non-digit character, followed by one or more spaces, again followed by one or more non-digit characters", which is a rough description of "at least two words". If anything not matching comes along, we skip it.

### Performance

The function is so short we actually do not really need to think about performance. However, I try to always do it. Just as a habit.

Our one-line above had one major performance issue whithin it simplicity: two split operations for something that could be done with only one. In the functionn we can save the result of the split operation in a variable, so only one is requires. Win! :-)

Now we have to glue all our words together in reverse order. A loop counting from the highest index of our array down to the first. I come from C, which is the primary reason why I use a for-loop instead of a `x..0 | foreach-object {}` pipe (and to avoid the pipe).

For adding up the words in reverse order I use the ability of loops to return all single outputs of each iteration in one array and then join them with a single join operation afterwards. This is significantly faster than adding every single substring to the final string during each operation.
_But again_: As long as you do not reverse half a book you propably will not notice it. But still ...

### This is it

The function is short, fast and can handle any space separated string you throw at it. No matter how many names a person has, no matter if a name is dash-separated (which will be treated as one word, because we only split at spaces), it should always reverse the word order.



I hope you can make some use from it. :-)
Happy coding!
Max