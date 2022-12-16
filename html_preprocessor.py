#!/bin/python3
import os
import re
from sys import argv
from collections.abc import Callable

"""
TODO:
- testing
- generate sidenav during parse_file for increased speed and to allow sidenav commands in multiline comments
- reintroduce the nav_selected class on nav feature
"""
"""
************************************************************ SETTINGS ************************************************************
"""
sidenav_format = """\
    <div class="sidenav">
    <ul>
        <li class="menudrop">&#9776;</li>
        #sidenav-content
    </ul>
    </div>
    """
sidenav_content_link = "<li class=\"sidenav_link\"><a href=\"#link\">#name</a></li>"
sidenav_content_section = "<li class=\"sidenav_section\">#name</li>"

exit_on_include_failure = False

"""
************************************************************ REGULAR EXPRESSIONS ************************************************************
"""
# SIDENAV
# heading with id
re_sidenav_heading = r"<h\d.*id=(?:\"|\')([a-zA-Z0-9_\-]+)(?:\"|\').*>(.+)</h\d>"
# custom entry
re_sidenav_custom = r"href=(?:\"|\')([^\"\' ]+)(?:\"|\') +name=(?:\"|\')(.+)(?:\"|\')"

# commas
re_set_map = r"([a-zA-Z0-9_]+) *\? *\{( *(?:[a-zA-Z0-9_*]+ *: *[^,]*, *)+[a-zA-Z0-9_*]+ *: *[^,]*) *,? *\}"
# semicolons
re_set_map_alt = r"([a-zA-Z0-9_]+) *\? *\{( *(?:[a-zA-Z0-9_*]+ *: *[^;]* *; *)+[a-zA-Z0-9_*]+ *: *[^;]*) *;? *\}"

""" #$(myvar) """
re_variable_use = r"#\$\(([a-zA-Z0-9_]+)\)"

""" only in comments """
re_preprocessor_command = r"#([a-zA-Z]+) *(.*) *"

COMMENT_BEGIN = "<!--"
COMMENT_END = "-->"


"""
************************************************************ GLOBALS ************************************************************
"""
glob_dependcies: list[str] = []

exit_codes = {
    "FileNotFound": 2,
    "MarkdownConversionError": 3,
}
error_levels = {
    "light": 0,
    "serious": 1,
    "critical": 2,
}
exit_on_error_level = error_levels["serious"]


"""
************************************************************ UTILITY ************************************************************
"""
DEBUG = False
def pdebug(*args, **keys):
    if DEBUG: print(*args, **keys)

TRACE = False
def ptrace(*args, **keys):
    if TRACE: print(*args, **keys)

def error(*args, level:int=exit_on_error_level, exit_code:int=1, **keys):
    if level >= exit_on_error_level:
        print(f"ERROR:", *args, **keys)
        exit(exit_code)
    else:
        print(f"WARNING:", *args, **keys)

def line_is_link_to_path(line, path):
    # check if the line is a link to html thats currently being processed
    match = re.search(r"<a href=(\"|\')(.+)(\"|\')>(.+)</a>", line)
    if match:
        # get filename
        match = re.match(r"[a-zA-Z0-9_\-]+\.html", match.groups()[1])
        if match and match.group() in path:
                return True
    return False

def pos2line(s: str, pos:int):
    return s[:pos].count('\n') + 1


def generate_dependecy_file(filename:str, deps:list[str]):
    line1 = f"{filename}:"
    s = ""
    for dep in deps:
        line1 += f" {dep}"
        s += f"{dep}:\n"
    return line1 #+ "\n" + s



