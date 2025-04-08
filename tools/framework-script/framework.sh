#!/bin/bash

#CONTAINER_NAME=$(docker ps --format "{{.Names}}")
CONTAINER_NAME="$1"
CONTAINER_NETWORK=$(docker ps --format "{{.Networks}}" | head -1)
IMAGE_NAME=$(docker ps --format "{{.Image}}" | head -1)
BRIDGE_ID=$(docker network inspect -f '{{.Id}}' $CONTAINER_NETWORK | cut -c 1-12)
BRIDGE_INTERFACE="br-$BRIDGE_ID"

echo "Container name: $CONTAINER_NAME"
echo "Container network: $CONTAINER_NETWORK"
echo "Bridge interface: $BRIDGE_INTERFACE"

cd ~/docker-research/containers/"$CONTAINER_NAME" || { echo "Failed to change directory. Exiting..."; exit 1; } > /dev/null 2>&1
mkdir results && cd results > /dev/null 2>&1

echo "Running trivy scan"
trivy image --security-checks vuln,misconfig $IMAGE_NAME > trivy_results.log 2>&1


echo Running docker bench for security

docker compose -f ~/docker-research/tools/docker-bench-security/docker-compose.yml run --rm docker-bench-security > DBfS_results.log 2>&1
docker compose -f ~/docker-research/tools/docker-bench-security/docker-compose.yml down

echo Linpeas checks
docker cp ~/docker-research/tools/linpeas/linpeas_fat.sh "$CONTAINER_NAME":/tmp/linpeas_fat.sh
docker exec "$CONTAINER_NAME" /tmp/linpeas_fat.sh > linpeas.log 2>&1

echo "WHOAMI check"
docker exec "$CONTAINER_NAME" whoami > whoami.log 2>&1

echo Capability Check
docker inspect --format='{{.HostConfig.CapAdd}}' "$CONTAINER_NAME" > cap_check.log 2>&1

echo Host Mounts
docker inspect --format='{{json .Mounts}}' "$CONTAINER_NAME" > host_mount.log 2>&1

echo Host File Access
docker exec "$CONTAINER_NAME" ls -lah /var/run/docker.sock > host_access.log 2>&1

echo "RunC Exploitable (CVE-2019-5736)"
docker exec -it "$CONTAINER_NAME" bash -c "echo '#!/bin/bash' > /bin/bash; echo 'echo Pwned > /tmp/pwned' >> /bin/bash; chmod +x /bin/bash"
docker restart "$CONTAINER_NAME"
if [ -n "$(ls -A /tmp/pwned 2>/dev/null)" ]; then
    echo "RunC exploitable YES" > runc_exploit.log
else
    echo "RunC exploitatble NO" > runc_exploit.log
fi

echo Privilaged Mode
docker inspect --format='{{.HostConfig.Privileged}}' "$CONTAINER_NAME" > priv_mode.log 2>&1

echo Proc mountable
docker exec "$CONTAINER_NAME" cat /proc/self/mountinfo > proc_mountable.log 2>&1

echo Check open ports
nmap -p- $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME") > nmap.log 2>&1

echo Starting tcpdump for 5 mins to capture normal packet behaviour
sudo tcpdump -i "$BRIDGE_INTERFACE" -w tcpdump_capture.pcap &
TCPDUMP_PID=$!

sleep 300

echo Stopping tcpdump
sudo kill "$TCPDUMP_PID"

# Wait for tcpdump to fully terminate
wait "$TCPDUMP_PID"
echo "tcpdump stopped. Capture saved to $TCPDUMP_OUTPUT"