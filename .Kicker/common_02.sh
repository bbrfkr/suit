source ~/.bash_profile

# Parameter set
echo "*********************************************"
echo "step01: delete the last parameters..."
echo "*********************************************"
rm -f Env/inventory.yml
rm -f Env/properties.yml

echo "*********************************************"
echo "step02: create inventory and properties..."
echo "*********************************************"
cp Env/i_${ROLE}.yml Env/inventory.yml
if [ -e Env/p_${ROLE}.yml ] ; then
  cp Env/p_${ROLE}.yml Env/properties.yml
fi

# Vagrant(pre)
echo "*********************************************"
echo "step03: launch target vms..."
echo "*********************************************"
cd .Vagrant/${VM01}
vagrant up
cd ../${VM02}
vagrant up

# Itamae
echo "*********************************************"
echo "step04: deploying by itamae..."
echo "*********************************************"
cd ../..
Bin/suit itamae exec

echo "wait server status is fixed..."
sleep 30s

# Serverspec
echo "*********************************************"
echo "step05: test by serverspec..."
echo "*********************************************"
Bin/suit serverspec exec
RC_SS=$?

# Infrataster
echo "*********************************************"
echo "step06: test by infrataster..."
echo "*********************************************"
Bin/suit infrataster exec
RC_IT=$?

# Vagrant(post)
echo "*********************************************"
echo "step07: delete target vms..."
echo "*********************************************"
cd .Vagrant/${VM01}
vagrant destroy -f
cd ../${VM02}
vagrant destroy -f

# represent exit status
echo "*********************************************"
echo "serverspec exit status: ${RC_SS}"
echo "infrataster exit status: ${RC_IT}"
echo "*********************************************"

if [ $(( $RC_SS + $RC_IT )) -eq 0 ]; then
  exit 0
else
  exit 1
fi

