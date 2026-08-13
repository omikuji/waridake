# -*- coding: utf-8 -*-
"""Prepends the same language navigation line to every README."""
import io, os, re

ROOT = '/Users/omikuji/dev/omikuji/waridake'
NAMES = [
    ('en', 'English'), ('ar', 'العربية'), ('cs', 'Čeština'), ('da', 'Dansk'),
    ('de', 'Deutsch'), ('es', 'Español'), ('fi', 'Suomi'), ('fr', 'Français'),
    ('he', 'עברית'), ('hi', 'हिन्दी'), ('id', 'Bahasa Indonesia'), ('it', 'Italiano'),
    ('ja', '日本語'), ('ko', '한국어'), ('nb', 'Norsk'), ('nl', 'Nederlands'),
    ('pl', 'Polski'), ('pt-BR', 'Português'), ('ru', 'Русский'), ('sv', 'Svenska'),
    ('th', 'ไทย'), ('tr', 'Türkçe'), ('uk', 'Українська'), ('vi', 'Tiếng Việt'),
    ('zh-Hans', '简体中文'), ('zh-Hant', '繁體中文'),
]

def filename(code):
    return 'README.md' if code == 'en' else 'README.%s.md' % code

def nav(current):
    parts = []
    for code, name in NAMES:
        parts.append('**%s**' % name if code == current else '[%s](%s)' % (name, filename(code)))
    return ' · '.join(parts)

def apply():
    for code, _ in NAMES:
        path = os.path.join(ROOT, filename(code))
        if not os.path.exists(path):
            print('missing:', filename(code)); continue
        lines = io.open(path, encoding='utf-8').read().split('\n')
        # title, blank, [old nav, blank] ...
        head = [lines[0], '']
        rest = lines[1:]
        while rest and (rest[0].strip() == '' or ' · ' in rest[0] or rest[0].startswith('[English]')
                        or rest[0].startswith('**English**')):
            if rest[0].strip() == '' or ' · ' in rest[0]:
                rest.pop(0)
            else:
                break
        io.open(path, 'w', encoding='utf-8').write('\n'.join(head + [nav(code), ''] + rest))
    print('navigation written for %d files' % len(NAMES))

if __name__ == '__main__':
    apply()
