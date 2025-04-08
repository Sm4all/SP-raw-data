# README

This repository contains all the raw data for all tests ran in this project as well as a location for the tools and build frameworks to be stored.

## Framework

The framework built for the testing for this project is located at [tools/framework-script/framework.sh](https://github.com/Sm4all/SP-raw-data/blob/master/tools/framework-script/framework.sh)

## Tools

Tool used in this project are all located in the [tools](https://github.com/Sm4all/SP-raw-data/tree/master/tools) directory.

## Running

This repository also contains all the tools needed to run these containers. This can come in multiple forms such as a compose file or a script to run the container.

Some examples include:

```bash
$ docker compose -f containers/portainer/docker-compose.yml up -d
$ ./containers/Minecraft_Java_Server/command.sh
$ docker compose -f containers/website/docker-compose.yml up -d
$ docker compose -f containers/open-webui/docker-compose.yaml -f containers/open-webui/docker-compose.gpu.yaml -f containers/open-webui/docker-compose.api.yaml up -d --build
```

## Results

All the results for each container are separated into its own respective container directory. All results are in a results directory within this container directory.

This includes logs such as but not limited to:

- [Docker Bench for Security](https://github.com/Sm4all/SP-raw-data/blob/master/containers/Minecraft_Java_Server/results/DBfS_results.log)
- [Trivy](https://github.com/Sm4all/SP-raw-data/blob/master/containers/Minecraft_Java_Server/results/trivy_results.log)
- [LinPEAS](https://github.com/Sm4all/SP-raw-data/blob/master/containers/Minecraft_Java_Server/results/linpeas.log)
- [Wireshark PCAP files](https://github.com/Sm4all/SP-raw-data/blob/master/containers/Minecraft_Java_Server/results/tcpdump_capture.pcap)
- [Proc Path Checks](https://github.com/Sm4all/SP-raw-data/blob/master/containers/Minecraft_Java_Server/results/proc_mountable.log)
- [Whoami Checks](https://github.com/Sm4all/SP-raw-data/blob/master/containers/Minecraft_Java_Server/results/whoami.log)

For example:

```bash
- Pi-hole Results are located at: [containers/pihole/results](https://github.com/Sm4all/SP-raw-data/tree/master/containers/pihole/results)
- Minecraft Java Server Results are located at: [containers/Minecraft_Java_Server/results](https://github.com/Sm4all/SP-raw-data/tree/master/containers/Minecraft_Java_Server/results)
- Traefik Results are located at: [containers/traefik_proxy/results](https://github.com/Sm4all/SP-raw-data/tree/master/containers/traefik_proxy/results)
```

All results are fairly self-explanatory, and the implications and interpretations of these results are explained in this report.

## Testing.html

- If more information is needed about the results, please view the document [Testing.html](https://github.com/Sm4all/SP-raw-data/blob/master/Testing.html) to view more information and a table of results.
- This document was originally written in notion and exported as a HTML file rather than a Markdown file due to the size of tables included.
- This document contains the rough notes while results were being gathered..