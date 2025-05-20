#!/bin/zsh

# This script is used to build DocC documentation for the StoreHelper package in a static HTML format suitable for hosting on
# GitHub Pages at https://russell-archer.github.io/StoreHelper/documentation/storehelper/
#
# Run this script from the root of the StoreHelper project directory.
#
# We get GitHub to automatically create a static website from this package's DocC documentation by using GitHub Pages as follows:
#
# 1. Create our DocC documentation using a mixture of source code comments, articles, tutorials and guides.
#    See here for details: https://www.swift.org/documentation/docc/
#
# 2. Generate the static website using the Swift package manager. The package manager is included in Xcode.
#    You can verify your installation by typing swift package --version in a terminal
#
# 3. Open a terminal and navigate to the root of this package and run this script
#
# 4. Documentation will be output to the /docs directory in the root of this package. It's in a format suitable for hosting on GitHub Pages
#
# 5. If this is the first time you’ve generated documentation to the /docs folder, make sure to add /docs and all sub-directories to your git repo
#
# 6. Open this package's GitHub repo in a browser, then open Settings > Pages
#
# 7. Set the source of the website to be "Deploy from a branch" and then select the appropriate branch (e.g. main) and folder (/docs)
#
# 8. The above enables GitHub Pages and sets it to automatically update the published documentation website when source is pushed to the main branch.
#    This assumes that you'll be hosting your documentation website on github.io, and your GitHub Pages website URL will be in the form: {username}.github.io/{repository}
#
# 9. After a few minutes documentation should be available from: https://russell-archer.github.io/StoreHelper/documentation/storehelper/

echo "Build DocC documentation for the StoreHelper package."
echo "Press [Return] to continue or ^C to abort..."
read -n -s
swift package --allow-writing-to-directory docs generate-documentation --target StoreHelper --disable-indexing --transform-for-static-hosting --hosting-base-path StoreHelper --output-path docs
