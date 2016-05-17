# bashrc

*   Replace the current `.django_bash_completion.sh` file with a symlink to the customised version (required for bashrc).
```
# if symlink exists, delete it, if file exists, archive it.
if [[ -L ~/.django_bash_completion.sh ]]; then
    echo "deleting symlink"
    rm ~/.django_bash_completion.sh
elif [[ -f ~/.django_bash_completion.sh ]]; then
    echo "archiving file"
    mv ~/.django_bash_completion.sh ~/.django_bash_completion.sh.$(date +%Y%m%d_%H%M%S)
else
    echo ".django_bash_completion.sh does not exist."
fi

# recreate symlink
ln -s ~/bashrc/.django_bash_completion.sh ~/.django_bash_completion.sh
```

*   Replace the current `.bashrc` file with a symlink to the customised version.
```
# if symlink exists, delete it, if file exists, archive it.
if [[ -L ~/.bashrc ]]; then
    echo "deleting symlink"
    rm ~/.bashrc
elif [[ -f ~/.bashrc ]]; then
    echo "archiving file "
    mv ~/.bashrc ~/.bashrc.$(date +%Y%m%d_%H%M%S)
else
    echo ".bashrc does not exist."
fi

# recreate symlink
ln -s ~/bashrc/.bashrc ~/.bashrc

# activate new bashrc file
source ~/.bashrc
```