# Git Repository Browser on Production

Assuming that the working copy is always on master (?) and last version

Never ever commit in this repository!

* Browse a working tree (no action)

* action=reset
  Reset local changes
    * clean index and working tree
        git reset --hard
    * Remove untracked or ignored local files and directories
        git clean -xdf

* action=update
  Pull from origin (first reset):
    git pull

* action=rollback&file=...
  Checkout previous version of a file
    git checkout HEAD^ -- file

* action=delete&file=...
* action=modify&file=... # modify or add new file (edit)

* action=rollback
  Checkout previous commit
    git checkout HEAD^      # detached state
    git reset --soft master # back to master

