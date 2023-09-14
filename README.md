# bUwUma
**Bu**ild **W**ebsites **U**sing **Ma**ke

## Overview
`bUwUma` is a build system that uses **GNU make** and a **preprocessor** written in python to build **static**, **multilingual** websites.

This readme only documents the preprocessor.
For more information and a quickstart guide on how to use `bUwUma`, please 
refer to the article [on my website](https://quintern.xyz/en/software/buwuma.html).

# HTML Preprocessor Documentation
## Syntax
### Commands
- All commands must be located within a html comment that starts with `<!--` and ends with `-->`.
- Commands start with a `#` character, the command must follow the `#` immediately.
- Everything after the command until the end of the comment or a newline character are considered the argument of the command.

```html
<!-- #command everything here is an argument -->
<!--
    #command everything here is an argument
    #anothercommand more arguments
    While this is a comment right now, it will be UNCOMMENTED in the after the preprocessor finishes!
    #comment This will be a single line html comment after the preprocessor finishes.
-->
```

- All commands return a string, which can be empty.
- If a comment contains a command, the entire comment will replaced with the return value of the command.
- If there are multiple commands in a comment, it will be replaced by all the return values added together.

### Variables
- Variable names must only consist of these characters: `a-zA-Z0-9_`
- A variable with name `varname` can be used like this: `#$(varname)`
- A variable usage will be replaced by the value of the variable
- Any variable that has is not defined has empty string as value

### General
- Whitespaces around a token are ignored, so `<!--#include     dir/file-->` is the same as `<!-- #include dir/file -->`
- If a command-comment takes up a whole line, the whole line including the newline character is replaced.


## Commands
### include
Include the content of a file at the position of the command.

**Synopsis**:
`<!-- #include path/to-a-text-file.html -->`

**Argument**:
A absolute or relative path to a text file

**Return Value**:
The content of the file or `<!-- Could not include '{args}' -->` empty string if the file can not be opened.

---

### set 
Set the value of a variable

**Synopsis**:
Set the value of `varname` to `this is the value`:
`<!-- #set varname this is the value -->`

Set the value of `varname` depending on the value of `othervar`:
`<!-- #set varname othervar?{*:fallback,key1:val1,key2:val2...}>`

**Argument**:
The first word is the name of the variable, the rest is the value or a dictionary.

**Return Value**:
Empty string

You can make the value of `varname` dependant on the value of another variable `othervar` by using a dictionary-like syntax described above.
In this case, `varname` will take the first value from the dictionary that matches tha value of `othervar`. 
`*` always everything and can be used as fallback. General wildcards like `a*` to match everything that starts with a are not supported.
Instead of commas `,` you can also use semicolons `;` as separators, but this must be consistend within the map.

### return
Same as `set`, but it returns the value of the variable that is being set. This is meant to use with maps, when you need a variable from a map you can 'inline' it with `return`

### default
Same as `set`, but it sets the variable's value only if it has no value yet.

---

### comment
Comment the arguemnts.

**Synopsis**:
`<!-- #comment This will stay as comment in the html -->`

**Argument**:
Any string

**Return Value**:
The argument in comment tags

This can be useful in multi-line comments that contain other commands: In that case, the comment tags will be removed and each command replaced with
its return value, so if you want to just have commented text in there you can use `#comment` 

### uncomment
Uncomment the comment.

**Synopsis**:
`<!-- #uncomment This will not be commented -->`

**Argument**:
Any string

**Return Value**:
The argument

This can be useful when you want to look at the unprocessed html without variables or when your syntax highlighting gets confused by a variable.

---

### conditionals
To turn on or off entire blocks, `if`, `elif` can `else` be used.
These commands must not be in multi-line comments.
Logical and `&&` and logical or `||` can be used to chain conditions.
If a condition is true, the corresponding block is included while all other blocks are deleted.

**Synopsis**
```
<!-- #if #$(var) == value && #$(other_var) == other_value -->
...
<!-- #elif #$(var) == value || #$(other_var) != other_value -->
...
<!-- #else -->
...
<!-- #endif -->
```

**Argument** Condition for `if` and `elif`, ignored for `else` and `endif`
**Return Value** Empty String

---

### sidenav
Manage the generation of a content menu which contains links to all headings in your html that have an id. The menu is called sidenav here.
An entry is a html heading with a id: `<h1 id=myheading>This heading will be linked in the sidenav</h1>`

**Synopsis**:
`<!-- #sidenav sidenav-command arguments -->`
sidenav-command must be one of the following:

#### `include`
Include the generated sidenav at this position. This command will always be executed last, after the whole file has been parsed.

**Argument**:
Ignored

**Return Value**:
The generated sidenav

#### `section`
Group all following entries in named section.

**Argument**:
The name of the section

**Return Value**
Empty string

#### `name`
Use a custom name instead of the heading itself for the link to the next heading.

**Argument**:
The link-name of the next heading

**Return Value**:
Empty string

#### `custom`
Include a custom link in the sidenav.

**Synopsis**:
`<!-- #sidenav custom href="my-link" name="Go to my link!" -->`

**Argument**:
Must be `href="..." name="..."`. Either single `'` or double `"` quotes are required.

**Return Value**:
Empty string

---

## Pitfalls
- The `#include` command must not be in the last line of the file
- The `#include` command can not be in multi-line comment if the included file also contains comments
- `#if`, `#elif`, `#else` and `#endif` must not be in multi-line comments
- The maps in `set` must have **at least 2** options
- If you want to use variables in markdown, you have to escape the `#` with a backslash, so `#$(var)` becomes `\#$(var)`
- You can not use the `return` command from within the arguments of other commands. Commands are executed in order, so `return` will end up as argument of the first command and thus never be executed
