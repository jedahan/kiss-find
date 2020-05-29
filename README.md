(if you are looking for kiss-find itself [go here])

[go here]: https://github.com/Admicos/kiss-repo/tree/master/custom/kiss-find

# The kiss-find Database Tools

This repository contains the tools used to create the kiss-find database, and
the list of KISS repositories crawled through.

If you just want to download the complete database used in kiss-find, that is 
available at: `https://files.ecmelberk.com/kiss-find.gz`, and is updated daily.

## Add Your Repository

Send a pull request against the `repo_list` file, with your repository Git
clone URL in the proper sorted position.

Please note that the scripts are not tested with anything other than the 
GitHub-like `https://example.com/user/repo` URL format. If your repository URL
doesn't adhere to that format, let me know and I'll try to make it work.

## Database Creation

Download `git`, `python3` and `jq` and run `./build.sh`
