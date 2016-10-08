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
cp Env/p_${ROLE}.yml Env/properties.yml

# Vagrant(pre)
echo "*********************************************"
echo "step03: launch target vms..."
echo "*********************************************"
cd Vagrant/${VM01}
vagrant up

# Itamae
echo "*********************************************"
echo "step04: deploying by itamae..."
echo "*********************************************"
cd ../..
Itamae/itamae_exec.sh

# Serverspec
echo "*********************************************"
echo "step05: test by serverspec..."
echo "*********************************************"
Serverspec/serverspec_exec.sh
RC_SS=$?

# Infrataster
echo "*********************************************"
echo "step06: test by infrataster..."
echo "*********************************************"
Infrataster/infrataster_exec.sh
RC_IT=$?

# Vagrant(post)
echo "*********************************************"
echo "step07: delete target vms..."
echo "*********************************************"
cd Vagrant/${VM01}
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

