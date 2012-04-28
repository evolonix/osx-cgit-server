#!/bin/bash
# Creates the Git user.

function die () {
#    echo >&2 "$@"
	echo >&2 "Usage: creategituser.sh password"
    exit 1
}

if [ "$#" -lt 1 ];
then
	die
fi

# Get a Group ID value to be used when creating the 'git' group
groupmaxid=$(dscl . -list /Groups PrimaryGroupID | awk '{print $2}' | sort -ug | tail -1)
groupnumber=$((groupmaxid+1))

#Create the Group 'git'
echo "Creating Group 'git' with group id = $groupnumber"
sudo dscl . -create /Groups/git PrimaryGroupID $groupnumber

# Get a user ID value to be used when creating the 'git' user
maxid=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
usernumber=$((maxid+1))
username=git
realname="Git"

echo "Creating a 'git' user with id = $usernumber"
dscl . -create /Users/$username
dscl . -create /Users/$username UserShell /bin/bash
dscl . -create /Users/$username RealName $realname
dscl . -create /Users/$username UniqueID $usernumber
dscl . -create /Users/$username NFSHomeDirectory /Users/$username
# Replace with a real password
dscl . -passwd /Users/$username $1
dscl . -create /Users/$username PrimaryGroupID $username

# Create the user's home directory plus the .ssh directory
mkdir -p /Users/$username/.ssh
chmod 0700 /Users/$username/.ssh
touch /Users/$username/.ssh/authorized_keys
chmod 700 /Users/$username/.ssh
chmod 600 /Users/$username/.ssh/authorized_keys

# create the .bashrc to add git to their path
echo "PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin" > /Users/$username/.bashrc
echo "GIT_INSTALL=/usr/local/git" >> /Users/$username/.bashrc
echo "MYSQL_INSTALL=/usr/local/mysql" >> /Users/$username/.bashrc
echo "IMAGEMAGICK_INSTALL=/usr/local/imagemagick" >> /Users/$username/.bashrc
echo "SPHINX_INSTALL=/usr/local/sphinx" >> /Users/$username/.bashrc
echo "PATH=$PATH:$GIT_INSTALL/bin" >> /Users/$username/.bashrc
echo "PATH=$PATH:$GITORIOUS_ROOT/script" >> /Users/$username/.bashrc
echo "PATH=$PATH:$MYSQL_INSTALL/bin" >> /Users/$username/.bashrc
echo "PATH=$PATH:$SPHINX_INSTALL/bin" >> /Users/$username/.bashrc
echo "PATH=$PATH:$IMAGEMAGICK_INSTALL/bin" >> /Users/$username/.bashrc

#Make sure the permissions are set correctly
chmod ug+rw /Users/$username/.bashrc

# Change ownership of the users directory to their username
chown -R $username:git /Users/$username

# We need to add the _www user as a member of the 'git' group
echo "Adding '_www' as a member of the 'git' group."
dscl . append /Groups/git GroupMembership _www

exit 0