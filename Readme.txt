Use RMagick to composite / blend a folder of images together. Defaults to the Lighten operation which is useful for pics of fireworks

brew install ImageMagick
gem install rmagick

defaults to files in ./source and put composite image in ./result

Current options

Usage: ruby blend.rb [options]

    -i, --index FILE                 start at INDEX index
    -s, --start FILE                 start at FILE file name
    -f, --folder FOLDER              source files are in FOLDER name
    -o, --out FOLDER                 composite file in FOLDER name
    -n, --limit NUM                  limit to the first NUM files
    -m, --skip NUM                   Only process every NUM files (skip the rest)
    -x, --fx EFFECT                  composite EFFECT lighten, darken, multiply

    -h, --help                       Show this help message.

