# bUwUma
**Bu**ild **W**ebsites **U**sing **Ma**ke

## Overview
`bUwUma` is a build system that uses **GNU make** and a **preprocessor** written in python to build **static**, **multilingual** websites.

This readme only documents the preprocessor.
For more information and a quickstart guide on how to use `bUwUma`, please 
refer to the article [on my website](https://quintern.xyz/en/software/buwuma.html).

# HTML Preprocessor Documentation
## Markdown support
Using the `#include` command (see below) you can include markdown files, which will be automatically
converted to html using [mdtex2html](https://pypi.org/project/mdtex2html), which also supports converting LaTeX to MathML.
If mdtex2html is not installed `python-markdown` will be used instead.
Preprocessor commands in included markdown files will be handled as well.

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
Include the content of a file (or only a specific section in that file) at the position of the command.

**Synopsis**:
`<!-- #include path/to-a-text-file.html -->`
`<!-- #include path/to-a-text-file.html section_name -->`

**Argument**:
A absolute or relative path to a text file [ + section name ]

**Return Value**:
The content of the file or `<!-- Could not include '{args}' -->` empty string if the file can not be opened.

---

### section
Start a section in a file. The section is only used by the `include` command to determine the start and end of a section

**Synopsis**:
`<!-- #section section_name -->`

**Argument**:
Name of the section

**Return Value**:
Empty String

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

### unset 
Unset a variable

**Synopsis**:
Unset `varname`, it will no longer be defined and can therefor be set with `default` again.
`<!-- #unset varname -->`

**Argument**:
Name of the variable

**Return Value**:
Empty string

---

### comment
Comment the arguemnts.

**Synopsis**:
`<!-- #comment This will stay as comment in the html -->`

**Argument**:
Any string

**Return Value**:
The argument in comment tags


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
These commands can not be nested.
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
Group all following entries in named section. `section` may not appear in conditional blocks.

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

### sitemap
Used for automatically generating a `sitemap.xml` for the website.

#### `include`
Include the current page in the sitemap

**Synopsis**:
`<!-- #sitemap include -->`
`<!-- #sitemap include https://use.custom.link/for-this/site -->`

**Argument**:
Optional: Use a different link for this page

**Return Value**:
Empty string


#### `priority`
Set the `priority` field

**Synopsis**:
`<!-- #sitemap priority 0.8 -->`

**Argument**:
Float between 0.0 and 1.0

**Return Value**:
Empty string


#### `changefreq`
Set the `changefreq` field

**Synopsis**:
`<!-- #sitemap changefreq never -->`

**Argument**:
One of *always, hourly, daily, weekly, monthly, yearly, never*

**Return Value**:
Empty string


#### `lastmod`
Set the `lastmod` field

**Synopsis**:
`<!-- #sitemap lastmod 2023-12-29T14:00:05+01:00 -->`

**Argument**:
The lastmod date in w3c date format

**Return Value**:
Empty string

---


## Pitfalls
- The `include` command must not be in the last line of the file
- The maps in `set` must have **at least 2** options
- The `section` commands must not be in a conditional block
- The conditionals must not be neseted
- If you want to use variables in markdown, you have to escape the `#` with a backslash, so `#$(var)` becomes `\#$(var)`
- You can not use the `return` command from within the arguments of other commands. Commands are executed in order, so `return` will end up as argument of the first command and thus never be executed