"""
************************************************************ SIDENAV ************************************************************
"""
class Sidenav:
    LINK = 0
    SECTION = 1
    # 0: link, 1: section
    entries: list[tuple[int, str, str]] = []
    skip_next = False
    custom_name = None
    @staticmethod
    def addEntry(name: str, link: str):
        if Sidenav.skip_next:
            Sidenav.skip_next = None
            return
        if Sidenav.custom_name:
            name = Sidenav.custom_name
            Sidenav.custom_name = None
        Sidenav.entries.append((Sidenav.LINK, name, link))
    @staticmethod
    def addSection(name):
        Sidenav.entries.append((Sidenav.SECTION, name, ""))
    @staticmethod
    def setCustomName(name: str):
        Sidenav.custom_name = name
    @staticmethod
    def skipNext():
        Sidenav.skip_next = True
    @staticmethod
    def generate() -> str:
        pdebug(f"Sidenav.generate(): found the following entries: {Sidenav.entries}")
        sidenav:list[str] = sidenav_format.split('\n')
        content_i = -1
        for i in range(len(sidenav)):  # find in which line the entries need to be placed
            if "#sidenav-content" in sidenav[i]:
                content_i = i
                break
        if content_i >= 0:
            sidenav.pop(content_i)
            added_links = []
            for i in reversed(range(len(Sidenav.entries))):
                entry = Sidenav.entries[i]
                if entry[0] == Sidenav.LINK:
                    if entry[2] in added_links: continue  # no duplicates
                    added_links.append(entry[2])
                    sidenav.insert(content_i, sidenav_content_link.replace("#name", entry[1]).replace("#link", entry[2]))
                else:
                    sidenav.insert(content_i, sidenav_content_section.replace("#name", entry[1]))
        sidenav_s = ""
        for line in sidenav: sidenav_s += line + "\n"  # cant use "".join because of newlines
        return sidenav_s
    @staticmethod
    def cmd_sidenav(args:str, variables:dict[str,str]) -> str:
        space = args.find(" ")
        if space < 0:
            space = len(args)
        cmd = args[:space]
        cmd_args = ""
        if 0 < space and space < len(args) - 1:
            cmd_args = args[space+1:].strip(" ")
        if cmd == "skip":
            Sidenav.skipNext()
        elif cmd == "section":
            Sidenav.addSection(cmd_args)
        elif cmd == "name":
            Sidenav.setCustomName(cmd_args)
        elif cmd == "custom":
            match = re.fullmatch(re_sidenav_custom, cmd_args)
            if match:
                Sidenav.addEntry(match.groups()[1], match.groups()[0])
            else:
                error(f"cmd_sidenav: Invalid argument for command 'custom': '{cmd_args}'", level=error_levels["light"])
        elif cmd == "include":
            return Sidenav.generate()
        else:
            error(f"cmd_sidenav: Invalid command: '{cmd}'", level=error_levels["light"])

        return ""


"""
************************************************************ COMMANDS ************************************************************
All these commands take one arg with trimmed whitespaces.
The arg may be anything

They all need to return a string, which will be placed
into the source file at the place where the command was.
"""
def cmd_include(args: str, variables:dict[str, str]={}) -> str:
    pdebug(f"cmd_include: args='{args}', variables='{variables}'")
    content = ""
    try:
        with open(args) as file:
            content = file.read()
    except:
        error(f"cmd_include: Could not open file '{args}'", level=error_levels["serious"], exit_code=exit_codes["FileNotFound"])
        content = f"<!-- Could not include '{args}' -->"
    if args.endswith(".md"):
        try:
            from markdown import markdown
            content = markdown(content, output_format="xhtml")
        except:
            error(f"cmd_include: Could convert markdown to html for file '{args}'. Is python-markdown installed?", level=error_levels["critical"], exit_code=exit_codes["MarkdownConversionError"])
            content = f"<!-- Could not convert to html: '{args}' -->"
    glob_dependcies.append(args)
    return content

def cmd_set(args: str, variables:dict[str, str]={}) -> str:
    # re_set_map = r"([a-zA-Z0-9_]+)\?\{(([a-zA-Z0-9_]+:.+,)*([a-zA-Z0-9_]+:.+))\}"
    # <!-- #set section=lang?{*:Fallback,de:Abschnitt,en:Section} -->
    space = args.find(' ')
    # pdebug(f"cmd_set: varname='{args[:space]}, 'arg='{args[space+1:]}', variables='{variables}'")
    if not (space > 0 and space < len(args)-1):
        variables[args] = ""
        pdebug(f"cmd_set: Setting to emptry string: {args}")
    else:
        varname = args[:space]
        variables[varname] = ""
        # check if map assignment with either , or ;
        separator = ','
        match = re.fullmatch(re_set_map, args[space+1:].strip(' '))
        if not match:
            match = re.fullmatch(re_set_map_alt, args[space+1:].strip(' '))
            separator = ';'
        if match:
            pdebug(f"cmd_set: Map {match.group()}")
            depends = match.groups()[0]
            if not depends in variables:
                pdebug(f"cmd_set: Setting from map, but depends='{depends}' is not in variables")
                return ""
            depends_val = variables[depends]
            for option in match.groups()[1].split(separator):
                option = option.strip(" ")
                pdebug(f"cmd_set: Found option {option}")
                colon = option.find(':')  # we will find one, regex guarantees
                if option[:colon].strip(" ") == depends_val or option[:colon].strip(" ") == "*":
                    variables[varname] = option[colon+1:].strip(" ")

        else:  # simple asignment
            value = args[space+1:]
            variables[varname] = value.strip(" ")
            pdebug(f"cmd_set: Assignment {varname} -> {value.strip(' ')}")
    return ""

def cmd_default(args: str, variables:dict[str, str]={}) -> str:
    separator = args.find(' ')
    if args[:separator] not in variables:
        return cmd_set(args, variables)
    return ""


