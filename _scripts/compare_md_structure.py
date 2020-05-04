#!/usr/bin/python3
import argparse
import difflib
import io
import logging
import markdown
import os
import re
import sys

from collections import Counter
from lxml import etree

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(description='Analyze element hierarchy of md files')
parser.add_argument(
    '--langs', type=lambda s: s.split(','),
    help='If specified, only analyze md files for given languages.')
parser.add_argument(
    '--include-regex',
    dest='include_regex',
    help='If specified, only tag string representations that match this will be analyzed.')
parser.add_argument(
    '--exclude-regex',
    dest='exclude_regex', 
    help='If specificed, tag strings representations that do not match will be skipped.')
parser.add_argument(
    '--show-tag-summaries',
    action='store_true',
    dest='show_tag_summaries',
    help='If given, print summaries of tag names where differences were found.')
parser.add_argument(
    '--ignore-order',
    action='store_true',
    dest='ignore_order',
    help='If enabled, only compare the presence/absence of tags but ignore their relative order.')

parser.add_argument(
    '--hide-diffs',
    action='store_true',
    dest='hide_diffs',
    help='If specified, do not show diffs for each file.')
args = parser.parse_args()

md_files = []
for root, _, files in os.walk("."):
    md_files.extend(os.path.join(root, f) for f in files if f[-3:] == ".md")

# Construct [basename][language] --> element tree
base_lang_trees = {}
md_filenames = {} # [basename][language] --> filenames
for f in md_files:
    path, base = os.path.split(f)
    if '/build/' in path:
        continue
    lang_dirs = [x for x in path.split("/") if len(x) == 2]
    if not lang_dirs:
        continue
    lang = lang_dirs[-1]
    if lang != 'en' and args.langs and lang not in args.langs:
        continue
    with open(f, encoding='utf-8') as fd:
        try:
            tree = etree.HTML(markdown.markdown(fd.read()))
            base_lang_trees.setdefault(base, {})[lang] = tree
            md_filenames.setdefault(base, {})[lang] = f
        except etree.XMLSyntaxError:
            logger.warning(f'Failed to parse {f}')


def tag_sequences(tree):
    """Creates string representation of element tree tags.

    Document is traversed in the document order and each element
    is transformed into string representation:

    /path/to/tag#attr1=value1#attr2=value2#...

    Where /path/to/tag has html and body tags removed and
    whitelist/blacklist regexes are applied.

    Resulting list of tag strings is returned.
    """
    tags = []
    for el in tree.iterdescendants():
        fp = [x.tag for x in el.iterancestors()] + [el.tag]
        fp = [tag for tag in fp if tag not in ['html', 'body']]
        path = '/'.join(fp)
        attrs = '#'.join(f'{k}={v}' for k, v in sorted(el.items()) if k not in ['alt'])
        rep = f'/{path}#{attrs}'
        if not path:
            continue
        if args.include_regex and not re.search(args.include_regex, rep):
            continue
        if args.exclude_regex and re.search(args.exclude_regex, rep):
            continue
        tags.append(rep)
    return tags


# Per language counters
total_files = Counter()
equal_files = Counter()
tag_summaries = Counter()

for base, html_trees in base_lang_trees.items():
    if 'en' not in html_trees:
        logger.warning(f"Do not have source file for {base}")
        continue

    source_tags = tag_sequences(html_trees['en'])
    for lang, tree in html_trees.items():
        #for t in tag_sequences(tree):
        #    print(t)
        if lang == 'en':
            continue
        dest_tags = tag_sequences(tree)
        total_files.update([lang])
        if source_tags == dest_tags:
            equal_files.update([lang])
        else:
            sym_diff = set(source_tags).symmetric_difference(set(dest_tags))
            diff_tags = [x.split('#')[0].split('/')[-1] for x in sym_diff]
            tag_summaries.update(diff_tags)
            if args.hide_diffs:
                continue
            if args.ignore_order:
                source_tags = sorted(source_tags)
                dest_tags = sorted(dest_tags)

            diff = difflib.unified_diff(
                source_tags, dest_tags,
                fromfile=md_filenames[base]['en'],
                tofile=md_filenames[base][lang],
                lineterm='')
            diff = list(diff)[2:]  # Remove header
            diff = [x for x in diff if x[0] in '+-']   # Retain only differing lines
            diff.insert(0, f'=== {md_filenames[base][lang]} ===')  # Add custom header

            print("")
            print("\n".join(diff))

found_diffs = False
for lang in sorted(total_files):
    if total_files[lang] == equal_files[lang]:
        logger.info('[lang]: all {total_files[lang]} equal.')
        continue
    found_diffs = True
    print(
        f'[{lang}]: {equal_files[lang]}/{total_files[lang]} of analyzed pairs equal. '
        f'{total_files[lang] - equal_files[lang]} files differ. '
        f'({100.0 * equal_files[lang] / total_files[lang]:.2f}% equal)')

if args.show_tag_summaries:
    print('Frequency of tag discrepancies between english and translations.')
    for tag, cnt in tag_summaries.most_common():
        print(f'{cnt}\t{tag}')

if found_diffs:
    sys.exit(1)
