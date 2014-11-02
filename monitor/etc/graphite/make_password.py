
# 
# Convenience script to hash a raw password for use in a django fixture
#

import os
import sys
import django.contrib.auth.hashers as h

if len(sys.argv) != 3:
    sys.stderr.write("usage: make_password.py input_file raw_password\n")
    sys.exit(1)

input_file = sys.argv[1]
raw_password = sys.argv[2]

if not os.path.exists(input_file):
    sys.stderr.write("Unable to find input_file\n")
    sys.exit(1)


password_hash = h.make_password(raw_password)
sys.stderr.write("Password: %s  Hash: %s" % (raw_password, password_hash))

with open(input_file, "r") as f:
    contents = f.read()

with open(input_file, "w") as f:
    f.write(contents.replace("%PASSWORD_HASH%", password_hash))

