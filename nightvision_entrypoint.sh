apt-get update && apt-get install -y python3-pip
wget -c https://downloads.nightvision.net/binaries/latest/nightvision_latest_linux_amd64.tar.gz -O - | tar -xz
mv nightvision /usr/local/bin/ 
python3 -m pip install semgrep --user


nightvision swagger extract ./ -t $NIGHTVISION_TARGET --lang spring || true

if [ ! -e openapi-spec.yml ]; then
    cp backup-openapi-spec.yml openapi-spec.yml
fi

nightvision scan -t $NIGHTVISION_TARGET -a $NIGHTVISION_APP --auth $NIGHTVISION_AUTH > scan-results.txt
nightvision export sarif -s "$(head -n 1 scan-results.txt)" --swagger-file openapi-spec.yml

git clone https://github.com/jxbt/nightvision_reporter.git
cd nightvision_reporter
apt-get update
apt-get install -y python3-pip python3-venv google-chrome-stable
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt  

cd nightvision_reporter
source .venv/bin/activate
python3 main.py --sarif ../results.sarif --out nightvision-report.pdf
