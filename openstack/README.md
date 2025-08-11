# cloud-practical

Skeleton project and files for cloud practicals.

## Configuration
1. Clone the repository
```bash
git clone https://gitea.master-oivm.fr/UPEC/Cloud_computing
```
2. Copy your __clouds.yaml__ and __lab.ovpn__ or modify provided sample files
3. Create a new virtual env to match project dependencies
```bash
# sudo needed to install the openvpn client
sudo ./setup-env.sh
# acivate the virtualenv
source .venv/bin/activate
```
4. Connect the OVPN client to access the lab
```bash
sudo openvpn lab.ovpn
```
5. Check
```bash
(.venv) openstack project list
```
