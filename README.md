# Perdrix Server
(c) 2025 Somanos Sar Licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**

See [LICENSE](LICENSE) for full terms.

# This module is the Server part of the project Perdrix, designed as a simple ERP

# Dependencies
This module is a Drumee plugin. It is intended to run withind a Drumee Server Runtime Environment. 

This module is designed to serve data to the [perdrix-ui module](https://github.com/somanos/perdrix-ui).


# Getting started

Install the server from [here](https://github.com/somanos/perdrix-server)

```console
git clone https://github.com/somanos/perdrix-server

```

## Prepare the Drumee OS environment


After installation, changes the file docker.yaml accordingly to your setup
```console
cd perdrix-server
vi docker.yaml

```

Pay attention to path provided as volumes mount points, you will need to provide the same to the perdrix-server setup

After changes completed, install the container
```console
sudo docker compose -f docker.yaml up -d

```

You can follow the installation progress with
```console
sudo docker logs --follow perdrix
```

Watch out the logs. If the installation went smoothly, you will see the link that provides admin password initialization. If you missed out the logs.


```console
sudo docker exec perdrix cat /data/tmp/welcome.html
```

Once the Drumee OS installed, go into the directory perdrix-server if ever you left it

```console
npm i 
```

The package is now available within the container at /mnt/devel

```console
sudo docker exec -it perdrix bash
cd /mnt/devel
npm run register-plugin
npm run initialize-database-with-data-deletion
```

Now your server environment is ready for dvelopement. From the project directory

```console
npm run dev
```

Your server in now running.

To see logs, open a new terminal and get into the container 
```console
sudo docker exec -it perdrix bash
```

```console
drumee log devel/service
```

Now, you can head to the UI projet to complete the setup.