def cmd_comment(args: str, variables:dict[str, str]={}) -> str:
    return f"<!-- {args} -->"
def cmd_uncomment(args: str, variables:dict[str, str]={}) -> str:
    return args


command2function:dict[str, Callable[[str, dict[str,str]], str]] = {
    "include":      cmd_include,
    "set":          cmd_set,
    "default":      cmd_default,
    "comment":      cmd_comment,
    "uncomment":    cmd_uncomment,
    "sidenav":      Sidenav.cmd_sidenav
}

"""
************************************************************ PARSING ************************************************************
"""
def parse_file(file:str, variables:dict[str,str]):
    sidenav_include_pos = -1
    comment_begin = -1
    remove_comment = False
    i = 0
    # if file.count(COMMENT_BEGIN) != file.count(COMMENT_END):

    while i < len(file):  # at start of new line or end of comment
        # replace variable usages in the current line
        line_end = file.find('\n', i)
        if line_end < 0: line_end = len(file)
        file = file[:i] + replace_variables(file[i:line_end], variables) + file[line_end:]
        line_end = file.find('\n', i)
        if line_end < 0: line_end = len(file)
        ptrace("Line after replacing variables:", file[i:line_end])

        # check if heading for sidenav in line
        match = re.search(re_sidenav_heading, file[i:line_end])
        if match:
            Sidenav.addEntry(match.groups()[1], f"#{match.groups()[0]}")
            ptrace("> Found heading with id:", match.groups())

        if comment_begin < 0:  # if not in comment, find next comment
            comment_begin = file.find(COMMENT_BEGIN, i, line_end)
            # ptrace(f"i={i}, line_end={line_end}, comment_begin={comment_begin}")
            if comment_begin < 0:
                i = line_end + 1
                continue
            else:
                # jump to comment_begin
                old_i = i
                i = comment_begin + len(COMMENT_BEGIN)  # after comment begin
                ptrace(f"> Found comment begin, jumping from pos {old_i} to {i}")

        # if here, i at the character after COMMENT_BEGIN
        # sanity check
        tmp_next_begin = file.find(COMMENT_BEGIN, i)
        if 0 < tmp_next_begin and  tmp_next_begin < file.find(COMMENT_END, i):
            error(f"Found next comment begin before the comment starting in line {pos2line(file, comment_begin)} is ended! Skipping comment. Comment without proper closing tags: '{file[i:line_end]}'", level=error_levels["light"])
            comment_begin = -1
            continue
        # either at newline (if in multiline comment) or at comment end
        possible_command_end = line_end
        comment_end = file.find(COMMENT_END, i, line_end)
        # ptrace(f"i={i}, line_end={line_end}, comment_begin={comment_begin}, comment_end={comment_end}, line={file[i:line_end]}")
        if comment_end > 0: possible_command_end = comment_end
        assert(possible_command_end >= i)

        ptrace(f"> Possible command end: {possible_command_end}, possible command: {file[i:possible_command_end]}")
        # find commands
        # pdebug(">>> Line ", file[i:possible_command_end])
        match = re.fullmatch(re_preprocessor_command, file[i:possible_command_end].strip(" "))
        if match:  # command comment
            remove_comment = True
            command = match.groups()[0]
            args = match.groups()[1].replace('\t', ' ').strip(' ')
            ptrace(f"> Found command '{command}' with args '{args}'")
            if command == "sidenav" and args == "include":  # if args contains anything else this wont work
                sidenav_include_pos = comment_begin  # remove the comment 
                insert_str = ""
            elif command not in command2function:
                error(f"Invalid command in line {pos2line(file, i)}: {command}", level=error_levels["light"])
                insert_str = ""
            else:
                insert_str = command2function[command](args, variables)
            file = file[:i] + insert_str + file[possible_command_end:]
            # replaced string of length possible_command_end - i with one of length insert_str
            index_correction = -(possible_command_end - i) + len(insert_str)
            possible_command_end += index_correction
            line_end += index_correction
            comment_end += index_correction
            ptrace(f"> After command, the line is now '{file[i:possible_command_end]}'")
            # i += len(insert_str)

        # remove comment if done
        if possible_command_end == comment_end:
            remove_newline = 0
            if file[comment_begin-1] == '\n' and file[comment_end+len(COMMENT_END)] == '\n':  # if the comment consumes the whole file, remove the entire line
                remove_newline = 1

            if remove_comment:
                # remove the comment tags, basically uncomment the comment
                # pdebug(f"Removing comment tags from pos {comment_begin} to {comment_end}")
                file = file[:comment_begin] + file[comment_begin+len(COMMENT_BEGIN):comment_end] + file[comment_end+len(COMMENT_END)+remove_newline:]
                possible_command_end -= len(COMMENT_BEGIN)
                i -= len(COMMENT_BEGIN)
            remove_comment = False
            comment_begin = -1
        else:  # multiline comment
            i = line_end + 1
            ptrace(f"Multiline comment, jumping to next line. char[i]='{file[i]}'")
        # i = possible_command_end commented, because if something containing new commands is inserted we need to parse that as well
    if sidenav_include_pos >= 0:
        file = file[:sidenav_include_pos] + Sidenav.generate() + file[sidenav_include_pos:]
    return file


