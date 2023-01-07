#!/usr/bin/env python3

import platform
import re, json, codecs, collections.abc, argparse


fgbg_function_regex = re.compile(r'([fb]g)\((.+)\)')

template = ''
variables = {'options': {}}

current_platform = platform.system()
generator_constants = {
    'IS_MACOS': current_platform == 'Darwin',
    'IS_LINUX': current_platform == 'Linux'
}

# Gets a keyword by dot notation (and prepares it if it's a color)
def parse_keyword(obj, ref):
    val = obj
    for key in ref.split('.'):
        try:
            val = val[key]
        except KeyError:
            return None

    if key[-3:] == '_fg':
        return f'\[\e[38;5;{val}m\]'
    elif key[-3:] == '_bg':
        return f'\[\e[48;5;{val}m\]'
    else:
        return val

def change_fgbg(color, target_ground):
    if target_ground == 'bg':
        target_ground = '48'
    else: # fg
        target_ground = '38'

    return re.sub(r'(?<=\\e\[)[34]8(?=;)', target_ground, color)

# Matches:
# {{ variable.in.json }}
def process_variable_match(match):
    keyword = match.group(1)

    needs_inverting = re.match(fgbg_function_regex, keyword)
    if needs_inverting:
        keyword = needs_inverting.group(2)

    replacement = parse_keyword(variables, keyword)
    if replacement:
        if needs_inverting:
            return change_fgbg(replacement, needs_inverting.group(1))
        else:
            return replacement
    elif replacement is None:
        print('WARNING: Keyword <' + keyword + '> not found')
        return ''

# Matches:
# {~ option ~} thing to be toggled {~ /option ~}
def process_option_match(match):
    negate = match.group(1) == '!'
    if parse_keyword(variables['options'], match.group(2)) == 'yes' or parse_keyword(generator_constants, match.group(2)):
        if not negate:
            return match.group(3)
    else:
        if negate:
            return match.group(3)

    return ''

# https://stackoverflow.com/a/3233356/854076
def update_style(d, u):
    for k, v in u.items():
        if isinstance(v, collections.abc.Mapping):
            r = update_style(d.get(k, {}), v)
            d[k] = r
        else:
            d[k] = u[k]
    return d

def main():
    global variables

    args_parser = argparse.ArgumentParser(description='Parses a Bash prompt from a template using variables')
    args_parser.add_argument('--template', '-t', nargs='?', default='fancy', help='Template name')
    args_parser.add_argument('--palette', '-p', nargs='?', default='base16-bespin.dark', help='Color palette to use')
    args_parser.add_argument('--style', '-s', nargs='?', default='default', help='Variation of the default style')
    args_parser.add_argument('--hostname', '-w', nargs='?', default='', help='Override hostname with given value')
    args = args_parser.parse_args()

    template_path = 'templates/' + args.template + '/' + args.template + '.template'
    try:
        template = open(template_path, 'r').read()
    except IOError:
        print ('Template <' + args.template + '> not found')
        exit(1)

    variables_path = 'templates/' + args.template + '/styles/' + 'default.json'
    variables = json.loads(open(variables_path, 'r').read())

    # Alt style besides 'default'
    if args.style != 'default':
        style_path = 'templates/' + args.template + '/styles/' + args.style + '.json'
        try:
            style = json.loads(open(style_path, 'r').read())
        except IOError:
            print ('Style <'+ args.style + '> not found')
            exit(1)
        # Applies style on top of defaults
        update_style(variables, style)

    # Override hostname if defined
    if len(args.hostname) > 0:
        variables['strings']['hostname'] = args.hostname

    if len(args.palette) > 0:
        variables['strings']['palette'] = args.palette

    result = re.sub(r"\{\{\s?(.+?)\s?\}\}", process_variable_match, template)
    result = re.sub(r"\{~\s?(!)?(.+?)\s?~\}(.*?)\{~\s?/\1?\2\s?~\}", process_option_match, result, flags=re.DOTALL)

    # ToDo: Allow custom filenames, what was I thinking here?
    the_output = codecs.open('bash_prompt', 'w', encoding='utf8')
    the_output.write(result)

main()
