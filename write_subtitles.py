import os

OVERRIDE_NAME = "vinny_christmas"
LANGUAGES = {"english"}

addon_name = OVERRIDE_NAME
bytes = ""
lua_format = """return
{{
    mod = "{0}";
    languages =
    {{
{1}
    }}
}}"""

content_path = os.path.dirname(os.path.realpath(__file__))
if not addon_name or addon_name == "":
    addon_name = os.path.basename(content_path)
game_path = os.path.dirname(f"../../../game/hlvr_addons/{addon_name}/")

subtitles_path = os.path.join(content_path, "resource/subtitles")
lua_path = os.path.join(game_path, "scripts/vscripts/subtitles")

print(f"addon_name: {addon_name}")
print(f"content_path: {content_path}")
print(f"game_path: {game_path}")
print(f"subtitles_path: {subtitles_path}")
print(f"lua_path: {lua_path}")

for language in LANGUAGES:
    file = os.path.join(subtitles_path, language + ".dat")
    print(f"Looking for {file}")
    if os.path.exists(file):
        with open(file, "rb") as f:
            print(f"Reading {language} bytes...")
            b = [str(x) for x in f.read()]
            # print(b)
            bytes += f"\t\t{language} = {{{','.join(b)}}},\n"

data_file = os.path.join(lua_path, "data.lua")
print(f"Writing {data_file}")
with open(data_file, "w") as f:
    f.write(lua_format.format(addon_name, bytes))

print("DONE")
input()
