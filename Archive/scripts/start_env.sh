#/bin/bash
cd ~/user/mids-w210-capstone/docker_clusters  
docker-compose up -d
docker ps -a
docker-compose exec anaconda jupyter notebook --notebook-dir=/user --ip='*' --port=8888 --no-browser --allow-root
cd ~/user/mids-w210-capstone/scripts

