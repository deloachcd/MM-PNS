#!/bin/sh

cp templates/PNASfile config/PNASfile
chmod 600 config/PNASfile
echo "Created empty config from template, you can edit it with:"
echo "<your_favorite_editor> config/PNASfile"
