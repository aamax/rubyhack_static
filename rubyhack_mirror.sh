#!/bin/bash

# Mirror the existing site using `wget`. Arguments:
#
#   --mirror
#     Create a mirror of the URL given. Equivalent to "-r -N -l inf --no-remove-listing".
#
#   --convert-links
#     After the download is complete, convert the links in the document to
#     make them suitable for local viewing. This affects not only the visible hyperlinks,
#     but any part of the document that links to external content, such as embedded
#     images, links to style sheets, hyperlinks to non-HTML content, etc.
#
#   --page-requisites
#     This option causes Wget to download all the files that are necessary
#     to properly display a given HTML page. This includes such things as inlined images,
#     sounds, and referenced stylesheets.
#
#   --adjust-extension
#     If a file of type application/xhtml+xml or text/html is downloaded
#     and the URL does not end with the regexp \.[Hh][Tt][Mm][Ll]?, this option will cause
#     the suffix .html to be appended to the local filename.
#
#   --span-hosts
#     Normally, --mirror will not leave the domain specified on the command
#     line. This argument is to let wget get files from other domains (e.g. AWS S3) while
#     performing the mirrror.
#   --domains
#     Used with the `--span-hosts` option. Specifies the domains that --span-hosts is allowed to
#     access. We don't want to spider the whole web, only get our S3 images, so we specify
#     only the two domains we want to access here.

wget --mirror \
     --convert-links \
     --page-requisites \
     --adjust-extension \
     --span-hosts \
     --domains rubyhack.s3.us-west-1.amazonaws.com,rubyhack.com \
     https://rubyhack.com

# AWS S3 static sites also need us to have an error page. Get some random page on rubyhack.com and
# save it as "error.html" so we can upload it for our error page.
wget --output-file rubyhack.com/error.html rubyhack.com/nothing.html

# When using --span-hosts, `wget` will make a separate directory for every domain it is accesses.
# This means the images we had on S3 will be saved in a separate directory from the HTML of
# rubyhack site.
#
# Here we create an `images` directory in the main rubyhack.com directoryand move the images in
# to that new dir .
mkdir rubyhack.com/images
mv rubyhack.s3.us-west-1.amazonaws.com/variants rubyhack.com/images

# Go through all the HTML pages and rewrite any links/images that point to AWS S3 and rewrite then
# so they point to the local copies of the files (now in images/variants from previous command).
# Changes "../../rubyhack.s3.us-west-1.amazonaws.com/variants/" prefix of filenames to our local
# directory path off the root at "../images/variants/"
find rubyhack.com -name '*.html' -exec sed -i '' -E 's/\.\.\/\.\.\/rubyhack\.s3\.us-west-1\.amazonaws\.com\/variants\/\.\./images\/variants\//g' {} \;

# The process should be done now, the *contents* of the rubyhack.com directory can now be uploaded
# to S3.
echo "Done."
echo "You can now upload the *contents* of the rubyhack.com directory to the S3 bucket."
echo "Remember to set the S3 permissions to \"public read-only\" when uploading."