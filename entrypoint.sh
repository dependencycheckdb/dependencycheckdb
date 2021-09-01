./dependency-check/bin/dependency-check.sh --updateonly --connectionString jdbc:h2:/home/h2/db --dbUser sa --propertyfile dependency-check.properties

H2_PWD=`openssl rand -base64 32`

java -cp h2.jar:dependency-check-core.jar org.h2.tools.Shell -url jdbc:h2:/home/h2/db -user sa -password sa -sql "ALTER USER sa SET PASSWORD '${H2_PWD}';"

echo "data.password=${H2_PWD}" > dependency-check.properties

while true; do sleep 86400; date; ./dependency-check/bin/dependency-check.sh --updateonly --connectionString jdbc:h2:tcp://localhost/db --dbUser sa --propertyfile dependency-check.properties; done &

java -cp h2.jar org.h2.tools.Server -ifExists -tcp -tcpAllowOthers -baseDir /home/h2
