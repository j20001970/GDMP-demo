#!/usr/bin/python
import os
import subprocess
import sys
from shutil import copyfile, move

mediapipe_rel = "GDMP/mediapipe/mediapipe"
custom_path = "mediapipe"

def custom_setup(path):
    """
    Copy custom mediapipe files such as graphs and modules to mediapipe workspace.
    Custom directores that already exist will not created.
    If file to copy already exists, original file will be renamed with .original extension.
    """
    for root, dirs, files in os.walk(path):
        try:
            custom_rel = os.path.relpath(root, path)
            for dir in dirs:
                if not os.path.exists(os.path.join(mediapipe_rel, custom_rel, dir)):
                    os.makedirs(os.path.join(mediapipe_rel, custom_rel, dir))
                    print("created %s" % os.path.join(mediapipe_rel, custom_rel, dir))
            for file in files:
                if os.path.exists(os.path.join(mediapipe_rel, custom_rel, file)):
                    move(os.path.join(mediapipe_rel, custom_rel, file), os.path.join(mediapipe_rel, custom_rel, file)+".original")
                copyfile(os.path.join(root, file), os.path.join(mediapipe_rel, custom_rel, file))
                print("created %s" % os.path.join(mediapipe_rel, custom_rel, file))
        except Exception as e:
            print(e)
            continue

def custom_cleanup(path):
    """
    Remove custom mediapipe files from mediapipe workspace.
    Only files that exist in custom path will be removed, will also rename .original file back if exist.
    Only empty directory will be removed.
    """
    for root, dirs, files in reversed(list(os.walk(path))):
        try:
            custom_rel = os.path.relpath(root, path)
            for file in files:
                if os.path.exists(os.path.join(mediapipe_rel, custom_rel, file)):
                    os.remove(os.path.join(mediapipe_rel, custom_rel, file))
                    print("removed %s" % os.path.join(mediapipe_rel, custom_rel, file))
                if os.path.exists(os.path.join(mediapipe_rel, custom_rel, file)+".original"):
                    move(os.path.join(mediapipe_rel, custom_rel, file)+".original", os.path.join(mediapipe_rel, custom_rel, file))
            for dir in dirs:
                if not os.listdir(os.path.join(mediapipe_rel, custom_rel, dir)):
                    os.rmdir(os.path.join(mediapipe_rel, custom_rel, dir))
                    print("removed %s" % os.path.join(mediapipe_rel, custom_rel, dir))
        except Exception as e:
            print(e)
            continue

# copy custom files
if custom_path:
    os.chdir(os.path.dirname(__file__))
    print("Custom files: copying...")
    custom_setup(custom_path)

try:
    subprocess.run(["GDMP/build.py"] + sys.argv[1:])
except BaseException as e:
    print(e)

if custom_path:
    os.chdir(os.path.dirname(__file__))
    print("Custom files: cleaning up...")
    custom_cleanup(custom_path)
