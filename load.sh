# Replace the current `.bashrc` file with a symlink to the customised version.

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

echo "recreating symlink"
ln -s ~/git/bashrc/.bashrc ~/.bashrc

echo "To activate, run:"
echo "source ~/.bashrc"