def replace_variables(html:str, variables:dict[str, str]):
    """
    find usage of variables and replace them with their value
    """
    matches = []
    for match in re.finditer(re_variable_use, html):
        matches.append(match)
    html_list = list(html)
    for match in reversed(matches):
        pdebug(f"Found variable usage {match.groups()[0]}, match from {match.start()} to {match.end()}")
        value = ""
        if match.groups()[0] in variables: value = variables[match.groups()[0]]
        for _ in range(match.start(), match.end()):
            html_list.pop(match.start())
        html_list.insert(match.start(), value.strip(" "))
    return ''.join(html_list)

"""
************************************************************ COMMAND LINE ************************************************************
"""
def missing_arg_val(arg):
    print("Missing argument for", arg)
    exit(1)

def missing_arg(arg):
    print("Missing ", arg)
    exit(1)

def help():
    helpstring = """Synopsis:
    Inject <inject-file> into <target-file>:
        python3 html-inect.py --target <target-file> --output <output-file> [OPTIONS]
    \nCommand line options:
    --target <file>             path to the target file
    --output <file>             output to this file instead of overwriting target
    --inplace                   edit target file in place
    --var <varname>=<value>     set the value of a variable. Can be used multiple times
    --output-deps <file>        output a Makefile listing all dependencies
    --help                      show this
    --exit-on <errorlevel>      where errorlevel is 'light', 'serious' or 'critical'
    """
    print(helpstring)

if __name__ == "__main__":
    variables:dict[str, str] = {}
    # parse args
    target_path = ""
    output_path = ""
    dep_output_path = ""
    gen_sidenav = False
    inplace = False
    i = 1
    while i in range(1, len(argv)):
        if argv[i] == "--target":
            if len(argv) > i + 1: target_path = argv[i+1].strip(" ")
            else: missing_arg_val(argv[i])
            i += 1
        elif argv[i] == "--output":
            if len(argv) > i + 1: output_path = argv[i+1].strip(" ")
            else: missing_arg_val(argv[i])
            i += 1
        elif argv[i] == "--output-deps":
            if len(argv) > i + 1: dep_output_path = argv[i+1].strip(" ")
            else: missing_arg_val(argv[i])
            i += 1
        elif argv[i] == "--exit-on":
            if argv[i+1].strip(" ") in error_levels.keys():
                if len(argv) > i + 1: exit_on_error_level = error_levels[argv[i+1].strip(" ")]
                else: missing_arg_val(argv[i])
            else:
                error(f"Invalid argument for --exit-on: {argv[i+1]}. Valid are {error_levels.keys()}")
            i += 1
        elif argv[i] == "--var":
            if len(argv) > i + 1:
                sep = argv[i+1].find('=')
                if sep > 0 and sep < len(argv[i+1]):
                    variables[argv[i+1][:sep].strip(" ")] = argv[i+1][sep+1:].strip(" ")
            else: missing_arg_val(argv[i])
            i += 1
        elif argv[i] == "--inplace":
            inplace = True
        elif argv[i] == "--help":
            help()
            exit(0)
        else:
            error(f"Invalid argument: {argv[i]}")
        i += 1
    # sanity checks
    if not target_path: missing_arg("--target")
    if not os.path.isfile(target_path): error(f"Invalid target: {target_path} (does not exist)")
    if inplace: output_path = target_path
    if not output_path:
        print("Missing output path, just printing to stdout. Use --output or --inplace to save the result.")

    # get html
    with open(target_path, "r") as file:
        target_html = file.read()


    output_html = parse_file(target_html, variables)

    # pdebug(f"Output: {output_html}")

    # save
    if output_path:
        with open(output_path, "w") as file:
            file.write(output_html)
    else:
        print(output_html)

    if dep_output_path:
        if output_path != target_path:
            glob_dependcies.append(target_path)
        depfile = generate_dependecy_file(output_path, glob_dependcies)
        pdebug(f"Writing dependency file to {os.path.abspath(dep_output_path)}: {depfile}")
        with open(dep_output_path, "w") as file:
            file.write(depfile)
